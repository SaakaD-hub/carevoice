#!/usr/bin/env bash
# One-time GitHub setup for CareVoice.
# Creates the repo under SaakaD-hub, pushes the code, protects main, adds labels,
# and invites teammates.
#
# Requirements: git, GitHub CLI (gh) logged in:  gh auth login
#
# Usage (run from the repo root):
#   ./scripts/setup-github.sh                        # create + push + protect
#   ./scripts/setup-github.sh teammate1 teammate2    # ...and invite these GitHub users
#
# Note: branch protection is free on PUBLIC repos. On a private repo it needs
# GitHub Pro (free with the GitHub Student Developer Pack).

set -euo pipefail

OWNER="SaakaD-hub"
REPO="carevoice"
VISIBILITY="${VISIBILITY:-public}"

command -v gh >/dev/null || { echo "Install the GitHub CLI: https://cli.github.com"; exit 1; }
gh auth status >/dev/null || { echo "Run: gh auth login"; exit 1; }

# 1. Init and first commit
if [ ! -d .git ]; then
  git init -b main
  git add .
  git commit -m "chore: initial CareVoice scaffold"
fi

# 2. Create the GitHub repo and push
if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  gh repo create "$OWNER/$REPO" --"$VISIBILITY" --source=. --remote=origin --push \
    --description "Turns hospital discharge instructions into a watch list for home care aides, flags warning signs from voice notes, and tracks every alert to a response (IBM AI Builders Challenge)"
else
  echo "Repo $OWNER/$REPO already exists, pushing main"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -u origin main
fi

# 3. Repo settings: squash merges only, delete branches after merge
gh repo edit "$OWNER/$REPO" \
  --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false \
  --delete-branch-on-merge --enable-issues

# 4. Protect main: PR required, 1 approval, code owner review, CI must pass
gh api -X PUT "repos/$OWNER/$REPO/branches/main/protection" \
  -H "Accept: application/vnd.github+json" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Backend (build + tests)", "Frontend (build)", "Secret scan"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
echo "main is protected"

# 5. Labels for each module
for label in "M1 Discharge Baseline:8c564b" "M2 Voice Intake:1f77b4" "M3 Note Structurer:ff7f0e" \
             "M4 Risk Engine:d62728" "M5 Escalation:9467bd" "M6 Family Portal:2ca02c" \
             "M7 Dashboards:17becf" "M8 Stretch:7f7f7f" "task:0e8a16" "infra:5319e7" "demo:fbca04"; do
  name="${label%%:*}"; color="${label##*:}"
  gh label create "$name" --color "$color" --repo "$OWNER/$REPO" --force >/dev/null
done
echo "labels created"

# 6. Invite teammates with write access (they get an email invite)
for user in "$@"; do
  gh api -X PUT "repos/$OWNER/$REPO/collaborators/$user" -f permission=push >/dev/null
  echo "invited $user"
done

echo "Done: https://github.com/$OWNER/$REPO"
