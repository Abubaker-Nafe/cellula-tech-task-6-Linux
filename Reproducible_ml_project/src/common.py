"""Shared project paths, configuration and training data helpers."""

import hashlib
import json
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "config" / "params.yaml"
REQUIREMENTS = ROOT / "requirements.txt"
RAW_DATA = ROOT / "data" / "raw" / "data.csv"
PROCESSED = ROOT / "data" / "processed"
MODELS = ROOT / "models"
REPORTS = ROOT / "reports"
TRACKING_DB = ROOT / "mlflow.db"
TRACKING_URI = f"sqlite:///{TRACKING_DB.as_posix()}"
DATASET_PAGE = "https://www.kaggle.com/datasets/shree1992/housedata"
DATASET_DOWNLOAD = (
    "https://www.kaggle.com/api/v1/datasets/download/shree1992/housedata"
    "?datasetVersionNumber=2"
)
DATASET_SHA256 = "6ee4b80d887b92bafed19d11e59614d60b78b9cfc1aed7ad5c37e8cd5f20fa1f"
TARGET = "price"


def read_config():
    with CONFIG.open(encoding="utf-8") as stream:
        return yaml.safe_load(stream)


def read_json(path):
    with path.open(encoding="utf-8") as stream:
        return json.load(stream)


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as stream:
        json.dump(data, stream, indent=2, sort_keys=True, allow_nan=False)
        stream.write("\n")


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def read_split(name, schema):
    import pandas as pd

    numeric = [*schema["numeric_features"], TARGET]
    dtypes = dict.fromkeys(numeric, "float64")
    dtypes.update(dict.fromkeys(schema["categorical_features"], "object"))
    data = pd.read_csv(PROCESSED / f"{name}.csv", dtype=dtypes, float_precision="round_trip")
    return data.drop(columns=TARGET), data[TARGET]


def regression_metrics(actual, predicted):
    from math import sqrt

    from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

    mse = float(mean_squared_error(actual, predicted))
    return {
        "mae": float(mean_absolute_error(actual, predicted)),
        "mse": mse,
        "rmse": sqrt(mse),
        "r2": float(r2_score(actual, predicted)),
    }
