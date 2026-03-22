#!/bin/bash

# Winning Orchestrator Stop Hook
# Modernized from Ralph Loop — supports orchestrator loop for parallel strategy management
# Prevents session exit while orchestration is active, feeds monitoring prompt back

set -euo pipefail

HOOK_INPUT=$(cat)

STATE_FILE=".claude/winning-orchestrator.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse YAML frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

if [[ -z "$FRONTMATTER" ]]; then
  echo "FATAL: State file exists but contains no YAML frontmatter." >&2
  echo "" >&2
  echo "  Recovery: Remove the corrupted state file and re-launch:" >&2
  echo "    rm .claude/winning-orchestrator.local.md" >&2
  echo "    /winning:launch YOUR_GOAL" >&2
  exit 0
fi

ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
STRATEGIES=$(echo "$FRONTMATTER" | grep '^strategies:' | sed 's/strategies: *//')
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' | sed 's/^"\(.*\)"$/\1/')
LAST_OUTPUT_HASH=$(echo "$FRONTMATTER" | grep '^last_output_hash:' | sed 's/last_output_hash: *//' || echo "")

# Session isolation
STATE_SESSION=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' || true)
HOOK_SESSION=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
if [[ -n "$STATE_SESSION" ]] && [[ "$STATE_SESSION" != "$HOOK_SESSION" ]]; then
  exit 0
fi

# Validate numeric fields with detailed corruption messages
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "FATAL: State file corrupted — 'iteration' field is not a valid number." >&2
  echo "  Found: iteration: '$ITERATION'" >&2
  echo "" >&2
  echo "  This usually happens when the state file was manually edited or" >&2
  echo "  a concurrent process wrote to it simultaneously." >&2
  echo "" >&2
  echo "  Recovery options:" >&2
  echo "    1. Fix manually: edit .claude/winning-orchestrator.local.md" >&2
  echo "       and set 'iteration' to a valid number (e.g., iteration: 1)" >&2
  echo "    2. Start fresh: rm .claude/winning-orchestrator.local.md" >&2
  echo "       then re-run /winning:launch with your goal" >&2
  rm "$STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "FATAL: State file corrupted — 'max_iterations' field is not a valid number." >&2
  echo "  Found: max_iterations: '$MAX_ITERATIONS'" >&2
  echo "" >&2
  echo "  Recovery options:" >&2
  echo "    1. Fix manually: edit .claude/winning-orchestrator.local.md" >&2
  echo "       and set 'max_iterations' to a valid number (e.g., max_iterations: 10)" >&2
  echo "    2. Start fresh: rm .claude/winning-orchestrator.local.md" >&2
  echo "       then re-run /winning:launch with your goal" >&2
  rm "$STATE_FILE"
  exit 0
fi

if [[ ! "$STRATEGIES" =~ ^[0-9]+$ ]]; then
  echo "FATAL: State file corrupted — 'strategies' field is not a valid number." >&2
  echo "  Found: strategies: '$STRATEGIES'" >&2
  echo "" >&2
  echo "  Recovery options:" >&2
  echo "    1. Fix manually: edit .claude/winning-orchestrator.local.md" >&2
  echo "       and set 'strategies' to a valid number (e.g., strategies: 3)" >&2
  echo "    2. Start fresh: rm .claude/winning-orchestrator.local.md" >&2
  echo "       then re-run /winning:launch with your goal" >&2
  rm "$STATE_FILE"
  exit 0
fi

# Calculate elapsed time
ELAPSED_MSG=""
if [[ -n "$STARTED_AT" ]]; then
  START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$STARTED_AT" +%s 2>/dev/null \
    || date -d "$STARTED_AT" +%s 2>/dev/null \
    || echo "")
  if [[ -n "$START_EPOCH" ]]; then
    NOW_EPOCH=$(date +%s)
    ELAPSED_SECS=$((NOW_EPOCH - START_EPOCH))
    ELAPSED_MIN=$((ELAPSED_SECS / 60))
    ELAPSED_SEC=$((ELAPSED_SECS % 60))
    if [[ $ELAPSED_MIN -gt 0 ]]; then
      ELAPSED_MSG="${ELAPSED_MIN}m${ELAPSED_SEC}s"
    else
      ELAPSED_MSG="${ELAPSED_SEC}s"
    fi
  fi
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Winning orchestrator: Max iterations ($MAX_ITERATIONS) reached after ${ELAPSED_MSG:-unknown time}."
  echo "   Consolidate the best result from deployed strategies."
  rm "$STATE_FILE"
  exit 0
fi

# Get transcript and check for completion promise
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "FATAL: Winning orchestrator — transcript file not found at: $TRANSCRIPT_PATH" >&2
  echo "" >&2
  echo "  This is unexpected. The transcript should exist at this point." >&2
  echo "  Recovery: rm .claude/winning-orchestrator.local.md" >&2
  rm "$STATE_FILE"
  exit 0
fi

if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "WARNING: Winning orchestrator — no assistant messages in transcript yet." >&2
  echo "  Transcript: $TRANSCRIPT_PATH" >&2
  echo "  This may happen on the first iteration. Removing state to prevent stuck loop." >&2
  rm "$STATE_FILE"
  exit 0
fi

# Cap transcript grep to last 200 lines for safety (transcripts can be huge)
LAST_LINES=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -n 200)
if [[ -z "$LAST_LINES" ]]; then
  rm "$STATE_FILE"
  exit 0
fi

set +e
LAST_OUTPUT=$(echo "$LAST_LINES" | jq -rs '
  map(.message.content[]? | select(.type == "text") | .text) | last // ""
' 2>&1)
JQ_EXIT=$?
set -e

if [[ $JQ_EXIT -ne 0 ]]; then
  echo "FATAL: Winning orchestrator — failed to parse transcript with jq." >&2
  echo "  jq output: $LAST_OUTPUT" >&2
  echo "" >&2
  echo "  This usually means the transcript JSON is malformed." >&2
  echo "  Recovery: rm .claude/winning-orchestrator.local.md" >&2
  rm "$STATE_FILE"
  exit 0
fi

# Detect stuck loop — hash the last output and compare to previous
CURRENT_HASH=$(printf '%s' "$LAST_OUTPUT" | shasum -a 256 | cut -d' ' -f1)
STUCK_WARNING=""
if [[ -n "$LAST_OUTPUT_HASH" ]] && [[ "$LAST_OUTPUT_HASH" == "$CURRENT_HASH" ]]; then
  STUCK_WARNING=" | WARNING: Output identical to previous iteration — agent may be stuck"
fi

# Check completion promise
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Winning orchestrator: Goal achieved after ${ELAPSED_MSG:-unknown time} — <promise>$COMPLETION_PROMISE</promise>"
    rm "$STATE_FILE"
    exit 0
  fi
fi

# Continue orchestrator loop
NEXT_ITERATION=$((ITERATION + 1))

# Extract prompt text (everything after closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "FATAL: Winning orchestrator — no prompt text found after YAML frontmatter." >&2
  echo "  The state file exists but the orchestration instructions are missing." >&2
  echo "" >&2
  echo "  Recovery: rm .claude/winning-orchestrator.local.md" >&2
  echo "  Then re-launch: /winning:launch YOUR_GOAL" >&2
  rm "$STATE_FILE"
  exit 0
fi

# Update iteration and last_output_hash atomically
TEMP_FILE="${STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$TEMP_FILE"

# Update or insert last_output_hash in frontmatter
if grep -q '^last_output_hash:' "$TEMP_FILE"; then
  sed -i '' "s/^last_output_hash:.*$/last_output_hash: $CURRENT_HASH/" "$TEMP_FILE"
else
  awk -v hash="$CURRENT_HASH" 'BEGIN{c=0} /^---$/{c++; if(c==2){print "last_output_hash: " hash}} {print}' "$TEMP_FILE" > "${TEMP_FILE}.2"
  mv "${TEMP_FILE}.2" "$TEMP_FILE"
fi

mv "$TEMP_FILE" "$STATE_FILE"

# Build system message
ITER_DISPLAY="$NEXT_ITERATION"
if [[ $MAX_ITERATIONS -gt 0 ]]; then
  ITER_DISPLAY="$NEXT_ITERATION/$MAX_ITERATIONS"
fi

ELAPSED_PART=""
if [[ -n "$ELAPSED_MSG" ]]; then
  ELAPSED_PART=" | elapsed: $ELAPSED_MSG"
fi

RATE_PART=""
if [[ -n "$ELAPSED_MSG" ]] && [[ -n "$START_EPOCH" ]]; then
  if [[ $ELAPSED_SECS -gt 0 ]] && [[ $NEXT_ITERATION -gt 1 ]]; then
    # iterations per minute, scaled by 100 for 2 decimal places
    RATE_X100=$(( (NEXT_ITERATION - 1) * 6000 / ELAPSED_SECS ))
    RATE_WHOLE=$((RATE_X100 / 100))
    RATE_FRAC=$((RATE_X100 % 100))
    RATE_PART=" | rate: ${RATE_WHOLE}.$(printf '%02d' $RATE_FRAC) iter/min"
  fi
fi

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="Winning iteration ${ITER_DISPLAY} | ${STRATEGIES} strategies${ELAPSED_PART}${RATE_PART}${STUCK_WARNING} | To finish: <promise>$COMPLETION_PROMISE</promise> (ONLY when TRUE)"
else
  SYSTEM_MSG="Winning iteration ${ITER_DISPLAY} | ${STRATEGIES} strategies${ELAPSED_PART}${RATE_PART}${STUCK_WARNING} | No completion promise set"
fi

jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
