# Zero G Talent Agent API Reference

Public, no authentication required. Built specifically for AI agents — slim JSON shape, pre-built URLs, plain-text description, no internal IDs or null fields.

## Search Jobs

```
GET https://zerogtalent.com/api/agent/jobs
```

Active jobs only, sorted by listing freshness (`createdAt` descending).

### Parameters

| Param            | Type   | Default | Description                                                                                  |
| ---------------- | ------ | ------- | -------------------------------------------------------------------------------------------- |
| `q`              | string | —       | Keyword (full-text + fuzzy)                                                                  |
| `company`        | string | —       | Company slug (see `references/companies.md`). Repeat the param for multi-company OR.         |
| `industry`       | string | —       | `SPACE`, `AI`, `ROBOTICS`, `DEFENSE`, `FRONTIER`, `VC` (case-insensitive)                    |
| `location`       | string | —       | Country slug (`united-states`), US state (`california`), or city                             |
| `addressCountry` | string | —       | ISO-2 country code (`US`, `GB`, `DE`)                                                        |
| `addressRegion`  | string | —       | US state code (`CA`, `TX`) or region code                                                    |
| `employmentType` | string | —       | `full-time`, `internship`, `part-time`, `contract`                                           |
| `remote`         | string | —       | `true` for remote-only jobs (`location=remote` does NOT work — use this instead)             |
| `filters`        | string | —       | SEO-style combined slug (e.g., `python-and-internship`, `aerospace`)                         |
| `limit`          | number | 10      | Results per page (max 50)                                                                    |
| `offset`         | number | 0       | Pagination offset (max 49,000)                                                               |
| `format`         | string | —       | `md` for compact markdown (one block per job)                                                |

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
- **`salary.interval`** is lowercase (`year`, `hour`, `month`, …). Format hourly rates differently — don't divide by 1000.
- **`company.industry`** is the uppercase `CompanyIndustry` enum.
- **Pagination**: pass `nextOffset` as `offset` in the next request. `hasMore: false` when you've reached the tail.

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

Fetch a single job's full details + up to 5 related active roles at the same company. Pass the `slug` from a search result — or the trailing segment of an `applyUrl` / `jdUrl`. Returns 404 if the job is closed or unknown.

### Parameters

| Param    | Type   | Default | Description                                            |
| -------- | ------ | ------- | ------------------------------------------------------ |
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
    "salary": { "min": 85000, "max": 120000, "currency": "USD", "interval": "year" },
    "listedAt": "2026-05-17T02:51:20.875Z",
    "company": { "name": "SpaceX", "slug": "spacex", "industry": "SPACE", "logoUrl": "https://zerogtalent.com/logos/spacex.jpeg", "country": "USA" },
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
