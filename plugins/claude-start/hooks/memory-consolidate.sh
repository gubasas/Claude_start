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
