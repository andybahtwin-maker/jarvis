#!/usr/bin/env bash
set -euo pipefail
# Generate an SSH key (skip if you already have one)
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -C "andy@jarvis" -N "" -f ~/.ssh/id_ed25519

# Start agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Show the public key for GitHub → Settings → SSH and GPG keys → New SSH key
echo "----- ADD THIS KEY TO GITHUB -----"
cat ~/.ssh/id_ed25519.pub
echo "----------------------------------"

# Test GitHub auth
ssh -T git@github.com || true