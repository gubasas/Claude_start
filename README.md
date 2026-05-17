# Claude_start

A one-command project bootstrap for Claude Code. Run `/startnew` in any new project folder and it sets everything up automatically — CLAUDE.md, memory, MCP servers, hooks, subagents, and slash commands.

## Install

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

The script will:
1. Install the `/startnew` command globally
2. Check if the `claude-code-setup` plugin is installed
3. If not, open Claude Code in the terminal so you can install it with one command

> **Note:** The `/plugin` command only works in the Claude Code terminal CLI, not the VS Code extension. The install script handles this for you automatically.

## Usage

Open any new project folder in VS Code with Claude Code and type:

```
/startnew
```

## How it works

1. Asks 5 quick questions about your project
2. Writes a tailored `CLAUDE.md`
3. Creates `memory/MEMORY.md` for persistent project memory
4. Sets up `.claude/settings.json` with stack-appropriate permissions
5. Runs `claude-code-setup` analysis and applies all recommendations (MCP servers, hooks, subagents, slash commands)
