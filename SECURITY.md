# Security Policy

CareVoice is a prototype built for the IBM AI Builders Challenge. It is **not** approved for use with real patient data.

## Reporting a vulnerability

Please don't open a public issue. Use GitHub's **Security → Report a vulnerability** on this repo, or contact @SaakaD-hub directly. We aim to reply within 3 days.

## Ground rules for contributors

- Secrets live in `.env` or in your deployment platform's secret store, never in Git.
- Every pull request is scanned for leaked secrets (gitleaks).
- Dependabot opens weekly update PRs. Merge security updates promptly.
- Logs must never contain transcripts, client names, or API keys.
