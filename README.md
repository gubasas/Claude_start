# Claude_start

One command to set up Claude Code properly for any new project — memory, config, automations, all of it.

Works in Claude Code anywhere it runs — terminal, VS Code, and the Claude desktop app's Code mode. The one-time plugin install step needs the terminal CLI (the script handles this for you).

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

Questions 2, 3, and 5 also accept `suggest` instead of an answer — type that and `/startnew` proposes a recommendation based on what you've told it so far.

Every technical term that comes up (git init, MCP server, hook, subagent, slash command) is explained in plain language the first time it appears.

### Step 2 — CLAUDE.md

Writes a tailored `CLAUDE.md`. Section order is intentional: **Memory System comes directly after Project Overview** — before tech stack and goals — so Claude's behavioral rules carry maximum attention weight at the top of every session. Below that: tech stack, project goals, development commands, conventions, architecture notes, and (if provided) reference links.

### Step 3 — Two-layer memory system + memory hooks

Creates a `memory/` folder with two layers:

- **`memory/MEMORY.md`** — the index. Always loaded into context. One-liner per topic, pointers only — never detail. Stays concise so it never gets truncated.
- **`memory/project.md`** — the first detail file, pre-populated with everything from the intake. Future detail files are created as the project evolves (decisions made, bugs root-caused, patterns established, constraints discovered).

Also creates **`.claude/settings.json`** with stack-appropriate permissions, and installs two memory-maintenance hooks automatically (see below).

### Step 4 — Plugin check

Checks `installed_plugins.json` to see if `claude-code-setup` is installed. If missing, it tells you what to run and skips straight to the summary — the rest of the setup (CLAUDE.md, memory, config, memory hooks) is still complete.

### Step 5 — Reference link fetching and analysis

If you provided reference links:

- **Non-fetchable links** (Figma, Miro, Notion design pages, Loom, Google Slides) are filtered out automatically and skipped with a brief note.
- For the remaining links, you choose per-link: **summary mode** (a lightweight subagent fetches each page and returns a ~300-word digest, low context cost) or **deep-dive mode** (full page content held in context — useful for API references or config docs you want recommendations grounded in).

Then runs `claude-code-setup` analysis, using the fetched content to make recommendations more specific to your actual stack and references.

### Step 6 — Execute all recommendations

Three memory-maintenance hooks are always installed regardless of `claude-code-setup` (see "Files created per project" below). Then, every recommendation from `claude-code-setup` is applied automatically:

| Category | What gets created |
|---|---|
| **MCP servers** | Added to `.mcp.json` at the project root |
| **Hooks** | Script created at `.claude/hooks/` (`.sh` on Mac/Linux, `.ps1` on Windows), registered in settings |
| **Subagents** | Agent file created at `.claude/agents/{name}.md` with YAML frontmatter |
| **Slash commands** | Command file created at `.claude/commands/{name}.md` |

No approval step — everything runs automatically. If you want to know what any installed tool does, just ask Claude — it'll explain anything in your `.claude/` folder.

### Step 7 & 8 — Final update and summary

Appends a `## Claude Code Setup` section to `CLAUDE.md` listing every automation that was installed, then prints a full summary of every file created and every automation applied.

---

## Memory hooks — always installed

These two hooks are installed in every project by `/startnew`, independent of `claude-code-setup`:

| Hook | When it fires | What it does |
|---|---|---|
| `memory-signal.sh` | After each Claude response | Scans for trigger phrases (decisions, fixes, preferences) and prompts Claude to write a memory entry |
| `memory-consolidate.sh` | Once, when the session grows long (~90% context) | Silently consolidates the session to memory files, then shows a checkpoint message offering `/compact` or keep-going |

**The checkpoint message** (from `memory-consolidate`) looks like this when it fires:

> "Quick checkpoint — this session is getting long. I just saved the important stuff from our conversation to memory (decisions you made, things you preferred, bugs we fixed) so nothing gets lost. In a bit, my short-term memory will automatically shrink to make room (this is called compaction). Two options: 1) Type `/compact` now — fresh clean slate, all the important stuff is in memory anyway. 2) Keep going as-is. Just hit 1 or 2."

This is normal — it means the memory system is working.

### Desktop app and hooks

Hooks may not fire when using Claude Code inside the **Claude desktop app**. If that's your environment and you chose **perfect recall** mode during setup, Claude will still follow the memory instructions baked into `CLAUDE.md` — writing entries proactively without the hook prompts. The **before-compact only** mode is unaffected either way.

> **Note:** Desktop app hook behavior hasn't been exhaustively tested across all versions. If you notice hooks firing or not firing differently, please open an issue.

---

## Files created per project

```
{project-root}/
  CLAUDE.md                               ← tailored project context for Claude
  .mcp.json                               ← MCP server config (project-scoped)
  .gitignore                              ← created or updated
  memory/
    MEMORY.md                             ← memory index (always loaded)
    project.md                            ← project overview detail file
  .claude/
    settings.json                         ← permissions + hook registration
    hooks/
      memory-signal.sh                    ← always installed (decision/fix/preference detection)
      memory-consolidate.sh               ← always installed (~90% context checkpoint)
      {other-hooks}.sh                    ← from claude-code-setup recommendations (if any)
    agents/{agent-name}.md                ← subagent definitions (if recommended)
    commands/{command-name}.md            ← slash commands (if recommended)
```

---

## Updating

**The universal update path — works from any version:**

**Mac / Linux**
```bash
git pull && ./install.sh
```

**Windows (PowerShell)**
```powershell
git pull; .\install.ps1
```

`install.sh` is safe to re-run. It updates `/startnew`, `/startupdate`, and the hook cache — regardless of what version you had before.

> If you have a recent version already installed, `./update.sh` (or `.\update.ps1`) does the same thing without re-checking the Claude Code setup steps.

**To also update hooks in an existing project**, open that project in Claude Code and run:

```
/startupdate
```

This copies the latest hook scripts from the cache into `.claude/hooks/` and verifies `settings.json` registration.

## Re-running

`/startnew` is safe to re-run. Use it to refresh automation recommendations after installing `claude-code-setup`, or in any new project folder.
