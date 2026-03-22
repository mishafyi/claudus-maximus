#!/bin/bash

# Winning Orchestrator Status Script
# Reports current orchestration state

set -euo pipefail

STATE_FILE=".claude/winning-orchestrator.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "No active winning orchestration."
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
STRATEGIES=$(echo "$FRONTMATTER" | grep '^strategies:' | sed 's/strategies: *//')
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' | sed 's/^"\(.*\)"$/\1/')

echo "🏁 Winning Orchestration Status"
echo "════════════════════════════════"
echo ""
echo "  Iteration:          $ITERATION / $MAX_ITERATIONS"
echo "  Strategies:         $STRATEGIES parallel"
echo "  Completion promise: $COMPLETION_PROMISE"
echo "  Started at:         $STARTED_AT"
echo ""

# Extract goal from prompt
GOAL=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE" | grep '^GOAL:' | sed 's/^GOAL: *//')
if [[ -n "$GOAL" ]]; then
  echo "  Goal: $GOAL"
fi

echo ""
echo "  State file: $STATE_FILE"
