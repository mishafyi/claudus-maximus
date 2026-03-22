---
name: cancel
description: This skill should be used when the user invokes /winning:cancel to stop an active parallel strategy orchestration. Removes the orchestrator state file and disables the monitoring loop. Background strategy agents may continue running independently.
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cancel-loop.sh)", "Bash(test -f .claude/winning-orchestrator.local.md:*)", "Read(.claude/winning-orchestrator.local.md)"]
---

# Cancel Winning Orchestration

Execute the cancel script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/cancel-loop.sh"
```

Report the cancellation result to the user, including how many iterations were completed.

Important: Warn the user that background strategy-runner agents may still be running independently. Their results will no longer be orchestrated or consolidated.
