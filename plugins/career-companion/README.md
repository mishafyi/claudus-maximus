# Career Companion

Career companion for frontier tech industries. Searches live job openings, tailors resumes, and runs mock interviews.

Powered by [Zero G Talent](https://zerogtalent.com) — live data from hundreds of companies via direct ATS integrations.

## What it does

- **Find jobs** — search 20,000+ live openings across space, AI, robotics, and defense via public API
- **Resume help** — review, critique, and tailor resumes to specific job descriptions
- **Interview prep** — mock interviews with company-specific questions and honest feedback

## Trigger phrases

Activates when you mention jobs, careers, hiring, resumes, interviews, salaries, or frontier tech companies (SpaceX, OpenAI, Anthropic, Blue Origin, NASA, Boston Dynamics, etc.).

## How it works

Bundles the Zero G Talent MCP connector — `https://zerogtalent.com/api/mcp` (Streamable HTTP, read-only, no account or API key) — exposing five read-only tools: `search_jobs` (relevance-ranked, like the site's AI chat), `get_job`, `resolve_company`, `search_people` (semantic), `resolve_person`. Where the connector isn't available the skill falls back to `curl` against the same public API. Either way you get live job listings with salary data, company info, and direct apply links.

The connector also works outside Claude Code: in Claude.ai / Desktop / mobile add it as a custom connector (Customize → Connectors → Add custom connector → `https://zerogtalent.com/api/mcp`), or open the prefilled dialog: <https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=Zero%20G%20Talent&connectorUrl=https%3A%2F%2Fzerogtalent.com%2Fapi%2Fmcp>.

## Installation

```bash
claude --plugin-dir /path/to/career-companion
```

Or install from the claudus-maximus marketplace.

## Components

| Component     | File                                              | Purpose                                       |
| ------------- | ------------------------------------------------- | --------------------------------------------- |
| MCP connector | `.mcp.json`                                       | Zero G Talent remote MCP server (4 read-only tools) |
| Skill         | `skills/career-companion/SKILL.md`                | Main skill with workflow, templates, and tips |
| API Reference | `skills/career-companion/references/api.md`       | Endpoint docs, params, response schemas       |
| Company Slugs | `skills/career-companion/references/companies.md` | Company lookup by industry with URL prefixes  |
