---
name: status
description: This skill should be used when the user invokes /winning:status to check progress of an active parallel strategy orchestration. Displays current iteration, deployed strategy count, elapsed time, goal text, completion promise, and interprets progress with actionable advice.
---

# Winning Status

Execute the status script to display all active orchestration state:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/status.sh"
```

If the state file exists, also read `.claude/winning-orchestrator.local.md` and present:
- Current iteration number and max iterations
- Current phase (Deploy / Assess / Eliminate / Consolidate)
- Completion promise
- Start time and elapsed duration
- Goal text
- Score Table (if populated)

If no state file exists, report: "No active winning orchestration."

## Interpretation

After presenting raw state, provide an interpretation based on the data:

### Phase Assessment

Determine the current phase from the iteration number and max_iterations:
- Iteration 1 → Phase: Deploy
- Iterations 2-3 → Phase: Assess
- Iterations 4 to (max-1) → Phase: Eliminate
- Final iteration → Phase: Consolidate

### Progress Interpretation

Read the Score Table from the state file. If scores are present, interpret them:

1. **Compute iteration ratio**: `current_iteration / max_iterations`
   - Ratio < 0.3: "Early stage — still establishing baselines"
   - Ratio 0.3-0.6: "Mid-stage — should see clear differentiation between strategies"
   - Ratio 0.6-0.8: "Late stage — winner should be emerging"
   - Ratio > 0.8: "Final stretch — consolidation imminent"

2. **Identify the leader**: Strategy with highest Progress score
   - Report: "Strategy [X] is leading with Progress=[N]"

3. **Flag concerns**:
   - Any strategy with Velocity < 2 after iteration 3: "Strategy [X] is stagnating (Velocity=[N]) — candidate for elimination"
   - Any strategy with Risk < 3: "Strategy [X] is in danger zone (Risk=[N])"
   - All strategies with Progress < 30 at ratio > 0.5: "WARNING: All strategies behind schedule. Consider redeployment."
   - No Score Table present after iteration 1: "WARNING: Scores not yet recorded. Orchestrator should score all strategies."

4. **Predict outcome**:
   - If leader has Progress >= 70 and Velocity >= 5: "On track — likely to succeed within remaining iterations"
   - If leader has Progress >= 70 and Velocity < 5: "Behind schedule — leader is slowing down"
   - If leader has Progress < 50 and ratio > 0.5: "At risk — insufficient progress for remaining iterations"
   - If leader has Progress >= 90: "Victory imminent — consolidation should begin"

### Advice

Based on the interpretation, provide one concrete recommendation:
- "Continue monitoring — strategies are differentiating as expected"
- "Consider eliminating Strategy [X] — it has breached the velocity threshold"
- "Trigger Victory Protocol — Strategy [X] has reached Progress >= 90"
- "Consider redeployment — all strategies are stagnating"
- "Begin consolidation — this is the final iteration"
