"""Profile the raw data and build deterministic property-level splits."""

import matplotlib
import numpy as np
import pandas as pd
from sklearn.model_selection import GroupShuffleSplit

from src.common import PROCESSED, RAW_DATA, REPORTS, TARGET, read_config, sha256, write_json

matplotlib.use("Agg")
from matplotlib import pyplot as plt
from matplotlib.ticker import FuncFormatter

NUMERIC_FEATURES = [
    "bedrooms", "bathrooms", "sqft_living", "sqft_lot", "floors", "waterfront", "view",
    "condition", "sqft_above", "sqft_basement", "yr_built", "yr_renovated",
]


def plot_distribution(prices):
    fig, ax = plt.subplots(figsize=(8, 4.3), layout="constrained")
    ax.hist(prices, bins=np.geomspace(prices.min(), max(prices.max(), prices.min() * 1.01), 36), color="#16786b")
    ax.set(xscale="log", xlabel="Sale price (USD, log scale)", ylabel="Sales", title="Distribution of positive sale prices")
    ax.xaxis.set_major_formatter(FuncFormatter(lambda price, _: f"${price:,.0f}"))
    ax.grid(axis="y", alpha=0.22)
    fig.savefig(REPORTS / "price_distribution.png", dpi=150)
    plt.close(fig)


def split_by_property(data, groups, settings):
    seed = settings["seed"]
    test_fraction = settings["test_fraction"]
    validation_fraction = settings["validation_fraction"]
    if not (test_fraction > 0 and validation_fraction > 0 and test_fraction + validation_fraction < 1):
        raise ValueError("The validation and test fractions must be positive and add up to less than one.")

    development, test = next(GroupShuffleSplit(n_splits=1, test_size=test_fraction, random_state=seed)
                             .split(data, groups=groups))
    validation_share = validation_fraction / (1 - test_fraction)
    train, validation = next(GroupShuffleSplit(n_splits=1, test_size=validation_share, random_state=seed)
                             .split(data.iloc[development], groups=groups.iloc[development]))
    return {"train": development[train], "validation": development[validation], "test": test}


def main():
    settings = read_config()["prepare"]
    raw = pd.read_csv(RAW_DATA)
    required = {*NUMERIC_FEATURES, TARGET, "city", "street", "statezip"}
    if missing := required.difference(raw.columns):
        raise ValueError(f"Missing expected columns in {RAW_DATA.name}: {', '.join(sorted(missing))}")

    data = raw.drop_duplicates().copy()
    prices = pd.to_numeric(data[TARGET], errors="coerce")
    valid_price = prices.gt(0) & np.isfinite(prices)
    data = data.loc[valid_price].copy()
    data[TARGET] = prices.loc[valid_price]
    if data.empty:
        raise ValueError("No valid positive sale prices after cleaning.")

    data[NUMERIC_FEATURES] = data[NUMERIC_FEATURES].apply(pd.to_numeric, errors="coerce").replace([np.inf, -np.inf], np.nan)
    data["city"] = data["city"].astype("string").str.strip().replace("", pd.NA)
    streets = data["street"].astype("string").str.strip().fillna("").str.casefold()
    groups = data["city"].fillna("").str.casefold() + "|" + streets
    groups = groups.mask(streets.eq(""), "missing-street:" + data.index.to_series().astype(str))
    categories = ["city"]
    if settings["include_zip_code"]:
        data["zip_code"] = data["statezip"].astype("string").str.extract(r"\b([0-9]{5})\s*$", expand=False)
        categories.append("zip_code")
    features = [*NUMERIC_FEATURES, *categories]
    clean = data[[*features, TARGET]]

    PROCESSED.mkdir(parents=True, exist_ok=True)
    REPORTS.mkdir(parents=True, exist_ok=True)
    splits = {}
    for name, indices in split_by_property(clean, groups, settings).items():
        if len(indices) < 2:
            raise ValueError(f"The {name} split needs at least two rows for regression metrics.")
        output = PROCESSED / f"{name}.csv"
        clean.iloc[indices].to_csv(output, index=False, lineterminator="\n")
        splits[name] = {
            "rows": len(indices),
            "properties": int(groups.iloc[indices].nunique()),
            "sha256": sha256(output),
        }

    manifest = {
        "categorical_features": categories,
        "numeric_features": NUMERIC_FEATURES,
        "raw_sha256": sha256(RAW_DATA),
        "settings": settings,
        "splits": splits,
    }
    write_json(PROCESSED / "manifest.json", manifest)
    write_json(REPORTS / "data_profile.json", {
        **manifest,
        "raw_shape": list(raw.shape),
        "raw_columns": raw.columns.tolist(),
        "raw_missing_values": raw.isna().sum().map(int).to_dict(),
        "exact_duplicates_removed": int(raw.duplicated().sum()),
        "invalid_prices_removed": int((~valid_price).sum()),
        "clean_rows": len(clean),
        "prepared_missing_values": clean[features].isna().sum().map(int).to_dict(),
        "positive_price_summary_usd": clean[TARGET].describe(percentiles=[.05, .25, .5, .75, .95]).to_dict(),
        "most_frequent_cities": clean["city"].value_counts().head(10).map(int).to_dict(),
    })
    plot_distribution(clean[TARGET])
    print(f"Prepared {len(clean):,} of {len(raw):,} Kaggle rows.")
    print(", ".join(f"{name}={details['rows']:,}" for name, details in splits.items()))


if __name__ == "__main__":
    main()
