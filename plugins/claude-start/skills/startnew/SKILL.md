---
name: startnew
description: Bootstrap a new project — creates CLAUDE.md, memory, settings, MCP servers, hooks, subagents, and slash commands automatically
allowed-tools: [Read, Write, Edit, Bash, WebFetch]
---

# Claude_start — New Project Bootstrap

You are the Claude_start setup assistant. Work through the steps below in order.

---

## Step 0 — Detect Existing Files

Before asking any questions, check for common project files that could pre-fill the answers:

```bash
ls -1 CLAUDE.md package.json README.md pyproject.toml Cargo.toml go.mod requirements.txt setup.py composer.json 2>/dev/null
```

- **No files found** → proceed directly to Step 1, asking all questions normally.
- **Files found** → tell the user which ones were found and ask:

  > "I found [file list]. Should I read them to pre-fill your project details? (yes/no)"

  - **Yes** → Read each found file with the Read tool. From the content, extract best-guess answers for questions 1–5 (name, type, stack, goal, common commands). Present them to the user:

    > "Here's what I gathered — let me know if anything needs adjusting:"
    > 1. Name: ...
    > 2. Type: ...
    > 3. Stack: ...
    > 4. Goal: ...
    > 5. Commands: ...

    If you couldn't determine a value, say "unclear — your input needed". Then ask question 6 (reference links) to complete the intake. Skip the rest of Step 1.

  - **No** → proceed to Step 1 normally.

---

## Step 1 — Gather Project Details

Ask the user the following questions **one at a time**, conversationally. Wait for each answer before asking the next.

1. **Project name** — What is this project called?
2. **Project type** — What kind of project is this? (web app, CLI tool, API/backend, data pipeline, mobile app, library, automation script, other)
3. **Tech stack** — What languages, frameworks, and key libraries? (rough is fine)
4. **Goal** — In one or two sentences, what does this project accomplish or solve?
5. **Common commands** — What shell commands will you run most? (e.g. `npm run dev`, `python app.py`, `make test`)
6. **Reference links** — Do you have any reference links to share? (docs, Figma, repos, API references — or "none" to skip)

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

{If reference links were provided in question 6:}
## Reference Links
{Bulleted list of all provided links, each on its own line as a markdown link if a title can be inferred, otherwise bare URL}

## Memory System

Project memory lives in `memory/` and uses two layers:

- **`memory/MEMORY.md`** — index file, always loaded. One-liner per topic. Never write detail here — pointers only.
- **`memory/{topic}.md`** — detail files, read on demand. Create one whenever you capture a decision, architectural constraint, discovered bug pattern, or context that would otherwise be lost.

**When to read:** Check `memory/MEMORY.md` before any non-trivial task. Open a detail file only when its topic is relevant.
**When to write:** A decision was made, a pattern was confirmed, a constraint was discovered. Lead with the fact; add **Why:** and **How to apply:** lines so future context survives time passing.
**When NOT to write:** Things derivable from the code, git history, or already in CLAUDE.md.
```

Omit the `## Reference Links` section entirely if the user answered "none" or provided no links.

---

## Step 3 — Create Two-Layer Memory and Project Config

### Memory — Layer 1: Index

**`memory/MEMORY.md`** — the index. Always loaded into context. One entry per topic, max ~150 chars per line. Must stay concise — entries after line 150 get truncated.

```markdown
# Memory Index

- [Project Overview](project.md) — {one-line summary: what the project is and its core goal}
```

### Memory — Layer 2: Detail Files

**`memory/project.md`** — first detail file, pre-populated from the Q&A answers:

```markdown
---
name: project-overview
description: Core project facts gathered at project setup
metadata:
  type: project
---

**Name:** {project name}
**Type:** {project type}
**Stack:** {tech stack}
**Goal:** {goal}
**Commands:** {common commands}
{If reference links were provided: **Reference links:** {list of links}}
```

### Memory Usage Rules (embed in CLAUDE.md — see Step 2)

Claude should follow these rules when working on this project:

- **Read MEMORY.md first** to see what memories exist before starting any non-trivial task.
- **Read a detail file** only when its topic is relevant to the current task — don't load everything upfront.
- **Write a new detail file** when capturing something that would otherwise be lost: a decision made, a pattern established, a bug root-caused, an architectural constraint discovered.
- **Update MEMORY.md** with a one-liner pointer every time a new detail file is created.
- **Never write memory content directly into MEMORY.md** — it's an index only.
- Detail files use this frontmatter format:

```markdown
---
name: {kebab-case-slug}
description: {one-line summary — used to decide relevance}
metadata:
  type: {project | decision | bug | feedback | reference}
---

{Detail content here. For decisions/bugs: lead with the fact, then **Why:** and **How to apply:** lines.}
```

### Project Config

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
cat ~/.claude/plugins/installed_plugins.json 2>/dev/null | grep -i "claude-code-setup" || echo "NOT_INSTALLED"
```

**Windows (PowerShell):**
```powershell
if (Get-Content "$HOME\.claude\plugins\installed_plugins.json" -ErrorAction SilentlyContinue | Select-String -Pattern "claude-code-setup") { "INSTALLED" } else { "NOT_INSTALLED" }
```

- **Installed** → tell the user "claude-code-setup found, running analysis..." and continue to Step 5.
- **Not installed** → tell the user:

  > "claude-code-setup isn't installed yet. Run `/plugin install claude-code-setup@claude-plugins-official` and then re-run `/startnew` to get tailored automation recommendations. Skipping to summary for now."

  Then jump directly to Step 7, skipping Steps 5 and 6.

---

## Step 5 — Fetch Reference Links and Run Analysis

### 5a — Classify Links

If the user provided reference links, do the following before fetching anything:

**Filter non-fetchable links.** Tools like Figma, Miro, Notion design pages, Google Slides, and Loom return little or no useful text when fetched. Silently skip these unless the user explicitly named them in a deep-dive request. If any are skipped, mention it briefly: "Skipping [Figma link] — design tool pages don't yield useful text."

**Show a cost explainer** for the remaining fetchable links:

> "Found {N} fetchable link(s). Before I fetch them, here's what each mode costs:
>
> - **Summary** (default) — a lightweight subagent fetches each page and returns a ~300-token digest. Low context cost, fast.
> - **Deep dive** — the full raw page is fetched and held in context (~10k–50k tokens per link). Use this when you want recommendations grounded in exact API schemas, config options, or full reference docs.
>
> Any links you'd like deep-dived? List them (by number or URL), or say "none"."

Split links into two lists based on the user's answer: **summary_links** and **deep_dive_links**.

---

### 5b — Fetch Links

**Summary links** — for each, spawn a subagent with this prompt:

> "Fetch [URL] and return a 200–300 word summary: what technology, tool, or API this page describes; its key concepts; and any patterns, constraints, or conventions a developer should know when setting up automation or tooling for a project using it. Ignore navigation, ads, and boilerplate."

Collect all summaries. They replace raw page content in your context — do not hold the full page yourself.

**Deep-dive links** — fetch each directly with WebFetch and hold the full content in context.

If there were no fetchable links (all skipped or user answered "none"), skip this section.

---

### 5c — Run Analysis

Tell the user: "Analyzing your project for tailored automation recommendations..."

Invoke the plugin with: "recommend automations for this project"

Use the link summaries and any deep-dive content to make recommendations more specific — e.g. if a fetched doc describes a particular API, suggest an MCP server or hook tailored to it.

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
```

---

## Step 8 — Final Summary

Print:

```
Claude_start complete ✓  {Project Name}

Created:
  CLAUDE.md
  memory/MEMORY.md       ← index (always loaded)
  memory/project.md      ← project overview detail (layer 2)
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
