# claudus-maximus

A Claude Code plugin marketplace. Four plugins that give Claude superpowers it doesn't ship with — diagramming from real code analysis, evolutionary multi-agent problem solving, live job search for frontier tech, and a newspaper-grade writing guideline for long-form content.

## Install

```bash
/plugin marketplace add mishafyi/claudus-maximus
```

Then install individual plugins:

```bash
/plugin install diagram@claudus-maximus
/plugin install winning@claudus-maximus
/plugin install career-companion@claudus-maximus
/plugin install journalist@claudus-maximus
```

## Plugins

| Plugin                                | Version | Category      | What it does                                                                       |
| ------------------------------------- | ------- | ------------- | ---------------------------------------------------------------------------------- |
| [diagram](#diagram)                   | 1.2.0   | visualization | Generates Mermaid diagrams from actual codebase analysis — not guesswork           |
| [winning](#winning)                   | 0.8.0   | orchestration | Deploys parallel agents on competing strategies, keeps the winner                  |
| [career-companion](#career-companion) | 1.0.0   | productivity  | Searches 20,000+ live jobs, tailors resumes, runs mock interviews                  |
| [journalist](#journalist)             | 1.1.0   | productivity  | Newspaper prose discipline + narrative craft for any extended long-form writing    |

---

### diagram

Two-agent pipeline that reads your code first, then produces accurate Mermaid `.mmd` files.

**How it works:**

1. **code-explorer** traces execution paths, maps architecture, documents dependencies
2. **diagram-builder** reads the correct Mermaid syntax reference, converts analysis into color-coded diagrams

Supports 27 diagram types — flowcharts, sequence diagrams, ER diagrams, architecture maps, C4, state machines, Gantt, mindmaps, Kanban, and more.

**Try it:**

```
draw the auth flow
create an architecture diagram of this project
diagram the database schema
```

**Components:** 2 agents (code-explorer, diagram-builder), 1 skill, 27 Mermaid syntax references

---

### winning

> Winning is all that matters. Winning is the only goal.

Evolutionary parallel strategy orchestrator. Deploys 3 agents per round on different strategies, compares results against a verification command, records what worked and what didn't, then redeploys with accumulated learnings. No cycle limits. No round limits. Loops until the goal is verifiably achieved.

**How it works:**

```
Goal → Refine → Deploy 3 agents → Verify → None pass? → Record learnings → Redeploy → ...
                                          → One passes? → Consolidate → Done
```

**Try it:**

```
/winning:launch "Refactor the payment module to use the strategy pattern with full test coverage"
/winning:how-to-win "What's the best approach to migrate from REST to GraphQL?"
/winning:status
/winning:cancel
```

**Components:** 2 agents, 4 commands, 2 skills, hooks, shell scripts

---

### career-companion

Career companion for frontier tech industries — space, AI, robotics, and defense. Powered by [Zero G Talent](https://zerogtalent.com) with live data from hundreds of companies via direct ATS integrations. No API key required.

**What it does:**

- **Find jobs** — search live openings across SpaceX, OpenAI, Anthropic, NASA, Boston Dynamics, and 200+ more
- **Resume help** — review, critique, and tailor resumes to specific job descriptions
- **Interview prep** — mock interviews with company-specific questions and honest feedback

**Try it:**

```
find me AI engineer roles at Anthropic
review my resume for this SpaceX posting
run a mock interview for a robotics position at Boston Dynamics
```

**Components:** 1 skill, API reference, company directory

---

### journalist

Writing guideline for long-form content. Combines newspaper prose discipline (NYT/AP/WSJ traditions) with narrative craft (the longform-feature tradition — story shape, voice, earned realizations, research woven into prose rather than dumped as citations).

**Two pillars:**

1. **Newspaper rules** — active voice, plain words, *said* attribution, no clichés, no editorializing, proper numbers/dates/punctuation. NYT style by default.
2. **Narrative craft** — show don't dump, voice, cliff-hangers, the reveal, the wiki test.

**Try it:**

```
write a 1200-word feature on <topic> for my newsletter
edit this draft — too much hedging and throat-clearing
help me structure a 5000-word longform for The Atlantic
polish this op-ed in WSJ style
```

For drafts over ~500 words, ask Claude to "dispatch a parallel review" — three reviewer subagents (prose, copy-editing, narrative) run concurrently and return structured critiques.

**Components:** 1 skill, 4 deep-dive references (narrative-craft, anti-patterns, citation-and-sourcing, copy-editing-mechanics), 3 subagent prompt templates

---

## Structure

```
claudus-maximus/
├── .claude-plugin/
│   ├── plugin.json              # Marketplace manifest
│   └── marketplace.json         # Plugin registry
└── plugins/
    ├── diagram/                 # Mermaid diagrams from code analysis
    │   ├── agents/              # code-explorer, diagram-builder
    │   └── skills/diagram/      # Orchestrator skill + 27 syntax references
    ├── winning/                 # Evolutionary parallel orchestrator
    │   ├── agents/              # strategy-runner, researcher
    │   ├── commands/            # launch, how-to-win, status, cancel
    │   ├── skills/              # winning, how-to-win
    │   ├── hooks/               # Stop hook (loop engine)
    │   └── scripts/             # setup-loop, status, cancel-loop
    ├── career-companion/        # Job search + resume + interviews
    │   └── skills/              # career-companion skill + API/company refs
    └── journalist/              # Long-form writing guideline
        └── skills/journalist/   # SKILL.md + references/ (narrative-craft,
                                 # anti-patterns, citation-and-sourcing,
                                 # copy-editing-mechanics) + prompts/
                                 # (prose/copy-editor/narrative reviewers)
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with plugin support
- `jq` and `perl` in PATH (for winning plugin hooks)

## License

MIT
