#!/bin/bash
# Claude_start updater — pulls latest changes and refreshes the global command and hook cache

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$HOME/.claude/commands"
HOOKS_CACHE="$HOME/.claude/claude-start/hooks"
HOOKS_SRC="$SCRIPT_DIR/plugins/claude-start/hooks"

echo ""
echo "Claude_start updater"
echo "--------------------"

# Pull latest
cd "$SCRIPT_DIR"
git pull

# Refresh global commands
cp plugins/claude-start/skills/startnew/SKILL.md "$COMMANDS_DIR/startnew.md"
echo "✓ /startnew updated to latest version"

STARTUPDATE_SRC="$SCRIPT_DIR/plugins/claude-start/skills/startupdate/SKILL.md"
if [ -f "$STARTUPDATE_SRC" ]; then
  cp "$STARTUPDATE_SRC" "$COMMANDS_DIR/startupdate.md"
  echo "✓ /startupdate updated to latest version"
fi

# Refresh hook cache — /startupdate reads from here to patch existing projects
mkdir -p "$HOOKS_CACHE"
cp "$HOOKS_SRC/memory-signal.sh" "$HOOKS_CACHE/memory-signal.sh"
cp "$HOOKS_SRC/memory-consolidate.sh" "$HOOKS_CACHE/memory-consolidate.sh"
chmod +x "$HOOKS_CACHE/memory-signal.sh" "$HOOKS_CACHE/memory-consolidate.sh"
echo "✓ Hook cache refreshed at ~/.claude/claude-start/hooks"
echo ""
echo "Run /startupdate in any existing project to apply the latest hooks."
echo ""
