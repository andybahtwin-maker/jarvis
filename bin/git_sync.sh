#!/usr/bin/env bash
set -euo pipefail

REPO="$HOME/Jarvis/workspace"
cd "$REPO"

# set your identity (once per repo)
git config user.name "Andy Bahtwin"
git config user.email "andybahtwin@gmail.com"

# add everything new/changed
git add -A

# commit with timestamp (only if there are changes)
if ! git diff --cached --quiet; then
  msg="[auto] snapshot $(date -u +'%F %T UTC')"
  git commit -m "$msg"
  echo "[ok] committed: $msg"
else
  echo "[info] nothing new to commit"
fi

# push if remote is set
if git remote get-url origin >/dev/null 2>&1; then
  git push origin main
  echo "[ok] pushed to origin/main"
else
  echo "[warn] no remote set. Add one with:"
  echo "  cd $REPO && git remote add origin <url> && git branch -M main && git push -u origin main"
fi
