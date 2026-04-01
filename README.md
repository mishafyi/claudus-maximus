# claudus-maximus

A Claude Code plugin marketplace. Three plugins that give Claude superpowers it doesn't ship with — diagramming from real code analysis, evolutionary multi-agent problem solving, and live job search for frontier tech.

## Install

```bash
/install mishafyi/claudus-maximus
```

Then enable the plugins you want. Each plugin works independently.

## Plugins

| Plugin                                | Version | Category      | What it does                                                             |
| ------------------------------------- | ------- | ------------- | ------------------------------------------------------------------------ |
| [diagram](#diagram)                   | 1.1.0   | visualization | Generates Mermaid diagrams from actual codebase analysis — not guesswork |
| [winning](#winning)                   | 0.8.0   | orchestration | Deploys parallel agents on competing strategies, keeps the winner        |
| [career-companion](#career-companion) | 1.0.0   | productivity  | Searches 20,000+ live jobs, tailors resumes, runs mock interviews        |

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

**Components:** 4 agents, 1 command, 1 skill, 27 Mermaid syntax references

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

## Structure

```
claudus-maximus/
├── .claude-plugin/
│   ├── plugin.json              # Marketplace manifest
│   └── marketplace.json         # Plugin registry
└── plugins/
    ├── diagram/                 # Mermaid diagrams from code analysis
    │   ├── agents/              # code-explorer, diagram-builder, code-architect, code-reviewer
    │   ├── commands/            # feature-dev-orchestrator
    │   └── skills/diagram/      # Orchestrator skill + 27 syntax references
    ├── winning/                 # Evolutionary parallel orchestrator
    │   ├── agents/              # strategy-runner, researcher
    │   ├── commands/            # launch, how-to-win, status, cancel
    │   ├── skills/              # winning, how-to-win
    │   ├── hooks/               # Stop hook (loop engine)
    │   └── scripts/             # setup-loop, status, cancel-loop
    └── career-companion/        # Job search + resume + interviews
        └── skills/              # career-companion skill + API/company refs
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with plugin support
- `jq` and `perl` in PATH (for winning plugin hooks)

## License

MIT
