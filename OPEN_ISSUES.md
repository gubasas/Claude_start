# Open Issues

Known gaps and things to revisit. Add an entry when you find something; check it off when it's resolved.

---

## Unresolved

### 1. Desktop app hook behavior — partially confirmed

**What we know:** `memory-consolidate.sh` (Stop hook) fires in the Claude desktop app — confirmed by the checkpoint message appearing during a real session. This means Stop hooks work in the desktop app in general.

**What we don't know:** Whether `memory-signal.sh` fires correctly. It's harder to confirm — requires real trigger phrases in a working session rather than a quick test. The earlier smoke test that suggested hooks weren't firing was likely a false negative (counter file may have landed in wrong directory due to the dirname bug, which is now fixed).

**Impact:** Likely lower than originally thought. If Stop hooks fire, both hooks should work. The README desktop app caveat ("may not fire") is now probably overcautious — but leave it until signal is confirmed.

**Next step:** During a real project session in the desktop app, check whether `.claude/hooks/.ms_count` increments and `.ms_last` updates after a trigger phrase exchange. If confirmed, update the README caveat and close this issue.

---

### ~~2. Per-project hook updater~~ ✓ RESOLVED *(2026-05-19)*

Hook scripts are now standalone files at `plugins/claude-start/hooks/`. `install.sh` and `update.sh` cache them to `~/.claude/claude-start/hooks/`. A `/startupdate` slash command copies the latest cached versions into the current project's `.claude/hooks/` and verifies `settings.json` registration.

---

### 3. Pattern B — content-based option selections not reliably detected

**What we know:** Pattern B detects brief user replies after Claude presents a list of options. The regex looks for list markers in the prior Claude message (`[0-9]+[.)]`, `[-–—*•]`, etc.) and a short user reply.

**What we don't know:** When a user picks by content keyword (e.g. "reliability" instead of "2" or "the second one"), Pattern B may still fire on the list marker match — but the trigger phrase cooldown (5-turn minimum) may prevent it from firing if a signal was detected recently.

**Impact:** Some option selections might not get persisted to memory. In practice, a later exchange often triggers Pattern A anyway.

**Next step:** Evaluate whether the 5-turn cooldown should be reduced for Pattern B specifically, or whether Pattern B should have its own independent cooldown counter.

---

### ~~4. Windows: memory hooks use `.sh` — no `.ps1` equivalents~~ ✓ RESOLVED *(2026-05-19)*

`memory-signal.ps1` and `memory-consolidate.ps1` added. SKILL.md now detects OS at the start of Step 3 and branches on `.sh` vs `.ps1` for both file copying and `settings.json` registration (`pwsh -File` on Windows). `/startupdate` also handles both extensions.

---

### 5. PreCompact hook — no usable instruction channel

**What we know:** Claude Code's `PreCompact` hook event exists but neither `hookSpecificOutput` (schema error) nor `decision:block` (produces a user-facing error, Claude never receives the reason) provides a usable instruction channel. We removed `memory-precompact.sh` as a result.

**Impact:** There's no way to trigger memory consolidation at the moment compaction begins. `memory-consolidate.sh` fires at ~90% context as a Stop hook, which is close but not perfectly timed.

**Next step:** Monitor Claude Code release notes for changes to PreCompact hook output handling. Re-add a pre-compaction hook if an instruction channel becomes available.

---

## Resolved

- **Windows `.ps1` hooks** — `memory-signal.ps1` and `memory-consolidate.ps1` added; OS detection in Step 3 branches on extension and `settings.json` registration format. `/startupdate` handles both. *(2026-05-19)*
- **Per-project hook updater** — `/startupdate` command added; hooks stored as standalone files in repo, cached to `~/.claude/claude-start/hooks/` by install/update scripts. *(2026-05-19)*
- **Pattern B regex missing em-dash/en-dash** — `[-*•]` didn't match Claude's em-dash bullets. Fixed: changed to `[-–—*•]`. *(2026-05-19)*
- **memory-signal.sh cooldown before detection** — hook exited early for 4 of every 5 turns before checking patterns. Fixed: cooldown now gates only the fire, not the detection. *(2026-05-19)*
- **dirname bug in hook template** — nested `$(dirname "$0")` was dropped during SKILL.md template writes. Fixed: changed to `${BASH_SOURCE[0]%/*}`. *(2026-05-19)*
- **Memory hooks missing from settings.json on first run** — Step 6 overwrote Step 3's settings.json. Fixed: explicit IMPORTANT instruction to read existing file and merge. *(2026-05-19)*
- **MCP servers written to settings.json instead of .mcp.json** — Fixed: bolded instruction in SKILL.md, MCP servers now go to `.mcp.json`. *(2026-05-19)*
- **Memory System section at bottom of CLAUDE.md** — Fixed: SKILL.md now explicitly requires Memory System directly after Project Overview. *(2026-05-19)*
