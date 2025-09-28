#!/usr/bin/env python3
import json, sys, os, datetime

INBOX = os.path.expanduser("~/Jarvis/workspace/inbox")
RESULTS = os.path.expanduser("~/Jarvis/workspace/results")
JOURNALS = os.path.expanduser("~/Jarvis/workspace/journals")

os.makedirs(RESULTS, exist_ok=True)
os.makedirs(JOURNALS, exist_ok=True)

def log(msg):
    stamp = datetime.datetime.now().strftime("%F %T %z")
    with open(os.path.join(RESULTS, "last_run.txt"), "a") as f:
        f.write(f"[{stamp}] {msg}\n")
    print(msg)

def handle_journal_now():
    today = datetime.date.today().isoformat()
    path = os.path.join(JOURNALS, f"{today}.md")
    with open(path, "a") as f:
        f.write(f"\n## Journal entry {datetime.datetime.now().isoformat()}\n\n")
    log(f"journal-now → appended to {path}")

def main():
    if len(sys.argv) < 2:
        sys.exit("Usage: jarvis_cmd_processor.py <cmd.json>")
    with open(sys.argv[1]) as f:
        cmd = json.load(f)

    if cmd.get("cmd") == "journal-now":
        handle_journal_now()
    else:
        log(f"unhandled cmd: {cmd}")

if __name__ == "__main__":
    main()
