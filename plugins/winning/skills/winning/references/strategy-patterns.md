# Strategy Patterns

Common strategy decomposition templates for different task types.

## Pattern Selection Guide

Use this decision tree to pick the right pattern. Match on task keywords.

```
TASK TYPE?
|
|-- Contains "build", "create", "implement", "add feature"
|   |-- Modifying existing codebase with established patterns? -> Methodology Split
|   |-- Greenfield / new module? -> Architecture Split
|
|-- Contains "fix", "bug", "broken", "error", "failing"
|   |-- Know which component is broken? -> Fix Approach Split
|   |-- Don't know where the bug is? -> Diagnosis Split
|
|-- Contains "slow", "optimize", "performance", "speed", "latency"
|   -> Dimension Split
|
|-- Contains "refactor", "restructure", "clean up", "migrate"
|   |-- High test coverage exists? -> Scope Split (Incremental)
|   |-- Low/no test coverage? -> Scope Split (Extract-and-replace)
|
|-- Contains "design", "UI", "UX", "content", "copy", "page"
|   -> Perspective Split
|
|-- None of the above? -> Methodology Split (safest default)
```

## Code Implementation Tasks

### Pattern: Methodology Split
Best for: Adding features to existing codebases with established conventions.

- **Strategy A -- TDD-first**: Write comprehensive tests, then implement to satisfy them
- **Strategy B -- Prototype-first**: Build working prototype fast, then add tests and refine
- **Strategy C -- Spec-first**: Define interfaces/types/schemas, then implement against contracts

Example brief for Strategy A (TDD-first on "add user authentication"):
```
YOUR STRATEGY: TDD-first — write all auth tests before writing any auth code
FIRST_ACTION: Write test cases for login, logout, token refresh, and permission checks using the project's existing test framework
```

### Pattern: Architecture Split
Best for: Greenfield projects or new modules where structure is undecided.

- **Strategy A -- Monolithic**: Single module, direct implementation, optimize later
- **Strategy B -- Modular**: Decompose into small focused modules from the start
- **Strategy C -- Event-driven**: Build around events/messages for loose coupling

Example brief for Strategy B (Modular on "build notification system"):
```
YOUR STRATEGY: Modular — separate transport, templating, and delivery into independent modules
FIRST_ACTION: Define module boundaries and interfaces for transport (email/SMS/push), template engine, and delivery scheduler
```

## Bug Fixing Tasks

### Pattern: Diagnosis Split
Best for: Bugs where the root cause location is unknown.

- **Strategy A -- Top-down**: Start from symptoms, trace through call stack
- **Strategy B -- Bottom-up**: Start from data layer, verify each layer upward
- **Strategy C -- Bisect**: Binary search through recent changes to isolate the breaking commit

Example brief for Strategy A (Top-down on "users see 500 error on checkout"):
```
YOUR STRATEGY: Top-down — start from the 500 error response and trace backward through the request handler
FIRST_ACTION: Find the checkout endpoint handler, add logging at entry/exit, reproduce the error, read the logs
```

### Pattern: Fix Approach Split
Best for: Bugs where the broken component is already identified.

- **Strategy A -- Minimal patch**: Smallest change that fixes the symptom
- **Strategy B -- Root cause**: Trace to fundamental issue, fix the underlying problem
- **Strategy C -- Rewrite**: Replace the buggy component entirely with cleaner implementation

Example brief for Strategy B (Root cause on "token refresh fails silently"):
```
YOUR STRATEGY: Root cause — trace why the refresh token flow fails instead of patching the symptom
FIRST_ACTION: Read the token refresh handler code, identify where errors are swallowed or state is lost
```

## Optimization Tasks

### Pattern: Dimension Split
Best for: Performance problems — speed, memory, throughput.

- **Strategy A -- Algorithmic**: Better data structures, reduced complexity
- **Strategy B -- Caching**: Add memoization, precomputation, result caching
- **Strategy C -- Parallelism**: Concurrent execution, batch processing, async operations

Example brief for Strategy A (Algorithmic on "search endpoint takes 3s"):
```
YOUR STRATEGY: Algorithmic — replace the linear scan with an indexed lookup
FIRST_ACTION: Profile the search endpoint to identify the hottest code path, measure current complexity
```

## Content/Design Tasks

### Pattern: Perspective Split
Best for: UI, UX, content, or design tasks with subjective quality criteria.

- **Strategy A -- User-first**: Optimize for end-user experience and clarity
- **Strategy B -- System-first**: Optimize for maintainability and extensibility
- **Strategy C -- Performance-first**: Optimize for speed and resource efficiency

## Refactoring Tasks

### Pattern: Scope Split
Best for: Restructuring existing code while maintaining behavior.

- **Strategy A -- Incremental**: Small safe refactors, one at a time, tests green after each
- **Strategy B -- Extract-and-replace**: Build new implementation alongside old, swap atomically
- **Strategy C -- Strangler fig**: Route new calls to new code, gradually migrate old callers

Example brief for Strategy A (Incremental on "extract payment logic from monolith"):
```
YOUR STRATEGY: Incremental — extract one function at a time, run tests after each extraction
FIRST_ACTION: Identify all payment-related functions in the monolith, list them by dependency order (leaves first)
```

## General Principles

1. **Genuine diversity**: Strategies must differ in approach, not just in minor details
2. **Independent execution**: No strategy should depend on another's output
3. **Measurable progress**: Each strategy must produce verifiable intermediate results
4. **Early signal**: Design strategies so failures surface fast, not at the end
