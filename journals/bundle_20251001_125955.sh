#!/usr/bin/env bash
set -euo pipefail

# --- bash block 1 ---
echo "first block" && mkdir -p ~/Jarvis/tmp_demo

# --- bash block 2 ---
cat <<'SH' > ~/Jarvis/tmp_demo/hello.sh
#!/usr/bin/env bash
echo "heredoc works!"
SH
chmod +x ~/Jarvis/tmp_demo/hello.sh
~/Jarvis/tmp_demo/hello.sh

