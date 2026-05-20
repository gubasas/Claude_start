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

# Version-safe command update — refuse to downgrade
version_of() {
  grep -m1 '^version:' "$1" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0"
}

version_gt() {
  # Returns true if $1 > $2 (simple semver comparison via sort -V)
  [ "$(printf '%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ] && [ "$1" != "$2" ]
}

install_command() {
  local src="$1" dest="$2" label="$3"
  local repo_ver installed_ver
  repo_ver=$(version_of "$src")
  installed_ver=$(version_of "$dest" 2>/dev/null || echo "0.0.0")
  if [ -f "$dest" ] && ! version_gt "$repo_ver" "$installed_ver"; then
    echo "⚠ $label skipped — installed version ($installed_ver) is same or newer than repo ($repo_ver)"
    return
  fi
  cp "$src" "$dest"
  echo "✓ $label updated  ($installed_ver → $repo_ver)"
}

install_command "plugins/claude-start/skills/startnew/SKILL.md" "$COMMANDS_DIR/startnew.md" "/startnew"

STARTUPDATE_SRC="$SCRIPT_DIR/plugins/claude-start/skills/startupdate/SKILL.md"
if [ -f "$STARTUPDATE_SRC" ]; then
  install_command "$STARTUPDATE_SRC" "$COMMANDS_DIR/startupdate.md" "/startupdate"
fi

# Refresh hook cache — /startupdate reads from here to patch existing projects
mkdir -p "$HOOKS_CACHE"
cp "$HOOKS_SRC/memory-signal.sh" "$HOOKS_CACHE/memory-signal.sh"
cp "$HOOKS_SRC/memory-consolidate.sh" "$HOOKS_CACHE/memory-consolidate.sh"
cp "$HOOKS_SRC/memory-signal.ps1" "$HOOKS_CACHE/memory-signal.ps1"
cp "$HOOKS_SRC/memory-consolidate.ps1" "$HOOKS_CACHE/memory-consolidate.ps1"
chmod +x "$HOOKS_CACHE/memory-signal.sh" "$HOOKS_CACHE/memory-consolidate.sh"
echo "✓ Hook cache refreshed at ~/.claude/claude-start/hooks"
echo ""
echo "Run /startupdate in any existing project to apply the latest hooks."
echo ""
