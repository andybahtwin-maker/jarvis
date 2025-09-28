#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/Jarvis"
INBOX="$ROOT/inbox"
DONE="$ROOT/processed"
LOG="$ROOT/logs/dispatcher.log"
SKILLS="$ROOT/skills"
BIN="$ROOT/workspace/bin"

LLAMA="$BIN/jarvis_llama.sh"        # your existing runner
MODEL_DEFAULT="${MODEL_DEFAULT:-llama3.2:3b}"

mkdir -p "$INBOX" "$DONE" "$(dirname "$LOG")"

log(){ printf '%s %s\n' "[$(date +'%F %T')]" "$*" | tee -a "$LOG" ; }

parse_json () {  # usage: parse_json KEY FILE
  /usr/bin/python3 - <<PY "$2" "$1"
import json,sys,Pathlib
p=Pathlib.Path(sys.argv[1])
data=json.load(open(sys.argv[1]))
key=sys.argv[2]
val=data.get(key,"")
print(val if isinstance(val,str) else json.dumps(val))
PY
}

handle_file () {
  f="$1"
  cmd="$(parse_json cmd "$f" 2>/dev/null || printf '')"

  # Also allow { "cmd":"llama", "prompt":"...", "model":"..." }
  if [[ "$cmd" == "llama" ]]; then
    prompt="$(parse_json prompt "$f" || true)"
    model="$(parse_json model "$f" || true)"
    model="${model:-$MODEL_DEFAULT}"
    log "LLAMA: model=$model"
    MODEL="$model" "$LLAMA" "$prompt" >>"$LOG" 2>&1 || true

  elif [[ "$cmd" == "summarize clipboard" ]]; then
    log "Skill: summarize-clipboard"
    MODEL="$MODEL_DEFAULT" "$LLAMA" "Summarize my clipboard." >>"$LOG" 2>&1 || true

  elif [[ "$cmd" == note* ]]; then
    note="${cmd#note }"
    if [[ -x "$SKILLS/note-to-notion.sh" ]]; then
      STAMP="$(date +'%Y-%m-%d %H:%M:%S')" \
      "$SKILLS/note-to-notion.sh" "$note" >>"$LOG" 2>&1 || true
    else
      log "WARN: note-to-notion.sh missing or not executable"
    fi

  else
    log "WARN: unknown command in $(basename "$f"): '$cmd'"
  fi
}

log "dispatcher started (watching $INBOX)"
while true; do
  shopt -s nullglob
  for f in "$INBOX"/*.json; do
    log "processing $(basename "$f")"
    handle_file "$f"
    mv "$f" "$DONE/$(basename "$f")"
  done
  sleep 3
done
