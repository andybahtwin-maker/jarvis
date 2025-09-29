#!/usr/bin/env bash
set -euo pipefail
cd ~/Jarvis/workspace

git init
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:andybahtwin-maker/jarvis.git

# Safety: never push secrets
grep -q '^\.env$' .gitignore || cat <<GI >> .gitignore
.env
.env.*
!.env.example
GI

git add .
git commit -m "Jarvis workspace init/update" || true
git push -u origin main
