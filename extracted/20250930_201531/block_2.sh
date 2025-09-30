bash <<'CHECK'
cd ~/Jarvis
echo "[files]"
ls -1 bin/jarvis_* fs/extract_code_blocks.py 2>/dev/null || true
echo
echo "[watcher log tail]"
tail -n 25 logs/watcher.out 2>/dev/null || echo "(no log yet)"
echo
echo "[latest results dir]"
ls -1 workspace/results | tail -n 1 | awk '{print "workspace/results/"$0}'
CHECK
