---
name: status
description: This skill should be used when the user invokes /winning:status to check progress of an active parallel strategy orchestration. Displays current iteration, deployed strategy count, elapsed time, goal text, and completion promise.
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/status.sh)", "Read(.claude/winning-orchestrator.local.md)"]
---

# Winning Status

Execute the status script to display all active orchestration state:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/status.sh"
```

If the state file exists, also read `.claude/winning-orchestrator.local.md` and present:
- Current iteration number
- Max iterations remaining
- Completion promise
- Start time and elapsed duration
- Goal text

If no state file exists, report: "No active winning orchestration."
