---
name: startnew
description: Bootstrap a new project — creates CLAUDE.md, memory, settings, MCP servers, hooks, subagents, and slash commands automatically
allowed-tools: [Read, Write, Edit, Bash]
---

# Claude_start — New Project Bootstrap

You are the Claude_start setup assistant. Work through the steps below in order.

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

## Step 4 — Check for claude-code-setup Plugin

Detect the OS first:

**Mac/Linux:**
```bash
uname -s
```

**Then check if the plugin is installed:**

**Mac/Linux:**
```bash
ls ~/.claude/plugins/ 2>/dev/null | grep -i "claude-code-setup" || echo "NOT_INSTALLED"
```

**Windows (PowerShell):**
```powershell
if (Get-ChildItem "$HOME\.claude\plugins\" -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "claude-code-setup" }) { "INSTALLED" } else { "NOT_INSTALLED" }
```

- **Installed** → tell the user "claude-code-setup found, running analysis..." and continue to Step 5.
- **Not installed** → tell the user:

  > "claude-code-setup isn't installed yet. Run `/plugin install claude-code-setup@claude-plugins-official` and then re-run `/startnew` to get tailored automation recommendations. Skipping to summary for now."

  Then jump directly to Step 7, skipping Steps 5 and 6.

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
- On Mac/Linux: `chmod +x .claude/hooks/{hook-name}.sh`
- Register in `.claude/settings.json` under `"hooks"`

### Subagents
Create `.claude/agents/{agent-name}.md` with YAML frontmatter and system prompt following the Claude Code agent file format.

### Slash Commands
Create `.claude/commands/{command-name}.md` with the recommended content.

### Skills / Other
Apply any remaining recommendations appropriately.

---

## Step 7 — Update CLAUDE.md

Append to `CLAUDE.md`:

```markdown
## Claude Code Setup

### Installed Automations
{Bulleted list of every MCP server, hook, subagent, and slash command that was created — or "Run /startnew again after installing claude-code-setup to get automation recommendations." if the plugin was missing}

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

MCP servers:    {list or none}
Hooks:          {list or none}
Subagents:      {list or none}
Slash commands: {list or none}

{If claude-code-setup was missing}
Next: install claude-code-setup with /plugin install claude-code-setup@claude-plugins-official
      then re-run /startnew to apply automation recommendations.
```

End with: "You're all set. I'll keep `memory/MEMORY.md` updated as we work. Run `/startnew` anytime in a new project folder."
