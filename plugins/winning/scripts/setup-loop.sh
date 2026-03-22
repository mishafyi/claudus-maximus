#!/bin/bash

# Winning Orchestrator Setup Script
# Modernized from Ralph Loop — creates orchestrator state file for parallel strategy management

set -euo pipefail

# Dependency checks — the stop hook requires jq and perl
MISSING_DEPS=()
if ! command -v jq >/dev/null 2>&1; then
  MISSING_DEPS+=("jq")
fi
if ! command -v perl >/dev/null 2>&1; then
  MISSING_DEPS+=("perl")
fi

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  echo "ERROR: Missing required dependencies: ${MISSING_DEPS[*]}" >&2
  echo "" >&2
  echo "  The winning orchestrator stop hook requires these tools at runtime." >&2
  echo "  Install them before launching:" >&2
  for dep in "${MISSING_DEPS[@]}"; do
    case "$dep" in
      jq)   echo "    brew install jq       # or: apt-get install jq" >&2 ;;
      perl) echo "    perl is usually pre-installed on macOS/Linux" >&2 ;;
    esac
  done
  exit 1
fi

# Validate session ID is available for session isolation
if [[ -z "${CLAUDE_CODE_SESSION_ID:-}" ]]; then
  echo "WARNING: CLAUDE_CODE_SESSION_ID is not set." >&2
  echo "  Session isolation will be disabled — the stop hook cannot verify" >&2
  echo "  that orchestration belongs to this session." >&2
  echo "  Proceeding anyway, but be cautious with multiple concurrent sessions." >&2
  echo "" >&2
fi

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
        echo "ERROR: --max-iterations requires a positive integer" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --completion-promise requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --strategies)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[1-9][0-9]*$ ]]; then
        echo "ERROR: --strategies requires a positive integer (1-10)" >&2
        exit 1
      fi
      if [[ "$2" -gt 10 ]]; then
        echo "ERROR: --strategies max is 10 (got: $2)" >&2
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
  echo "ERROR: No goal provided" >&2
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
  echo "WARNING: Active orchestration found at iteration $EXISTING_ITERATION" >&2
  echo "   Cancel it first with /winning:cancel" >&2
  exit 1
fi

mkdir -p .claude

STARTED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""

cat > .claude/winning-orchestrator.local.md <<EOF
---
active: true
iteration: 1
session_id: ${CLAUDE_CODE_SESSION_ID:-}
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
strategies: $STRATEGIES
started_at: "$STARTED_AT"
last_output_hash: ""
---

WINNING ORCHESTRATOR — ITERATION CYCLE

GOAL: $PROMPT

STRATEGIES TO DEPLOY: $STRATEGIES parallel approaches
MAX ITERATIONS: $MAX_ITERATIONS

PHASE PROTOCOL (follow the phase matching your current iteration):

PHASE 1 — DEPLOY (iteration 1):
  - Analyze the goal and fill the Goal Definition Template from SKILL.md
  - Decompose into $STRATEGIES genuinely different strategies
  - Dispatch each as a background Agent (strategy-runner) with run_in_background: true and isolation: "worktree"
  - Initialize Score Table: Progress=0, Velocity=N/A, Risk=7 for each strategy
  - Do NOT eliminate anything yet

PHASE 2 — ASSESS (iterations 2-3):
  - Check agent notifications and collect PROGRESS_REPORT blocks
  - Score every strategy: Progress (0-100), Velocity (0-10), Risk (0-10)
  - Velocity = min(10, (current_progress - previous_progress) / 3)
  - Risk starts at 10, subtract: blocker (-2), ambiguous work (-3), repeated failure (-3), fundamental approach flaw (-5)
  - Flag Risk < 3 as "danger zone"
  - Only eliminate if Progress=0 AND no signs of life
  - Otherwise let strategies continue

PHASE 3 — ELIMINATE (iterations 4 to $((MAX_ITERATIONS - 1)), if any):
  - Hard thresholds: Velocity < 2 = kill. Risk < 3 for 2 consecutive iterations = kill.
  - Progress >= 90 for any strategy = Victory Protocol (verify then consolidate)
  - All strategies eliminated = redeploy new strategies from failure analysis
  - All strategies Velocity < 3 = analyze stagnation, consider full redeployment

PHASE 4 — CONSOLIDATE (iteration $MAX_ITERATIONS, the final iteration):
  - No eliminations. Pick highest Progress score.
  - Progress >= 70: consolidate as final result
  - Progress < 70: consolidate best-effort with explicit gap analysis
  - Merge useful partial results from eliminated strategies
  - Output final Score Table and lessons learned

SCORE TABLE (update every iteration):
| Strategy | Progress | Velocity | Risk | Status |
|----------|----------|----------|------|--------|
| (fill after deployment) |

RULES:
- No hedging. Make decisions and execute.
- Score every strategy every iteration. No skipping scores.
- Apply elimination thresholds mechanically — do not make exceptions.
- Kill underperformers immediately when thresholds are breached.
- Failures surface immediately for aggressive pivot.
- Only output the completion promise when the goal is genuinely and verifiably achieved.
- When the goal is fully achieved, output: <promise>$COMPLETION_PROMISE</promise>
EOF

cat <<EOF
Winning orchestration activated!

Goal: $PROMPT
Strategies: $STRATEGIES parallel approaches
Max iterations: $MAX_ITERATIONS
Completion promise: $COMPLETION_PROMISE
Session: ${CLAUDE_CODE_SESSION_ID:-<not set>}
Started at: $STARTED_AT

The stop hook is now active. Each cycle, check on your deployed strategies,
eliminate underperformers, and consolidate when a winner emerges.

To monitor: /winning:status
To cancel:  /winning:cancel

================================================================
CRITICAL — Completion Promise
================================================================

To complete, output this EXACT text:
  <promise>$COMPLETION_PROMISE</promise>

ONLY when the goal is genuinely and verifiably achieved.
Do NOT output false promises to exit the loop.
================================================================
EOF

echo ""
echo "GOAL: $PROMPT"
echo ""
echo "Begin by analyzing this goal and decomposing it into $STRATEGIES competing strategies."
