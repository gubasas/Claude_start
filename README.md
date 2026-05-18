# Claude_start

One command to set up Claude Code properly for any new project — memory, config, automations, all of it.

Works in Claude Code anywhere it runs — terminal, VS Code, and the Claude desktop app's Code mode. The one-time plugin install step needs the terminal CLI (the script handles this for you). Run `/startnew` in any new project folder and it sets up everything automatically — CLAUDE.md, a two-layer memory system, project config, MCP servers, hooks, subagents, and slash commands.

---

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

The script installs `/startnew` globally and checks whether the `claude-code-setup` plugin is installed. If it isn't, it opens Claude Code in the terminal so you can install it with one command before continuing.

> **VS Code users:** The `/plugin` command only works in the Claude Code terminal CLI, not the VS Code extension. The install script handles this step for you automatically.

---

## Prerequisite

For full automation recommendations, install the official `claude-code-setup` plugin once via the Claude Code terminal CLI:

```
/plugin install claude-code-setup@claude-plugins-official
```

`/startnew` will remind you if it's missing and still complete the rest of the setup without it.

---

## Usage

Open any new project folder in Claude Code and type:

```
/startnew
```

---

## What it does — step by step

### Step 0 — Smart file detection

Before asking any questions, `/startnew` scans for existing project files (`package.json`, `README.md`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `requirements.txt`, etc.). If found, it offers to read them and pre-fill your project details automatically — so you only need to confirm or correct instead of typing everything from scratch.

### Step 1 — Project intake (6 questions)

If no files were detected (or you chose to answer manually), it asks six questions one at a time:

1. **Project name**
2. **Project type** — web app, CLI, API, data pipeline, mobile app, library, automation script, etc.
3. **Tech stack** — languages, frameworks, key libraries
4. **Goal** — one or two sentences on what the project accomplishes
5. **Common shell commands** — what you'll run most (`npm run dev`, `python app.py`, `make test`, etc.)
6. **Reference links** — docs, Figma, repos, API references (or "none" to skip)

### Step 2 — CLAUDE.md

Writes a tailored `CLAUDE.md` with: project overview, tech stack, goals, development commands, code conventions placeholder, architecture notes placeholder, and (if provided) a reference links section. It also embeds the memory usage rules so Claude knows exactly how to use the memory system going forward.

### Step 3 — Two-layer memory system

Creates a `memory/` folder with two layers:

- **`memory/MEMORY.md`** — the index. Always loaded into context. One-liner per topic, pointers only — never detail. Stays concise so it never gets truncated.
- **`memory/project.md`** — the first detail file, pre-populated with everything from the intake. Future detail files are created here as the project evolves (decisions made, bugs root-caused, patterns established, constraints discovered).

Also creates **`.claude/settings.json`** with stack-appropriate permissions pre-filled based on your answer to question 5 (npm, pip, go, cargo, make, etc.).

### Step 4 — Plugin check

Checks `installed_plugins.json` to see if `claude-code-setup` is installed. If missing, it tells you what to run and skips straight to the summary — the rest of the setup (CLAUDE.md, memory, config) is still complete.

### Step 5 — Reference link fetching and analysis

If you provided reference links:

- **Non-fetchable links** (Figma, Miro, Notion design pages, Loom, Google Slides) are filtered out automatically and skipped with a brief note.
- For the remaining links, you choose per-link: **summary mode** (a lightweight subagent fetches each page and returns a ~300-word digest, low context cost) or **deep-dive mode** (full page content held in context — useful for API references or config docs you want recommendations grounded in).

Then runs `claude-code-setup` analysis, using the fetched content to make recommendations more specific to your actual stack and references.

### Step 6 — Execute all recommendations

Applies every recommendation from `claude-code-setup` automatically:

| Category | What gets created |
|---|---|
| **MCP servers** | Added to `.claude/settings.json` under `"mcpServers"` |
| **Hooks** | Script created at `.claude/hooks/` (`.sh` on Mac/Linux, `.ps1` on Windows), registered in settings |
| **Subagents** | Agent file created at `.claude/agents/{name}.md` with YAML frontmatter |
| **Slash commands** | Command file created at `.claude/commands/{name}.md` |

No approval step — everything runs automatically.

### Step 7 & 8 — Final update and summary

Appends a `## Claude Code Setup` section to `CLAUDE.md` listing every automation that was installed, then prints a full summary of every file created and every automation applied.

---

## Files created per project

```
{project-root}/
  CLAUDE.md                          ← tailored project context for Claude
  memory/
    MEMORY.md                        ← memory index (always loaded)
    project.md                       ← project overview detail file
  .claude/
    settings.json                    ← permissions + MCP server config
    hooks/{hook-name}.sh             ← hook scripts (if recommended)
    agents/{agent-name}.md           ← subagent definitions (if recommended)
    commands/{command-name}.md       ← slash commands (if recommended)
```

---

## Updating

To pull the latest version of `/startnew`:

**Mac / Linux**
```bash
./update.sh
```

**Windows (PowerShell)**
```powershell
.\update.ps1
```

## Re-running

`/startnew` is safe to re-run. Use it to refresh automation recommendations after installing `claude-code-setup`, or in any new project folder.
