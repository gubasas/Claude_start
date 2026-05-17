# Claude_start — New Project Bootstrap

You are the Claude_start setup assistant. Work through the steps below in order.

---

## Step 0 — First Time Setup (runs once per machine)

First, detect the operating system by running:

```bash
uname -s 2>/dev/null || echo "Windows"
```

Use this to determine whether to use Unix or Windows shell syntax for all subsequent commands in this flow. On Windows, use PowerShell syntax; on Mac/Linux, use bash syntax. The home directory is `~` on Mac/Linux and `$HOME` or `$env:USERPROFILE` on Windows.

Check if this is the first time Claude_start has been configured:

**Mac/Linux:**
```bash
cat ~/.claude/.claudestart_configured 2>/dev/null || echo "NOT_CONFIGURED"
```

**Windows (PowerShell):**
```powershell
if (Test-Path "$HOME\.claude\.claudestart_configured") { Get-Content "$HOME\.claude\.claudestart_configured" } else { "NOT_CONFIGURED" }
```

### If NOT_CONFIGURED:

Welcome the user warmly — they've just installed Claude_start. Tell them:

> "Welcome to Claude_start! Before we set up your first project, let's configure your global command name. You'll use this command every time you start a new project in Claude Code."

Ask: **"What do you want to name your project-start command?"**

Give three suggested options and let them pick or type their own:
- `startnew` (default)
- `setup`
- `bootstrap`

Once they choose a name (call it `{cmd}`):

1. Copy the current command file to `~/.claude/commands/{cmd}.md` (Mac/Linux) or `$HOME\.claude\commands\{cmd}.md` (Windows)
2. Write the marker file with `cmd={cmd}` to `~/.claude/.claudestart_configured` (Mac/Linux) or `$HOME\.claude\.claudestart_configured` (Windows)
3. Tell them: "Done! From now on, type `/{cmd}` in any new project folder to run the full setup. Continuing with your first project now..."

### If already configured:

Read the configured command name from the marker file and proceed silently to Step 1.

---

## Step 1 — Gather Project Details

Ask the user the following questions **one at a time**, conversationally. Wait for each answer before asking the next.

1. **Project name** — What is this project called?
2. **Project type** — What kind of project is this? (web app, CLI tool, API/backend, data pipeline, mobile app, library, automation script, other)
3. **Tech stack** — What languages, frameworks, and key libraries? (rough is fine)
4. **Goal** — In one or two sentences, what does this project accomplish or solve?
5. **Common commands** — What shell commands will you run most? (e.g. `npm run dev`, `python app.py`, `make test`)

Confirm answers back briefly and move on — note "let me know if you want to adjust anything" and continue.

---

## Step 2 — Write CLAUDE.md

Write `CLAUDE.md` in the current working directory:

```markdown
# {Project Name}

## Project Overview
{One paragraph from answers to questions 1, 2, 4}

## Tech Stack
{Bulleted list from question 3}

## Project Goals
{2–4 concrete goals inferred from the description}

## Development Commands
{Code block of commands from question 5, one label per line}

## Code Conventions
To be defined — update this as the project matures.

## Architecture Notes
To be filled in as the architecture takes shape.
```

---

## Step 3 — Create Memory Structure and Project Config

**`memory/MEMORY.md`**:
```markdown
# Memory Index

_No memories yet. Claude will populate this as the project evolves._
```

**`.claude/settings.json`** with stack-appropriate permissions:
```json
{
  "permissions": {
    "allow": []
  }
}
```

Add allow rules based on what the user mentioned in question 5:
- npm/npx → `"Bash(npm run *)"`, `"Bash(npm install *)"`, `"Bash(npx *)"`
- pip/python → `"Bash(pip install *)"`, `"Bash(python3 *)"`
- go → `"Bash(go run *)"`, `"Bash(go test *)"`, `"Bash(go build *)"`
- cargo → `"Bash(cargo run *)"`, `"Bash(cargo test *)"`, `"Bash(cargo build *)"`
- make → `"Bash(make *)"`

Only add rules for tools the user actually mentioned.

---

## Step 4 — Check and Install claude-code-setup Plugin

Check if the plugin is installed using the appropriate command for the detected OS:

**Mac/Linux:**
```bash
ls ~/.claude/plugins/ 2>/dev/null | grep -i "claude-code-setup" || echo "NOT_INSTALLED"
```

**Windows (PowerShell):**
```powershell
if (Get-ChildItem "$HOME\.claude\plugins\" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "claude-code-setup" }) { "INSTALLED" } else { "NOT_INSTALLED" }
```

- Found → tell user "claude-code-setup already installed, running analysis..."
- NOT_INSTALLED → tell user "Installing claude-code-setup..." then run `/plugin install claude-code-setup@claude-plugins-official`

---

## Step 5 — Run Analysis

Tell the user: "Analyzing your project for tailored automation recommendations..."

Invoke the plugin with: "recommend automations for this project"

Collect all recommendations grouped by: MCP servers, Skills, Hooks, Subagents, Slash commands.

---

## Step 6 — Execute All Recommendations

**Execute everything automatically.** Do not ask for approval per-item.

### MCP Servers
Add each to `.claude/settings.json` under `"mcpServers"` with the correct config.

### Hooks
- Create hook script at `.claude/hooks/{hook-name}.sh` (Mac/Linux) or `.claude/hooks/{hook-name}.ps1` (Windows)
- On Mac/Linux only: make it executable with `chmod +x .claude/hooks/{hook-name}.sh`
- Register in `.claude/settings.json` under `"hooks"`

### Subagents
- Create `.claude/agents/{agent-name}.md` with YAML frontmatter and system prompt following Claude Code agent file format

### Slash Commands
- Create `.claude/commands/{command-name}.md` with the recommended content

### Skills / Other
Apply any remaining recommendations appropriately.

---

## Step 7 — Update CLAUDE.md

Append to `CLAUDE.md`:

```markdown
## Claude Code Setup

### Installed Automations
{Bulleted list of every MCP server, hook, subagent, and slash command that was created}

### Memory
Project memory lives in `memory/MEMORY.md`. Claude will populate it as the project evolves.
```

---

## Step 8 — Final Summary

Print:

```
Claude_start complete ✓  {Project Name}

Created:
  CLAUDE.md
  memory/MEMORY.md
  .claude/settings.json
  {any additional files}

Plugin:
  claude-code-setup — {installed / already installed}

MCP servers:    {list or none}
Hooks:          {list or none}
Subagents:      {list or none}
Slash commands: {list or none}
```

End with: "You're all set. I'll keep `memory/MEMORY.md` updated as we work. Run `/{cmd}` anytime in a new project folder."
