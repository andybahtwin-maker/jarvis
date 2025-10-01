#!/usr/bin/env bash
set -euo pipefail
# Clear stale lock
rm -f ~/Jarvis/workspace/.git/index.lock

# Make sure Git is initialized correctly
cd ~/Jarvis/workspace
git status