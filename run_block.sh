#!/usr/bin/env bash
set -euo pipefail
echo "Hello from bash"
mkdir -p demo && echo "file.txt" > demo/.keep
ls -la