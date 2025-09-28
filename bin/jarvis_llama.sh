#!/usr/bin/env bash
set -euo pipefail

MODEL="llama3.2:3b"
PROMPT="${1:-Summarize my clipboard.}"
OUTDIR="$HOME/Jarvis/workspace/results"
STAMP="$(date +'%Y%m%d_%H%M%S')"
OUTFILE="$OUTDIR/llama_${STAMP}.txt"

mkdir -p "$OUTDIR"

echo "### LLaMA run (\$MODEL) - \$(date)" >"$OUTFILE"
echo >>"$OUTFILE"
echo "### Prompt" >>"$OUTFILE"
echo "\$PROMPT" >>"$OUTFILE"
echo >>"$OUTFILE"
echo "### Response" >>"$OUTFILE"

# Make sure ollama service is running
if ! pgrep -x ollama >/dev/null 2>&1; then
  echo "[info] Starting ollama service..." >&2
  ollama serve >/dev/null 2>&1 &
  sleep 5
fi

# Pull model if missing
if ! ollama list | grep -q "\$MODEL"; then
  echo "[info] Pulling model \$MODEL..." >&2
  ollama pull "\$MODEL"
fi

# Run inference
ollama run "\$MODEL" "\$PROMPT" >>"$OUTFILE" 2>&1

# Save last_run marker
echo "[jarvis-llama] wrote \$OUTFILE" >> "$OUTDIR/last_run.txt"
