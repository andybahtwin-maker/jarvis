#!/usr/bin/env bash
set -euo pipefail

# --- block 1 (bash) ---
echo "first block" && mkdir -p ~/Jarvis/tmp_demo

# --- block 3 (bash) ---
cat <<'SH' > ~/Jarvis/tmp_demo/hello.sh
#!/usr/bin/env bash
echo "heredoc works!"
SH
chmod +x ~/Jarvis/tmp_demo/hello.sh
~/Jarvis/tmp_demo/hello.sh

python3 /home/andhe001/Jarvis/workspace/journals/block_20251001_133528_2.py
