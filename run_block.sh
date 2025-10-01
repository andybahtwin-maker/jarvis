#!/usr/bin/env bash
set -euo pipefail
# Ensure we have *something* to commit (safe no-op if README exists)
[ -f ~/Jarvis/workspace/README.md ] || cat > ~/Jarvis/workspace/README.md <<'MD'
# Jarvis Workspace
Automated by Jarvis (hands-off). This workspace mirrors what I paste into the terminal.
MD

# If your script is present, use it; otherwise inline the same logic.
if [ -x ~/Jarvis/workspace/setup_git.sh ]; then
  bash ~/Jarvis/workspace/setup_git.sh
else
  cd ~/Jarvis/workspace
  git init
  git branch -M main
  git remote remove origin 2>/dev/null || true
  git remote add origin git@github.com:andybahtwin-maker/jarvis.git
  grep -q '^\.env$' .gitignore || cat <<GI >> .gitignore
.env
.env.*
!.env.example
GI
  git add .
  git commit -m "Jarvis workspace init/update" || true
  git push -u origin main
fi

# Friendly summary
echo "[OK] Pushed ~/Jarvis/workspace → github.com/andybahtwin-maker/jarvis (branch: main)"