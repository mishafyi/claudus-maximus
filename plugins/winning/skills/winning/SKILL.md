---
name: winning
description: This skill should be used when the user asks to "optimize a task with parallel strategies", "deploy winning strategies", "run competing approaches", "find the best approach by trying multiple strategies", or mentions "winning", "parallel optimization", "strategy competition". Orchestrates multiple background agents running Ralph-style loops to converge on the best solution.
version: 0.5.0
---

# Winning Orchestrator

## Phase 0 -- Refine (Before Iteration 1)

Present **exactly 4 options**:

```
GOAL REFINEMENT -- Pick one or type your own:

(1) FAITHFUL REWRITE -- Restructured, nothing added.
    GOAL: [restate exact intent]  SUCCESS_METRIC: [from their words]  VERIFICATION: [obvious check]

(2) SUGGESTED METRICS -- Goal + concrete recommended metrics.
    GOAL: [intent + measurable targets]  SUCCESS_METRIC: [numbers/thresholds/pass-fail]  VERIFICATION: [specific command]

(3) 10X METRICS -- Same goal, 10x the bar.
    GOAL: [ambitious level]  SUCCESS_METRIC: [stretch targets]  VERIFICATION: [rigorous multi-point check]

(4) TYPE SOMETHING ELSE -- Describe your goal differently.
```

- Option 1: pure restructuring, add nothing user didn't say
- Option 2: industry-standard metrics (code -> coverage% + test count; perf -> latency + throughput; content -> word count + structure)
- Option 3: multiply Option 2 numerics by 2-5x (80% -> 95%, 500ms -> 100ms, 10 tests -> 50)
- All options need concrete VERIFICATION command
- Already precise goal -> recommend option 1 pre-selected
- Wait for selection, fill Goal Definition Template, proceed to Phase 1

**Example: User says "make my API faster"**

```
GOAL REFINEMENT -- Pick one or type your own:

(1) FAITHFUL REWRITE -- Restructured, nothing added.
    GOAL: Reduce API response times from current values to faster values
    SUCCESS_METRIC: API responses are measurably faster than before changes
    VERIFICATION: Run timing measurements before and after, compare results

(2) SUGGESTED METRICS -- Goal + concrete recommended metrics.
    GOAL: Reduce p95 response time of all API endpoints below 200ms
    SUCCESS_METRIC: p95 latency < 200ms across all endpoints under current production load
    VERIFICATION: `k6 run load-test.js --duration 60s | grep 'p(95)' # must show < 200ms`

(3) 10X METRICS -- Same goal, 10x the bar.
    GOAL: Reduce p95 response time below 50ms and support 10x current RPS without degradation
    SUCCESS_METRIC: p95 latency < 50ms at 10x current RPS; zero error rate increase
    VERIFICATION: `k6 run load-test.js --vus 500 --duration 120s | grep -E 'p\(95\)|http_req_failed' # p95 < 50ms AND failed = 0.00%`

(4) TYPE SOMETHING ELSE -- Describe your goal differently.
```

User picks (2). Orchestrator fills the Goal Definition Template using option (2)'s values and proceeds to Phase 1.

## Phase 1 -- Deploy (Iteration 1)

- Fill Goal Definition Template (all fields required)
- Load `references/strategy-patterns.md`, pick pattern via Selection Guide
- Fill Strategy Decomposition Template (one per strategy)
- Dispatch each as background Agent (see Agent Deployment)
- Initialize Score Table: `Progress=0`, `Velocity=N/A`, `Risk=7`
- No eliminations -- establish baseline

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
  RISK: Slow queries may not be the bottleneck -- latency could be network or serialization

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

Diversity check passed:
- No shared first actions (EXPLAIN ANALYZE vs. cache-ability audit vs. await chain audit)
- No identical intermediate artifacts (indexes vs. Redis config vs. refactored handlers)
- Each succeeds independently

Initial Score Table:

```
SCORES (iteration 1 of 8):
| Strategy              | Progress | Velocity | Risk | Status   |
|-----------------------|----------|----------|------|----------|
| A: Query-Optimization |     0    |   N/A    |   7  | ON_TRACK |
| B: Caching-Layer      |     0    |   N/A    |   7  | ON_TRACK |
| C: Async-Refactor     |     0    |   N/A    |   7  | ON_TRACK |

Decision: All strategies deployed. No eliminations -- establishing baseline.
```

## Phase 2 -- Assess (Iterations 2-3)

- Collect PROGRESS_REPORT blocks from agents
- Score all strategies (see Scoring System), compute velocity from delta
- Flag `Risk < 3` as danger zone
- Eliminate ONLY if ALL true: `Progress=0` AND `files_changed` empty AND agent BLOCKED/no report
- Otherwise redeploy for another iteration

**Example: Phase 2 assessment at iteration 2**

Agent A reported: progress_score=20, files_changed=[src/db/indexes.sql], assessment=ON_TRACK.
Agent B reported: progress_score=15, files_changed=[src/cache/redis.ts], assessment=ON_TRACK.
Agent C produced no PROGRESS_REPORT and no files.

```
SCORES (iteration 2 of 8):
| Strategy              | Progress | Velocity | Risk | Status   |
|-----------------------|----------|----------|------|----------|
| A: Query-Optimization |    20    |    7     |   8  | ON_TRACK |
| B: Caching-Layer      |    15    |    5     |   7  | ON_TRACK |
| C: Async-Refactor     |     0    |    0     |   3  | BLOCKED  |

Decision: C has Progress=0, files_changed empty, and no PROGRESS_REPORT. All three
conditions met -- eliminate C. A and B continue.
```

If Agent C had reported progress_score=0 but files_changed=[src/handlers/audit.md], the files_changed condition would NOT be met (list not empty), so C would NOT be eliminated -- redeployed instead.

## Phase 3 -- Eliminate (Iterations 4 to max-1)

- Hard kills: `Velocity < 2` -> kill; `Risk < 3` two consecutive -> kill
- `Progress >= 90` -> Victory Protocol
- One strategy left -> run uncontested
- All eliminated -> redeploy from failure analysis
- Redeployment: allowed if eliminated slot + >= 3 iterations remain + < 2 redeployments this run; new strategy must avoid failed approach
- All surviving `Velocity < 3` for 2 consecutive -> kill all, redeploy `STRATEGY_COUNT` new strategies avoiding low-velocity approaches

## Phase 4 -- Consolidate (Final Iteration)

- No eliminations. Pick highest Progress.
- `Progress >= 70`: consolidate as final result
- `Progress < 70`: best-effort with explicit gap analysis
- Merge eliminated strategies' non-overlapping files that cover unmet SUCCESS_METRIC parts; discard overlapping files
- Report final Score Table (all strategies including eliminated) with lessons

## Victory Protocol (Any Iteration)

Triggered at `Progress >= 90`. Run VERIFICATION_COMMAND on real output. Pass -> consolidate, terminate others, declare victory. Fail -> downgrade Progress, resume normal phase.

**Example: Victory Protocol verification at iteration 5**

Agent C reported progress_score=92. Orchestrator runs verification:

```
$ k6 run load-test.js --duration 60s | grep 'p(95)'
  http_req_duration...........: p(95)=140ms
```

140ms < 200ms target. Verification PASSES. Consolidate C's output, terminate Agent A, declare victory.

If result were p95=220ms: downgrade C's Progress from 92 to 70 (metric not met), set Risk=7, continue iteration 6 without victory.

## Goal Definition Template

Fill BEFORE deploying. Reject if any field not concrete.

```
GOAL: [one sentence, specific and measurable]
SUCCESS_METRIC: [binary pass/fail -- e.g., "all 47 tests pass", "response time < 200ms"]
VERIFICATION_COMMAND: [exact command proving success]
MAX_ITERATIONS: [hard cap, default: 10]
STRATEGY_COUNT: [2-4, default: 3]
COMPLETION_PROMISE: [exact output phrase on achievement]
ISOLATION_NEEDED: [yes/no -- yes if strategies modify overlapping files]
```

"Make it better" is not a goal. "All 47 tests pass with >80% coverage" is.

## Strategy Decomposition Template

One per strategy. Each MUST differ in approach, not minor details.

```
STRATEGY [A/B/C/D]:
  NAME: [short label]
  APPROACH: [1-2 sentences, fundamentally different path]
  FIRST_ACTION: [exact first thing agent does]
  EXPECTED_SIGNAL_BY_CYCLE_2: [what progress looks like if working]
  RISK: [primary failure mode]
```

Diversity check before dispatch: no shared first actions, no identical intermediate artifacts, each succeeds independently.

## Agent Deployment

Dispatch via Agent tool with `run_in_background: true`. Use `isolation: "worktree"` when `ISOLATION_NEEDED=yes`.

```
STRATEGY BRIEF
==============
GOAL: [from Goal Definition]
SUCCESS_METRIC: [from Goal Definition]
VERIFICATION_COMMAND: [from Goal Definition]

YOUR STRATEGY: [name] -- [approach]
FIRST_ACTION: [from decomposition]

RULES:
- Work in cycles: act -> verify -> assess -> next action
- Maximum 5 cycles before reporting final result
- If blocked for more than 1 cycle, report BLOCKED immediately
- Do not switch to a different strategy
- Provide verification evidence for every claim
- End your output with a PROGRESS_REPORT block

PROGRESS_REPORT FORMAT:
PROGRESS_REPORT:
- progress_score: [0-100]
- velocity: [0-10]
- blockers: [list or "none"]
- next_action: [what you would do next]
- files_changed: [list]
- tests_passing: [N passing / total, or "N/A"]
- assessment: [ON_TRACK | AT_RISK | BLOCKED | COMPLETED]
```

## Scoring System

Three dimensions per cycle, from PROGRESS_REPORT + artifacts + verification:

| Dimension | Range | Computation |
|-----------|-------|-------------|
| Progress | 0-100 | % goal done. Count files, tests, features. Verify agent self-report against artifacts. |
| Velocity | 0-10 | `min(10, (current_progress - previous_progress) / 3)`. 0 if flat, 10 if +30pts. |
| Risk | 0-10 | Start 10. Per blocker `-2`, no concrete next_action for remaining work `-3`, same blocker 2+ consecutive iterations `-3`, approach contradicts known constraint `-5`. Floor 0. |

### Thresholds

| Condition | Action |
|-----------|--------|
| `Velocity < 2` after iteration 3 | Kill immediately |
| `Risk < 3` two consecutive iterations | Kill immediately |
| `Progress >= 90` | Victory Protocol |
| All `Velocity < 3` after iteration 4 | Full redeployment |

### Score Table (update every iteration)

```
SCORES (iteration N of M):
| Strategy  | Progress | Velocity | Risk | Status       |
|-----------|----------|----------|------|--------------|
| A: [name] |    65    |    7     |   8  | ON_TRACK     |
| B: [name] |    30    |    2     |   4  | AT_RISK      |
| C: [name] |    --    |    --    |  --  | ELIMINATED@3 |

Decision: [what and why]
```

Status values: `ON_TRACK`, `AT_RISK`, `BLOCKED`, `COMPLETED`, `ELIMINATED@N`.

**Example: Scoring at iteration 4 with one elimination**

Agent A (Query-Optimization) reported: progress_score=65, fixed 3 slow queries, 2 endpoints under 200ms, 3 remain.
Agent B (Caching-Layer) reported: progress_score=30, Redis connected, cache hit rate 12%, no latency improvement.
Agent C (Async-Refactor) reported: progress_score=80, parallelized 4 handlers, p95 dropped from 450ms to 180ms.

Score computation:

- **Strategy A**: Progress=65 (3/5 endpoints fixed, verified). Previous=40. Velocity=min(10,(65-40)/3)=8. Risk=10-0=10 (no blockers).
- **Strategy B**: Progress=30 (Redis works, no latency gain). Previous=25. Velocity=min(10,(30-25)/3)=1. Risk=10-3(ambiguous work)-2(hit rate blocker)=5.
- **Strategy C**: Progress=80 (4/5 handlers done, measured). Previous=55. Velocity=min(10,(80-55)/3)=8. Risk=10-0=10 (one handler left).

```
SCORES (iteration 4 of 8):
| Strategy              | Progress | Velocity | Risk | Status       |
|-----------------------|----------|----------|------|--------------|
| A: Query-Optimization |    65    |    8     |  10  | ON_TRACK     |
| B: Caching-Layer      |    30    |    1     |   5  | ELIMINATED@4 |
| C: Async-Refactor     |    80    |    8     |  10  | ON_TRACK     |

Decision: Eliminated B -- Velocity=1 < 2 threshold after iteration 3. A and C both strong.
C closest to victory (Progress=80). If C hits 90 next iteration, enter Victory Protocol.
```

## Consolidation Output

```
RESULT
======
WINNING_STRATEGY: [name]
FINAL_SCORES: Progress=[N/100] Velocity=[N/10] Risk=[N/10]
ITERATIONS_USED: [N of max]

WHAT WAS DONE:
[bullet list of concrete changes/artifacts]

VERIFICATION:
[exact command and output]

SCORE HISTORY:
[full Score Table from each iteration]

ELIMINATED STRATEGIES:
- [name]: eliminated@[N], P=[x] V=[x] R=[x], reason: [one line]

LESSONS:
- [what scores revealed about which approaches work]
- [what failed and at what threshold]
```

**Example: Consolidation output for the API latency task**

```
RESULT
======
WINNING_STRATEGY: Async-Refactor
FINAL_SCORES: Progress=95/100 Velocity=8/10 Risk=10/10
ITERATIONS_USED: 6 of 8

WHAT WAS DONE:
- Refactored 5 request handlers from sequential await chains to Promise.all parallel I/O
- Added connection pooling (pool size 20) to database client in src/db/pool.ts
- Parallelized 3 independent downstream HTTP calls in src/handlers/dashboard.ts
- Reduced p95 from 450ms to 140ms across all endpoints

VERIFICATION:
$ k6 run load-test.js --duration 60s
  http_req_duration...........: avg=89ms  p(95)=140ms
  http_reqs...................: 12847 total, 214.1/s
  http_req_failed.............: 0.00%
RESULT: PASS -- p95=140ms < 200ms target

SCORE HISTORY:
  Iteration 1: A=0/NA/7 B=0/NA/7 C=0/NA/7
  Iteration 2: A=20/7/8  B=15/5/7  C=30/10/9
  Iteration 3: A=40/7/9  B=25/3/6  C=55/8/10
  Iteration 4: A=65/8/10 B=30/1/5(ELIMINATED) C=80/8/10
  Iteration 5: A=75/3/10 C=92/4/10 -> Victory Protocol triggered for C
  Iteration 6: Verification passed. C declared winner.

ELIMINATED STRATEGIES:
- Caching-Layer: eliminated@4, P=30 V=1 R=5, reason: Velocity=1 < 2 threshold; cache hit rate never exceeded 12%
- Query-Optimization: survived but lost, P=75 V=3 R=10, reason: effective but slower convergence

LESSONS:
- Async parallelization delivered fastest p95 improvement because bottleneck was sequential I/O, not query speed
- Caching failed because API serves mostly unique-per-user data with low cache hit potential
- Query optimization was viable but converged slower; right pick if bottleneck were database-bound
```

## References

- **`references/strategy-patterns.md`** -- pattern templates with selection guide
