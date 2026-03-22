# Strategy Patterns

Common strategy decomposition templates for different task types. Select and adapt patterns based on the task domain.

## Code Implementation Tasks

### Pattern: Methodology Split
- **Strategy A — TDD-first**: Write comprehensive tests, then implement to satisfy them
- **Strategy B — Prototype-first**: Build working prototype fast, then add tests and refine
- **Strategy C — Spec-first**: Define interfaces/types/schemas, then implement against contracts

### Pattern: Architecture Split
- **Strategy A — Monolithic**: Single module, direct implementation, optimize later
- **Strategy B — Modular**: Decompose into small focused modules from the start
- **Strategy C — Event-driven**: Build around events/messages for loose coupling

## Bug Fixing Tasks

### Pattern: Diagnosis Split
- **Strategy A — Top-down**: Start from symptoms, trace through call stack
- **Strategy B — Bottom-up**: Start from data layer, verify each layer upward
- **Strategy C — Bisect**: Binary search through recent changes to isolate the breaking commit

### Pattern: Fix Approach Split
- **Strategy A — Minimal patch**: Smallest change that fixes the symptom
- **Strategy B — Root cause**: Trace to fundamental issue, fix the underlying problem
- **Strategy C — Rewrite**: Replace the buggy component entirely with cleaner implementation

## Optimization Tasks

### Pattern: Dimension Split
- **Strategy A — Algorithmic**: Better data structures, reduced complexity
- **Strategy B — Caching**: Add memoization, precomputation, result caching
- **Strategy C — Parallelism**: Concurrent execution, batch processing, async operations

## Content/Design Tasks

### Pattern: Perspective Split
- **Strategy A — User-first**: Optimize for end-user experience and clarity
- **Strategy B — System-first**: Optimize for maintainability and extensibility
- **Strategy C — Performance-first**: Optimize for speed and resource efficiency

## Refactoring Tasks

### Pattern: Scope Split
- **Strategy A — Incremental**: Small safe refactors, one at a time, tests green after each
- **Strategy B — Extract-and-replace**: Build new implementation alongside old, swap atomically
- **Strategy C — Strangler fig**: Route new calls to new code, gradually migrate old callers

## General Principles

1. **Genuine diversity**: Strategies must differ in approach, not just in minor details
2. **Independent execution**: No strategy should depend on another's output
3. **Measurable progress**: Each strategy must produce verifiable intermediate results
4. **Early signal**: Design strategies so failures surface fast, not at the end
