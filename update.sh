#!/bin/bash
# Claude_start updater — pulls latest changes and refreshes the global command

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(dirname "$0")"

echo ""
echo "Claude_start updater"
echo "--------------------"

# Pull latest
cd "$SCRIPT_DIR"
git pull

# Refresh global command
cp plugins/claude-start/skills/startnew/SKILL.md "$COMMANDS_DIR/startnew.md"
echo "✓ /startnew updated to latest version"
echo ""
