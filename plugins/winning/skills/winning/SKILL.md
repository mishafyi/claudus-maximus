---
name: winning
description: This skill should be used when the user asks to "optimize a task with parallel strategies", "deploy winning strategies", "run competing approaches", "find the best approach by trying multiple strategies", or mentions "winning", "parallel optimization", "strategy competition". Orchestrates multiple background agents running Ralph-style loops to converge on the best solution.
version: 0.1.0
---

# Winning Orchestrator

Parallel strategy orchestrator that deploys multiple competing approaches to solve a task, monitors their progress, eliminates underperformers, and consolidates the winning result.

## Architecture

The orchestrator operates as a Ralph-style loop in the main session. Within each iteration, it manages background agents that execute independent strategies.

**Flow:**
1. Define winning conditions — concrete metrics, hard deadline, resource budget
2. Decompose the task into 2-4 competing strategies
3. Dispatch each strategy as a background Agent with clear iteration instructions
4. Monitor progress each orchestrator cycle
5. Eliminate strategies that are not moving the needle
6. Consolidate the winning strategy's output
7. Exit when goal is met

## Goal Definition

Before deploying any agents, establish crystal-clear winning conditions:

- **Success metric**: Concrete, measurable, binary (pass/fail)
- **Max iterations**: Hard cap on orchestrator cycles (default: 10)
- **Strategy count**: Number of parallel approaches (default: 3)
- **Completion promise**: Exact phrase that signals the goal is achieved

Reject vague goals. "Make it better" is not a goal. "All 47 tests pass with >80% coverage" is.

## Strategy Decomposition

Break the task into genuinely different approaches. Not variations — fundamentally different strategies:

- **Approach diversity**: Each strategy must take a meaningfully different path
- **Independence**: Strategies must not depend on each other's output
- **Verifiability**: Each strategy must produce independently testable results

Example for "Build a REST API":
- Strategy A: TDD-first — write all tests, then implement to make them pass
- Strategy B: Schema-first — define OpenAPI spec, generate scaffolding, fill in logic
- Strategy C: Vertical slices — implement one complete endpoint at a time, iterate

## Agent Deployment

Dispatch each strategy as a background Agent using the Agent tool with `run_in_background: true`. Each agent receives:

1. The original task goal and success metrics
2. Its specific strategy instructions
3. Iteration guidance — work in cycles, verify after each cycle
4. Completion criteria matching the orchestrator's promise

Use `isolation: "worktree"` when strategies modify the same files to prevent conflicts.

## Monitoring and Elimination

Each orchestrator cycle:

1. Check which background agents have completed (via notifications)
2. For completed agents — evaluate their output against success metrics
3. For running agents — assess if the strategy is viable based on partial output
4. **Kill underperformers immediately** — do not wait for them to finish if a better strategy has already succeeded
5. Redirect resources to the winning approach

## Escalation Logic

- Goal hit by any strategy → consolidate that strategy's work, terminate others, report results
- All strategies failed → analyze failure modes, formulate new strategies, redeploy
- Max iterations reached → report best partial result with gap analysis

## Output

Final report includes:
- Which strategy won and why
- Iteration count and resource usage
- Consolidated result from the winning strategy
- Lessons from eliminated strategies (what failed and why)

## References

For strategy decomposition patterns, see:
- **`references/strategy-patterns.md`** — common strategy templates for different task types
