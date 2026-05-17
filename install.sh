#!/bin/bash
# Claude_start installer
# Installs /startnew globally and opens Claude Code to install the claude-code-setup plugin

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SOURCE="$(dirname "$0")/plugins/claude-start/skills/startnew/SKILL.md"

echo ""
echo "Claude_start installer"
echo "----------------------"

# Check Claude Code is installed
if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' command not found. Make sure Claude Code CLI is installed."
  echo "Download it at: https://claude.ai/code"
  exit 1
fi

if [ ! -d "$HOME/.claude" ]; then
  echo "Error: ~/.claude not found. Make sure Claude Code is installed first."
  exit 1
fi

# Install the /startnew command
mkdir -p "$COMMANDS_DIR"
cp "$SOURCE" "$COMMANDS_DIR/startnew.md"
echo "✓ /startnew command installed"

# Check if claude-code-setup plugin is already installed
PLUGIN_INSTALLED=$(cat ~/.claude/plugins/installed_plugins.json 2>/dev/null | grep -i "claude-code-setup" || echo "")

if [ -n "$PLUGIN_INSTALLED" ]; then
  echo "✓ claude-code-setup plugin already installed"
  echo ""
  echo "All done! Open any project folder in Claude Code and type /startnew"
else
  echo ""
  echo "One more step: installing the claude-code-setup plugin."
  echo "Claude Code is opening now — run this command when it loads:"
  echo ""
  echo "  /plugin install claude-code-setup@claude-plugins-official"
  echo ""
  echo "Then type /exit and open your project in VS Code."
  echo ""
  read -p "Press Enter to open Claude Code..."
  claude
fi
