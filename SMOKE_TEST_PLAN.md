# /startnew Smoke Test Plan
Target: `/Users/alexk/Documents/TestProject` — clean empty project  
Mac/Linux only. Windows .sh gap is a known issue, documented in Part J.

Current system state (as of this test):
- **3 hooks**: memory-signal.sh (perfect recall mode only), memory-consolidate.sh (both modes)
- **2 memory modes**: perfect recall (signal + consolidate) vs before-compact only (consolidate only)
- **Consolidate threshold**: 200000 bytes (~90% context)
- **Signal cooldown**: 5 turns between fires, detection runs every turn
- **PreCompact hook**: removed — cannot instruct Claude from PreCompact event (verified)
- **Sweep hook**: removed — redundant with signal now that detection runs every turn

---

## PRELIMINARY — 3-Environment Fire Test

**Do this before the full smoke test. ~5 minutes. Go/no-go gate.**

`decision:block` on Stop hooks was verified to work in one environment. The VS Code extension is the most likely to handle it differently. If VS Code breaks this, the hook system is broken for most users.

**In each environment below:**
1. Open TestProject (after running /startnew — see Part B first)
2. Send: **`Let's use SQLite for this project`**
3. Wait for Claude's full response
4. Observe: does a second unprompted follow-up response appear asking to write a memory entry?

| Environment | Result | Notes |
|---|---|---|
| Terminal CLI | [ ] follow-up appeared / [ ] nothing | |
| VS Code extension | [ ] follow-up appeared / [ ] nothing | |
| Desktop app Code mode | [ ] follow-up appeared / [ ] nothing | |

**If VS Code shows nothing:** Stop. Debug `decision:block` in VS Code before proceeding — affects all non-technical users.

**If all three show follow-up responses:** Proceed with the full test.

- [ ] 3-environment check complete — result: ___________________

---

## PART A — Pre-test setup

### Step 1 — Confirm TestProject is empty

```bash
ls -la /Users/alexk/Documents/TestProject
```

Expected: `.DS_Store` only. If anything else is present:
```bash
rm -rf /Users/alexk/Documents/TestProject/.claude /Users/alexk/Documents/TestProject/.git /Users/alexk/Documents/TestProject/memory
rm -f /Users/alexk/Documents/TestProject/CLAUDE.md /Users/alexk/Documents/TestProject/.gitignore /Users/alexk/Documents/TestProject/.mcp.json
```

- [ ] TestProject confirmed empty

---

### Step 2 — Add debug instrumentation to hook scripts

**Do this AFTER /startnew has run** (hooks don't exist yet). Return here after Step 7.

For each script, insert the instrumentation block immediately after the `#!/bin/bash` line. Where noted, also change `INPUT=$(cat)` to avoid consuming stdin twice.

#### 2a — `memory-signal.sh`

Add after `#!/bin/bash`:
```bash
# === DEBUG — REMOVE AFTER TEST ===
_DEBUG_STDIN="$(cat)"
printf '\n=== %s: memory-signal.sh fired ===\n' "$(date)" >> /tmp/claude-hook-debug.log
printf '%s\n' "$_DEBUG_STDIN" >> /tmp/claude-hook-debug.log
# === END DEBUG ===
```
Then change `INPUT=$(cat)` → `INPUT="${_DEBUG_STDIN}"`

#### 2b — `memory-consolidate.sh`

Add after `#!/bin/bash`:
```bash
# === DEBUG — REMOVE AFTER TEST ===
_DEBUG_STDIN="$(cat)"
printf '\n=== %s: memory-consolidate.sh fired ===\n' "$(date)" >> /tmp/claude-hook-debug.log
printf '%s\n' "$_DEBUG_STDIN" >> /tmp/claude-hook-debug.log
# === END DEBUG ===
```
Then change `INPUT=$(cat)` → `INPUT="${_DEBUG_STDIN}"`

After adding instrumentation, verify the log file is being written after any Claude response:
```bash
cat /tmp/claude-hook-debug.log
```

- [ ] Instrumentation added to both scripts (do after Step 7)

---

### Step 3 — Confirm no leftover test hooks

```bash
grep -i "test-hook\|TEST_MARKER\|precompact-test" ~/.claude/settings.json && echo "PROBLEM: still there" || echo "OK"
ls /tmp/precompact-test*.sh /tmp/precompact-hook*.log 2>&1
```

Expected: grep finds nothing, ls reports all files missing.

- [ ] Clean

---

### Step 4 — Verify claude-code-setup plugin is installed

```bash
cat ~/.claude/plugins/installed_plugins.json | grep -i "claude-code-setup" && echo "INSTALLED" || echo "NOT INSTALLED"
```

- [ ] claude-code-setup confirmed installed

---

## PART B — Run /startnew

### Step 5 — Open TestProject in Claude Code and run /startnew

Open `/Users/alexk/Documents/TestProject` in Claude Code.  
Type `/startnew` and use the following exact inputs:

| Question | Input | What to verify |
|---|---|---|
| Q1 — Project name | `BookTracker` | Accepted |
| Q2 — Project type | `web app` | Accepted |
| Q3 — Tech stack | `suggest` | **See Step 5a** |
| Q4 — Goal | `A personal book tracker that logs what I've read and want to read` | Accepted |
| Q5 — Common commands | `suggest` | **See Step 5b** |
| Q6 — Reference links | `none` | No link-fetching step runs |
| **Memory mode** | `1` (perfect recall) | **See Step 5c** |

#### Step 5a — Verify `suggest` on Q3 (tech stack)

Claude should respond with one specific recommendation:
> "Based on what you've said, I'd suggest [specific stack] because [one-sentence reason]. Sound good, or want something different?"

**Pass:** Single recommendation, not a menu. Starts with "Based on what you've said". Relevant to a book-tracking web app.  
**Fail:** Multiple options as a list, or a clarifying question instead of proposing.

- [ ] PASS

#### Step 5b — Verify `suggest` on Q5 (common commands)

Same format check. Commands must match the Q3 stack.

- [ ] PASS

#### Step 5c — Verify memory mode question

The question should appear before hook creation and read approximately:

> "One quick choice — how should I handle memory during sessions?
> 1 — Perfect recall: I scan every exchange...roughly 100–200 extra tokens, maybe 5–10 times per session...
> 2 — Before-compact only: I only save memory when the session is nearly full (90% context)...Zero overhead...
> Type 1 or 2."

**Pass:** Both options explained in plain language, token cost mentioned for option 1, 90% threshold mentioned for option 2.

- [ ] Question appeared with both options explained
- [ ] Answered `1`

---

### Step 6 — Verify git init plain-language prompt

When /startnew reaches the git check:

> "Want me to set up version control for this folder? (This is called git init — it lets you save snapshots of your project as you work..."

**Answer: `yes`**

Also verify `.gitignore` explanation appears:
> "Also creating a .gitignore — this tells version control which files to ignore..."

- [ ] Plain-language git init prompt present
- [ ] .gitignore explanation present
- [ ] Git repo initialized

---

### Step 7 — Allow /startnew to complete fully

Let the full flow run including claude-code-setup analysis and final summary.

**After completion, immediately return to Step 2 and add debug instrumentation.**

- [ ] /startnew completed with final summary printed
- [ ] Debug instrumentation added (Step 2 done)

---

## PART C — Verify files created

### Step 8 — File existence checks

```bash
cd /Users/alexk/Documents/TestProject
ls -la CLAUDE.md memory/MEMORY.md memory/project.md .gitignore .claude/settings.json \
  .claude/hooks/memory-signal.sh .claude/hooks/memory-consolidate.sh
```

Expected: all present.

- [ ] All files present

### Step 9 — Specific content checks

#### 9a — Memory System before Tech Stack in CLAUDE.md
```bash
awk '/## Memory System/{m=NR} /## Tech Stack/{t=NR} END{if(m>0 && t>0 && m<t) print "PASS: Memory System line " m ", Tech Stack line " t; else print "FAIL"}' CLAUDE.md
```
- [ ] PASS

#### 9b — memory/MEMORY.md contains pointer to project.md
```bash
grep "project.md" memory/MEMORY.md && echo "PASS" || echo "FAIL"
```
- [ ] PASS

#### 9c — memory/project.md populated with intake answers
```bash
grep -i "BookTracker\|web app\|book tracker" memory/project.md && echo "PASS" || echo "FAIL"
```
- [ ] PASS

#### 9d — settings.json uses ${CLAUDE_PROJECT_DIR} paths (not relative)
```bash
grep "CLAUDE_PROJECT_DIR" .claude/settings.json && echo "PASS" || echo "FAIL: relative paths"
```
- [ ] PASS

#### 9e — settings.json is valid JSON
```bash
python3 -m json.tool .claude/settings.json > /dev/null && echo "VALID" || echo "INVALID"
```
- [ ] VALID

#### 9f — settings.json has correct hooks for mode 1 (both signal + consolidate, no sweep, no PreCompact)
```bash
python3 -m json.tool .claude/settings.json
```
Expected: Stop array contains memory-signal.sh and memory-consolidate.sh. No PreCompact key. No sweep.

- [ ] signal.sh present
- [ ] consolidate.sh present
- [ ] No sweep.sh
- [ ] No PreCompact block

#### 9g — Both hook scripts are executable
```bash
ls -la .claude/hooks/
```
Expected: both `.sh` files show `-rwxr-xr-x`.

- [ ] Both executable

#### 9h — Hooks use decision:block (not systemMessage)
```bash
grep "systemMessage" .claude/hooks/memory-signal.sh .claude/hooks/memory-consolidate.sh && echo "FAIL: old format" || echo "PASS"
grep "decision.*block" .claude/hooks/memory-signal.sh && echo "signal OK" || echo "FAIL"
grep "decision.*block" .claude/hooks/memory-consolidate.sh && echo "consolidate OK" || echo "FAIL"
```
- [ ] No systemMessage
- [ ] decision:block in both

#### 9i — Consolidate threshold is 200000
```bash
grep "THRESHOLD=" .claude/hooks/memory-consolidate.sh
```
Expected: `THRESHOLD=200000`

- [ ] PASS

#### 9j — .mcp.json (only if MCP servers were recommended)
```bash
ls -la .mcp.json 2>/dev/null && python3 -m json.tool .mcp.json || echo "No .mcp.json (OK if none recommended)"
```
- [ ] Present and valid, OR absent with reason confirmed

---

## PART D — Test memory-signal.sh (Pattern A — phrase-based)

**Context:** by the time /startnew finishes and you send your first message, the Stop counter is already 10–15 turns in. Cooldown will be satisfied from the first exchange.

**After each message:** send it, wait for Claude's full response, then check:
```bash
tail -20 /tmp/claude-hook-debug.log
ls -la memory/ && cat memory/MEMORY.md
```

### Step 10a — Trigger phrase: "we should use"

Send: **`I think we should use SQLite for this project — it's simpler`**

Prediction: **Pattern A FIRES** — `we should use` matches.

- [ ] Debug log shows `memory-signal.sh fired`
- [ ] A follow-up response from Claude appears
- [ ] Follow-up writes a new file under `memory/` or appends to existing
- [ ] Qualitative: _How does the follow-up appear? Does it feel natural?_ ___

Check cooldown state:
```bash
cat .claude/hooks/.ms_count
cat .claude/hooks/.ms_last
```
- [ ] .ms_last updated to current count

### Step 10b — Cooldown in effect: "worked"

Send immediately after 10a: **`That actually worked!`**

Prediction: **DOES NOT FIRE** — `worked` matches but cooldown active (< 5 turns since 10a).

- [ ] No follow-up response
- [ ] Debug log shows signal fired but exited early (no decision:block output)
- [ ] count minus last < 5

### Step 10c — Cooldown in effect: "I hate"

Send immediately: **`I hate the way that turned out`**

Prediction: **DOES NOT FIRE** — still in cooldown.

- [ ] No follow-up response

**Note:** 10b and 10c are intentional cooldown tests. Hook runs every turn — detection happens, fire is suppressed. Correct behavior.

---

## PART E — Test memory-signal.sh (Pattern B — option selection)

Allow cooldown to clear: send 4 neutral messages first.

### Step 11 — Pattern B: numbered options

Send: **`What are some database options for a personal book tracker?`**

Claude should respond with numbered options.

- [ ] Numbered list present in Claude's response

### Step 12 — Brief selection reply

Send: **`2`**

Prediction: **Pattern B FIRES** — prior response has numbered list + user reply is 1 word (< 10 words).

- [ ] Debug log shows memory-signal.sh fired
- [ ] Follow-up response appears
- [ ] Memory entry names WHAT option 2 was (e.g. "user chose PostgreSQL"), not just "user said 2"
  — this verifies the reason text instructs binding, not just logging the number
- [ ] Qualitative: _Was the binding accurate?_ ___

### Step 13 — Pattern B: lettered/bulleted options

Send: **`What are some ways to structure the reading list — alphabetical, by genre, or by status?`**

- [ ] Claude presents lettered or bulleted alternatives

### Step 14 — Deictic selection

Send: **`the second one`**

Prediction: **Pattern B FIRES** if prior response had list markers and reply is brief.

- [ ] Fires or not (note result): ___
- [ ] If fired: memory entry names the actual option, not "the second one"

### Step 15 — Affirmative without prior numbered list

Ask Claude to compare two approaches in paragraph form (no numbered list).
Then send: **`yeah let's go with that`**

Prediction: **MAY NOT FIRE** — Pattern B regex looks for list markers. Paragraph format may not match.

- [ ] Record: fired / did not fire, and what format Claude used: ___
- [ ] If did not fire: note as known gap (paragraph-form comparisons not caught by Pattern B)

---

## PART F — Cooldown behavior

### Steps 16–17 — Rapid-fire trigger test

Send these 6 messages back-to-back with no waiting:

1. `Let's use PostgreSQL instead`
2. `That worked perfectly`
3. `I prefer keeping it simple`
4. `The issue was a missing index`
5. `Switch to async functions throughout`
6. `Turns out it was a config problem`

After all 6 responses:
```bash
cat .claude/hooks/.ms_count   # total Stop events
cat .claude/hooks/.ms_last    # last fire turn
tail -50 /tmp/claude-hook-debug.log | grep "memory-signal"
```

**Pass criteria:**
- Signal fired AT MOST once per 5 Stop events
- No more than 2 fires across all 6 messages
- Counter increments once per message

- [ ] At most 2 fires observed
- [ ] Counter increments correctly

### Step 17 — Qualitative cadence judgment

_With decision:block producing a visible follow-up response, does the conversation feel interrupted? Should cooldown be raised to 8–10 turns?_ ___

---

## PART G — Test memory-consolidate.sh (90% checkpoint)

### Step 18 — Lower threshold temporarily

Edit the generated script:
```bash
nano /Users/alexk/Documents/TestProject/.claude/hooks/memory-consolidate.sh
```

Find `THRESHOLD=200000` and change to:
```bash
THRESHOLD=10000
```

This fires after ~10KB of transcript (5–10 exchanges).

- [ ] Threshold changed to 10000

### Step 19 — Trigger and verify

Send 6–8 messages of moderate length until the hook fires. Watch for:

**19a — Two-phase action:**
- [ ] Claude does NOT announce it's saving memory (silent phase 1)
- [ ] User-visible checkpoint message appears containing ALL of:
  - "this session is getting long"
  - "short-term memory will automatically shrink" (plain-language compaction explanation)
  - "1) Type /compact now"
  - "2) Keep going as-is"
  - "keep working and ignore me" (escape clause)

**19b — Reply "2" (keep going):**
- [ ] Session continues normally
- [ ] Checkpoint does NOT re-fire on next response (one-per-session check)

**19c — Fresh session, trigger again, reply "1" (compact path):**
- [ ] /compact invoked, session compacts cleanly

**19d — Fresh session, trigger again, ignore (send unrelated message):**
- [ ] Session continues without block
- [ ] Checkpoint does NOT re-fire

### Step 20 — Restore threshold

```bash
# In .claude/hooks/memory-consolidate.sh:
# Change THRESHOLD=10000 back to THRESHOLD=200000
grep "THRESHOLD=" /Users/alexk/Documents/TestProject/.claude/hooks/memory-consolidate.sh
```

Expected: `THRESHOLD=200000`

- [ ] Restored

---

## PART H — Failure modes watch list

Watch for these throughout Parts D–G:

| # | Failure mode | How to detect | Likely cause |
|---|---|---|---|
| J1 | Hook fires, no follow-up response in VS Code | Log shows fired, no Claude response | `decision:block` not processed by VS Code extension |
| J2 | Follow-up appears but doesn't write memory | Claude says "nothing to note" or ignores instruction | `reason` text not specific enough |
| J3 | Infinite loop: follow-up triggers another follow-up | Rapid consecutive Claude responses | Cooldown not preventing re-fire after decision:block |
| J4 | Memory write goes to wrong file or creates duplicates | `memory/` contains junk entries | Claude using wrong filename convention |
| J5 | Pattern B fires but entry says "user said 2" not option name | Literal number in memory file | `reason` for Pattern B not instructing binding clearly |
| J6 | Counter file corrupted | `cat .claude/hooks/.ms_count` returns non-number | Script write error — check disk/permissions |
| J7 | Consolidate fires again next session | `.mc_fired` contains old transcript path | Session tracking bug — confirm file stores current UUID path |
| J8 | decision:block loops permanently | Claude keeps generating follow-ups without stopping | Cooldown logic broken |

**Windows note:** Memory hooks are `.sh` only. Windows users get bash failures. Known gap, future work.

---

## PART I — Qualitative observations

**Write this paragraph TWICE** — once as the builder (you know every moving part), once as a first-time friend (no prior context). If the two diverge significantly, the friend version determines whether to ship.

Address all four points in each version:

1. **Follow-up responses:** Did the `decision:block` follow-up feel natural ("Noted — SQLite selected as database") or mechanical ("MEMORY WRITTEN: ...")? Did it interrupt flow?

2. **90% checkpoint:** Did the consolidate message feel like a helpful pause or an awkward block? Would a friend understand it without prior context?

3. **Cooldown cadence:** With 5 turns between fires, did memory-writes feel intrusive or background? Should this be raised to 8–10 turns?

4. **Pattern B binding:** When you replied "2" — did Claude's memory entry correctly name the option, or say "option 2"?

---

**Version 1 — As builder:**

_Write here:_

---

**Version 2 — As first-time friend:**

_Write here:_

---

**Divergence check:** Note what specifically diverged and what it implies for the design.

---

## PART J — Cleanup

### Step 21 — Remove debug instrumentation

For each script in `.claude/hooks/`:
- Delete the `=== DEBUG ===` block (4 lines) from the top
- Restore `INPUT="${_DEBUG_STDIN}"` → `INPUT=$(cat)` in consolidate and signal

```bash
grep -r "DEBUG" /Users/alexk/Documents/TestProject/.claude/hooks/ && echo "CLEANUP INCOMPLETE" || echo "CLEAN"
```

- [ ] Both scripts cleaned

### Step 22 — Delete debug log

```bash
rm /tmp/claude-hook-debug.log && echo "deleted" || echo "already gone"
```

- [ ] Deleted

### Step 23 — Confirm consolidate threshold restored

```bash
grep "THRESHOLD=" /Users/alexk/Documents/TestProject/.claude/hooks/memory-consolidate.sh
```

Expected: `THRESHOLD=200000`

- [ ] Confirmed

### Step 24 — Confirm no test hooks in user settings.json

```bash
grep -i "test-hook\|TEST_MARKER\|precompact-test" ~/.claude/settings.json && echo "PROBLEM" || echo "OK"
```

- [ ] Clean

---

## FINAL REPORT TEMPLATE

```
PASS / FAIL / PARTIAL per part:
  Part A (setup):              [ ]
  Part B (/startnew UX):       [ ]
  Part C (files):              [ ]
  Part D (Pattern A):          [ ]
  Part E (Pattern B):          [ ]
  Part F (cooldown):           [ ]
  Part G (consolidate):        [ ]
  Part H (no failures):        [ ]

Qualitative paragraph (Part I):
[write here]

Fixes applied during testing:
[file:line — what changed]

Recommended next action:
[ ] Ship as-is
[ ] Ship with documentation updates only
[ ] Fix specific issues before shipping — list:
```
