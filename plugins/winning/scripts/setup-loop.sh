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
      jq)
        echo "    macOS:  brew install jq" >&2
        echo "    Debian: sudo apt-get install jq" >&2
        echo "    Arch:   sudo pacman -S jq" >&2
        echo "    Fedora: sudo dnf install jq" >&2
        ;;
      perl)
        echo "    perl is usually pre-installed on macOS/Linux" >&2
        echo "    Debian: sudo apt-get install perl" >&2
        echo "    Arch:   sudo pacman -S perl" >&2
        echo "    Fedora: sudo dnf install perl" >&2
        ;;
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

# Validate prompt doesn't contain characters that break the heredoc state file
if [[ "$PROMPT" == *'EOF'* ]]; then
  echo "ERROR: Goal text must not contain the literal string 'EOF'" >&2
  echo "  This would break the internal state file format." >&2
  exit 1
fi

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

PHASE PROTOCOL (see SKILL.md for full details):

PHASE 1 — DEPLOY (iteration 1): Analyze goal, decompose into $STRATEGIES strategies, dispatch as background Agents with isolation: "worktree". Initialize Score Table.
PHASE 2 — ASSESS (iterations 2-3): Collect PROGRESS_REPORTs, score all strategies (Progress/Velocity/Risk). Only eliminate if Progress=0 and no signs of life.
PHASE 3 — ELIMINATE (iterations 4-$((MAX_ITERATIONS - 1))): Kill Velocity<2 or Risk<3 for 2 consecutive. Progress>=90 triggers Victory Protocol.
PHASE 4 — CONSOLIDATE (iteration $MAX_ITERATIONS): Pick highest Progress, merge partial results, output Score Table and lessons.

SCORE TABLE (update every iteration):
| Strategy | Progress | Velocity | Risk | Status |
|----------|----------|----------|------|--------|
| (fill after deployment) |

RULES: Score every strategy every iteration. Apply elimination thresholds mechanically. Kill underperformers immediately. No hedging.
When the goal is fully achieved, output: <promise>$COMPLETION_PROMISE</promise>
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
