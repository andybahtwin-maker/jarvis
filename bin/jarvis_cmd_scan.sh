#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/Jarvis/workspace"
INBOX="$ROOT/inbox"
LOCK="$ROOT/results/cmd_scan.lock"

{
  shopt -s nullglob
  for f in "$INBOX"/*.json; do
    "$ROOT/jarvis_cmd_processor.py" "$f" || true
  done
} 200>"$LOCK"
