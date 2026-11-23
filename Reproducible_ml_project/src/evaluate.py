"""Select by validation RMSE and evaluate the winner on the held-out split."""

import joblib
import matplotlib
import mlflow
import numpy as np
import pandas as pd
from threadpoolctl import threadpool_limits

from src.common import (
    DATASET_PAGE, MODELS, PROCESSED, REPORTS, TARGET, TRACKING_URI,
    read_json, read_split, regression_metrics, write_json,
)

matplotlib.use("Agg")
from matplotlib import pyplot as plt
from matplotlib.ticker import FuncFormatter


def plot_predictions(actual, predicted):
    lower = min(actual.min(), predicted.min())
    upper = max(actual.max(), predicted.max())
    fig, ax = plt.subplots(figsize=(7, 5.5), layout="constrained")
    ax.scatter(actual, predicted, s=15, color="#16786b", alpha=0.55, edgecolors="none")
    ax.plot([lower, upper], [lower, upper], color="#334155", linestyle="--", label="Perfect prediction")
    if lower > 0:
        ax.set(xscale="log", yscale="log")
        scale_label = "log scale"
    else:
        ax.set_xscale("symlog", linthresh=50_000)
        ax.set_yscale("symlog", linthresh=50_000)
        scale_label = "symmetric log scale"
    ax.set(
        xlabel=f"Actual sale price (USD, {scale_label})",
        ylabel=f"Predicted sale price (USD, {scale_label})",
        title="Held-out sales: actual vs. predicted",
    )
    for axis in (ax.xaxis, ax.yaxis):
        axis.set_major_formatter(FuncFormatter(lambda price, _: f"${price:,.0f}"))
    ax.grid(alpha=0.2)
    ax.legend(loc="upper left")
    fig.savefig(REPORTS / "actual_vs_predicted.png", dpi=150)
    plt.close(fig)


def main():
    schema = read_json(PROCESSED / "manifest.json")
    trials = read_json(MODELS / "run_manifest.json")["trials"]
    winner = min(trials, key=lambda name: (trials[name]["validation"]["rmse"], name))
    estimator = joblib.load(MODELS / f"{winner}.joblib")
    test_x, test_y = read_split("test", schema)
    actual = test_y.to_numpy()
    predicted = estimator.predict(test_x)
    metrics = regression_metrics(actual, predicted)

    write_json(REPORTS / "metrics.json", {
        "selected_model": winner,
        "selection_metric": "validation_rmse",
        "validation": {name: trial["validation"] for name, trial in trials.items()},
        "test": metrics,
        "test_rows": actual.size,
        "raw_sha256": schema["raw_sha256"],
        "test_split_sha256": schema["splits"]["test"]["sha256"],
    })
    pd.DataFrame({
        "actual_price": actual, "predicted_price": predicted, "residual": np.subtract(actual, predicted),
    }).to_csv(REPORTS / "predictions.csv", index=False, lineterminator="\n")
    plot_predictions(actual, predicted)

    mlflow.set_tracking_uri(TRACKING_URI)
    with mlflow.start_run(run_id=trials[winner]["run_id"]):
        dataset = mlflow.data.from_pandas(
            pd.concat([test_x, test_y], axis=1), source=DATASET_PAGE, targets=TARGET,
            name="kaggle-housedata-test", digest=schema["splits"]["test"]["sha256"][:16],
        )
        mlflow.log_input(dataset, context="test")
        mlflow.set_tag("selected_by", "validation_rmse")
        mlflow.log_metrics({f"test_{metric}": value for metric, value in metrics.items()})
        for name in ("metrics.json", "predictions.csv", "actual_vs_predicted.png"):
            mlflow.log_artifact(str(REPORTS / name), artifact_path="evaluation")
    print(f"Selected {winner} by validation RMSE. Held-out test metrics:")
    print(", ".join(f"{metric.upper()}={value:,.4f}" for metric, value in metrics.items()))


if __name__ == "__main__":
    with threadpool_limits(limits=1):
        main()
