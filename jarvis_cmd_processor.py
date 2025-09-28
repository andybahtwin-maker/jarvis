#!/usr/bin/env python3
import json, sys, os, datetime, shutil

ROOT      = os.path.expanduser("~/Jarvis/workspace")
INBOX     = os.path.join(ROOT, "inbox")
RESULTS   = os.path.join(ROOT, "results")
JOURNALS  = os.path.join(ROOT, "journals")
PROCESSED = os.path.join(ROOT, "processed")
for d in (RESULTS, JOURNALS, PROCESSED): os.makedirs(d, exist_ok=True)

def log(msg):
    stamp = datetime.datetime.now().strftime("%F %T %z")
    with open(os.path.join(RESULTS, "last_run.txt"), "a") as f:
        f.write(f"[{stamp}] {msg}\n")

def handle_journal_now(payload: dict):
    today = datetime.date.today().isoformat()
    path = os.path.join(JOURNALS, f"{today}.md")
    with open(path, "a", encoding="utf-8") as f:
        f.write(f"\n## Journal entry {datetime.datetime.now().isoformat()}\n\n")
        text = payload.get("text")
        if text: f.write(text.strip()+"\n")
    log(f"journal-now → {path}")

def main():
    if len(sys.argv) < 2:
        log("error: no cmd file provided")
        sys.exit(1)
    cmd_path = sys.argv[1]
    with open(cmd_path, encoding="utf-8") as f:
        data = json.load(f)

    cmd = data.get("cmd")
    if cmd == "journal-now":
        handle_journal_now(data)
    else:
        log(f"unhandled cmd: {data}")

    # archive the consumed command
    base = os.path.basename(cmd_path)
    dest = os.path.join(PROCESSED, f"{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}_{base}")
    try:
        shutil.move(cmd_path, dest)
        log(f"archived {base} → processed/")
    except Exception as e:
        log(f"archive failed for {base}: {e}")

if __name__ == "__main__":
    main()
