#!/usr/bin/env bash
set -euo pipefail

IN="$HOME/Jarvis/incoming"
OUT="$HOME/Jarvis/results"
DONE="$HOME/Jarvis/processed"
LLAMA="$HOME/Jarvis/workspace/bin/jarvis_llama.sh"
MODEL="${JARVIS_LLM_MODEL:-llama3.2:3b}"     # override by exporting env var if you like

log(){ printf "[%(%F %T)T] %s\n" -1 "$*" >> "$OUT/watch.log"; }

shopt -s nullglob
# Process any .txt or .md currently sitting there (new or left over)
for f in "$IN"/*.txt "$IN"/*.md; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  stamp="$(date +'%Y%m%d_%H%M%S')"
  outfile="$OUT/llama_incoming_${stamp}.txt"

  # Build prompt from file contents
  text="$(cat -- "$f")"
  prompt="Summarize this clip and extract key actions, names, dates, and links. Keep it concise.\n\n$text"

  log "processing: $base  (model=$MODEL)"
  if "$LLAMA" "$MODEL" "$prompt" > /dev/null 2>&1; then
    # jarvis_llama.sh already writes a nice transcript into results/llama_*.
    # But we also want a quick-copy summary file right here:
    printf "### Source\n%s\n\n### Prompt\n%s\n\n### Jarvis\n" "$base" "$prompt" > "$outfile"
    # Append the last run transcript body (most recent)
    awk 'f;/^### Response/{f=1}' "$OUT"/llama_* | tail -n +1 >> "$outfile" 2>/dev/null || true
    log "done: $base → $(basename "$outfile")"
  else
    log "ERROR running LLaMA for $base"
  fi

  # Move processed file out of the inbox
  mv -f -- "$f" "$DONE/$base"
done
