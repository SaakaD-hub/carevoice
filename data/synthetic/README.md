# Synthetic data

**Only made-up people live here.** Never add real client, aide, family or hospital information.

| Path | What it is |
|---|---|
| `discharge/johnson_discharge.pdf` | Fictional heart-failure discharge papers for "Margaret Johnson." Includes a planted gap (furosemide has no dose). Regenerate with `python3 scripts/make_synthetic_discharge.py data/synthetic/discharge/johnson_discharge.pdf` |
| `clients.json` *(to do)* | 5 fictional clients (name, age, family language) |
| `visits/*.json` *(to do)* | 10 visits per client. Transcripts include planted warning patterns that match each client's discharge watch list (e.g. ankle swelling on visits 13–14 for Mrs. Johnson) |

Every synthetic PDF must carry the "SYNTHETIC - FOR TESTING" watermark.
