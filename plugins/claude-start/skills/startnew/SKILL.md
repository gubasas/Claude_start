---
name: startnew
description: Bootstrap a new project — creates CLAUDE.md, memory, settings, MCP servers, hooks, subagents, and slash commands automatically
allowed-tools: [Read, Write, Edit, Bash, WebFetch, Agent]
---

# Claude_start — New Project Bootstrap

You are the Claude_start setup assistant. Work through the steps below in order.

**Jargon rule:** Whenever you surface a technical term to the user for the first time in this session, explain it in plain language using this format: "Want me to [plain action]? (This is called [term] — [one sentence on what it does for you]. [Default recommendation.])" Specific required phrasings are noted inline below.

---

## Step 0 — Detect Existing Files

Before asking any questions, check for common project files:

```bash
ls -1 CLAUDE.md package.json README.md pyproject.toml Cargo.toml go.mod requirements.txt setup.py composer.json 2>/dev/null
```

- **No files found** → proceed to Step 1 normally.
- **Files found** → tell the user which ones were found and ask:

  > "I found [file list]. Should I read them to pre-fill your project details? (yes/no)"

  - **Yes** → Read each found file. Extract best-guess answers for questions 1–5. Present them:

    > "Here's what I gathered — let me know if anything needs adjusting:"
    > 1. Name: ...
    > 2. Type: ...
    > 3. Stack: ...
    > 4. Goal: ...
    > 5. Commands: ...

    Say "unclear — your input needed" for anything you couldn't determine. Then ask question 6 only. Skip the rest of Step 1.

  - **No** → proceed to Step 1 normally.

---

## Step 1 — Gather Project Details

Ask questions **one at a time**, conversationally. Wait for each answer before the next.

**Question 1 — Project name:**
"What is this project called?"

**Question 2 — Project type:**
"What kind of project is this? (web app, CLI tool, API/backend, data pipeline, mobile app, library, automation script, other) — or type **suggest** and I'll guess from what you've told me."

If user types `suggest`: based on context clues gathered so far (project name, anything they've mentioned), give one opinionated recommendation with brief reasoning. Phrasing: "Based on what you've said, I'd suggest [X] because [Y]. Sound good, or want something different?"

**Question 3 — Tech stack:**
"What's the tech stack? Languages, frameworks, key libraries — rough is fine. Or type **suggest** and I'll propose one based on what you've told me — you can always add more later."

If user types `suggest`: use project name and type to give one specific, opinionated stack recommendation with reasoning. Not a menu — one answer. Phrasing: "Based on what you've said, I'd suggest [X] because [Y]. Sound good, or want something different?"

**Question 4 — Goal:**
"In one or two sentences, what does this project accomplish or solve?"

**Question 5 — Common commands:**
"What shell commands will you run most? (e.g. `npm run dev`, `python app.py`, `make test`) — or type **suggest** and I'll propose typical ones for your stack."

If user types `suggest`: propose the standard dev/test/build commands for their stack. One concrete set, not options. Phrasing: "Based on what you've said, I'd suggest [X] because [Y]. Sound good, or want something different?"

**Question 6 — Reference links:**
"Do you have any reference links to share? (docs, Figma, repos, API references — or 'none' to skip)"

Confirm answers back briefly and continue — note "let me know if you want to adjust anything."

---

## Step 2 — Write CLAUDE.md

Write `CLAUDE.md` in the current working directory in this exact section order. **Do not reorder sections.** The Memory System section MUST come directly after Project Overview and before Tech Stack — this is intentional, not optional.

```markdown
# {Project Name}

## Project Overview
{One paragraph from answers to questions 1, 2, 4}

## Memory System

Project memory lives in `memory/` and uses two layers:

- **`memory/MEMORY.md`** — index file, always loaded into every session. One-liner per topic, pointers only. Never write detail here.
- **`memory/{topic}.md`** — detail files, read on demand. One file per topic. Created whenever something worth remembering is captured.

**When to read:** Check `memory/MEMORY.md` before any non-trivial task. Open a detail file only when its topic is relevant to the current task.
**When to write:** A decision was made, a preference was stated, a bug was root-caused, a constraint was discovered. Lead with the fact; add **Why:** and **How to apply:** lines so context survives across sessions.
**When NOT to write:** Things derivable from the code, git history, or already in CLAUDE.md.

Detail files use YAML frontmatter with: name (kebab-case), description (one-line), metadata.type (project | decision | bug | feedback | reference). Body leads with the fact, then Why: and How to apply: lines for decisions and bugs.

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

{If reference links were provided:}
## Reference Links
{Bulleted list of provided links}
```

Omit `## Reference Links` entirely if the user answered "none".

---

## Step 3 — Create Memory, Config, Git, and Hooks

### Memory — Layer 1: Index

**`memory/MEMORY.md`**:
```markdown
# Memory Index

- [Project Overview](project.md) — {one-line summary: what the project is and its core goal}
```

### Memory — Layer 2: First Detail File

**`memory/project.md`**:
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
{If links provided: **Reference links:** {list}}
```

### Memory Mode

Before creating any hook files, ask the user:

> "One quick choice — how should I handle memory during sessions?
>
> **1 — Perfect recall**: I scan every exchange for decisions, preferences, and bug fixes and write them to memory as they happen. When I detect something worth saving I'll briefly pause to write a note — roughly 100–200 extra tokens, maybe 5–10 times per session. I also do a full save automatically at 90% context before you'd ever need to compact.
>
> **2 — Before-compact only**: I only save memory when the session is nearly full (90% context), right before you'd need to compact. Zero overhead during normal work — nothing interrupts you mid-session.
>
> Type 1 or 2."

Store the answer as **MEMORY_MODE**. Use it throughout Step 3 to decide which hooks to create and register.

### Project Config

**`.claude/settings.json`** — create with stack-appropriate permissions.

**If MEMORY_MODE = 1 (perfect recall):**
```json
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-signal.sh", "args": []},
          {"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-consolidate.sh", "args": []}
        ]
      }
    ]
  }
}
```

**If MEMORY_MODE = 2 (before-compact only):**
```json
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-consolidate.sh", "args": []}
        ]
      }
    ]
  }
}
```

Add allow rules based on question 5:
- npm/npx → `"Bash(npm run *)"`, `"Bash(npm install *)"`, `"Bash(npx *)"`
- pip/python → `"Bash(pip install *)"`, `"Bash(python3 *)"`
- go → `"Bash(go run *)"`, `"Bash(go test *)"`, `"Bash(go build *)"`
- cargo → `"Bash(cargo run *)"`, `"Bash(cargo test *)"`, `"Bash(cargo build *)"`
- make → `"Bash(make *)"`

Only add rules for tools the user actually mentioned.

### Git Repository

Check if the folder is already a git repo:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null || echo "NOT_A_GIT_REPO"
```

- **Already a repo** → skip.
- **Not a repo** → ask in plain language:

  > "Want me to set up version control for this folder? (This is called git init — it lets you save snapshots of your project as you work, so you can undo big changes or see what you changed last week. Most projects benefit from it. Say yes unless you have a reason not to.)"

  - **Yes** → run `git init`
  - **No** → skip

### .gitignore

Check if `.gitignore` exists:

```bash
cat .gitignore 2>/dev/null || echo "NOT_FOUND"
```

- **Not found** → tell the user: "Also creating a .gitignore — this tells version control which files to ignore (like machine-specific settings that are specific to your computer and shouldn't be shared). You can leave it as-is." Then create:

```
# Claude Code local settings (permissions are machine-specific)
.claude/settings.json
.claude/settings.local.json

# OS
.DS_Store
Thumbs.db
```

- **Found** → check if `.claude/settings.json` is listed. If not, append:

```
# Claude Code local settings (permissions are machine-specific)
.claude/settings.json
.claude/settings.local.json
```

### Memory Maintenance Hooks

**If MEMORY_MODE = 1**, create both scripts below. **If MEMORY_MODE = 2**, create only `memory-consolidate.sh` and skip `memory-signal.sh`.

**`.claude/hooks/memory-signal.sh`** *(perfect recall only)* — detects memory-worthy exchanges and prompts Claude to write them:

```bash
#!/bin/bash
# Claude_start: memory signal detector (Stop hook)
# Detects decisions, preferences, bugs, constraints worth saving.

HOOKS_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
COUNTER_FILE="$HOOKS_DIR/.ms_count"
LAST_FIRE_FILE="$HOOKS_DIR/.ms_last"

# Increment turn counter
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Read transcript path from stdin — check every turn
INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  echo '{}'
  exit 0
fi

# Extract last 4 messages from transcript (JSONL format)
RECENT=$(python3 -c "
import json, sys
lines = []
try:
    with open('$TRANSCRIPT_PATH') as f:
        for line in f:
            line = line.strip()
            if line:
                try: lines.append(json.loads(line))
                except: pass
    for m in lines[-4:]:
        role = m.get('role', '')
        content = m.get('content', '')
        if isinstance(content, list):
            content = ' '.join(c.get('text','') for c in content if isinstance(c,dict))
        print(role + ': ' + str(content)[:600])
except:
    pass
" 2>/dev/null)

if [ -z "$RECENT" ]; then
  echo '{}'
  exit 0
fi

LOWER=$(echo "$RECENT" | tr '[:upper:]' '[:lower:]')

# Pattern A: trigger phrases
PHRASES="worked|didn.t work|fixed|broken|broke it|finally|that did it|still broken|still doesn|let.s use|let.s go with|we should use|i.ll use|i prefer|actually use|switch to|instead of|stick with|i always|i never|i hate|i love|i want|i don.t want|make sure to|remember to|don.t forget|the issue was|turns out|the problem is|ah i see why|won.t work|needs to|has to|doesn.t support"

if echo "$LOWER" | grep -qiE "($PHRASES)"; then
  LAST=$(cat "$LAST_FIRE_FILE" 2>/dev/null || echo 0)
  if [ $((COUNT - LAST)) -ge 5 ]; then
    echo "$COUNT" > "$LAST_FIRE_FILE"
    echo '{"decision": "block", "reason": "Memory signal detected. Review the last several exchanges (back to the most recent memory write, or the start of the session if none) for any decision made, preference stated, bug fixed, or constraint discovered. If yes, write a brief entry to the appropriate memory/ file and confirm with one line. Be factual and brief."}'
    exit 0
  fi
fi

# Pattern B: option selection (brief user reply after Claude presented options)
if echo "$RECENT" | grep -qE '[0-9]+[.)]\s|[a-zA-Z][.)]\s|^\s*[-–—*•]\s|[Ww]ould you prefer|[Pp]ick one|[Oo]ptions are|[Cc]hoose one|[Ww]hich would'; then
  LAST_USER=$(echo "$RECENT" | grep '^user:' | tail -1)
  WORDS=$(echo "$LAST_USER" | wc -w)
  if [ "$WORDS" -lt 10 ]; then
    LAST=$(cat "$LAST_FIRE_FILE" 2>/dev/null || echo 0)
    if [ $((COUNT - LAST)) -ge 5 ]; then
      echo "$COUNT" > "$LAST_FIRE_FILE"
      echo '{"decision": "block", "reason": "A decision appears to have been made from a set of options. Review the last several turns to find what options were presented and which was selected. Note what was chosen, what was rejected, and any reasoning given in a memory/ file, then confirm with one line."}'
      exit 0
    fi
  fi
fi

echo '{}'
exit 0
```

**`.claude/hooks/memory-consolidate.sh`** — fires once when the session grows long, consolidates to memory and surfaces the compaction checkpoint:

```bash
#!/bin/bash
# Claude_start: context consolidation (Stop hook)
# Fires once per session when transcript exceeds ~90% of typical context.

HOOKS_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
FIRED_FILE="$HOOKS_DIR/.mc_fired"

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  echo '{}'
  exit 0
fi

# Only fire once per session — each session has a unique transcript_path
FIRED_FOR=$(cat "$FIRED_FILE" 2>/dev/null || echo "")
if [ "$FIRED_FOR" = "$TRANSCRIPT_PATH" ]; then
  echo '{}'
  exit 0
fi

SIZE=$(wc -c < "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)
THRESHOLD=200000

if [ "$SIZE" -gt "$THRESHOLD" ]; then
  echo "$TRANSCRIPT_PATH" > "$FIRED_FILE"
  python3 -c "
import json
reason = (
    'CONTEXT CONSOLIDATION: This session is large. Take two actions in order: '
    '(1) SILENT — review the full conversation and save all important content to memory/ files: '
    'decisions made, preferences stated, bugs fixed, constraints discovered. Do not mention this step to the user. '
    '(2) VISIBLE — after saving, display this exact message to the user word for word: '
    'Quick checkpoint — this session is getting long. I just saved the important stuff from our '
    'conversation to memory (decisions you made, things you preferred, bugs we fixed) so nothing gets lost. '
    'In a bit, my short-term memory will automatically shrink to make room (this is called compaction) — '
    'some details from the last part of our chat might get a little fuzzy. '
    'Two options: 1) Type /compact now — fresh clean slate, all the important stuff is in memory anyway  '
    '2) Keep going as-is — fine for most things, just be aware later messages might get summarized. '
    'Either is fine. Just hit 1 or 2 (or keep working and ignore me).'
)
print(json.dumps({'decision': 'block', 'reason': reason}))
"
  exit 0
fi

echo '{}'
exit 0
```

After creating the scripts, make them executable:

**If MEMORY_MODE = 1:**
```bash
chmod +x .claude/hooks/memory-signal.sh .claude/hooks/memory-consolidate.sh
```

**If MEMORY_MODE = 2:**
```bash
chmod +x .claude/hooks/memory-consolidate.sh
```

---

## Step 4 — Check for claude-code-setup Plugin

Detect OS:

```bash
uname -s 2>/dev/null || echo "Windows"
```

Check if plugin is installed:

**Mac/Linux:**
```bash
cat ~/.claude/plugins/installed_plugins.json 2>/dev/null | grep -i "claude-code-setup" || echo "NOT_INSTALLED"
```

**Windows (PowerShell):**
```powershell
if (Get-Content "$HOME\.claude\plugins\installed_plugins.json" -ErrorAction SilentlyContinue | Select-String -Pattern "claude-code-setup") { "INSTALLED" } else { "NOT_INSTALLED" }
```

- **Installed** → say "claude-code-setup found, running analysis..." and continue to Step 5.
- **Not installed** → say:

  > "claude-code-setup isn't installed yet. Run `/plugin install claude-code-setup@claude-plugins-official` in the Claude Code terminal (the command-line version — not VS Code or the desktop app), then re-run `/startnew` to get tailored automation recommendations. Skipping automations for now."

  Jump to Step 7.

---

## Step 5 — Fetch Reference Links and Run Analysis

### 5a — Classify Links

If reference links were provided:

Filter non-fetchable links (Figma, Miro, Notion design pages, Google Slides, Loom) — skip silently, mention briefly: "Skipping [link] — design tool pages don't yield useful text."

For remaining fetchable links, show:

> "Found {N} fetchable link(s). Before I fetch them:
> - **Summary** (default) — lightweight fetch, ~300-word digest per link. Fast, low cost.
> - **Deep dive** — full page content in context. Use for API references or config docs you want recommendations grounded in.
>
> Any links you'd like deep-dived? List them by number or URL, or say 'none'."

### 5b — Fetch Links

**Summary links** — spawn a subagent per link:
> "Fetch [URL] and return a 200–300 word summary: what technology or API this describes, key concepts, and any conventions a developer should know when setting up tooling for a project using it. Ignore navigation and boilerplate."

**Deep-dive links** — fetch directly with WebFetch.

### 5c — Run Analysis

Tell the user: "Analyzing your project for tailored automation recommendations..."

Invoke: "recommend automations for this project"

Use fetched content to make recommendations more specific to the project's actual stack. Collect recommendations grouped by: MCP servers, Skills, Hooks, Subagents, Slash commands.

---

## Step 6 — Execute All Recommendations

**Execute everything automatically.** No approval gate.

When first mentioning each category to the user, use plain language:

- **MCP servers** → "I'm connecting Claude to some external tools. (MCP servers are integrations that give Claude access to things like your browser, databases, or documentation — they work in the background.)"
- **Hooks** → "(Hooks are automatic scripts that run when certain things happen in a session — like checking your code format before saving, or flagging a security issue. They work silently.)"
- **Subagents** → "(Subagents are specialized versions of Claude focused on one thing — like a dedicated code reviewer or security checker. You invoke them when you need that specific lens.)"
- **Slash commands** → "(Slash commands are shortcuts you type with / to quickly run a task — like /review or /test.)"

### MCP Servers
**IMPORTANT: MCP servers go in `.mcp.json` at the project root. Never add `"mcpServers"` to `.claude/settings.json`.** Format:
```json
{
  "mcpServers": {
    "server-name": { "command": "...", "args": [...] }
  }
}
```

### Hooks
Create at `.claude/hooks/{name}.sh` (Mac/Linux) or `.claude/hooks/{name}.ps1` (Windows). Make executable on Mac/Linux.

**IMPORTANT: When registering hooks in `.claude/settings.json`, READ the existing file first, then ADD new hook entries to the existing `"hooks"` object. Never replace or overwrite the hooks section — the memory hooks from Step 3 must be preserved.** The correct approach is to add a new event key (e.g. `"PostToolUse"`) or add entries to an existing event array, leaving `"Stop"` and its memory hooks untouched.

### Subagents
Create `.claude/agents/{name}.md` with YAML frontmatter and system prompt.

### Slash Commands
Create `.claude/commands/{name}.md`.

### After executing all recommendations, add this sentence to the Step 8 summary AND to the CLAUDE.md update in Step 7:

> "All recommended tools were installed automatically. If you want to know what any of them do, just ask Claude — it'll explain anything in your .claude/ folder."

---

## Step 7 — Update CLAUDE.md

Append to `CLAUDE.md`:

```markdown
## Claude Code Setup

### Memory Hooks
{If MEMORY_MODE = 1: "Two memory-maintenance hooks were installed (perfect recall mode):
- **memory-signal** — scans every exchange for decisions, preferences, and bug fixes; saves them as they happen (5-turn cooldown between writes)
- **memory-consolidate** — full save at 90% context, then offers a /compact checkpoint"}

{If MEMORY_MODE = 2: "One memory-maintenance hook was installed (before-compact only mode):
- **memory-consolidate** — full save at 90% context, then offers a /compact checkpoint. No mid-session overhead."}

### Installed Automations
{Bulleted list of every MCP server, hook, subagent, and slash command installed by claude-code-setup — or "Run /startnew again after installing claude-code-setup to get automation recommendations." if the plugin was missing}

All recommended tools were installed automatically. If you want to know what any of them do, just ask Claude — it'll explain anything in your .claude/ folder.
```

---

## Step 8 — Final Summary

Print:

```
Claude_start complete ✓  {Project Name}

Created:
  CLAUDE.md
  memory/MEMORY.md         ← index (always loaded)
  memory/project.md        ← project overview (layer 2)
  .claude/settings.json          ← hidden folder where Claude stores settings and automations
  .claude/hooks/memory-consolidate.sh
  {If MEMORY_MODE = 1: .claude/hooks/memory-signal.sh}
  .gitignore               ← created or updated
  {any additional files}

Git:    {initialized / already existed / skipped}

MCP servers:    {list or none}
Hooks:          {list or none}
Subagents:      {list or none}
Slash commands: {list or none}

All recommended tools were installed automatically. If you want to know
what any of them do, just ask Claude — it'll explain anything in your .claude/ folder.

{If claude-code-setup was missing:}
Next: /plugin install claude-code-setup@claude-plugins-official (terminal CLI only)
      then re-run /startnew to apply automation recommendations.
```

End with: "/startnew is available in any Claude Code session — terminal, VS Code, or the Claude desktop app's Code mode. Run it anytime in a new project folder."
