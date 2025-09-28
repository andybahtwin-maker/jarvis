#!/usr/bin/env bash
set -euo pipefail
OUT="$HOME/Jarvis/workspace/results/llama_status.txt"
LOG="$HOME/Jarvis/workspace/results/last_run.txt"

say(){ printf "%s\n" "$*" | tee -a "$OUT" >/dev/null; }

: > "$OUT"
say "===== LLAMA STATUS @ $(date -Iseconds) ====="
say "uname  : $(uname -a)"
say "whoami : $(whoami)"
say ""

# 1) OLLAMA path (most common)
if command -v ollama >/dev/null 2>&1; then
  say "[ollama] found at: $(command -v ollama)"
  say "[ollama] version : $(ollama --version 2>&1)"
  say ""
  # daemon status (systemd-based installs)
  if systemctl --user status ollama.service >/dev/null 2>&1; then
    say "[ollama] systemd user service is present:"
    systemctl --user --no-pager --full status ollama.service | sed -n '1,12p' >> "$OUT" || true
  elif systemctl status ollama >/dev/null 2>&1; then
    say "[ollama] system service is present:"
    systemctl --no-pager --full status ollama | sed -n '1,12p' >> "$OUT" || true
  else
    say "[ollama] systemd service not detected (might run on-demand)."
  fi
  say ""
  say "[ollama] installed models:"
  ollama list 2>&1 | tee -a "$OUT" || say "(ollama list failed)"
  say ""
  # quick one-line test if a small model exists
  TEST_MODEL="$(ollama list 2>/dev/null | awk 'NR==2{print $1}')"
  if [ -n "${TEST_MODEL:-}" ]; then
    say "[ollama] smoke test with: $TEST_MODEL"
    ollama run "$TEST_MODEL" 'Say: LLAMA OK (one line).' 2>&1 | sed -n '1,3p' | tee -a "$OUT" || true
  else
    say "[ollama] no local models yet (pull one to test, e.g. `ollama pull llama3:8b`)."
  fi
  say ""
fi

# 2) llama.cpp (cli binaries like main/llama-cli)
CANDIDATES=( "$HOME/llama.cpp/main" "$HOME/llama.cpp/build/bin/main" "$(command -v llama-cli || true)" )
LLAMACPP=""
for c in "${CANDIDATES[@]}"; do
  [ -x "$c" ] && LLAMACPP="$c" && break
done
if [ -n "$LLAMACPP" ]; then
  say "[llama.cpp] binary: $LLAMACPP"
  say "[llama.cpp] version banner:"
  "$LLAMACPP" -h 2>&1 | sed -n '1,3p' | tee -a "$OUT" || true
  say ""
  # find a gguf model
  MODEL="$(find "$HOME/llama.cpp" "$HOME/models" -maxdepth 3 -type f -name "*.gguf" 2>/dev/null | head -n 1 || true)"
  if [ -n "${MODEL:-}" ]; then
    say "[llama.cpp] model gguf: $MODEL"
    say "[llama.cpp] smoke test prompt (first lines):"
    "$LLAMACPP" -m "$MODEL" -p "Say: LLAMA CPP OK (one line)." -n 32 2>&1 | sed -n '1,4p' | tee -a "$OUT" || true
  else
    say "[llama.cpp] no .gguf model found under ~/llama.cpp or ~/models."
  fi
  say ""
fi

# 3) Summary / hints
if ! command -v ollama >/dev/null 2>&1 && [ -z "${LLAMACPP:-}" ]; then
  say "No LLAMA runtime detected (ollama or llama.cpp)."
fi

echo "[llama-check] wrote $OUT" >> "$LOG"
