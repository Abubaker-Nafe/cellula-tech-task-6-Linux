"""Fit each configured regressor and record its validation run in MLflow."""

from importlib.metadata import version

import joblib
import mlflow
import mlflow.sklearn
import pandas as pd
from mlflow.models import infer_signature
from sklearn.compose import ColumnTransformer
from sklearn.dummy import DummyRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.impute import SimpleImputer
from sklearn.linear_model import Ridge
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from threadpoolctl import threadpool_limits

from src.common import (
    CONFIG, DATASET_PAGE, MODELS, PROCESSED, REPORTS, REQUIREMENTS, TARGET, TRACKING_URI,
    read_config, read_json, read_split, regression_metrics, sha256, write_json,
)


def build_pipeline(schema, estimator):
    numeric = Pipeline([
        ("impute", SimpleImputer(strategy="median", keep_empty_features=True)),
        ("scale", StandardScaler()),
    ])
    categorical = Pipeline([
        ("impute", SimpleImputer(strategy="constant", fill_value="Unknown")),
        ("encode", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
    ])
    preprocess = ColumnTransformer([
        ("numeric", numeric, schema["numeric_features"]),
        ("categorical", categorical, schema["categorical_features"]),
    ])
    return Pipeline([("preprocess", preprocess), ("regressor", estimator)])


def main():
    config = read_config()
    settings = config["train"]
    schema = read_json(PROCESSED / "manifest.json")
    train_x, train_y = read_split("train", schema)
    validation_x, validation_y = read_split("validation", schema)
    seed = config["prepare"]["seed"]

    mlflow.set_tracking_uri(TRACKING_URI)
    experiment = mlflow.set_experiment(settings["experiment_name"])
    model_dependencies = [
        f"{name}=={version(name)}"
        for name in ("mlflow", "numpy", "pandas", "scipy", "scikit-learn", "skops", "joblib", "threadpoolctl")
    ]
    datasets = {}
    for name, x, y in (("train", train_x, train_y), ("validation", validation_x, validation_y)):
        datasets[name] = mlflow.data.from_pandas(
            pd.concat([x, y], axis=1), source=DATASET_PAGE, targets=TARGET,
            name=f"kaggle-housedata-{name}", digest=schema["splits"][name]["sha256"][:16],
        )

    MODELS.mkdir(parents=True, exist_ok=True)
    estimators = {"dummy": DummyRegressor, "ridge": Ridge, "random_forest": RandomForestRegressor}
    trials = {}
    for name, spec in settings["models"].items():
        parameters = dict(spec["parameters"])
        trusted_types = ["numpy.dtype"]
        if spec["type"] == "random_forest":
            parameters.update(random_state=seed, n_jobs=1)
            trusted_types.append("sklearn.tree._tree.Tree")
        estimator = estimators[spec["type"]](**parameters)
        pipeline = build_pipeline(schema, estimator)

        with mlflow.start_run(run_name=name, tags={
            "raw_data_sha256": schema["raw_sha256"],
            "config_sha256": sha256(CONFIG),
            "validation_data_sha256": schema["splits"]["validation"]["sha256"],
        }) as run:
            mlflow.log_params({
                "estimator": spec["type"],
                "input_features": train_x.shape[1],
                "train_rows": len(train_x),
                "validation_rows": len(validation_x),
                **config["prepare"],
                **estimator.get_params(deep=False),
            })
            mlflow.log_input(datasets["train"], context="training")
            mlflow.log_input(datasets["validation"], context="validation")
            pipeline.fit(train_x, train_y)
            predicted = pipeline.predict(validation_x)
            metrics = regression_metrics(validation_y, predicted)
            mlflow.log_metrics({f"validation_{metric}": value for metric, value in metrics.items()})
            for path in (CONFIG, REQUIREMENTS, REPORTS / "data_profile.json", REPORTS / "price_distribution.png"):
                mlflow.log_artifact(str(path), artifact_path="training")
            mlflow.log_dict(metrics, "training/validation_metrics.json")

            example = train_x.head(3)
            model_info = mlflow.sklearn.log_model(
                sk_model=pipeline, name="model", input_example=example,
                signature=infer_signature(example, pipeline.predict(example)),
                serialization_format=mlflow.sklearn.SERIALIZATION_FORMAT_SKOPS,
                skops_trusted_types=trusted_types,
                pip_requirements=model_dependencies,
            )
            joblib.dump(pipeline, MODELS / f"{name}.joblib", compress=3)
            trials[name] = {"run_id": run.info.run_id, "model_uri": model_info.model_uri, "validation": metrics}
            print(f"{name}: validation RMSE={metrics['rmse']:,.2f}, MLflow run {run.info.run_id}", flush=True)

    write_json(MODELS / "run_manifest.json", {"experiment_id": experiment.experiment_id, "trials": trials})


if __name__ == "__main__":
    with threadpool_limits(limits=1):
        main()
