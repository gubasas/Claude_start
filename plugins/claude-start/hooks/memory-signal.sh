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
