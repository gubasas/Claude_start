# Claude_start

A one-command project bootstrap for Claude Code. Run `/startnew` in any new project folder and it sets everything up automatically — CLAUDE.md, memory, MCP servers, hooks, subagents, and slash commands.

## Option 1 — Install via Claude Code (recommended)

Add Claude_start as a custom plugin marketplace, then install:

```
/plugin marketplace add gubasas github:gubasas/Claude_start
/plugin install claude-start@gubasas
```

No terminal needed. Works on Mac, Linux, and Windows.

## Option 2 — Install via script (fallback)

**Mac / Linux**
```bash
git clone https://github.com/gubasas/Claude_start.git
cd Claude_start
./install.sh
```

**Windows (PowerShell)**
```powershell
git clone https://github.com/gubasas/Claude_start.git
cd Claude_start
.\install.ps1
```

## Prerequisite

For full automation recommendations, install the official `claude-code-setup` plugin once:

```
/plugin install claude-code-setup@claude-plugins-official
```

`/startnew` will remind you if it's missing.

## Usage

Open any new project folder in Claude Code and type:

```
/startnew
```
