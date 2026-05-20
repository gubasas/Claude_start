---
name: startupdate
version: "2.2.0"
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

## Step 3 — Detect OS and hook extension in use

```bash
uname -s 2>/dev/null || echo "Windows"
```

- `Darwin` or `Linux` → **Mac/Linux**, extension = `.sh`
- anything else → **Windows**, extension = `.ps1`

Also check which hooks are present in `.claude/hooks/` to determine if this project uses perfect recall (signal + consolidate) or before-compact only (consolidate only).

Show the user the first comment line of each installed hook vs. the cached version so they can see what's changing.

---

## Step 4 — Apply the update

Copy the matching extension from the cache, updating only hooks that are already present in the project.

**Mac/Linux — if `memory-signal.sh` exists:**
```bash
cp ~/.claude/claude-start/hooks/memory-signal.sh .claude/hooks/memory-signal.sh
chmod +x .claude/hooks/memory-signal.sh
```

**Mac/Linux — always:**
```bash
cp ~/.claude/claude-start/hooks/memory-consolidate.sh .claude/hooks/memory-consolidate.sh
chmod +x .claude/hooks/memory-consolidate.sh
```

**Windows — if `memory-signal.ps1` exists:**
```powershell
Copy-Item "$HOME\.claude\claude-start\hooks\memory-signal.ps1" ".claude\hooks\memory-signal.ps1" -Force
```

**Windows — always:**
```powershell
Copy-Item "$HOME\.claude\claude-start\hooks\memory-consolidate.ps1" ".claude\hooks\memory-consolidate.ps1" -Force
```

---

## Step 5 — Verify settings.json hook registration

Read `.claude/settings.json` and confirm the Stop hooks section registers the correct scripts for this OS. If any are missing, add them back (read → edit → write, never overwrite the full file).

**Mac/Linux expected entries:**
```json
{"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-consolidate.sh", "args": []}
{"type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-signal.sh", "args": []}
```

**Windows expected entries:**
```json
{"type": "command", "command": "pwsh", "args": ["-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-consolidate.ps1"]}
{"type": "command", "command": "pwsh", "args": ["-ExecutionPolicy", "Bypass", "-File", "${CLAUDE_PROJECT_DIR}/.claude/hooks/memory-signal.ps1"]}
```

Note: `memory-signal` entries should only be present/added if that hook was already in the project.

---

## Step 6 — Report

```
/startupdate complete

Updated:
  .claude/hooks/memory-consolidate.{sh|ps1}
  {.claude/hooks/memory-signal.{sh|ps1}  ← if applicable}

settings.json: {verified / repaired}

To keep hooks current, run update.sh from the Claude_start repo periodically,
then /startupdate in each project.
```
