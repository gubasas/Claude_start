# Open Issues

Known gaps and things to revisit. Add an entry when you find something; check it off when it's resolved.

---

## Unresolved

### 1. Desktop app hook behavior — needs proper testing

**What we know:** During smoke testing, hooks did not appear to fire when using Claude Code inside the Claude desktop app (counter file was never created). Claude still wrote memory entries because the CLAUDE.md instructions tell it to do so proactively.

**What we don't know:** Whether this is universal behavior or environment-specific. The Claude desktop app's hook execution model isn't documented. Hook behavior may differ across app versions.

**Impact:** Users on the desktop app in perfect recall mode rely entirely on Claude following CLAUDE.md instructions. If those instructions are followed (they appeared to be in our test), the outcome is the same. But the hook-based signal detection (Pattern A / B in memory-signal.sh) never runs, so memory writes depend on Claude proactively noticing — which may be less reliable.

**Next step:** Test hooks in the desktop app across at least two different sessions. Check whether `.claude/hooks/.ms_count` increments after each Claude response. If hooks never fire in the desktop app, document it definitively and consider surfacing a warning during `/startnew` setup when the desktop app is detected (if detectable).

---

### 2. Per-project hook updater

**What we know:** `update.sh` refreshes the global `/startnew` command. It does not update hook scripts (`.claude/hooks/memory-signal.sh`, etc.) in existing projects.

**Impact:** When memory hook logic improves, users with existing projects keep the old version. They'd have to manually copy files or re-run `/startnew`.

**Next step:** Design a `/startupdate` slash command that re-writes the memory hooks in the current project with the latest canonical versions. Options:
- Extract hook content from `~/.claude/commands/startnew.md` (SKILL.md) at update time
- Store hooks as standalone files in the repo (e.g. `plugins/claude-start/hooks/`) and have `update.sh` also copy them to a known location (e.g. `~/.claude/claude-start/hooks/`), then `/startupdate` reads from there
- The second option is cleaner and doesn't require parsing SKILL.md

See also: `update.sh` needs to save the install path somewhere so per-project updaters can find the canonical hook files.

---

### 3. Pattern B — content-based option selections not reliably detected

**What we know:** Pattern B detects brief user replies after Claude presents a list of options. The regex looks for list markers in the prior Claude message (`[0-9]+[.)]`, `[-–—*•]`, etc.) and a short user reply.

**What we don't know:** When a user picks by content keyword (e.g. "reliability" instead of "2" or "the second one"), Pattern B may still fire on the list marker match — but the trigger phrase cooldown (5-turn minimum) may prevent it from firing if a signal was detected recently.

**Impact:** Some option selections might not get persisted to memory. In practice, a later exchange often triggers Pattern A anyway.

**Next step:** Evaluate whether the 5-turn cooldown should be reduced for Pattern B specifically, or whether Pattern B should have its own independent cooldown counter.

---

### 4. Windows: memory hooks use `.sh` — no `.ps1` equivalents

**What we know:** `/startnew` generates `.sh` hook scripts. On Windows (PowerShell), these won't execute.

**Impact:** Windows users get hook entries registered in `settings.json` pointing to `.sh` files that can't run. Memory hooks silently fail.

**Next step:** Add PowerShell equivalents (`memory-signal.ps1`, `memory-consolidate.ps1`) to the SKILL.md templates and register the correct extension based on OS detection in Step 3.

---

### 5. PreCompact hook — no usable instruction channel

**What we know:** Claude Code's `PreCompact` hook event exists but neither `hookSpecificOutput` (schema error) nor `decision:block` (produces a user-facing error, Claude never receives the reason) provides a usable instruction channel. We removed `memory-precompact.sh` as a result.

**Impact:** There's no way to trigger memory consolidation at the moment compaction begins. `memory-consolidate.sh` fires at ~90% context as a Stop hook, which is close but not perfectly timed.

**Next step:** Monitor Claude Code release notes for changes to PreCompact hook output handling. Re-add a pre-compaction hook if an instruction channel becomes available.

---

## Resolved

- **Pattern B regex missing em-dash/en-dash** — `[-*•]` didn't match Claude's em-dash bullets. Fixed: changed to `[-–—*•]`. *(2026-05-19)*
- **memory-signal.sh cooldown before detection** — hook exited early for 4 of every 5 turns before checking patterns. Fixed: cooldown now gates only the fire, not the detection. *(2026-05-19)*
- **dirname bug in hook template** — nested `$(dirname "$0")` was dropped during SKILL.md template writes. Fixed: changed to `${BASH_SOURCE[0]%/*}`. *(2026-05-19)*
- **Memory hooks missing from settings.json on first run** — Step 6 overwrote Step 3's settings.json. Fixed: explicit IMPORTANT instruction to read existing file and merge. *(2026-05-19)*
- **MCP servers written to settings.json instead of .mcp.json** — Fixed: bolded instruction in SKILL.md, MCP servers now go to `.mcp.json`. *(2026-05-19)*
- **Memory System section at bottom of CLAUDE.md** — Fixed: SKILL.md now explicitly requires Memory System directly after Project Overview. *(2026-05-19)*
