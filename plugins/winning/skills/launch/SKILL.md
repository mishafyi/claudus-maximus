---
name: launch
description: This skill should be used when the user invokes /winning:launch to start a parallel strategy orchestration. Deploys multiple competing background agents on different approaches to solve a goal, monitors progress, eliminates underperformers, and consolidates the winning result.
argument-hint: "GOAL [--strategies N] [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh:*)", "Agent"]
---

# Launch Winning Orchestration

Execute the setup script to initialize the orchestrator loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" $ARGUMENTS
```

After setup completes, read the state file at `.claude/winning-orchestrator.local.md` to confirm activation.

Then immediately begin the orchestration process:

1. **Analyze the goal** — parse the task, define concrete success metrics
2. **Decompose into strategies** — create 2-4 genuinely different approaches (load `${CLAUDE_PLUGIN_ROOT}/skills/winning/references/strategy-patterns.md` for templates)
3. **Dispatch agents** — for each strategy, launch a background Agent using the Agent tool with:
   - `run_in_background: true`
   - `isolation: "worktree"` (when strategies modify overlapping files)
   - Clear task description including the strategy, success metrics, and iteration instructions
   - Instructions to work in cycles: implement → verify → iterate
4. **Monitor** — the Stop hook will keep the session alive. Each cycle, check on agent progress, evaluate results, eliminate underperformers
5. **Consolidate** — when a strategy wins, merge its work and report results

CRITICAL: When the goal is achieved, output `<promise>COMPLETION_PROMISE</promise>` with the exact promise text from the state file. Only output this when the statement is genuinely true.
