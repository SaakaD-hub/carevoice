# CareVoice Architecture and Build Plan

## One-line pitch

Hospitals send patients home with instructions nobody watches. CareVoice turns those instructions into a watch list for the home care aide, catches warning signs early from the aide's voice notes, and makes sure a nurse acts on every one.

## Why this combination

| Existing tools | What they miss |
|---|---|
| Discharge simplifiers (patient reads a checklist) | Nobody checks whether the patient is actually following it at home |
| Voice-to-note scribes for home care | Notes aren't compared with what the hospital said to watch |
| Change-in-condition alerts | A national trial found alerts without a structured response didn't reduce hospitalizations |

CareVoice links all three: **the discharge plan sets what to watch → aide notes are checked against it → every warning is tracked to a response.**

## System flow

```
                ┌─────────────────────────────────────────────────┐
 Discharge PDF  │ M1 Discharge Baseline                           │
 ─────────────► │ PDFBox text → LLM extraction → source-linked     │
                │ watch list + gaps flagged → nurse approves       │
                └───────────────────────┬─────────────────────────┘
                                        │ approved watch list
 Aide voice     ┌──────────────┐  ┌─────▼────────────┐  ┌───────────────────────┐
 ─────────────► │ M2 Voice     │─►│ M3 Note          │─►│ M4 Risk Engine        │
 (any language) │ Intake       │  │ Structurer       │  │ watch-list rules +    │
                │ STT+translate│  │ LLM → JSON note  │  │ trends across visits  │
                └──────────────┘  └──────────────────┘  └──────────┬────────────┘
                                                                   │ flags with reasons
                                        ┌──────────────────────────▼────────────┐
                                        │ M5 Closed-Loop Escalation             │
                                        │ flag → task (owner, SLA) → ack →      │
                                        │ action → outcome; overdue → escalate  │
                                        └───────────┬───────────────┬───────────┘
                                                    │               │
                                     ┌──────────────▼───┐   ┌───────▼──────────────┐
                                     │ M6 Family Portal │   │ M7 Dashboards        │
                                     │ plain-language   │   │ aide · nurse console │
                                     │ plan + updates   │   │ · agency outcomes    │
                                     └──────────────────┘   └──────────────────────┘
```

## Modules

| # | Module | Package | What it does | Done when |
|---|---|---|---|---|
| M1 | **Discharge Baseline** | `discharge` | Extracts text from the discharge PDF (PDFBox). The LLM returns JSON: medications, warning signs to watch, appointments, activity/diet limits. Every item carries the source line. Missing details (dose, frequency, date) become "gaps." A nurse approves, edits or rejects each item. | 3 synthetic discharge PDFs → watch lists; every item has a source quote that exists in the PDF; planted gaps are flagged |
| M2 | **Voice Intake** | `intake` | Accepts audio, runs speech-to-text, detects language, translates to English | English, Spanish and Haitian Creole samples transcribed in under 15s |
| M3 | **Note Structurer** | `notes` | LLM turns the transcript into a validated JSON care note | Golden set: field accuracy ≥ 90%; zero facts not found in the transcript |
| M4 | **Risk Engine** | `risk` | Deterministic rules. (a) **Watch-list match:** a note mentions something on the client's approved watch list. (b) **Trend:** decline across 3+ visits. (c) **Missed meds** against the discharge medication list. Each flag carries a plain-language reason. | Unit tests for every rule; golden-set precision and recall reported |
| M5 | **Closed-Loop Escalation** | `escalation` | Each flag becomes a task with owner, SLA and protocol. Acknowledge → action → outcome. Overdue tasks escalate a level. | Fake-clock tests cover SLA expiry and escalation chain |
| M6 | **Family Portal** | `family` | Plain-language care plan from M1 and visit updates, in the family's language, with no internal risk scores | 6th-grade reading level; test proves restricted fields never leak |
| M7 | **Dashboards** | frontend | Aide record screen, nurse console (approvals + open tasks), client timeline, agency outcome view | Playwright plays the full demo end to end |
| M8 | *Stretch:* Community resources / Storm mode | `resources` | Suggest verified services from a curated directory based on the care plan; or rank clients by risk before a storm | Only after the feature freeze, if everything is green |

### Shared pieces

- `llm/`: one `LlmClient` interface used by M1, M3 and M6, so swapping providers is one class
- `audit/`: who viewed or changed what, and when
- `client/`: clients, aides, nurses, family contacts, visits

## Data model (core tables)

```
client ──< discharge_plan ──< watch_item           (type, text, source_quote, page, status: pending/approved/rejected)
   │              └──< plan_gap                     (what's missing, e.g. "Furosemide: no dose listed")
   ├──< visit ──< care_note (JSONB)
   ├──< risk_flag ──< task ──< task_event           (created, acked, escalated, resolved + outcome)
   └──< family_update
```

## Example: how M1 and M4 work together

Discharge PDF line (page 2): *"Call your doctor if you gain more than 3 lbs in 2 days or notice swelling in your legs or ankles."*

M1 produces:
```json
{
  "type": "WARNING_SIGN",
  "watch_for": "leg or ankle swelling",
  "source_quote": "notice swelling in your legs or ankles",
  "page": 2,
  "status": "APPROVED"
}
```

Aide's voice note, visit 14 (in Spanish): *"Sus tobillos están más hinchados que ayer."* ("Her ankles are more swollen than yesterday.")

M4 raises:
```
RISK FLAG: WATCH_LIST_MATCH (high)
Reason: Discharge plan (p.2) says watch for ankle swelling.
        Swelling reported on visits 13 and 14.
Action: Nurse call within 4 hours (SLA).
```

## Testing strategy

| Layer | Approach |
|---|---|
| M4, M5 | Pure JUnit, no AI calls. Every rule and every SLA path is tested. Fake clock for time. |
| M1, M3 | **Golden set** in `data/golden/`: synthetic discharge PDFs and transcripts with expected JSON. `eval/` scores field accuracy and checks that every source quote really exists in the document. |
| LLM output | JSON schema validation on every response; invalid output is retried once, then marked for human review |
| API | Spring `@WebMvcTest` + Testcontainers Postgres for repositories |
| End to end | Playwright runs the demo script below |

## Build schedule (plan for Dec 2; anything after is buffer)

| Dates | Work | Exit check |
|---|---|---|
| Nov 13–14 | SkillsBuild certificate, activate IBM Bob, push repo, CI green | `/api/ping` works locally and CI passes |
| Nov 15–16 | Synthetic data: 5 clients, 3 discharge PDFs, 50 visits, golden-set labels | Seeder loads everything |
| Nov 17–18 | **M1 Discharge Baseline** + `LlmClient` | Source quotes verified; gaps flagged |
| Nov 19–21 | **M2 Voice Intake + M3 Note Structurer** | Golden-set accuracy reported |
| Nov 22–24 | **M4 Risk Engine** (watch-list + trend + missed meds) | All rule tests pass; precision/recall reported |
| Nov 25–26 | **M5 Closed-Loop Escalation** | Escalation tests pass |
| Nov 27 | **M6 Family Portal** (Thanksgiving, keep it small) | Readability + no-leak tests pass |
| Nov 28 | **M7 Dashboards** | Demo runs end to end |
| **Nov 29** | **Feature freeze.** Playwright, bug fixes only | E2E passes 3 times in a row |
| Nov 30 | Slides + video script, record video | Video at 2:50 |
| Dec 1 | Project page; teammate review | Every submission item checked |
| Dec 2 | Publish by noon | Published |

This is tight. If you fall behind, cut in this order: M8 → agency outcomes view in M7 → translation of family updates (keep English) → Haitian Creole in M2 (keep English + Spanish).

## Demo script (about 90 seconds of the 3-minute video)

1. **Upload** Mrs. Johnson's discharge papers (heart failure). The watch list appears with source highlights. One gap is flagged: "Furosemide: no dose listed." The nurse approves.
2. **Aide records** a Spanish voice note: ankles more swollen.
3. **Structured note** appears in English.
4. **Flag** fires: "Discharge plan p.2 says watch for swelling; reported on 2 visits in a row."
5. **Nurse console:** task with a 4-hour deadline. The demo fast-forwards the clock; it escalates to the supervisor. The nurse acknowledges and logs "called patient, MD adjusted diuretic."
6. **Family portal:** daughter gets a plain-language update in Spanish.
7. **Close** on the numbers: golden-set accuracy and detection rate.

## Responsible AI

- Not a diagnosis or prescription tool. A nurse approves every watch list and every escalation outcome.
- Every extracted instruction links to its source line; anything unsupported is rejected.
- Missing or ambiguous information is flagged, never invented.
- Synthetic data only. Logs never contain names, transcripts or document text.
