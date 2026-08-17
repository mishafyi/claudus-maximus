# Career Companion

Career companion for frontier tech industries. Searches live job openings, tailors resumes, runs mock interviews, and looks up companies and people.

Powered by [Zero G Talent](https://zerogtalent.com) — live openings from hundreds of space, AI, robotics and defense companies via direct ATS integrations, plus 180k+ profiles of people at those companies and the VC firms behind them.

## What it does

- **Find jobs** — search 35,000+ live openings across space, AI, robotics, and defense; relevance-ranked (hybrid keyword + semantic, so "guidance navigation and control engineer at SpaceX" just works), with salary data and direct apply links
- **Read the full job description** — requirements, responsibilities, tech stack, plus related open roles at the same company
- **Resume help** — review, critique, and tailor resumes to a specific job description's language
- **Interview prep** — mock interviews with role- and company-specific questions and honest feedback
- **Company & people lookup** — resolve a company to its profile and open-job count; semantic people search ("nuclear fusion founder") or exact-name lookup with profile links

## Trigger phrases

Activates when you mention jobs, careers, hiring, resumes, interviews, salaries, or frontier tech companies (SpaceX, OpenAI, Anthropic, Blue Origin, NASA, Boston Dynamics, etc.).

## How it works

Bundles the Zero G Talent MCP connector — `https://zerogtalent.com/api/mcp` (Streamable HTTP, read-only, no account or API key) — exposing five read-only tools: `search_jobs` (relevance-ranked, like the site's AI chat; `sort: "new"` for a freshness listing), `get_job`, `resolve_company`, `search_people` (semantic), `resolve_person` (exact name). Where the connector isn't available the skill falls back to `curl` against the same public API (documented in `skills/career-companion/references/api.md`). Either way you get live job listings with salary data, company info, and direct apply links.

The connector also works outside Claude Code: in Claude.ai / Desktop / mobile add it as a custom connector (Customize → Connectors → Add custom connector → `https://zerogtalent.com/api/mcp`), or open the prefilled dialog: <https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=Zero%20G%20Talent&connectorUrl=https%3A%2F%2Fzerogtalent.com%2Fapi%2Fmcp>. If both the connector and this plugin are present, Claude Code shows one set of tools (same server).

## Installation

```bash
claude plugin marketplace add mishafyi/claudus-maximus
claude plugin install career-companion@claudus-maximus
```

Or load it for one session only: `claude --plugin-dir /path/to/career-companion`.

## Components

| Component     | File                                              | Purpose                                                               |
| ------------- | ------------------------------------------------- | --------------------------------------------------------------------- |
| MCP connector | `.mcp.json`                                       | Zero G Talent remote MCP server (5 read-only tools)                   |
| Skill         | `skills/career-companion/SKILL.md`                | Main skill with workflow, output templates, and tips                  |
| API Reference | `skills/career-companion/references/api.md`       | REST endpoints (curl fallback), params, response schemas, MCP section |
| Company Slugs | `skills/career-companion/references/companies.md` | Company lookup by industry with URL prefixes                          |

## Privacy

The connector processes only the tool inputs Claude sends it and stores no conversation data. See <https://zerogtalent.com/privacy>.

## License

MIT — see the repository [LICENSE](../../LICENSE).
