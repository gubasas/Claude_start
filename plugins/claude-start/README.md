# claude-start

One-command project bootstrap for Claude Code.

Run `/startnew` in any new project folder and it will:

- Ask 5 quick questions about your project
- Write a tailored `CLAUDE.md`
- Create `memory/MEMORY.md` for persistent project memory
- Set up `.claude/settings.json` with stack-appropriate permissions
- Run `claude-code-setup` analysis and apply all recommendations (MCP servers, hooks, subagents, slash commands)

## Install

See the [main README](../../README.md) for installation instructions.

## Prerequisite

This plugin works best with `claude-code-setup` installed:

```
/plugin install claude-code-setup@claude-plugins-official
```

If it's not installed, `/startnew` will still set up CLAUDE.md and memory — you'll just miss the automation recommendations.

## Usage

Open any new project folder in Claude Code and type:

```
/startnew
```
