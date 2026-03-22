---
name: winning
description: This skill should be used when the user asks to "optimize a task with parallel strategies", "deploy winning strategies", "run competing approaches", "find the best approach by trying multiple strategies", or mentions "winning", "parallel optimization", "strategy competition". Orchestrates multiple background agents running Ralph-style loops to converge on the best solution.
version: 0.4.0
---

# Winning Orchestrator

Parallel strategy orchestrator that deploys multiple competing approaches to solve a task, monitors their progress, eliminates underperformers, and consolidates the winning result.

## Iteration Protocol

The orchestrator's behavior is determined by which phase the current iteration falls into. Follow the matching phase exactly.

### Phase 0 — Refine (Before Iteration 1)

Before deploying anything, refine the user's raw prompt into a precision-engineered goal. A vague prompt produces vague strategies and wastes iterations.

1. Take the user's raw input
2. Analyze it for: specificity, measurability, verifiability, decomposability
3. Present the user with **exactly 4 options** using this format:

```
GOAL REFINEMENT — Pick one or type your own:

(1) FAITHFUL REWRITE — Your goal, restructured into our framework. Nothing added.
    GOAL: [restate their exact intent in one precise sentence]
    SUCCESS_METRIC: [derived strictly from what they said]
    VERIFICATION: [most obvious check based on their words]

(2) SUGGESTED METRICS — Your goal + concrete metrics we recommend.
    GOAL: [their intent + specific measurable targets]
    SUCCESS_METRIC: [concrete numbers, thresholds, or pass/fail criteria]
    VERIFICATION: [specific command or check to prove success]

(3) 10X METRICS — Ambitious version. Same goal, 10x the bar.
    GOAL: [their intent pushed to an ambitious but achievable level]
    SUCCESS_METRIC: [stretch targets — harder, faster, more comprehensive]
    VERIFICATION: [rigorous multi-point verification]

(4) TYPE SOMETHING ELSE — Not what you meant? Describe your goal differently.
```

4. Wait for the user to pick (1), (2), (3), or type a custom goal
5. Use the selected option to fill the Goal Definition Template
6. Proceed to Phase 1

**Rules for refinement:**
- Option (1) must NOT add anything the user didn't say — pure restructuring
- Option (2) should add reasonable, industry-standard metrics for the task type
- Option (3) should push metrics to an ambitious but not impossible level (e.g., 80% coverage → 95%, "works" → "works + load tested at 1000 RPS")
- All options must have a concrete VERIFICATION command or check
- If the user's goal is already precise and measurable, say so and recommend skipping to Phase 1 with option (1) pre-selected

### Phase 1 — Deploy (Iteration 1)

1. Parse the refined goal into the Goal Definition Template below — fill every field
2. Load `references/strategy-patterns.md` and use the Pattern Selection Guide to pick a pattern
3. Fill in the Strategy Decomposition Template below — one entry per strategy
4. Dispatch each strategy as a background Agent (see Agent Deployment)
5. Initialize the Score Table with: Progress=0, Velocity=N/A, Risk=7 (default optimistic)
6. Do NOT eliminate anything. Let all strategies establish a baseline.

### Phase 2 — Assess (Iterations 2-3)

1. Check which agents completed or sent notifications
2. Collect PROGRESS_REPORT blocks from agent output (see Structured Progress Reporting)
3. Score every strategy using the three-dimensional Scoring System below
4. Compute velocity from progress delta since last evaluation
5. Flag any strategy with Risk < 3 as "danger zone"
6. First elimination ONLY if a strategy has Progress=0 and shows zero signs of life
7. Otherwise, let strategies continue — too early for aggressive cuts

### Phase 3 — Eliminate (Iterations 4 to max_iterations-1)

1. Score all strategies. Apply hard thresholds:
   - Velocity < 2 → kill immediately
   - Risk < 3 for two consecutive iterations → kill immediately
2. If any strategy hits Progress >= 90 → enter Victory Protocol
3. If only one strategy remains → let it run uncontested
4. If all strategies eliminated → redeploy new strategies derived from failure analysis
5. Consider redeploying a new strategy into an eliminated slot if iterations remain
6. If all strategies have Velocity < 3 → analyze stagnation, consider full redeployment

### Phase 4 — Consolidate (Final Iteration)

1. No more eliminations. This is the last chance.
2. Pick the strategy with the highest Progress score
3. If Progress >= 70: consolidate its output as the final result
4. If Progress < 70: consolidate best-effort result with explicit gap analysis
5. Merge any useful partial results from eliminated strategies if they complement the winner
6. Report final Score Table for all strategies (including eliminated ones) with lessons learned

### Victory Protocol (Any Iteration)

Triggered when any strategy reaches Progress >= 90:

1. Verify the winning strategy's output against the original success metric
2. Run the VERIFICATION_COMMAND — check real output, not claims
3. If verification passes: consolidate output, terminate all other strategies, declare victory
4. If verification fails: downgrade Progress score to match reality, continue normal phase protocol

## Goal Definition Template

Fill this out BEFORE deploying any agents. Reject the task if any field cannot be filled concretely.

```
GOAL: [one sentence, specific and measurable]
SUCCESS_METRIC: [binary pass/fail test — e.g., "all 47 tests pass", "response time < 200ms"]
VERIFICATION_COMMAND: [exact command to run that proves success — e.g., "npm test", "curl -s localhost:3000/health"]
MAX_ITERATIONS: [hard cap on orchestrator cycles, default: 10]
STRATEGY_COUNT: [2-4, default: 3]
COMPLETION_PROMISE: [exact phrase output when goal is achieved]
ISOLATION_NEEDED: [yes/no — yes if strategies modify overlapping files]
```

"Make it better" is not a goal. "All 47 tests pass with >80% coverage" is.

## Strategy Decomposition Template

Fill one entry per strategy. Each strategy MUST differ in approach, not just in minor details.

```
STRATEGY [A/B/C/D]:
  NAME: [short label — e.g., "TDD-first"]
  APPROACH: [1-2 sentences describing the fundamentally different path this takes]
  FIRST_ACTION: [the exact first thing this agent should do — e.g., "write test cases for all endpoints"]
  EXPECTED_SIGNAL_BY_CYCLE_2: [what progress looks like if this strategy is working — e.g., "3+ tests written and failing"]
  RISK: [primary way this strategy might fail — e.g., "test design may not cover edge cases"]
```

### Diversity Check

Before dispatching, verify:
- [ ] No two strategies share the same first action
- [ ] No two strategies would produce identical intermediate artifacts
- [ ] Each strategy could succeed even if the others fail completely

## Agent Deployment

Dispatch each strategy as a background Agent using the Agent tool with `run_in_background: true`. Each agent receives a brief structured exactly as follows:

```
STRATEGY BRIEF
==============
GOAL: [from Goal Definition]
SUCCESS_METRIC: [from Goal Definition]
VERIFICATION_COMMAND: [from Goal Definition]

YOUR STRATEGY: [name] — [approach description]
FIRST_ACTION: [from decomposition template]

RULES:
- Work in cycles: act -> verify -> assess -> next action
- Maximum 5 cycles before reporting final result
- If blocked for more than 1 cycle, report BLOCKED immediately
- Do not switch to a different strategy
- Provide verification evidence for every claim
- End your output with a PROGRESS_REPORT block (format below)

PROGRESS_REPORT FORMAT (emit this at the end of your work):
PROGRESS_REPORT:
- progress_score: [0-100, your honest estimate of goal completion percentage]
- velocity: [0-10, how much progress you made this cycle]
- blockers: [list of things preventing progress, or "none"]
- next_action: [what you would do next if given another cycle]
- files_changed: [list of files you created or modified]
- tests_passing: [number passing / total, or "N/A"]
- assessment: [ON_TRACK | AT_RISK | BLOCKED | COMPLETED]
```

Use `isolation: "worktree"` when `ISOLATION_NEEDED` is yes.

## Scoring System

Every strategy is scored on three dimensions each orchestrator cycle. Scores are assigned by the orchestrator based on agent PROGRESS_REPORT output, observable artifacts (files created, tests passing), and verification command results.

### Score Dimensions

| Dimension | Range | How to Compute |
|-----------|-------|----------------|
| **Progress** | 0-100 | Percentage of goal completion. What fraction of deliverables exist and are verified? Count concrete evidence: files created, tests passing, features working. Agent self-report is input but verify against artifacts. |
| **Velocity** | 0-10 | Rate of progress per iteration. Formula: `min(10, (current_progress - previous_progress) / 3)`. Score 0 if progress unchanged. Score 10 if progress jumped 30+ points. |
| **Risk** | 0-10 | Likelihood of success from current position. Start at 10, subtract: each active blocker (-2), ambiguous remaining work (-3), repeated failure on same issue (-3), fundamental approach flaw (-5). Floor at 0. |

### Elimination Thresholds

| Threshold | Condition | Action |
|-----------|-----------|--------|
| **Elimination** | Velocity < 2 after iteration 3 | Kill the strategy immediately. |
| **Danger zone** | Risk < 3 at any point | Flag. Kill if Risk stays < 3 next iteration. |
| **Victory** | Progress >= 90 | Enter Victory Protocol. Verify and consolidate. |
| **Stagnation** | All strategies Velocity < 3 after iteration 4 | Full redeployment with new strategies. |

### Score Table Format

Maintain this table in orchestrator state. Update every iteration.

```
SCORES (iteration N of M):
| Strategy   | Progress | Velocity | Risk | Status      |
|------------|----------|----------|------|-------------|
| A: [name]  |    65    |    7     |   8  | ON_TRACK    |
| B: [name]  |    30    |    2     |   4  | AT_RISK     |
| C: [name]  |    --    |    --    |  --  | ELIMINATED@3|

Decision: [what the orchestrator decided and why]
```

Use status values: `ON_TRACK`, `AT_RISK`, `BLOCKED`, `COMPLETED`, `ELIMINATED@N` (where N is the iteration it was killed).

## Consolidation Output

```
RESULT
======
WINNING_STRATEGY: [name]
FINAL_SCORES:
  Progress: [N/100]
  Velocity: [N/10]
  Risk: [N/10]
ITERATIONS_USED: [N of max]

WHAT WAS DONE:
[bullet list of concrete changes/artifacts]

VERIFICATION:
[exact command run and its output]

SCORE HISTORY:
[the full Score Table from each iteration, showing progression]

ELIMINATED STRATEGIES:
- [name]: eliminated at iteration [N], final scores P=[x] V=[x] R=[x], reason: [one line]

LESSONS:
- [what the scores revealed about which approaches work for this type of task]
- [what failed about eliminated approaches and at what threshold]
```

## References

For strategy pattern selection, see:
- **`references/strategy-patterns.md`** — pattern templates with selection guide
