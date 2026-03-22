#!/bin/bash

# Winning Orchestrator Status Script
# Reports current orchestration state with elapsed time and iteration rate

set -euo pipefail

STATE_FILE=".claude/winning-orchestrator.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "No active winning orchestration."
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")

if [[ -z "$FRONTMATTER" ]]; then
  echo "ERROR: State file exists but contains no valid YAML frontmatter." >&2
  echo "  File: $STATE_FILE" >&2
  echo "  Recovery: rm $STATE_FILE" >&2
  exit 1
fi

ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
STRATEGIES=$(echo "$FRONTMATTER" | grep '^strategies:' | sed 's/strategies: *//')
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' | sed 's/^"\(.*\)"$/\1/')
SESSION_ID=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' || true)
LAST_OUTPUT_HASH=$(echo "$FRONTMATTER" | grep '^last_output_hash:' | sed 's/last_output_hash: *//' || echo "")

# Calculate elapsed time
ELAPSED_DISPLAY="unknown"
RATE_DISPLAY="--"
ELAPSED_SECS=0

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

    # Calculate iteration rate (iterations per minute)
    if [[ $ELAPSED_SECS -gt 0 ]] && [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ $ITERATION -gt 0 ]]; then
      RATE_X100=$(( ITERATION * 6000 / ELAPSED_SECS ))
      RATE_WHOLE=$((RATE_X100 / 100))
      RATE_FRAC=$((RATE_X100 % 100))
      RATE_DISPLAY="${RATE_WHOLE}.$(printf '%02d' $RATE_FRAC) iter/min"
    fi
  fi
fi

# Progress bar (guard against MAX_ITERATIONS=0 and overflow)
PROGRESS_BAR=""
if [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] && [[ $MAX_ITERATIONS -gt 0 ]]; then
  PCT=$((ITERATION * 100 / MAX_ITERATIONS))
  if [[ $PCT -gt 100 ]]; then PCT=100; fi
  FILLED=$((PCT / 5))
  EMPTY=$((20 - FILLED))
  PROGRESS_BAR="["
  for ((i=0; i<FILLED; i++)); do PROGRESS_BAR+="="; done
  if [[ $FILLED -lt 20 ]]; then PROGRESS_BAR+=">"; EMPTY=$((EMPTY - 1)); fi
  for ((i=0; i<EMPTY; i++)); do PROGRESS_BAR+=" "; done
  PROGRESS_BAR+="] ${PCT}%"
fi

# Stuck detection
STUCK_MSG=""
if [[ -n "$LAST_OUTPUT_HASH" ]]; then
  STUCK_MSG="  (tracking active)"
else
  STUCK_MSG="  (not yet tracked)"
fi

echo "Winning Orchestration Status"
echo "================================================================"
echo ""
echo "  Iteration:          $ITERATION / $MAX_ITERATIONS  $PROGRESS_BAR"
echo "  Strategies:         $STRATEGIES parallel"
echo "  Elapsed time:       $ELAPSED_DISPLAY"
echo "  Iteration rate:     $RATE_DISPLAY"
echo "  Completion promise: $COMPLETION_PROMISE"
echo "  Started at:         $STARTED_AT"
echo "  Session:            ${SESSION_ID:-<not set>}"
echo "  Stuck detection:    $STUCK_MSG"
echo ""

# Estimated time remaining (guard against zero iteration rate)
if [[ $ELAPSED_SECS -gt 0 ]] && [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ $ITERATION -gt 0 ]] && [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] && [[ $MAX_ITERATIONS -gt 0 ]]; then
  REMAINING_ITERS=$((MAX_ITERATIONS - ITERATION))
  if [[ $REMAINING_ITERS -gt 0 ]]; then
    SECS_PER_ITER=$((ELAPSED_SECS / ITERATION))
    if [[ $SECS_PER_ITER -gt 0 ]]; then
      ETA_SECS=$((REMAINING_ITERS * SECS_PER_ITER))
      ETA_MIN=$((ETA_SECS / 60))
      ETA_SEC=$((ETA_SECS % 60))
      if [[ $ETA_MIN -gt 0 ]]; then
        echo "  ETA (at current rate): ~${ETA_MIN}m ${ETA_SEC}s"
      else
        echo "  ETA (at current rate): ~${ETA_SEC}s"
      fi
    else
      echo "  ETA (at current rate): <1s per iteration"
    fi
    echo ""
  fi
fi

# Staleness warning: started > 1 hour ago with low iteration count
if [[ $ELAPSED_SECS -gt 3600 ]] && [[ "$ITERATION" =~ ^[0-9]+$ ]] && [[ $ITERATION -le 2 ]]; then
  echo "  WARNING: Orchestration may be stale — running for over 1 hour"
  echo "  with only $ITERATION iteration(s). Consider cancelling with /winning:cancel."
  echo ""
fi

# Extract goal from prompt
GOAL=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE" | grep '^GOAL:' | sed 's/^GOAL: *//')
if [[ -n "$GOAL" ]]; then
  echo "  Goal: $GOAL"
fi

echo ""
echo "  State file: $STATE_FILE"
