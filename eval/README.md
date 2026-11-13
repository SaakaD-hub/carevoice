# Evaluation

Scripts that score the AI modules against `data/golden/`:

| Module | Metrics |
|---|---|
| M1 Discharge Baseline | Watch-item recall, gap detection rate, hallucinated quotes (target: 0) |
| M3 Note Structurer | Field-level accuracy; facts not found in the transcript (target: 0) |
| M4 Risk Engine | Precision and recall of flags, split by rule (watch-list match, trend, missed meds) |

Results go in the project page and the demo video, e.g. "Caught 27 of 29 planted warning signs with zero invented facts."
