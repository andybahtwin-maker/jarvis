#!/usr/bin/env bash
set -euo pipefail
cd ~/Jarvis/workspace
git add .
git commit -m "Jarvis auto-update $(date +%F_%T)" || true
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:andybahtwin-maker/jarvis.git
git push -u origin main