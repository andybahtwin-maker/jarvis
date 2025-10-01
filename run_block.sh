#!/usr/bin/env bash
set -euo pipefail
# Heal repo & set upstream (idempotent)
cd ~/Jarvis/workspace
rm -f .git/index.lock

git init
git branch -M main

git config user.name  "Jarvis (Hands-Off)"
git config user.email "jarvis@local"
git config pull.rebase true
git config rebase.autoStash true

# Ensure origin
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:andybahtwin-maker/jarvis.git

# Sensible ignores
grep -qxF 'results/*.log' .gitignore || cat >> .gitignore <<'GI'
results/*.log
__pycache__/
*.pyc
.env
.env.*
!.env.example
GI

git add -A
git commit -m "Bootstrap autosync" || true

# If remote is ahead, rebase; then push
git fetch origin main || true
git pull --rebase origin main || true
git push -u origin main || true

echo "[OK] Repo healed & upstream set."