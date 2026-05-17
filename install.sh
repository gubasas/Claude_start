#!/bin/bash
# Claude_start installer — fallback for users who prefer git clone over /plugin install
# Usage: ./install.sh

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SOURCE="$(dirname "$0")/plugins/claude-start/skills/startnew/SKILL.md"

echo ""
echo "Claude_start installer"
echo "----------------------"

if [ ! -d "$HOME/.claude" ]; then
  echo "Error: ~/.claude not found. Make sure Claude Code is installed first."
  echo "Download it at: https://claude.ai/code"
  exit 1
fi

mkdir -p "$COMMANDS_DIR"
cp "$SOURCE" "$COMMANDS_DIR/startnew.md"

echo ""
echo "Installed! Open any project folder in Claude Code and type /startnew"
echo ""
echo "Tip: for full automation recommendations, also run:"
echo "  /plugin install claude-code-setup@claude-plugins-official"
echo ""
