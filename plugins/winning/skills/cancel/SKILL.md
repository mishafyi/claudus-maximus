---
name: cancel
description: This skill should be used when the user invokes /winning:cancel to stop an active parallel strategy orchestration. Salvages partial results before removing state, then disables the monitoring loop. Background strategy agents may continue running independently.
---

# Cancel Winning Orchestration

## Step 1 — Salvage Partial Results

BEFORE running the cancel script, read `.claude/winning-orchestrator.local.md` to extract:

1. **Score Table**: If scores exist, identify the leading strategy (highest Progress score)
2. **Goal**: What was being worked on
3. **Iteration reached**: How far the orchestration got
4. **Phase**: What phase was active (Deploy/Assess/Eliminate/Consolidate)

Check if any background agents have completed by looking for agent completion notifications in the conversation. For any completed agents:
- Note their final STRATEGY RESULT and PROGRESS_REPORT
- Note their FILES_CHANGED list
- Note their STATUS (SUCCEEDED / PARTIALLY_SUCCEEDED / FAILED / BLOCKED)

## Step 2 — Execute Cancellation

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/cancel-loop.sh"
```

## Step 3 — Report with Salvaged Context

Report to the user:

1. **Cancellation confirmed**: iterations completed, phase at cancellation
2. **Salvaged results** (if any agents completed or made progress):
   - Leading strategy name and its scores (Progress/Velocity/Risk)
   - Files changed by completed agents — these contain usable partial work
   - Whether any strategy was close to completion (Progress >= 70)
3. **Recommendation**:
   - If a strategy had Progress >= 70: "Strategy [X] was near completion. Its output in [files] may be directly usable."
   - If a strategy had Progress 30-69: "Strategy [X] made partial progress. Review [files] for reusable work."
   - If no strategy exceeded Progress 30: "No strategy made significant progress. Consider a different approach."
   - If no scores were recorded (cancelled during iteration 1): "Cancelled before assessment. No partial results to salvage."
4. **Warning**: Background strategy-runner agents may still be running independently. Their results will no longer be orchestrated or consolidated. If running in worktrees, those worktrees will persist until manually cleaned up.
