# winning

> v0.5.0

Parallel strategy orchestrator for Claude Code. Deploys multiple competing approaches to solve a task, scores their progress each cycle, eliminates underperformers, and consolidates the winning result.

## Quick Start

```bash
/winning:launch "Build a REST API with CRUD operations and full test coverage"
```

The orchestrator begins with **Phase 0 -- Goal Refinement** before deploying any agents:

```
GOAL REFINEMENT -- Pick one or type your own:

(1) FAITHFUL REWRITE -- Restructured, nothing added.
    GOAL: Build REST API with CRUD for all entities and full test coverage
    SUCCESS_METRIC: All CRUD endpoints respond correctly; test suite passes with coverage report
    VERIFICATION: Run test suite, check all endpoints return expected status codes

(2) SUGGESTED METRICS -- Goal + concrete recommended metrics.
    GOAL: Build REST API with CRUD for all entities, >80% test coverage, all endpoints return <200ms
    SUCCESS_METRIC: 100% of CRUD endpoints pass integration tests; coverage >= 80%
    VERIFICATION: `npm test -- --coverage | grep 'All files' # >= 80%`

(3) 10X METRICS -- Same goal, 10x the bar.
    GOAL: Build REST API with CRUD, >95% coverage, <50ms p95, input validation, error handling
    SUCCESS_METRIC: Coverage >= 95%; p95 < 50ms; all edge cases tested
    VERIFICATION: `npm test -- --coverage && k6 run load-test.js | grep 'p(95)'`

(4) TYPE SOMETHING ELSE -- Describe your goal differently.
```

You pick a number (or type a custom goal). Then the orchestrator proceeds through Phases 1-4 automatically.

## How It Works

```
User Goal
    |
    v
Phase 0: REFINE -- Present 4 goal options, user picks one
    |
    v
Phase 1: DEPLOY -- Decompose into N strategies, dispatch background agents
    |               Each agent runs in isolated worktree with own iteration loop
    v
Phase 2: ASSESS -- Collect progress reports, score (Progress/Velocity/Risk)
    |               Eliminate only if: Progress=0 AND no files AND agent blocked
    v
Phase 3: ELIMINATE -- Hard kills: Velocity<2 or Risk<3 twice
    |                  Victory Protocol if Progress>=90
    |                  Redeploy from failure analysis if all eliminated
    v
Phase 4: CONSOLIDATE -- Pick highest Progress, merge non-overlapping artifacts
    |                    Run verification command, report final scores
    v
  RESULT
```

### Scoring System

Each strategy is scored every cycle on three dimensions:

| Dimension | Range | Rule |
|-----------|-------|------|
| Progress | 0-100 | % of goal completed, verified against artifacts |
| Velocity | 0-10 | `min(10, (current_progress - previous_progress) / 3)` |
| Risk | 10 to 0 | Starts at 10. Deductions: blocker -2, no next_action -3, repeated blocker -3 |

### Victory Protocol

When any strategy hits Progress >= 90, the orchestrator runs the verification command on real output. If verification passes, that strategy wins immediately. If it fails, Progress is downgraded and normal iteration resumes.

## Commands

| Command | Description |
|---------|-------------|
| `/winning:launch GOAL [OPTIONS]` | Start orchestration with Phase 0 goal refinement |
| `/winning:status` | Show current scores and iteration progress |
| `/winning:cancel [--force]` | Cancel active orchestration |

### Launch Options

| Option | Default | Description |
|--------|---------|-------------|
| `--strategies N` | 3 | Number of parallel strategies (1-10) |
| `--max-iterations N` | 10 | Max orchestrator cycles |
| `--completion-promise TEXT` | "GOAL ACHIEVED" | Phrase signaling completion |

### Cancel Options

`/winning:cancel` cancels the current session's orchestration and salvages partial results from any agents that made progress.

`/winning:cancel --force` cancels the orchestration even if it belongs to a different Claude Code session. Use this when a previous session crashed or was closed without cancelling.

## Architecture

```
winning/
├── skills/
│   ├── winning/                   # Main orchestrator (Phase 0-4 logic)
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── strategy-patterns.md  # Pattern library with decision tree
│   ├── launch/SKILL.md            # /winning:launch -- init + delegate
│   ├── status/SKILL.md            # /winning:status -- show scores
│   └── cancel/SKILL.md            # /winning:cancel -- salvage + stop
├── agents/
│   └── strategy-runner.md         # Background agent template
├── hooks/
│   ├── hooks.json                 # Stop hook registration
│   └── stop-hook.sh               # Loop engine (keeps session alive)
└── scripts/
    ├── setup-loop.sh              # Initialize orchestrator state
    ├── status.sh                  # Report orchestration status
    └── cancel-loop.sh             # Cancel with session verification
```

## Requirements

- Claude Code with plugin support
- `jq` and `perl` available in PATH (standard on macOS/Linux)
- No external plugins required -- winning includes its own loop engine
