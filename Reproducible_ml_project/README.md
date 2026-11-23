# Reproducible house-price experiment

The DVC pipeline takes the assigned Kaggle `data.csv` through data profiling, preparation, training and held-out evaluation. Scikit-learn fits a median baseline, Ridge and two Random Forest configurations. MLflow records a separate run for each fit. [Kaggle House Price Prediction dataset](https://www.kaggle.com/datasets/shree1992/housedata)

## Run the project

Use CPython 3.14 on Linux and Git. Run these commands from `Reproducible_ml_project/` after cloning the enclosing repository. The completed local workspace already has an environment and generated outputs.

```bash
python3.14 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python main.py fetch
python main.py run
```

The dependency file pins the direct and transitive package versions. `fetch` downloads Kaggle dataset version 2, extracts `data.csv` and verifies SHA-256 before writing it. If you downloaded the ZIP through Kaggle, use `python main.py fetch --archive /path/to/housedata.zip`. The raw CSV is tracked by DVC. [Dataset pointer](data/raw/data.csv.dvc)

```bash
dvc dag
dvc status
python main.py run --force
```

Use `--force` to fit every model again and create fresh MLflow runs. An unchanged `dvc repro` reuses the current outputs. The SQLite database and model artifacts live in `mlflow.db` and `mlruns/` on this machine. Run the tracking server in a second terminal.

```bash
python main.py ui
```

Open `http://127.0.0.1:5000` and select **Cellula House Prices**. Select one run for each of the four model names, choose **Compare**, and inspect `validation_rmse`. In the Ridge run, look at the `test_*` metrics and **Artifacts**. The model package includes the fitted preprocessing steps, a model signature and an example input. [Verified MLflow runs](reports/demo/mlflow_runs.txt)

## Data and evaluation

The CSV has 4,600 rows and 18 columns. Preparation removed 49 rows with nonpositive prices, leaving 4,551 usable sales. A fixed seed of 42 assigns 3,183 rows to training, 684 to validation and 684 to testing. A property group uses normalized street and city, so repeated sales of the same home stay together. Features include property measurements, building and renovation years, city and ZIP code. Street addresses are used only for grouping. The pipeline fits imputation, scaling and one-hot encoding on the training split. [Data profile](reports/demo/data_profile.json) · [Price distribution](reports/demo/price_distribution.png)

| Model | Validation MAE | Validation RMSE | Validation R² |
| --- | ---: | ---: | ---: |
| Ridge, alpha 10 | $105,264.03 | **$210,003.61** | 0.7411 |
| Random Forest, depth 18 | $115,034.74 | $231,019.99 | 0.6867 |
| Random Forest, depth 10 | $130,545.50 | $251,070.61 | 0.6300 |
| Median baseline | $229,899.88 | $424,655.45 | −0.0586 |

Ridge had the lowest validation RMSE. The evaluation stage measured the selected model on the separate test split.

| Held-out metric | Ridge |
| --- | ---: |
| Mean absolute error (USD) | 116,441.64 |
| Mean squared error (USD²) | 42,333,997,920.45 |
| Root mean squared error (USD) | 205,752.27 |
| R² | 0.6902 |

The test MAE is the average absolute error in dollars. The test RMSE gives larger misses more weight. The price distribution has a long upper tail, with a maximum positive sale price of $26.59 million. A forced full rerun produced byte-identical metrics and predictions on the pinned environment. [Metrics](reports/demo/metrics.json) · [Actual vs. predicted](reports/demo/actual_vs_predicted.png) · [Rerun evidence](reports/demo/reproducibility.txt)

## Reproduce and restore DVC versions

DVC locks the raw data, stage dependencies and output hashes in `dvc.lock`. The `.dvc/config` default remote is the project-local `.dvc-storage/` directory. `dvc push` copies raw data and outputs to that local store. A fresh clone can get the exact raw version from Kaggle with `python main.py fetch`, or from a configured shared DVC remote with `dvc pull`.

The completed workspace has both prepared datasets in the local store. Restore the alternate dataset without switching branches using `dvc pull data/versions/v2_without_zip.dvc`. Its splits and manifest appear under `data/versions/v2_without_zip/`. [Version 2 DVC pointer](data/versions/v2_without_zip.dvc)

From a Git commit containing the baseline pipeline, run the following to create and restore two preprocessing versions. The variant omits ZIP code and retains the original raw data, grouping and seed.

```bash
baseline=$(git rev-parse HEAD)
dvc push data/raw/data.csv.dvc prepare
git switch -c preprocessing-v2
sed -i 's/^  include_zip_code: true$/  include_zip_code: false/' config/params.yaml
dvc repro prepare
dvc push data/raw/data.csv.dvc prepare
git add config/params.yaml dvc.lock
git commit -m "Prepare housing data without ZIP codes"
sha256sum data/processed/train.csv

git switch --detach "$baseline"
dvc pull data/raw/data.csv.dvc prepare
sha256sum data/processed/train.csv
```

The version check pulled both versions into a fresh checkout from a local DVC store. The restored baseline training split matched the delivered split byte for byte. [Version restoration evidence](reports/demo/data_versions.txt)

## Project files

| Path | Purpose |
| --- | --- |
| `main.py` | Dataset download, DVC runner and tracking server |
| `config/params.yaml` | Seeds, split sizes, preprocessing switches and hyperparameters |
| `data/raw/` and `data/processed/` | Kaggle input and generated train, validation and test splits |
| `src/data_preprocessing.py`, `src/train.py`, `src/evaluate.py` | DVC stages |
| `dvc.yaml` and `dvc.lock` | Pipeline definition and content hashes |
| `models/` | Fitted pipelines and MLflow run references |
| `reports/` | Data profile, metrics, predictions, plots and demo evidence |

The official references cover the DVC pipeline and versioning workflow and the MLflow tracking server. [DVC reproduction](https://doc.dvc.org/command-reference/repro) · [DVC checkout](https://doc.dvc.org/command-reference/checkout) · [MLflow tracking](https://mlflow.org/docs/latest/tracking/)
