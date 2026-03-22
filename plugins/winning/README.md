# winning

Parallel strategy orchestrator for Claude Code. Deploys multiple competing approaches to solve a task, monitors progress, eliminates underperformers, and consolidates the winning result.

Built on a modernized Ralph Loop engine that supports orchestrator-level iteration with parallel background agents.

## Quick Start

```bash
/winning:launch "Build a REST API with CRUD operations and full test coverage" --strategies 3 --max-iterations 10
```

The orchestrator will:
1. Analyze the goal and decompose into 3 competing strategies
2. Dispatch each strategy as an isolated background agent
3. Monitor progress each cycle, eliminating underperformers
4. Consolidate the winning strategy's output when the goal is achieved

## Commands

| Command | Description |
|---------|-------------|
| `/winning:launch GOAL [OPTIONS]` | Start orchestration with parallel strategies |
| `/winning:status` | Show current orchestration progress |
| `/winning:cancel` | Cancel active orchestration |

### Launch Options

| Option | Default | Description |
|--------|---------|-------------|
| `--strategies N` | 3 | Number of parallel strategies (1-10) |
| `--max-iterations N` | 10 | Max orchestrator cycles |
| `--completion-promise TEXT` | "GOAL ACHIEVED" | Phrase signaling completion |

## How It Works

```
Goal → Decompose into N strategies
         ↓
    Deploy N background agents (each in isolated worktree)
         ↓
    Monitor cycle: check progress → eliminate losers → redirect resources
         ↓
    Winner found → consolidate output → done
         ↓
    All failed → analyze → new strategies → redeploy
```

The orchestrator runs as a Ralph-style loop in the main session. A Stop hook keeps the session alive between monitoring cycles. Each strategy executes independently in a background agent with its own worktree.

## Architecture

```
winning/
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/
│   ├── winning/                   # Main orchestrator skill (auto-triggered)
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── strategy-patterns.md
│   ├── launch/SKILL.md            # /winning:launch command
│   ├── status/SKILL.md            # /winning:status command
│   └── cancel/SKILL.md            # /winning:cancel command
├── agents/
│   └── strategy-runner.md         # Background agent for strategy execution
├── hooks/
│   ├── hooks.json                 # Stop hook registration
│   └── stop-hook.sh               # Orchestrator loop engine
└── scripts/
    ├── setup-loop.sh              # Initialize orchestrator state
    ├── status.sh                  # Report orchestration status
    └── cancel-loop.sh             # Cancel orchestration
```

## Requirements

- Claude Code with plugin support
- `ralph-loop` plugin NOT required (winning includes its own modernized loop engine)
- `jq` and `perl` available in PATH (standard on macOS/Linux)
