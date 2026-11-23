# Cellula Technologies MLOps Internship · Task 9

| Deliverable | What to show |
| --- | --- |
| Linux commands | Eleven runnable assignments and the recorded terminal session. [Linux exercises](Linux_commands/README.md) |
| Linux networking research | Three PDFs covering 20 commands, with annotated output, comparison tables and six Linux terminal captures. [Fundamentals](Linux_research/01_networking_fundamentals.pdf) · [Diagnostics](Linux_research/02_diagnostics_and_communication.pdf) · [Advanced operations](Linux_research/03_advanced_network_operations.pdf) |
| Reproducible ML project | Four tracked scikit-learn runs, held-out evaluation and a DVC pipeline with a verified two-version data restore. [House-price experiment](Reproducible_ml_project/README.md) |

## Mentor demo

1. Run `bash Linux_commands/run_demo.sh` from the project root to replay all eleven exercises in a new scratch directory. [Recorded Linux demo](Linux_commands/demo_transcript.txt)
2. Open the three networking PDFs and walk through the command comparisons and terminal captures.
3. From `Reproducible_ml_project`, run `.venv/bin/python main.py ui` and open the **Cellula House Prices** experiment at `http://127.0.0.1:5000`. Compare the four models by `validation_rmse`, then open the Ridge run to inspect its held-out metrics and artifacts. [Experiment setup and results](Reproducible_ml_project/README.md)

On the 684-row held-out set, Ridge achieved **$116,441.64 MAE**, **$205,752.27 RMSE** and **0.6902 R²**. A forced DVC rerun reproduced the metrics and predictions byte for byte.
