---
name: status
description: This skill should be used when the user invokes /winning:status to check progress of an active parallel strategy orchestration. Displays current state and interprets progress with actionable advice.
---

# Winning Status

Run the status script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/status.sh"
```

If no state file exists, report "No active winning orchestration." and stop.

Read `.claude/winning-orchestrator.local.md` and present: iteration (current/max), active phase, goal, completion promise, elapsed time, and Score Table if populated.

## Interpret

Compute **iteration ratio** = `current_iteration / max_iterations` and classify:

| Ratio   | Stage       | Expectation                              |
|---------|-------------|------------------------------------------|
| < 0.3   | Early       | Establishing baselines                   |
| 0.3-0.6 | Mid         | Clear differentiation between strategies |
| 0.6-0.8 | Late        | Winner should be emerging                |
| > 0.8   | Final       | Consolidation imminent                   |

From the Score Table, identify the **leader** (highest Progress) and flag concerns:

| Condition                                           | Flag                                               |
|-----------------------------------------------------|----------------------------------------------------|
| Velocity < 2 after iteration 3                      | "[X] is stagnating -- candidate for elimination"   |
| Risk < 3                                            | "[X] is in danger zone"                            |
| All strategies Progress < 30 at ratio > 0.5         | "WARNING: All strategies behind schedule"           |
| No Score Table after iteration 1                    | "WARNING: Scores not yet recorded"                 |
| Leader Progress >= 90                               | "Victory imminent -- begin consolidation"          |
| Leader Progress >= 70 and Velocity >= 5             | "On track -- likely to succeed"                    |
| Leader Progress >= 70 and Velocity < 5              | "Leader is slowing down"                           |
| Leader Progress < 50 at ratio > 0.5                 | "At risk -- insufficient progress"                 |

## Advice

Provide exactly one recommendation based on the most critical flag above:
- "Continue monitoring" (no flags triggered)
- "Consider eliminating [X]" (velocity/risk threshold breached)
- "Trigger Victory Protocol" (Progress >= 90)
- "Consider redeployment" (all strategies stagnating)
- "Begin consolidation" (final iteration)
