#!/usr/bin/env bash
set -euo pipefail

cd ~/Jarvis/workspace

# Initialize repo if it isn't one already
git init

# Add your GitHub repo as remote
git remote remove origin 2>/dev/null || true
git remote add origin git@github.com:andybahtwin-maker/jarvis.git

# Make sure branch is main
git branch -M main

# Stage and commit everything (first commit if needed)
git add .
git commit -m "Initial commit from Jarvis workspace" || true

# Push up to GitHub
git push -u origin main
