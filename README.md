# 🎇 Jarvis

Jarvis is a **lightweight AI + automation framework** that runs directly in your terminal — acting as your personal AI assistant that **executes**, **logs**, and **syncs** your automation tasks.

It bridges **ChatGPT (or any LLM)** with your **local environment**, so when you paste an AI-generated command or code block, Jarvis:
- Extracts the code or command
- Runs it safely in your environment
- Captures logs and results
- Snapshots output files
- Automatically syncs everything to GitHub

---

## 🚀 Quick Overview

```plain text
Jarvis is not just a shell.
It’s an AI-driven dispatcher that runs your code, logs results, and keeps your repo clean.

Think of it as a local workflow engine for AI-powered automation.
📁 Project Structure

Jarvis/
├── README.md                  # Documentation (this file)
├── .gitignore                 # Ignore results, caches, artifacts
├── setup_git.sh               # Initialize Git + remote connection
├── jarvis_watcher.sh          # Inbox watcher & executor loop
├── jarvis_cmd_processor.py    # Core parsing and dispatch engine
├── bin/                       # CLI entrypoints and utilities
│   ├── jarvis                 # Main dispatcher CLI
│   ├── jarvis-dispatcher.sh   # Command dispatcher
│   ├── jarvis-log             # Logging helper
│   ├── jarvis-env             # Environment loader
│   ├── jarvis-secret          # Secret management helper
│   ├── jarvis_llama.sh        # Ollama / local LLM integration
│   └── process_incoming.sh    # Inbox → results pipeline
├── skills/                    # Drop-in “skills” (modular automations)
│   ├── note-to-notion         # Push notes to Notion
│   └── summarize-clipboard    # Summarize clipboard content
├── fs/                        # Filesystem utilities
│   └── inventory.py
└── logs/                      # Auto-generated run logs

⚙️ Installation

    Clone the repo:

git clone https://github.com/your-username/jarvis.git
cd jarvis

Run setup:

chmod +x setup_git.sh
./setup_git.sh

Grant permissions for scripts:

chmod +x bin/*

Start the watcher:

    ./jarvis_watcher.sh

🧠 How It Works

    Input detection — Jarvis watches your “inbox” (clipboard, text file, or stdin).

    Command parsing — jarvis_cmd_processor.py detects runnable snippets.

    Execution sandbox — Commands are executed with isolated environment handling.

    Logging — Output and errors are logged and versioned.

    Syncing — Commits are pushed automatically to GitHub or Notion.

🪄 Extending Jarvis

To add your own automation:

    Create a new skill in skills/

skills/my-new-skill/

Add an executable file or script:

skills/my-new-skill/run.sh

Register it by editing:

    bin/jarvis-dispatcher.sh

Example:

case "$command" in
  "my-new-skill")
    ./skills/my-new-skill/run.sh "$@"
    ;;
esac

🧩 Integrations

    Ollama / LLaMA models via jarvis_llama.sh

    Notion API for notes and summaries

    GitHub Sync for logging and repo backup

    Clipboard automation for quick local actions

🧰 Example Usage

# Run Jarvis watcher (passive mode)
./jarvis_watcher.sh

# Or run a command directly
jarvis "summarize clipboard"

# Push notes to Notion
jarvis "note-to-notion"

🧑‍💻 Development Notes

    Language: Bash + Python 3.11+

    Optional: Ollama / local LLM backends

    Logging: All runs timestamped to /logs

    Safety: Executes in isolated env with rollback support

🗂️ License

MIT License — free to modify, extend, and deploy.
🔗 Links

    Notion Page

Coinbase Pipeline (Related Project)
