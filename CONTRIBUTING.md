# Contributing to CareVoice

Thanks for helping. This guide covers how to get set up, how we work, and the few rules we don't bend.

## 1. Get access

- **Team members:** ask @SaakaD-hub to invite your GitHub username. Accept the email invite, then clone the repo directly.
- **Everyone else:** fork the repo and open pull requests from your fork.

## 2. Set up your machine

You need:

| Tool | Version | Check |
|---|---|---|
| Git | any recent | `git --version` |
| Docker Desktop (or Docker Engine + Compose) | 24+ | `docker compose version` |
| Java (JDK) | 21 | `java -version` |
| Maven | 3.9+ | `mvn -v` |
| Node.js | 22 | `node -v` |
| IBM Bob | student trial | required development tool for this challenge |

Then:

```bash
git clone https://github.com/SaakaD-hub/carevoice.git
cd carevoice
cp .env.example .env          # fill in the values
docker compose up --build
```

- App: http://localhost:5173
- API health check: http://localhost:8080/api/ping
- Splunk (logs): http://localhost:8000, user `admin`, password from `.env`

**Faster loop while coding** (database in Docker, apps on your machine):

```bash
docker compose up -d postgres
cd backend && mvn spring-boot:run
cd frontend && npm install && npm run dev
```

## 3. How we work

1. **Pick or create an issue** using the Task template, and assign yourself.
2. **Create a branch** from `main`:
   - `feat/m3-appetite-trend`
   - `fix/m1-empty-audio`
   - `docs/deployment-guide`
3. **Commit small and often** using [Conventional Commits](https://www.conventionalcommits.org):
   - `feat(risk): flag 3 consecutive low-appetite visits`
   - `fix(intake): reject empty audio files`
   - `test(risk): add golden-set cases for confusion`
4. **Open a pull request** into `main`. Fill in the template.
5. **CI must pass** and **one approval** is required before merging. We squash-merge.
6. Delete your branch after merge (GitHub does this automatically).

Nobody pushes directly to `main`, including the repo owner.

## 4. Code standards

- **Backend:** Java 21, Spring Boot. One package per module (`discharge`, `intake`, `notes`, `risk`, `escalation`, `family`). See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the module plan. Business logic goes in services, not controllers.
- **Risk engine (M4) and escalation (M5)** must have unit tests for every rule. They are deterministic, so test them without calling any AI service.
- **Database changes** go in a new Flyway migration (`V2__add_task_table.sql`). Never edit a migration that's already merged.
- **Logging:** use SLF4J (`log.info(...)`). Logs are JSON and go to Splunk. Never log transcripts, client names or API keys.
- **Frontend:** React function components. Keep pages in `src/pages/`.

## 5. Rules we don't bend

1. **No real patient data. Ever.** Use only the made-up clients and discharge papers in `data/synthetic/`. This applies to code, tests, screenshots, logs and demo videos.
2. **No secrets in Git.** Keys go in `.env` (ignored by Git). CI runs a secret scanner on every PR.
3. **Log your IBM Bob usage.** When Bob helps with a change, add a line to [`docs/bob-log.md`](docs/bob-log.md). The judges score how we used Bob, and this log is our evidence.
4. **AI suggests, people decide.** No feature may make a medical decision without a nurse reviewing it.

## 6. Getting help

Open an issue, or ask in the team channel. If you're stuck for more than 30 minutes, ask. That's faster for everyone.
