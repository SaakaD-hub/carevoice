# CareVoice

**From hospital discharge to safe recovery at home.**
CareVoice turns discharge instructions into a watch list for home care aides, catches warning signs early from their voice notes, and makes sure a nurse acts on every one.

Built for the IBM AI Builders Challenge 2026 (AI for Good track) using IBM Bob.

---

## The problem

When an older adult leaves the hospital, they go home with pages of instructions: new medications, things to watch for, appointments to keep. The person who sees them most in the weeks that follow is usually a home care aide, not a doctor or nurse.

Four things go wrong in that gap:

1. **The instructions get lost.** Discharge papers are long, full of medical terms, and often end up in a drawer. The aide never learns that "watch for ankle swelling" or "weigh daily" was on the list.
2. **Paperwork is hard.** Aides write notes after long shifts, often unpaid, and many don't speak English as a first language. Important details get left out or written vaguely.
3. **Nobody connects the dots.** One bad day doesn't mean much. Three bad days in a row, on exactly the thing the hospital said to watch, does. But no one is comparing the notes with the instructions.
4. **Warnings go nowhere.** A national study of home care found that sending alerts to the office, without a clear plan for who responds and how, did not reduce hospital visits.

The result: patients end up back in the hospital within weeks, often for problems that were visible early.

## What CareVoice does

| Step | What happens | In plain terms |
|---|---|---|
| 1. **Read the discharge papers** | The agency uploads the hospital discharge document. AI pulls out medications, warning signs and appointments, and links each one to the exact line it came from. Anything missing or unclear is flagged, never guessed. A nurse approves the result. | The hospital's instructions become a short "what to watch" list for this client. |
| 2. **Speak** | After each visit, the aide talks into their phone for about a minute, in any language. | No typing, no forms. |
| 3. **Organize** | AI turns what they said into a clean, structured care note in English. | Meals, medications, mood, mobility, falls, swelling and breathing are all filled in. |
| 4. **Check against the watch list** | CareVoice compares today's note with the watch list and with recent visits. | "Discharge plan says watch for swelling. Aide reported swollen ankles on 2 visits in a row. Nurse should check in today." |
| 5. **Make sure someone acts** | Each warning becomes a task with a named owner and a deadline. If nobody responds in time, it goes up to the next person. | Warnings can't sit in an inbox. Every one gets an answer. |
| 6. **Keep the family informed** | The family gets the care plan and regular updates in plain language, in their own language. | They know what to watch for and how their loved one is doing. |

## What makes it different

Some tools simplify discharge papers. Others turn voice into notes. CareVoice connects the two and closes the loop:

- **The hospital's instructions drive what gets watched at home.** Each client gets their own watch list, not a generic checklist.
- **It looks across visits, not just one.** It catches slow changes a single note would miss.
- **It closes the loop.** Every warning is tracked until someone acts and records what they did. This is the step research shows is missing.
- **It shows its sources.** Every instruction links back to the line in the discharge document, and every warning says *why* it was raised.
- **It works in everyone's language.** Aides speak naturally; families read updates in the language they're most comfortable with.

## Who it helps

- **Clients:** problems are caught early, so fewer return trips to the hospital.
- **Aides:** less paperwork, and they know exactly what to look for.
- **Nurses and agencies:** one screen showing who needs attention today, and why.
- **Families:** a care plan they can understand and regular updates.
- **Hospitals:** fewer patients readmitted within 30 days of discharge.

## How it works (simplified)

```
Discharge papers → AI builds watch list → Nurse approves
                                              ↓
Aide speaks → Speech to text → AI builds care note → Checked against watch list + recent visits
                                                              ↓
                       Family update  ←  Nurse task with deadline (escalates if ignored)
```

- **Discharge reader** pulls the text from the PDF and extracts instructions, each linked to its source line.
- **Speech-to-text** turns the voice recording into words and translates them if needed.
- **AI note builder** organizes the words into a standard care note and never adds facts the aide didn't say.
- **Pattern checker** uses clear, written rules (not a black box) to compare notes against the watch list and spot trends over time.
- **Follow-up tracker** assigns tasks, watches deadlines and escalates if nobody responds.

## Built with

- **IBM Bob:** our main development tool, used to design, write, test and improve the code
- Java and Spring Boot (backend)
- React (web app that works on phones)
- PostgreSQL (database)
- Apache PDFBox (reading discharge documents)
- IBM Watson Speech to Text and an AI language model
- Splunk (log collection and monitoring)
- Docker and GitHub Actions (packaging and automated testing)

## Privacy and safety

- The demo uses **only made-up clients, discharge papers and visits.** No real patient information is used.
- AI **supports** people; it does not diagnose or prescribe. A nurse approves every watch list and reviews every warning.
- Missing or unclear information is flagged, never invented.
- Families see plain-language summaries, not internal risk scores.

## Try it

You need [Docker Desktop](https://docs.docker.com/get-docker) installed.

```bash
git clone https://github.com/SaakaD-hub/carevoice.git
cd carevoice
cp .env.example .env
docker compose up --build
```

Then open:
- **The app:** http://localhost:5173
- **Splunk (logs and monitoring):** http://localhost:8000

Full setup and server deployment: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md). How the system is built: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Monitoring guide: [docs/MONITORING.md](docs/MONITORING.md).

## Want to help?

We welcome contributors. Read [CONTRIBUTING.md](CONTRIBUTING.md) to get set up, then pick an open issue. Please also read our [Code of Conduct](CODE_OF_CONDUCT.md).

## What's next

- Pilot with a real home care agency and a partner hospital
- Receive discharge documents directly from hospital systems instead of uploads
- Suggest verified community services (meals, transport, pharmacy delivery) based on the care plan
- Add a "storm mode" that ranks clients by risk before severe weather or power outages

## Team

**David Saaka:** Software engineer with 15 years of experience, working in home care technology in Massachusetts, and an MS Computer Science student at Maharishi International University.
