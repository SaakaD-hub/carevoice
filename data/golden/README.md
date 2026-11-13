# Golden set

Labeled synthetic cases used to measure accuracy. The scores go in the demo video and project page.

| Folder | Module | Each case has |
|---|---|---|
| `discharge/` | M1 Discharge Baseline | `<name>_expected.json`: expected watch items (with exact source quotes) and expected gaps |
| `notes/` *(to do)* | M3 Note Structurer | `transcript.txt` + `expected_note.json` |
| `flags/` *(to do)* | M4 Risk Engine | visit sequence + approved watch list + `expected_flags.json` |

Target size: 3 discharge documents, 30 transcripts, 30 flag scenarios.

**Hard rule for M1:** every source quote the system produces must appear word for word in the PDF. A quote that doesn't is counted as a hallucination.
