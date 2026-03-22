---
name: cancel
description: This skill should be used when the user invokes /winning:cancel to stop an active parallel strategy orchestration. Salvages partial results before removing state, then disables the monitoring loop.
---

# Cancel Winning Orchestration

## Step 1 -- Salvage

BEFORE cancelling, read `.claude/winning-orchestrator.local.md` and extract:
- **Score Table**: identify leading strategy (highest Progress)
- **Goal**: what was being worked on
- **Iteration reached** and **phase** at cancellation

Check conversation for completed background agents. For each, note: STRATEGY RESULT status, PROGRESS_REPORT scores, and FILES_CHANGED list.

## Step 2 -- Cancel

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/cancel-loop.sh"
```

## Step 3 -- Report

1. **Cancellation confirmed**: iterations completed, phase at cancellation
2. **Salvaged results** (from completed or in-progress agents):
   - Leading strategy name and scores (Progress/Velocity/Risk)
   - Files changed by completed agents
   - Non-overlapping files from eliminated strategies that cover unmet SUCCESS_METRIC parts (per Phase 4 merge rules) -- flag these as candidates for manual merge
3. **Recommendation** (exactly one):

   | Condition                               | Recommendation                                                            |
   |-----------------------------------------|---------------------------------------------------------------------------|
   | Any strategy Progress >= 70             | "[X] was near completion. Its output in [files] may be directly usable."  |
   | Any strategy Progress 30-69             | "[X] made partial progress. Review [files] for reusable work."            |
   | No strategy exceeded Progress 30        | "No significant progress. Consider a different approach."                 |
   | Cancelled during iteration 1 (no scores)| "Cancelled before assessment. No partial results to salvage."             |

4. **Cleanup note**: Background strategy-runner agents may still be running independently. Their results will no longer be orchestrated. If using worktrees, run `git worktree list` to identify and `git worktree remove <path>` to clean up orphaned worktrees.
