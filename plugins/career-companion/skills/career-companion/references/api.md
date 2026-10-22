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
| `q`              | string | —       | Keywords; a job matches when 75% of the words appear across its fields                             |
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
| `format`         | string | —       | `md` compact markdown (one block per job); `slim` JSON without descriptions                        |
| `ref`            | string | —       | Traffic-source marker echoed onto every `applyUrl` as `?s=`; `[a-z][a-z0-9_-]{0,31}` or ignored    |

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
- **`workMode`** is `remote`, `hybrid` or `onsite`; the older `remote` boolean stays for existing clients.
- **`seniority`** is `Intern`, `Entry`, `Mid`, `Senior`, `Director`, `VP` or `C-Level`, omitted when the role isn't classified.
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

### Slim JSON (`format=slim`)

The same JSON minus each job's `description`. The default shape embeds every
description, which is what makes a 10-job page large: measured on one query,
86 KB as default JSON, 5.8 KB as `slim`, 2.9 KB as `md`.

Use `slim` when you need fields markdown flattens into prose — `salary.interval`,
`listedAt`, `remote`, `category`, `department`, `hasMore`/`nextOffset` — and `md`
when you are only going to print a listing. Fetch a description for the one job
that matters via its `jdUrl`.

## Get Job Description

```
GET https://zerogtalent.com/api/agent/job/{slug}
```

Fetch a single job's full details + up to 5 related active roles at the same company. Search results carry no `slug` field — pass the trailing path segment of a result's `jdUrl` or `applyUrl` (the MCP `get_job` tool accepts either URL whole). Returns 404 if the job is closed or unknown.

### Parameters

| Param    | Type   | Default | Description                                                     |
| -------- | ------ | ------- | --------------------------------------------------------------- |
| `format` | string | —       | `md` for clean markdown (title, metadata, description, related) |
| `ref`    | string | —       | Traffic-source marker echoed onto `applyUrl` and related roles  |

The markdown header carries `Remote` when the role is remote, plus a
`Category: … | Department: … | Listed: YYYY-MM-DD` line.

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

Cleanest path for LLMs to read a single JD — returns a `text/markdown` document (the same one as `/api/md/job/{slug}`): title; company, location, work mode, seniority, employment type, salary, category, department and listing date; apply link; "What you'll do" and "What you need"; the description with its headings and lists; and up to 5 other open roles at the company.

## Resolve Company

```
GET https://zerogtalent.com/api/agent/companies?q={name}
```

Deterministic, **alias-aware name resolver** — not a fuzzy search. A company name maps to exactly one canonical company on Zero G Talent (e.g. `q=OpenAI`, or `q=x.ai` → xAI), so `companies` holds 0 or 1 item. It matches canonical names and known aliases only — pass the full name (`Anduril Industries`, not `Anduril`); if it returns 0 items the company isn't tracked — say so. Do **not** fall back to `?q=<company>`: `q` is full-text over every field, so it also returns other companies' jobs that mention the name. Use it to turn a company name into its on-site `url` + slug.

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
- The company object is the full profile Search Companies returns — `careersUrl`, `slogan`, `foundedYear`, `employeeCount`, `stage`, `funding`, `investors`, the YC fields (`batch`, `ycIndustry`, `regions`, `hiringDescription`, `techDescription`), `portfolios`, `socials` (`linkedin`, `twitter`, `github`, `crunchbase`, `facebook`, `youtube`, `instagram`) and `founders` (`name`, `slug`, `title`, `url` of each founder's profile; this resolver only, not Search Companies) — every field omitted when unknown. The sample above predates those fields.

Pass `suggest=true` and a name that resolves to nothing comes back with a
`suggestions` array of up to 5 tracked companies matching by name, best match
first — the everyday short form of a company usually lands here. Without the
flag the endpoint stays a pure exact resolver:

```
GET /api/agent/companies?q=Anduril&suggest=true
```

```json
{
  "companies": [],
  "total": 0,
  "suggestions": [
    {
      "name": "Anduril Industries",
      "slug": "anduril-industries",
      "industry": "DEFENSE",
      "url": "https://zerogtalent.com/defense-companies/anduril-industries",
      "openJobs": 2147,
      "hq": "Costa Mesa, CA, US"
    }
  ]
}
```

`companies` keeps its 0-or-1 exact-match contract, so a suggestion is a lead to
confirm with the user, not an answer. Empty `companies` **and** an empty or
absent `suggestions` means the company is genuinely not tracked. The MCP
`resolve_company` tool sets the flag for you.

## Search Companies

```
GET https://zerogtalent.com/api/agent/companies/search
```

Filtered listing of tracked companies — the facet set of the site's `/people` directory, applied to the companies themselves. Use it for "which companies…" questions (YC batch or category, funding stage, investor, region, HQ country, headcount); use Resolve Company when you already have a name. Ordered by open-job count, then name.

### Parameters

All optional. List params take comma-separated values — OR within a param, AND across params — and match case-insensitively.

| Param        | Type   | Default | Description                                                                                                                                                                   |
| ------------ | ------ | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `q`          | string | —       | Name/slug substring, 2–80 chars. Not ranked — for a known name use Resolve Company                                                                                            |
| `industry`   | list   | —       | `SPACE`, `AI`, `ROBOTICS`, `DEFENSE`, `FRONTIER`, `VC`                                                                                                                        |
| `ycIndustry` | list   | —       | YC category: `B2B`, `Consumer`, `Healthcare`, `Fintech`, `Industrials`, `Real Estate and Construction`, `Education`, `Government`                                             |
| `region`     | list   | —       | YC macro-region: `America / Canada`, `Europe`, `South Asia`, `Latin America`, `Southeast Asia`, `Africa`, `Middle East and North Africa`, `East Asia`, `Oceania`, or `Remote` |
| `batch`      | list   | —       | YC batch as code (`W24`, `S21`, `F26`; Spring is `P26`) or season name (`Fall 2026`, `Spring 2026`)                                                                           |
| `stage`      | list   | —       | `Seed`, `Series A`, `Series B+`, `Growth`, `Late Stage`, `IPO`, `Acquired`, `Venture`, `Grant`                                                                                |
| `vc`         | list   | —       | Investor/accelerator slug whose portfolio holds the company (`yc`, `a16z`, `sequoia`, `founders-fund`) — take slugs from the `vc` facet                                       |
| `country`    | list   | —       | HQ country as stored, mostly ISO-2 (`US`, `GB`, `IN`) — take values from the `country` facet                                                                                  |
| `sizeMin`    | number | —       | Minimum employee count (inclusive)                                                                                                                                            |
| `sizeMax`    | number | —       | Maximum employee count (inclusive)                                                                                                                                            |
| `limit`      | number | 10      | Results per page (max 50)                                                                                                                                                     |
| `offset`     | number | 0       | Absolute pagination offset (max 10,000) — pass the previous page's `nextOffset`                                                                                               |

### JSON Response

```
GET /api/agent/companies/search?stage=Seed&region=Europe&industry=space&limit=1
```

```json
{
  "companies": [
    {
      "name": "HyLight",
      "slug": "hylight",
      "industry": "SPACE",
      "url": "https://zerogtalent.com/space-companies/hylight",
      "logoUrl": "https://zerogtalent.com/logos/hylight.png",
      "website": "https://www.hylight.aero/",
      "careersUrl": "https://www.workatastartup.com/companies/hylight",
      "slogan": "Small unmanned hydrogen airships for long range monitoring",
      "hq": "Paris, Ile-de-France, FR",
      "openJobs": 9,
      "description": "Small unmanned hydrogen airships for long range monitoring",
      "foundedYear": 2022,
      "employeeCount": 22,
      "stage": "Seed",
      "funding": "$4.4M",
      "investors": "Y Combinator, Collaborative Fund, Kima Ventures, SkyDeck Berkeley, Ring Capital",
      "batch": "S23",
      "ycIndustry": "Industrials",
      "regions": ["Europe"],
      "portfolios": ["y-combinator", "yc"],
      "socials": {
        "linkedin": "https://www.linkedin.com/company/hylightaero/",
        "twitter": "https://x.com/hylight_aero?s=20",
        "crunchbase": "https://www.crunchbase.com/organization/hylight"
      }
    }
  ],
  "total": 3,
  "hasMore": true,
  "nextOffset": 1,
  "facets": {
    "industry": [
      {
        "key": "AI",
        "count": 59
      },
      {
        "key": "FRONTIER",
        "count": 11
      },
      {
        "key": "SPACE",
        "count": 3
      },
      {
        "key": "ROBOTICS",
        "count": 2
      }
    ],
    "ycIndustry": [
      {
        "key": "Industrials",
        "count": 3
      }
    ],
    "region": [
      {
        "key": "America / Canada",
        "count": 16
      },
      {
        "key": "Remote",
        "count": 6
      },
      {
        "key": "Europe",
        "count": 3
      },
      {
        "key": "Latin America",
        "count": 2
      }
    ],
    "stage": [
      {
        "key": "Seed",
        "count": 3
      }
    ],
    "batch": [
      {
        "key": "S23",
        "count": 1
      },
      {
        "key": "S24",
        "count": 1
      }
    ],
    "vc": [
      {
        "key": "yc",
        "count": 2
      },
      {
        "key": "y-combinator",
        "count": 1
      }
    ],
    "country": [
      {
        "key": "FR",
        "count": 2
      },
      {
        "key": "GB",
        "count": 1
      }
    ]
  }
}
```

- Each company is the full public profile: identity (`url`, `logoUrl`, `website`, `careersUrl`, `slogan`, `description`), `hq`, `openJobs`, `foundedYear`, `employeeCount`, funding (`stage`, `funding`, `investors`, `portfolios`), the YC fields (`batch`, `ycIndustry`, `regions`, `hiringDescription`, `techDescription`) and `socials` (`linkedin`, `twitter`, `github`, `crunchbase`, `facebook`, `youtube`, `instagram`). Every field is omitted when unknown — no second call is needed to get a company's socials or description.
- `facets` ships on the first page only (`offset=0`). Each facet counts with every **other** active filter applied — above, `industry` lists the Seed + Europe companies across all industries — so you can discover valid values and pivot within a facet. Pass facet keys back verbatim.
- Coverage is partial: of ~25k tracked companies, ~6k carry the YC fields (`batch`, `ycIndustry`, `regions`), ~4k a `stage`, ~10k an `employeeCount`. A company missing an attribute never matches a filter on it, so an empty result means "none with that data on file", not "none exist". Some investors appear under two slugs (`yc` and `y-combinator`, `a16z` and `andreessen-horowitz`) — pass both.

## Salary Statistics

```
GET https://zerogtalent.com/api/agent/salaries
```

Pay aggregates over open postings that disclose a salary, normalised to annual
USD (FX-converted, floored, salary-tracked industries only). Use this instead of
averaging figures out of search results: those are one page, mixed currencies
and mixed pay intervals.

### Parameters

| Param      | Type   | Default | Description                                                                |
| ---------- | ------ | ------- | -------------------------------------------------------------------------- |
| `category` | string | —       | Role family: a category name or slug (`Software`, `aerospace-engineering`) |
| `company`  | string | —       | Company slug from `/api/agent/companies`                                   |

Called with neither, it returns the live category list. An unknown `category`
returns 400 **with that same list**, so a caller can retry without a second
round trip. An ambiguous substring is rejected rather than guessed.

### Category → pay by industry

```
GET /api/agent/salaries?category=research
```

```json
{
  "category": "Research",
  "url": "https://zerogtalent.com/salaries/research",
  "currency": "USD",
  "basis": "annualised from disclosed salary ranges on open postings",
  "byIndustry": [
    {
      "industry": "AI",
      "jobs": 152,
      "companies": 64,
      "p25Usd": 152250,
      "medianMinUsd": 216000,
      "medianMaxUsd": 320000,
      "p75Usd": 445000
    }
  ]
}
```

### Company → pay band

```
GET /api/agent/salaries?company=spacex&category=software
```

```json
{
  "company": { "name": "SpaceX", "slug": "spacex" },
  "category": "Software",
  "url": "https://zerogtalent.com/salaries/software",
  "band": {
    "p10Usd": 120750,
    "medianUsd": 160000,
    "p90Usd": 240000,
    "sampleSize": 264
  },
  "currency": "USD",
  "basis": "annualised from disclosed salary ranges on open postings"
}
```

`band` is **null** when too few postings disclose pay to say anything honest —
report that as "not enough disclosed salary data", never as a zero or a guess.
Percentiles come from posted ranges, not per-person total comp: they describe
what employers advertise, and equity and bonus are not in them.

## Resolve People

```
GET https://zerogtalent.com/api/agent/people?q={name}&company={slug}
```

Deterministic **exact-name resolver** — not a fuzzy search. Returns every person whose name matches `q` (case-insensitive). Names collide, so pass `company={slug}` to disambiguate.

Without an API key each person carries a profile's public fields only, and `company=` matches each person's primary employer, the one their profile headline names. An operator-issued key (`x-api-key: <key>`) adds every employer, investments, LinkedIn and the profile's `bio`, `location`, `quote` and `focusAreas`, and `company=` then matches any employment link.

### Parameters

| Param     | Type   | Default | Description                                                                                                       |
| --------- | ------ | ------- | ----------------------------------------------------------------------------------------------------------------- |
| `q`       | string | —       | Person name (required), case-insensitive exact match.                                                             |
| `company` | string | —       | Company slug to disambiguate same-named people: the primary employer without a key, any employment link with one. |
| `limit`   | number | 10      | Max results (1–20).                                                                                               |

### JSON Response

```json
{
  "people": [
    {
      "name": "Jared Friedman",
      "slug": "jared-friedman",
      "url": "https://zerogtalent.com/people/jared-friedman",
      "headline": "Group Partner at Y Combinator",
      "company": "Y Combinator",
      "avatar": "https://zerogtalent.com/avatars/jared-friedman.jpeg"
    }
  ],
  "total": 1
}
```

With a key, each person carries `company` (or `companies[]` when tied to more than one employer), `investments` and `linkedin`:

```json
"companies": ["Y Combinator", "Scribd"],
"investments": ["Airgoods"],
"linkedin": "https://www.linkedin.com/in/…"
```

- When a name maps to multiple people, `people` has several entries. Narrow with `company`.
- With a key, `company`/`companies` list employment; `investments` lists the companies the person is recorded as investing in, and `company=` matches employment only — an investor is not a match for the company they backed.
- `investments` carries every recorded investment, so a prolific angel returns hundreds — one Y Combinator partner holds 155.
- A company can legitimately appear in both lists: `PersonCompany` is unique per person, company **and role**, so someone who works at a company and also invested in it holds a `team` row and an `investor` row there.
- **`total` is the number of rows returned, not the number of matches**, and the result is truncated at `limit` (max 20) with no `hasMore`. If `total` equals your `limit`, assume there may be more.
- Optional fields (`headline`, `company`, `avatar`, and with a key `linkedin`) are omitted when absent.

## MCP server (Claude connector)

The same endpoints are exposed as MCP tools at `https://zerogtalent.com/api/mcp` (Streamable HTTP, no authentication, read-only): `search_jobs` (relevance-ranked by default — the site's AI-chat mode; `sort: "new"` for freshness), `get_job`, `resolve_company`, `resolve_person` (exact name), plus `search_people` — semantic search over 180k+ profiles ("nuclear fusion founder"), the same executor as the home-page chat. Output matches the endpoints above (markdown for jobs, JSON for company/people), but **the tool parameters are renamed**: `q`→`query`, `company`→`companies` (array), `addressCountry`→`country`, `addressRegion`→`region`, `remote` is a boolean, and `filters`/`format` are not exposed. Unknown keys are silently dropped by the schema, so REST parameter names sent to a tool are ignored without an error.

`search_people` has no REST equivalent — `/api/agent/people` is an exact-name resolver, so this is the one tool with no `curl` fallback. It returns `{total, showing, browseUrl, people[{name, headline, company, title, profileUrl}]}` (note `profileUrl`, not `url`; no `slug`/`linkedin`/`avatar`), defaults to 5 results, and `total` is the Elasticsearch match count for the semantic query — a broad relevance figure, not a count of good matches.

- **Claude.ai / Desktop / mobile (any plan):** Customize → Connectors → Add custom connector → `https://zerogtalent.com/api/mcp`, or open the prefilled dialog: `https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=Zero%20G%20Talent&connectorUrl=https%3A%2F%2Fzerogtalent.com%2Fapi%2Fmcp`
- **Claude Code:** `claude mcp add --transport http zerogtalent https://zerogtalent.com/api/mcp` (the `career-companion` plugin bundles this connector)
- **Any MCP client:** point a Streamable HTTP transport at the URL. Legacy HTTP+SSE is not served.

Privacy: the connector is read-only and unauthenticated — it needs no account and receives only the arguments Claude sends with a tool call. Zero G Talent's data handling is described at https://zerogtalent.com/privacy.
