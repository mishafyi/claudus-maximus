# Zero G Talent Agent API Reference

Public, no authentication required. Built specifically for AI agents — slim JSON shape, pre-built URLs, plain-text description, no internal IDs or null fields.

Example payloads below are real responses captured 2026-08-17; live counts and asset extensions change, so treat the values as shape documentation rather than current data.

## Search Jobs

```
GET https://zerogtalent.com/api/agent/jobs
```

Active jobs only. Default order is listing freshness (`createdAt` descending); pass `sort=relevance` for hybrid keyword + semantic ranking (the same mode the site's AI chat uses — descriptive queries work; pagination then stops at the top-200 fusion window).

### Parameters

| Param            | Type   | Default | Description                                                                                        |
| ---------------- | ------ | ------- | -------------------------------------------------------------------------------------------------- |
| `q`              | string | —       | Keyword (full-text + fuzzy)                                                                        |
| `sort`           | string | `new`   | `new` = freshness (exhaustive); `relevance` = hybrid BM25 + semantic ranking (top 200)             |
| `company`        | string | —       | Company slug (see `references/companies.md`). Repeat the param for multi-company OR.               |
| `industry`       | string | —       | `SPACE`, `AI`, `ROBOTICS`, `DEFENSE`, `FRONTIER`, `VC` (case-insensitive)                          |
| `location`       | string | —       | Country slug (`united-states`), US state (`california`), or city                                   |
| `addressCountry` | string | —       | ISO-2 country code (`US`, `GB`, `DE`)                                                              |
| `addressRegion`  | string | —       | US state code (`CA`, `TX`) or region code                                                          |
| `employmentType` | string | —       | `full-time`, `internship`, `part-time`, `contract`                                                 |
| `remote`         | string | —       | `true` for remote-only jobs (`location=remote` does NOT work — use this instead)                   |
| `filters`        | string | —       | SEO-style combined slug (e.g., `python-and-internship`, `aerospace`)                               |
| `limit`          | number | 10      | Results per page (max 50)                                                                          |
| `offset`         | number | 0       | Absolute pagination offset (max 49,000) — pass the previous page's `nextOffset`; any `limit` works |
| `format`         | string | —       | `md` for compact markdown (one block per job)                                                      |

### JSON Response

```json
{
  "jobs": [
    {
      "title": "Stock Plan Administrator",
      "location": "Hawthorne, CA, United States",
      "remote": false,
      "employmentTypes": ["FULL_TIME"],
      "category": "Business & Finance",
      "department": "G&A",
      "salary": {
        "min": 85000,
        "max": 120000,
        "currency": "USD",
        "interval": "year"
      },
      "listedAt": "2026-05-17T02:51:20.875Z",
      "company": {
        "name": "SpaceX",
        "slug": "spacex",
        "industry": "SPACE",
        "logoUrl": "https://zerogtalent.com/logos/spacex.jpeg",
        "country": "USA"
      },
      "applyUrl": "https://zerogtalent.com/space-jobs/spacex/stock-plan-administrator-8553046002",
      "jdUrl": "https://zerogtalent.com/api/agent/job/stock-plan-administrator-8553046002",
      "description": "SpaceX was founded under the belief that…"
    }
  ],
  "total": 1667,
  "hasMore": true,
  "nextOffset": 10
}
```

Notes:

- **No internal IDs, no `null` fields.** Optional fields are omitted from the response (smaller payloads).
- **`applyUrl`** points at the user-facing job page. **`jdUrl`** points at the markdown JD endpoint below.
- **`listedAt`** is when the job was first listed on Zero G Talent (project-canonical freshness — matches the homepage's sort).
- **`description`** is the full plain-text description with HTML stripped. Cap your output to a snippet if you don't need the whole thing.
- **`salary.interval`** is the raw DB value and is normally UPPERCASE (`YEAR`, `HOUR`, `MONTH`, `WEEK`), with a small lowercase legacy tail — compare case-insensitively. Only yearly figures are annual totals; never divide an hourly/monthly/weekly rate by 1000.
- **`company.industry`** is the uppercase `CompanyIndustry` enum.
- **Pagination**: pass `nextOffset` as `offset` in the next request. Under the default `sort=new`, `hasMore: false` means you've reached the tail. Under `sort=relevance` it goes false at the top-200 rank-fusion window even though `total` reports the full match count — to page deeper than 200, switch to `sort=new` or narrow the filters.

### Markdown Format (`format=md`)

Compact text/markdown for token-efficient LLM consumption — one block per job with title, metadata, and links to apply / full JD:

```
**{title}** at {company}
{location} | {employmentType} | {salary}
[Apply]({applyUrl}) | [JD]({jdUrl})

Showing 10 of 1667 results
Next: offset=10
```

## Get Job Description

```
GET https://zerogtalent.com/api/agent/job/{slug}
```

Fetch a single job's full details + up to 5 related active roles at the same company. Search results carry no `slug` field — pass the trailing path segment of a result's `jdUrl` or `applyUrl` (the MCP `get_job` tool accepts either URL whole). Returns 404 if the job is closed or unknown.

### Parameters

| Param    | Type   | Default | Description                                                     |
| -------- | ------ | ------- | --------------------------------------------------------------- |
| `format` | string | —       | `md` for clean markdown (title, metadata, description, related) |

### JSON Response

```json
{
  "job": {
    "title": "Stock Plan Administrator",
    "location": "Hawthorne, CA, United States",
    "remote": false,
    "employmentTypes": ["FULL_TIME"],
    "category": "Business & Finance",
    "department": "G&A",
    "salary": {
      "min": 85000,
      "max": 120000,
      "currency": "USD",
      "interval": "year"
    },
    "listedAt": "2026-05-17T02:51:20.875Z",
    "company": {
      "name": "SpaceX",
      "slug": "spacex",
      "industry": "SPACE",
      "logoUrl": "https://zerogtalent.com/logos/spacex.jpeg",
      "country": "USA"
    },
    "applyUrl": "https://zerogtalent.com/space-jobs/spacex/stock-plan-administrator-8553046002",
    "jdUrl": "https://zerogtalent.com/api/agent/job/stock-plan-administrator-8553046002",
    "description": "SpaceX was founded under the belief that…"
  },
  "relatedJobs": [
    {
      "title": "Propulsion Engineer",
      "location": "Hawthorne, CA, United States",
      "company": { "name": "SpaceX", "slug": "spacex", "industry": "SPACE" },
      "applyUrl": "https://zerogtalent.com/space-jobs/spacex/propulsion-engineer-…",
      "jdUrl": "https://zerogtalent.com/api/agent/job/propulsion-engineer-…",
      "listedAt": "…",
      "employmentTypes": ["FULL_TIME"],
      "remote": false
    }
  ]
}
```

Related-job entries omit `description` to keep payloads small. Fetch each related job's `jdUrl` if you need the full text.

### Markdown Format (`format=md`)

Cleanest path for LLMs to read a single JD — returns a `text/markdown` document with title, metadata table, description, apply link, and related-roles list.

## Resolve Company

```
GET https://zerogtalent.com/api/agent/companies?q={name}
```

Deterministic, **alias-aware name resolver** — not a fuzzy search. A company name maps to exactly one canonical company on Zero G Talent (e.g. `q=OpenAI`, or `q=x.ai` → xAI), so `companies` holds 0 or 1 item. It matches canonical names and known aliases only — pass the full name (`Anduril Industries`, not `Anduril`); if it returns 0 items the company isn't tracked — say so. Do **not** fall back to `?q=<company>`: `q` is fuzzy full-text over the whole corpus, so it returns other companies' jobs (e.g. `q=wayve` → 16 results, none at Wayve). Use it to turn a company name into its on-site `url` + slug.

### Parameters

| Param | Type   | Default | Description                                                  |
| ----- | ------ | ------- | ------------------------------------------------------------ |
| `q`   | string | —       | Company name (required). Case-insensitive; resolves aliases. |

### JSON Response

```json
{
  "companies": [
    {
      "name": "OpenAI",
      "slug": "openai",
      "industry": "AI",
      "url": "https://zerogtalent.com/ai-companies/openai",
      "logoUrl": "https://zerogtalent.com/logos/openai.jpeg",
      "website": "https://openai.com",
      "hq": "San Francisco, CA, US",
      "openJobs": 721,
      "description": "…"
    }
  ],
  "total": 1
}
```

- `total: 0` + empty `companies` when the name doesn't resolve to a tracked company.
- `hq` is the company's stored address and is **not normalised to a city** — it may be a street address (SpaceX: `1 Rocket Road, TX, US`, NASA: `300 E Street SW, US`) or a city (`San Francisco, CA, US`). Don't parse it as `city, region, country`; show it verbatim.
- `openJobs` is the count of currently-active roles; `industry` is the uppercase `CompanyIndustry` enum.
- Optional fields (`logoUrl`, `website`, `hq`, `description`) are omitted when absent.

## Resolve People

```
GET https://zerogtalent.com/api/agent/people?q={name}&company={slug}
```

Deterministic **exact-name resolver** — not a fuzzy search. Returns every person whose name matches `q` (case-insensitive). Names collide, so pass `company={slug}` to disambiguate to the person at that company.

### Parameters

| Param     | Type   | Default | Description                                           |
| --------- | ------ | ------- | ----------------------------------------------------- |
| `q`       | string | —       | Person name (required), case-insensitive exact match. |
| `company` | string | —       | Company slug to disambiguate same-named people.       |
| `limit`   | number | 10      | Max results (1–20).                                   |

### JSON Response

```json
{
  "people": [
    {
      "name": "Gwynne Shotwell",
      "slug": "gwynne-shotwell",
      "url": "https://zerogtalent.com/people/gwynne-shotwell",
      "headline": "President & COO at SpaceX",
      "company": "SpaceX",
      "linkedin": "https://www.linkedin.com/in/…",
      "avatar": "https://zerogtalent.com/avatars/gwynne-shotwell.jpeg"
    }
  ],
  "total": 1
}
```

- When a name maps to multiple people, `people` has several entries; each carries `company` (or `companies[]` if tied to more than one). Narrow with `company`.
- **`total` is the number of rows returned, not the number of matches**, and the result is truncated at `limit` (max 20) with no `hasMore`. If `total` equals your `limit`, assume there may be more.
- Optional fields (`headline`, `linkedin`, `avatar`) are omitted when absent.

## MCP server (Claude connector)

The same endpoints are exposed as MCP tools at `https://zerogtalent.com/api/mcp` (Streamable HTTP, no authentication, read-only): `search_jobs` (relevance-ranked by default — the site's AI-chat mode; `sort: "new"` for freshness), `get_job`, `resolve_company`, `resolve_person` (exact name), plus `search_people` — semantic search over 180k+ profiles ("nuclear fusion founder"), the same executor as the home-page chat. Output matches the endpoints above (markdown for jobs, JSON for company/people), but **the tool parameters are renamed**: `q`→`query`, `company`→`companies` (array), `addressCountry`→`country`, `addressRegion`→`region`, `remote` is a boolean, and `filters`/`format` are not exposed. Unknown keys are silently dropped by the schema, so REST parameter names sent to a tool are ignored without an error.

`search_people` has no REST equivalent — `/api/agent/people` is an exact-name resolver, so this is the one tool with no `curl` fallback. It returns `{total, showing, browseUrl, people[{name, headline, company, title, profileUrl}]}` (note `profileUrl`, not `url`; no `slug`/`linkedin`/`avatar`), defaults to 5 results, and `total` is the Elasticsearch match count for the semantic query — a broad relevance figure, not a count of good matches.

- **Claude.ai / Desktop / mobile (any plan):** Customize → Connectors → Add custom connector → `https://zerogtalent.com/api/mcp`, or open the prefilled dialog: `https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=Zero%20G%20Talent&connectorUrl=https%3A%2F%2Fzerogtalent.com%2Fapi%2Fmcp`
- **Claude Code:** `claude mcp add --transport http zerogtalent https://zerogtalent.com/api/mcp` (the `career-companion` plugin bundles this connector)
- **Any MCP client:** point a Streamable HTTP transport at the URL. Legacy HTTP+SSE is not served.

Privacy: the connector is read-only and unauthenticated — it needs no account and receives only the arguments Claude sends with a tool call. Zero G Talent's data handling is described at https://zerogtalent.com/privacy.
