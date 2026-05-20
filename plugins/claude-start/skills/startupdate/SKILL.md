---
name: startupdate
version: "2.1.0"
description: Updates Claude_start memory hooks in the current project to the latest installed version
allowed-tools: [Read, Write, Edit, Bash]
---

# Claude_start — Per-Project Hook Updater

Update the memory hooks in the current project to the latest version from the Claude_start hook cache.

---

## Step 1 — Verify this is a startnew project

Check that `.claude/hooks/` exists and contains at least one Claude_start hook:

```bash
ls .claude/hooks/ 2>/dev/null || echo "NOT_FOUND"
```

- **No `.claude/hooks/` directory** → tell the user: "This folder doesn't look like it was set up with `/startnew`. Run `/startnew` first to initialize the project." Stop.
- **Found** → continue.

---

## Step 2 — Verify the hook cache exists

```bash
ls ~/.claude/claude-start/hooks/ 2>/dev/null || echo "NOT_FOUND"
```

- **NOT_FOUND** → tell the user: "The Claude_start hook cache wasn't found at `~/.claude/claude-start/hooks/`. This usually means you need to run `update.sh` (or `update.ps1` on Windows) from the Claude_start repo to refresh it. Once done, run `/startupdate` again." Stop.
- **Found** → continue.

---

## Step 3 — Show what will be updated

Read the current hook files to note their version (first comment line):

```bash
head -3 .claude/hooks/memory-signal.sh 2>/dev/null || echo "NOT_PRESENT"
head -3 .claude/hooks/memory-consolidate.sh 2>/dev/null || echo "NOT_PRESENT"
head -3 ~/.claude/claude-start/hooks/memory-signal.sh 2>/dev/null
head -3 ~/.claude/claude-start/hooks/memory-consolidate.sh 2>/dev/null
```

Tell the user briefly what's being replaced and what it's being replaced with (just the comment lines — no need to diff the full scripts).

---

## Step 4 — Apply the update

Determine which hooks are currently installed in this project and update only those:

**If `memory-signal.sh` exists in `.claude/hooks/`:**
```bash
cp ~/.claude/claude-start/hooks/memory-signal.sh .claude/hooks/memory-signal.sh
chmod +x .claude/hooks/memory-signal.sh
```

**Always update `memory-consolidate.sh`** (it's installed in both memory modes):
```bash
cp ~/.claude/claude-start/hooks/memory-consolidate.sh .claude/hooks/memory-consolidate.sh
chmod +x .claude/hooks/memory-consolidate.sh
```

---

## Step 5 — Verify settings.json hook registration

Read `.claude/settings.json` and confirm the Stop hooks section still registers both scripts. If either is missing, add it back using the merge pattern (read → edit → write, never overwrite the full file).

Expected Stop hook entries (the ones that may be missing):
```json
{"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-signal.sh", "args": []}
{"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-consolidate.sh", "args": []}
```

Note: `memory-signal.sh` should only be registered if it was present before the update (i.e. the project uses perfect recall mode).

---

## Step 6 — Report

Print a short summary:

```
/startupdate complete

Updated:
  .claude/hooks/memory-consolidate.sh
  {.claude/hooks/memory-signal.sh  ← if applicable}

settings.json: {verified / repaired}

To keep hooks current, run update.sh from the Claude_start repo periodically,
then /startupdate in each project.
```
