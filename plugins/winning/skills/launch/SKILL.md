---
name: launch
description: This skill should be used when the user invokes /winning:launch to start a parallel strategy orchestration. Initializes the orchestrator loop and delegates to the winning skill.
argument-hint: "GOAL [--strategies N] [--max-iterations N] [--completion-promise TEXT]"
---

# Launch Winning Orchestration

This is a launcher only. It initializes state then delegates all orchestration logic to the winning skill.

## Step 1: Initialize

Execute the setup script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" $ARGUMENTS
```

## Step 2: Confirm Activation

Read `.claude/winning-orchestrator.local.md` to confirm the state file was created and contains valid configuration.

## Step 3: Delegate

Follow the orchestration process defined in `${CLAUDE_PLUGIN_ROOT}/skills/winning/SKILL.md` starting from "Phase 0 — Refine". Present the user with the 4 goal refinement options, wait for their choice, THEN proceed to Phase 1. Do not duplicate or reinterpret those instructions — execute them as written.

CRITICAL: When the goal is achieved, output `<promise>COMPLETION_PROMISE</promise>` with the exact promise text from the state file. Only output this when the statement is genuinely true.
