#!/bin/bash
# Claude_start installer
# Copies the startnew command to ~/.claude/commands/ so it's available globally in Claude Code

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SOURCE="$(dirname "$0")/startnew.md"

echo ""
echo "Claude_start installer"
echo "----------------------"

# Check Claude Code is installed
if [ ! -d "$HOME/.claude" ]; then
  echo "Error: ~/.claude not found. Make sure Claude Code is installed first."
  echo "Download it at: https://claude.ai/code"
  exit 1
fi

# Create commands dir if needed
mkdir -p "$COMMANDS_DIR"

# Copy the command file
cp "$SOURCE" "$COMMANDS_DIR/startnew.md"

echo ""
echo "Installed! Open any project folder in Claude Code and type /startnew"
echo "On your first run, you'll be asked to choose your preferred command name."
echo ""
