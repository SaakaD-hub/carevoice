# Monitoring with Splunk

## How logs get to Splunk

```
Spring Boot app ──JSON logs to stdout──► Docker Splunk log driver ──HTTPS (HEC)──► Splunk
```

- The backend writes **structured JSON logs** (Elastic Common Schema) using Spring Boot's built-in structured logging. No Splunk library in the code.
- Docker's **Splunk logging driver** (configured in `docker-compose.yml`) sends every container's output to Splunk's **HTTP Event Collector (HEC)**.
- `docker compose logs` still works, because Docker keeps a local copy.

To send logs somewhere else later, only the compose file changes. The app code stays the same.

## First-time check

1. `docker compose up --build`, then wait 1–2 minutes for Splunk.
2. Open http://localhost:5173 (this calls `/api/ping`, which writes a log line).
3. Open http://localhost:8000, log in as `admin`, go to **Search & Reporting**, and run:

```spl
index=main source=carevoice
```

You should see events from `carevoice-backend-1`, `carevoice-frontend-1` and so on.

If nothing shows up:
- Check that `SPLUNK_HEC_TOKEN` in `.env` is a valid UUID and Splunk has finished starting (`docker compose logs splunk | tail`).
- On Docker Desktop, if `https://localhost:8088` isn't reachable by the log driver, set `SPLUNK_HEC_URL=https://host.docker.internal:8088` in `.env`.
- Restart the app containers after Splunk is up: `docker compose restart backend frontend`.

## Useful searches

**All backend logs, newest first**
```spl
index=main source=carevoice tag="*backend*"
| spath input=line
| table _time log.level message log.logger
```

**Errors in the last hour**
```spl
index=main source=carevoice earliest=-1h
| spath input=line
| search log.level=ERROR
| table _time log.logger message error.message
```

**Log volume by level (for a chart)**
```spl
index=main source=carevoice
| spath input=line
| timechart span=5m count by log.level
```

**Risk flags raised (once M3 logs `risk flag raised`)**
```spl
index=main source=carevoice "risk flag raised"
| spath input=line
| timechart span=1h count
```

**Escalations not acknowledged in time (once M4 logs `task escalated`)**
```spl
index=main source=carevoice "task escalated"
| spath input=line
| stats count by task.level
```

## Dashboard

Import `splunk/carevoice_dashboard.xml`:
**Search & Reporting → Dashboards → Create New Dashboard → Classic Dashboards → Source**, paste the file contents, and save.

## Alerts worth setting up

| Alert | Search | Trigger |
|---|---|---|
| Backend errors | errors search above | more than 5 in 5 minutes |
| App down | `index=main source=carevoice tag="*backend*" earliest=-10m` | 0 results |
| Escalation spike | escalations search | more than 3 in 1 hour |

Set these up under **Save As → Alert**.

## What we never log

Transcripts, client names, family contact details, or API keys. Log IDs instead (`visitId=42`, `clientId=7`).

## Discharge baseline activity (M1)

Log only IDs and counts, never document text:

```spl
index=main source=carevoice ("watch list extracted" OR "watch list approved" OR "plan gap flagged")
| spath input=line
| timechart span=1h count by message
```
