#!/bin/bash

# Winning Orchestrator Setup Script
# Modernized from Ralph Loop — creates orchestrator state file for parallel strategy management

set -euo pipefail

PROMPT_PARTS=()
MAX_ITERATIONS=10
COMPLETION_PROMISE="GOAL ACHIEVED"
STRATEGIES=3

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Winning Orchestrator — parallel strategy deployment

USAGE:
  /winning:launch GOAL [OPTIONS]

ARGUMENTS:
  GOAL    The task to optimize with parallel strategies

OPTIONS:
  --strategies <n>               Number of parallel strategies (default: 3)
  --max-iterations <n>           Max orchestrator cycles (default: 10)
  --completion-promise '<text>'  Promise phrase signaling goal achieved (default: "GOAL ACHIEVED")
  -h, --help                     Show this help

EXAMPLES:
  /winning:launch "Build a REST API with full test coverage" --strategies 3
  /winning:launch "Fix the auth bug" --max-iterations 5 --completion-promise "BUG FIXED"
  /winning:launch "Refactor payment module" --strategies 2 --max-iterations 15

STOPPING:
  /winning:cancel    Cancel the orchestration
  /winning:status    Check current progress
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: --max-iterations requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --completion-promise requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --strategies)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
        echo "❌ Error: --strategies requires a positive integer (1-10)" >&2
        exit 1
      fi
      if [[ "$2" -gt 10 ]]; then
        echo "❌ Error: --strategies max is 10 (got: $2)" >&2
        exit 1
      fi
      STRATEGIES="$2"
      shift 2
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

PROMPT="${PROMPT_PARTS[*]:-}"

if [[ -z "$PROMPT" ]]; then
  echo "❌ Error: No goal provided" >&2
  echo "" >&2
  echo "  Examples:" >&2
  echo "    /winning:launch Build a REST API with tests" >&2
  echo "    /winning:launch Fix the auth bug --strategies 2" >&2
  echo "" >&2
  echo "  For all options: /winning:launch --help" >&2
  exit 1
fi

# Check for existing orchestration
if [[ -f ".claude/winning-orchestrator.local.md" ]]; then
  EXISTING_ITERATION=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' ".claude/winning-orchestrator.local.md" | grep '^iteration:' | sed 's/iteration: *//')
  echo "⚠️  Active orchestration found at iteration $EXISTING_ITERATION" >&2
  echo "   Cancel it first with /winning:cancel" >&2
  exit 1
fi

mkdir -p .claude

COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""

cat > .claude/winning-orchestrator.local.md <<EOF
---
active: true
iteration: 1
session_id: ${CLAUDE_CODE_SESSION_ID:-}
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
strategies: $STRATEGIES
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

WINNING ORCHESTRATOR — ITERATION CYCLE

GOAL: $PROMPT

STRATEGIES TO DEPLOY: $STRATEGIES parallel approaches

ORCHESTRATOR INSTRUCTIONS:
1. If this is iteration 1 — analyze the goal, decompose into $STRATEGIES genuinely different strategies, and dispatch each as a background Agent (strategy-runner) with run_in_background: true and isolation: "worktree"
2. If this is a subsequent iteration — check on deployed agents, evaluate progress against goal metrics
3. Eliminate any strategy that is clearly failing or falling behind
4. If a strategy has succeeded — consolidate its output, terminate remaining agents
5. If all strategies failed — analyze failure modes, formulate new approaches, redeploy
6. When the goal is fully achieved, output: <promise>$COMPLETION_PROMISE</promise>

RULES:
- No hedging. Make decisions and execute.
- Kill underperformers immediately. Resources go only to what works.
- Failures surface immediately for aggressive pivot.
- Only output the completion promise when the goal is genuinely and verifiably achieved.
EOF

cat <<EOF
🏁 Winning orchestration activated!

Goal: $PROMPT
Strategies: $STRATEGIES parallel approaches
Max iterations: $MAX_ITERATIONS
Completion promise: $COMPLETION_PROMISE

The stop hook is now active. Each cycle, check on your deployed strategies,
eliminate underperformers, and consolidate when a winner emerges.

To monitor: /winning:status
To cancel:  /winning:cancel

═══════════════════════════════════════════════════════════
CRITICAL — Completion Promise
═══════════════════════════════════════════════════════════

To complete, output this EXACT text:
  <promise>$COMPLETION_PROMISE</promise>

ONLY when the goal is genuinely and verifiably achieved.
Do NOT output false promises to exit the loop.
═══════════════════════════════════════════════════════════
EOF

echo ""
echo "GOAL: $PROMPT"
echo ""
echo "Begin by analyzing this goal and decomposing it into $STRATEGIES competing strategies."
