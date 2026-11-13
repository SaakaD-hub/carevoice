# Deployment Guide

Everything you need to run CareVoice on your laptop, on a teammate's laptop, and on a public server for the demo.

## 1. Required tools

### On every developer's machine

| Tool | Version | What it's for | Get it |
|---|---|---|---|
| Git | recent | Version control | https://git-scm.com |
| GitHub CLI (`gh`) | recent | Creating the repo, PRs, inviting teammates | https://cli.github.com |
| Docker Desktop (or Docker Engine + Compose v2) | 24+ | Runs the database, app and Splunk | https://docs.docker.com/get-docker |
| JDK | 21 (Temurin recommended) | Backend | https://adoptium.net |
| Maven | 3.9+ | Backend build | https://maven.apache.org |
| Node.js | 22 LTS | Frontend | https://nodejs.org |
| IBM Bob | student trial | **Required** primary development tool | Challenge page |
| A code editor | — | VS Code or IntelliJ | — |

Hardware: 8 GB RAM minimum (Splunk alone uses about 2 GB). 16 GB is comfortable.

### Accounts and services

| Service | Why | Cost for this project |
|---|---|---|
| GitHub | Code, pull requests, CI (GitHub Actions) | Free (public repo) |
| Splunk | Log collection and monitoring | Free trial, see section 4 |
| Speech-to-text (IBM Watson STT or Whisper) | M2 Voice Intake | Free tier / trial |
| LLM (IBM watsonx.ai Granite or other) | M1 discharge extraction, M3 notes, M6 family updates | Free tier / trial |
| Cloud VM (IBM Cloud, DigitalOcean, AWS Lightsail, etc.) | Public demo server | Free credits or ~$12–24/month |
| Domain name (optional) | HTTPS URL for judges | Free subdomain (e.g. DuckDNS) or ~$10/year |

## 2. Run locally

```bash
git clone https://github.com/SaakaD-hub/carevoice.git
cd carevoice
cp .env.example .env
# Edit .env: set DB_PASSWORD, SPLUNK_PASSWORD (8+ chars) and SPLUNK_HEC_TOKEN (any UUID: run `uuidgen`)
docker compose up --build
```

| What | URL |
|---|---|
| App | http://localhost:5173 |
| API health | http://localhost:8080/api/ping |
| Backend health (detailed) | http://localhost:8080/actuator/health |
| Splunk | http://localhost:8000 (user `admin`) |

Stop everything: `docker compose down`. Wipe the data too: `docker compose down -v`.

## 3. Deploy to a public server (demo for judges)

We run the same Docker setup on one Linux VM. It's simple, cheap, and identical to local.

### 3.1 Create the server

- Ubuntu 24.04, **4 GB RAM** if using Splunk Cloud, **8 GB RAM** if running Splunk on the same server.
- Open ports **22** (SSH), **80** and **443** in the firewall. Nothing else.

### 3.2 Point a domain at it

Create an `A` record (e.g. `carevoice.yourdomain.com`) pointing to the server's public IP. Caddy will get the HTTPS certificate automatically.

### 3.3 Install Docker and start the app

```bash
ssh ubuntu@YOUR_SERVER_IP
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER && newgrp docker

git clone https://github.com/SaakaD-hub/carevoice.git
cd carevoice
cp .env.example .env
nano .env        # set DOMAIN, DB_PASSWORD, Splunk values, API keys
```

**Option A, Splunk Cloud:**

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

**Option B, Splunk on the same server:** in `.env` set `SPLUNK_HEC_URL=https://localhost:8088` and `SPLUNK_INSECURE_SKIP_VERIFY=true`, then:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile selfhosted-splunk up -d --build
```

Splunk's web UI is not exposed to the internet. Open it from your laptop through an SSH tunnel:

```bash
ssh -L 8000:localhost:8000 ubuntu@YOUR_SERVER_IP
# then browse to http://localhost:8000
```

### 3.4 Update the server after merging to main

```bash
cd carevoice && git pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

## 4. Splunk: which option and when

| Option | Trial length | Best for |
|---|---|---|
| Splunk Enterprise in Docker (local and Option B) | 60 days, 500 MB/day, then converts to a free license | Development and the demo server. **Recommended.** |
| Splunk Cloud Platform | 14 days, up to 5 GB/day | Only if you want hosted Splunk. **Start the trial around Nov 26** so it covers the deadline and judging. |

500 MB/day is far more than this app produces.

Setup details and useful searches: [MONITORING.md](MONITORING.md).

## 5. Secrets

- Locally: `.env` (ignored by Git).
- On the server: `.env` on the server only, readable by your user (`chmod 600 .env`).
- In GitHub Actions: Settings → Secrets and variables → Actions. CI doesn't need any secrets today.

## 6. Pre-demo checklist

- [ ] `https://YOUR_DOMAIN` loads and shows "Backend: ok"
- [ ] Logs from `carevoice-backend` show up in Splunk
- [ ] Demo data loaded (5 synthetic clients)
- [ ] `.env` on the server has real passwords, not the examples
- [ ] Server snapshot taken (so you can roll back if something breaks)
