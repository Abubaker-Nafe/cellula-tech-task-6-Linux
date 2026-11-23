#!/usr/bin/env python3
"""Download the dataset, reproduce the DVC stages or launch the tracking UI."""

import argparse
import os
import subprocess
import sys
from io import BytesIO
from pathlib import Path
from tempfile import NamedTemporaryFile
from urllib.error import URLError
from urllib.request import Request, urlopen
from zipfile import BadZipFile, ZipFile

from src.common import DATASET_DOWNLOAD, DATASET_SHA256, RAW_DATA, ROOT, TRACKING_URI, sha256


def verify_dataset(path):
    if sha256(path) != DATASET_SHA256:
        raise ValueError(f"{path.name} differs from the pinned Kaggle data.csv. Keep the existing file and check its source.")


def fetch_dataset(archive_path=None):
    if RAW_DATA.is_file():
        verify_dataset(RAW_DATA)
        print(f"Verified {RAW_DATA.relative_to(ROOT)}", flush=True)
        return

    if archive_path is None:
        request = Request(DATASET_DOWNLOAD, headers={"User-Agent": "Cellula-Task9/1.0", "Accept": "application/zip"})
        with urlopen(request, timeout=60) as response:
            archive_path = BytesIO(response.read())

    RAW_DATA.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(archive_path) as archive:
        contents = archive.read("data.csv")
    with NamedTemporaryFile(dir=RAW_DATA.parent) as stream:
        stream.write(contents)
        stream.flush()
        temporary_path = Path(stream.name)
        verify_dataset(temporary_path)
        try:
            RAW_DATA.hardlink_to(temporary_path)
        except FileExistsError:
            verify_dataset(RAW_DATA)

    print(f"Verified Kaggle version 2 and saved {RAW_DATA.relative_to(ROOT)}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    fetch = commands.add_parser("fetch", help="retrieve the pinned Kaggle data.csv")
    fetch.add_argument("--archive", type=Path, help="use an already downloaded Kaggle ZIP")
    run = commands.add_parser("run", help="reproduce the DVC pipeline")
    run.add_argument("--force", action="store_true", help="rerun every stage and create fresh MLflow runs")
    ui = commands.add_parser("ui", help="serve the local MLflow UI")
    ui.add_argument("--port", type=int, default=5000)
    args = parser.parse_args()

    try:
        if args.command == "fetch":
            fetch_dataset(args.archive)
            return 0
        if args.command == "run":
            if not RAW_DATA.exists():
                fetch_dataset()
            command = [sys.executable, "-m", "dvc", "repro"]
            if args.force:
                command.append("--force")
        else:
            command = [
                sys.executable, "-m", "mlflow", "server", "--backend-store-uri", TRACKING_URI,
                "--no-serve-artifacts", "--host", "127.0.0.1", "--port", str(args.port), "--workers", "1",
            ]

        environment = os.environ.copy()
        environment["PATH"] = os.pathsep.join([str(Path(sys.executable).parent), environment.get("PATH", os.defpath)])
        return subprocess.call(command, cwd=ROOT, env=environment)
    except (BadZipFile, KeyError, OSError, URLError, ValueError) as error:
        print(f"Task 9: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
