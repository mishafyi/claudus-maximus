#!/bin/bash

# Winning Orchestrator Cancel Script
# Removes orchestrator state file to stop the loop
# Includes session verification to prevent cross-session cancellation

set -euo pipefail

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

STATE_FILE=".claude/winning-orchestrator.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "No active winning orchestration to cancel."
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
STRATEGIES=$(echo "$FRONTMATTER" | grep '^strategies:' | sed 's/strategies: *//')
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' | sed 's/^"\(.*\)"$/\1/')
STATE_SESSION=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' || true)

# Session verification — prevent cancelling another session's orchestration
CURRENT_SESSION="${CLAUDE_CODE_SESSION_ID:-}"
if [[ -n "$STATE_SESSION" ]] && [[ -n "$CURRENT_SESSION" ]] && [[ "$STATE_SESSION" != "$CURRENT_SESSION" ]]; then
  if [[ $FORCE -eq 0 ]]; then
    echo "ERROR: This orchestration belongs to a different session." >&2
    echo "" >&2
    echo "  Orchestration session: $STATE_SESSION" >&2
    echo "  Current session:       $CURRENT_SESSION" >&2
    echo "" >&2
    echo "  To cancel anyway, use: /winning:cancel --force" >&2
    exit 1
  else
    echo "WARNING: Force-cancelling orchestration from different session." >&2
    echo "  Orchestration session: $STATE_SESSION" >&2
    echo "  Current session:       $CURRENT_SESSION" >&2
    echo "" >&2
  fi
fi

# Calculate elapsed time
ELAPSED_DISPLAY="unknown"
RATE_DISPLAY="--"

if [[ -n "$STARTED_AT" ]]; then
  START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$STARTED_AT" +%s 2>/dev/null \
    || date -d "$STARTED_AT" +%s 2>/dev/null \
    || echo "")
  if [[ -n "$START_EPOCH" ]]; then
    NOW_EPOCH=$(date +%s)
    ELAPSED_SECS=$((NOW_EPOCH - START_EPOCH))
    ELAPSED_HRS=$((ELAPSED_SECS / 3600))
    ELAPSED_MIN=$(( (ELAPSED_SECS % 3600) / 60 ))
    ELAPSED_SEC=$((ELAPSED_SECS % 60))

    if [[ $ELAPSED_HRS -gt 0 ]]; then
      ELAPSED_DISPLAY="${ELAPSED_HRS}h ${ELAPSED_MIN}m ${ELAPSED_SEC}s"
    elif [[ $ELAPSED_MIN -gt 0 ]]; then
      ELAPSED_DISPLAY="${ELAPSED_MIN}m ${ELAPSED_SEC}s"
    else
      ELAPSED_DISPLAY="${ELAPSED_SEC}s"
    fi

    # Calculate iteration rate
    if [[ $ELAPSED_SECS -gt 0 ]] && [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ $ITERATION -gt 0 ]]; then
      RATE_X100=$(( ITERATION * 6000 / ELAPSED_SECS ))
      RATE_WHOLE=$((RATE_X100 / 100))
      RATE_FRAC=$((RATE_X100 % 100))
      RATE_DISPLAY="${RATE_WHOLE}.$(printf '%02d' $RATE_FRAC) iter/min"
    fi
  fi
fi

# Extract goal for summary
GOAL=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE" | grep '^GOAL:' | sed 's/^GOAL: *//')

rm "$STATE_FILE"

echo "Winning orchestration cancelled."
echo ""
echo "  Summary:"
echo "  --------"
echo "  Completed iterations: $ITERATION / $MAX_ITERATIONS"
echo "  Strategies deployed:  $STRATEGIES"
echo "  Elapsed time:         $ELAPSED_DISPLAY"
echo "  Iteration rate:       $RATE_DISPLAY"
if [[ -n "$GOAL" ]]; then
  echo "  Goal:                 $GOAL"
fi
echo ""
echo "  Note: Background agents may still be running."
echo "  They will complete on their own but results won't be orchestrated."
