#!/usr/bin/env bash
# Jarvis dispatcher for LLAMA (Ollama backend)
set -euo pipefail

# input: JSON like {"cmd":"llama","model":"llama3:2.3b","prompt":"Hello"}
IN="${1:-}"
if [ -z "$IN" ]; then
  read -r IN
fi

MODEL="$(echo "$IN" | jq -r '.model // "llama3:2.3b"')"
PROMPT="$(echo "$IN" | jq -r '.prompt // empty')"
OUTDIR="$HOME/Jarvis/workspace/results"
mkdir -p "$OUTDIR"

STAMP="$(date -Iseconds)"
OUTFILE="$OUTDIR/llm_${STAMP}.md"

{
  echo "### LLaMA run ($MODEL) — $STAMP"
  echo ""
  echo "#### Prompt"
  echo "\`\`\`"
  echo "$PROMPT"
  echo "\`\`\`"
  echo ""
  echo "#### Response"
  echo "\`\`\`"
  ollama run "$MODEL" "$PROMPT" 2>&1
  echo "\`\`\`"
} | tee "$OUTFILE"

echo "[jarvis-llama] wrote $OUTFILE" >> "$OUTDIR/last_run.txt"
