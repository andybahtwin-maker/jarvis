#!/usr/bin/env bash
set -euo pipefail

VAULT="$HOME/.jarvis/.env"
mkdir -p "$(dirname "$VAULT")"
touch "$VAULT"
chmod 600 "$VAULT"

SCAN_ROOT="${1:-$HOME}"   # default: scan your whole home

echo "[info] Scanning for .env files under: $SCAN_ROOT" >&2

# temp file to hold consolidated entries
TMP="$(mktemp)"

# Iterate over every .env file
find "$SCAN_ROOT" -type f -name "*.env" 2>/dev/null | while read -r envfile; do
  echo "[scan] $envfile" >&2
  grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$envfile" || true
done >> "$TMP"

# Merge into vault (latest key wins)
sort -u "$TMP" > "$TMP.sorted"
while IFS='=' read -r k v; do
  # strip existing entry
  if grep -qE "^${k}=" "$VAULT"; then
    tmp2="$(mktemp)"
    grep -vE "^${k}=" "$VAULT" > "$tmp2" && mv "$tmp2" "$VAULT"
  fi
  printf '%s=%s\n' "$k" "$v" >> "$VAULT"
done < "$TMP.sorted"

rm -f "$TMP" "$TMP.sorted"
chmod 600 "$VAULT"

echo "[ok] Vault updated at $VAULT"
