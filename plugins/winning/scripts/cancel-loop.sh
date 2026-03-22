#!/bin/bash

# Winning Orchestrator Cancel Script
# Removes orchestrator state file to stop the loop

set -euo pipefail

STATE_FILE=".claude/winning-orchestrator.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "No active winning orchestration to cancel."
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
STRATEGIES=$(echo "$FRONTMATTER" | grep '^strategies:' | sed 's/strategies: *//')

rm "$STATE_FILE"

echo "🛑 Winning orchestration cancelled."
echo "   Completed iterations: $ITERATION"
echo "   Strategies deployed:  $STRATEGIES"
echo ""
echo "   Note: Background agents may still be running."
echo "   They will complete on their own but results won't be orchestrated."
