#!/usr/bin/env bash
set -euo pipefail

# --- model selection (strip any hidden CRs from pastes) ---
MODEL_RAW="${MODEL:-llama3.2:3b}"
MODEL="$(printf '%s' "$MODEL_RAW" | tr -d '\r')"

PROMPT="${1:-Summarize my clipboard.}"
OUTDIR="$HOME/Jarvis/workspace/results"
STAMP="$(date +'%Y%m%d_%H%M%S')"
OUTFILE="$OUTDIR/llama_${STAMP}.txt"

mkdir -p "$OUTDIR"

{
  echo "### LLaMA run ($MODEL) - $(date)"
  echo
  echo "### Prompt"
  echo "$PROMPT"
  echo
  echo "### Response"
} >"$OUTFILE"

# Ensure ollama is running
if ! pgrep -x ollama >/dev/null 2>&1; then
  echo "[info] Starting ollama service..." >&2
  ollama serve >/dev/null 2>&1 &
  sleep 5
fi

# (debug) show exact bytes of model name once per run
printf '[debug] model bytes: ' >>"$OUTFILE"
printf '%s' "$MODEL" | hexdump -C | sed -n '1p' >>"$OUTFILE"

# Pull if missing
if ! ollama list | awk 'NR>1{print $1}' | grep -Fxq "$MODEL"; then
  echo "[info] Pulling model $MODEL..." >&2
  ollama pull "$MODEL"
fi

# Run inference
ollama run "$MODEL" "$PROMPT" >>"$OUTFILE" 2>&1

# Mark last run
echo "[jarvis-llama] wrote $OUTFILE" >> "$OUTDIR/last_run.txt"
