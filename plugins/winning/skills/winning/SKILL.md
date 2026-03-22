---
name: winning
description: This skill should be used when the user asks to "optimize a task with parallel strategies", "deploy winning strategies", "run competing approaches", "find the best approach by trying multiple strategies", or mentions "winning", "parallel optimization", "strategy competition". Orchestrates multiple background agents running Ralph-style loops to converge on the best solution.
version: 0.5.0
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
- Option (2) must add industry-standard metrics for the task type: if the task involves code, add coverage percentage and test count; if it involves performance, add latency and throughput thresholds; if it involves content, add word count and structure requirements
- Option (3) must multiply Option (2) numeric metrics by 2-5x (e.g., 80% coverage becomes 95%, 500ms latency becomes 100ms, 10 tests becomes 50 tests)
- All options must have a concrete VERIFICATION command or check
- If the user's goal is already precise and measurable, say so and recommend skipping to Phase 1 with option (1) pre-selected

**Example: User says "make my API faster"**

```
GOAL REFINEMENT — Pick one or type your own:

(1) FAITHFUL REWRITE — Your goal, restructured into our framework. Nothing added.
    GOAL: Reduce API response times from current values to faster values
    SUCCESS_METRIC: API responses are measurably faster than before changes
    VERIFICATION: Run timing measurements before and after, compare results

(2) SUGGESTED METRICS — Your goal + concrete metrics we recommend.
    GOAL: Reduce p95 response time of all API endpoints below 200ms
    SUCCESS_METRIC: p95 latency < 200ms across all endpoints under current production load
    VERIFICATION: `k6 run load-test.js --duration 60s | grep 'p(95)' # must show < 200ms`

(3) 10X METRICS — Ambitious version. Same goal, 10x the bar.
    GOAL: Reduce p95 response time below 50ms and support 10x current RPS without degradation
    SUCCESS_METRIC: p95 latency < 50ms at 10x current RPS; zero error rate increase
    VERIFICATION: `k6 run load-test.js --vus 500 --duration 120s | grep -E 'p\(95\)|http_req_failed' # p95 < 50ms AND failed = 0.00%`

(4) TYPE SOMETHING ELSE — Not what you meant? Describe your goal differently.
```

User picks (2). Orchestrator fills the Goal Definition Template using option (2)'s values and proceeds to Phase 1.

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
6. Eliminate a strategy ONLY if ALL of these are true: Progress=0 AND files_changed is empty AND the agent reported BLOCKED or produced no PROGRESS_REPORT
7. If the conditions in step 6 are not all met, do not eliminate — redeploy the strategy for another iteration

### Phase 3 — Eliminate (Iterations 4 to max_iterations-1)

1. Score all strategies. Apply hard thresholds:
   - Velocity < 2 → kill immediately
   - Risk < 3 for two consecutive iterations → kill immediately
2. If any strategy hits Progress >= 90 → enter Victory Protocol
3. If only one strategy remains → let it run uncontested
4. If all strategies eliminated → redeploy new strategies derived from failure analysis
5. If a strategy is eliminated AND at least 3 iterations remain AND fewer than 2 redeployments have occurred this run: deploy a new strategy into the eliminated slot using failure analysis from the eliminated strategy's blockers to pick a different approach. Otherwise, do not redeploy.
6. If all surviving strategies have Velocity < 3 for 2 consecutive iterations: kill all strategies and redeploy STRATEGY_COUNT new strategies. Each new strategy must avoid the approaches that produced Velocity < 3.

### Phase 4 — Consolidate (Final Iteration)

1. No more eliminations. This is the last chance.
2. Pick the strategy with the highest Progress score
3. If Progress >= 70: consolidate its output as the final result
4. If Progress < 70: consolidate best-effort result with explicit gap analysis
5. For each eliminated strategy: if it produced files that the winning strategy did not produce AND those files address a part of the SUCCESS_METRIC not yet covered by the winner, merge those files into the final result. If the eliminated strategy's files overlap with the winner's files, discard the eliminated strategy's versions.
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

**Example: Phase 1 deployment for "reduce p95 latency < 200ms"**

Filled Goal Definition Template:

```
GOAL: Reduce p95 response time of all API endpoints below 200ms
SUCCESS_METRIC: p95 latency < 200ms across all endpoints under current production load
VERIFICATION_COMMAND: k6 run load-test.js --duration 60s | grep 'p(95)' # must show < 200ms
MAX_ITERATIONS: 8
STRATEGY_COUNT: 3
COMPLETION_PROMISE: "All API endpoints now respond with p95 < 200ms under load."
ISOLATION_NEEDED: yes
```

Filled Strategy Decomposition:

```
STRATEGY A:
  NAME: Query-Optimization
  APPROACH: Profile all SQL queries with EXPLAIN ANALYZE, add missing indexes, rewrite N+1 queries as JOINs
  FIRST_ACTION: Run EXPLAIN ANALYZE on the 5 slowest endpoints identified by current APM data
  EXPECTED_SIGNAL_BY_CYCLE_2: At least 2 slow queries identified with concrete optimization plans, 1 index added
  RISK: Slow queries may not be the bottleneck — latency could be network or serialization

STRATEGY B:
  NAME: Caching-Layer
  APPROACH: Add Redis caching for repeated reads, implement cache invalidation on writes, cache at the response level
  FIRST_ACTION: Identify the top 5 most-called GET endpoints and their cache-ability (idempotent, low-churn data)
  EXPECTED_SIGNAL_BY_CYCLE_2: Redis connected, at least 1 endpoint cached, before/after latency measured
  RISK: Cache invalidation bugs could serve stale data; cache misses may not improve p95

STRATEGY C:
  NAME: Async-Refactor
  APPROACH: Convert blocking I/O calls to async, parallelize independent downstream calls, add connection pooling
  FIRST_ACTION: Audit request handlers for sequential await chains that could be parallelized with Promise.all
  EXPECTED_SIGNAL_BY_CYCLE_2: At least 2 handlers refactored to parallel I/O, latency delta measured
  RISK: Parallelization may introduce race conditions; connection pool tuning may require iteration
```

Diversity check:
- [x] No two strategies share the same first action (EXPLAIN ANALYZE vs. cache-ability audit vs. await chain audit)
- [x] No two strategies produce identical intermediate artifacts (indexes vs. Redis config vs. refactored handlers)
- [x] Each strategy could succeed independently

Initial Score Table:

```
SCORES (iteration 1 of 8):
| Strategy              | Progress | Velocity | Risk | Status   |
|-----------------------|----------|----------|------|----------|
| A: Query-Optimization |     0    |   N/A    |   7  | ON_TRACK |
| B: Caching-Layer      |     0    |   N/A    |   7  | ON_TRACK |
| C: Async-Refactor     |     0    |   N/A    |   7  | ON_TRACK |

Decision: All strategies deployed. No eliminations — establishing baseline.
```

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
| **Risk** | 0-10 | Likelihood of success from current position. Start at 10, subtract: each active blocker reported by the agent (-2), remaining work that has no concrete next_action defined in the PROGRESS_REPORT (-3), agent reported the same blocker in 2+ consecutive iterations (-3), the strategy's core approach contradicts a known constraint from the Goal Definition (-5). Floor at 0. |

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
