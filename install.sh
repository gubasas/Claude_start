#!/bin/bash
# Claude_start installer — safe to re-run at any time to update to the latest version
# Installs /startnew and /startupdate globally, caches hook scripts, and checks the claude-code-setup plugin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"
HOOKS_CACHE="$HOME/.claude/claude-start/hooks"
SOURCE="$SCRIPT_DIR/plugins/claude-start/skills/startnew/SKILL.md"
HOOKS_SRC="$SCRIPT_DIR/plugins/claude-start/hooks"

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

# Install the /startupdate command (if it exists)
STARTUPDATE_SRC="$SCRIPT_DIR/plugins/claude-start/skills/startupdate/SKILL.md"
if [ -f "$STARTUPDATE_SRC" ]; then
  cp "$STARTUPDATE_SRC" "$COMMANDS_DIR/startupdate.md"
  echo "✓ /startupdate command installed"
fi

# Cache hook scripts so /startupdate can refresh existing projects
mkdir -p "$HOOKS_CACHE"
cp "$HOOKS_SRC/memory-signal.sh" "$HOOKS_CACHE/memory-signal.sh"
cp "$HOOKS_SRC/memory-consolidate.sh" "$HOOKS_CACHE/memory-consolidate.sh"
chmod +x "$HOOKS_CACHE/memory-signal.sh" "$HOOKS_CACHE/memory-consolidate.sh"
echo "✓ Hook scripts cached at ~/.claude/claude-start/hooks"
echo "  → Run /startupdate in any existing project to refresh its hooks."

# Check if claude-code-setup plugin is already installed
PLUGIN_INSTALLED=$(cat ~/.claude/plugins/installed_plugins.json 2>/dev/null | grep -i "claude-code-setup" || echo "")

if [ -n "$PLUGIN_INSTALLED" ]; then
  echo "✓ claude-code-setup plugin already installed"
  echo ""
  echo "Installed. /startnew is now available in any Claude Code session (terminal, VS Code, or the Claude desktop app's Code mode)."
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
