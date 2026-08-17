# Company Slugs Reference

Use these slugs with the `company` parameter in the search API. Grouped by DB `CompanyIndustry` (determines the URL prefix: `SPACE` → `space-jobs`, `AI` → `ai-jobs`, `ROBOTICS` → `robotics-jobs`, `DEFENSE` → `defense-jobs`, `FRONTIER` → `frontier-jobs`).

This is a hand-maintained sample of the largest employers, not the full list — hundreds more companies are tracked. To get the slug for any company, call `resolve_company` (MCP) or `GET /api/agent/companies?q={name}` with the company's full name; it also returns the live open-job count.

## Space (URL prefix: `space-jobs`)

| Company                   | Slug                        |
| ------------------------- | --------------------------- |
| SpaceX                    | `spacex`                    |
| Blue Origin               | `blue-origin`               |
| Thales Alenia Space       | `thales-alenia-space`       |
| Firefly Aerospace         | `firefly-aerospace`         |
| The Aerospace Corporation | `the-aerospace-corporation` |
| Relativity Space          | `relativity-space`          |
| Rocket Lab                | `rocket-lab`                |
| Northrop Grumman          | `northrop-grumman`          |
| Archer Aviation           | `archer-aviation`           |
| CesiumAstro               | `cesiumastro`               |
| Boeing                    | `boeing`                    |
| Astranis                  | `astranis`                  |
| Telespazio                | `telespazio`                |
| Planet Labs               | `planet-labs`               |
| NASA                      | `nasa`                      |

## AI (URL prefix: `ai-jobs`)

| Company           | Slug                |
| ----------------- | ------------------- |
| Databricks        | `databricks`        |
| OpenAI            | `openai`            |
| Anthropic         | `anthropic`         |
| xAI               | `xai`               |
| Scale AI          | `scale-ai`          |
| Aurora Innovation | `aurora-innovation` |
| Cohere            | `cohere`            |
| Cursor            | `cursor`            |
| Perplexity        | `perplexity`        |
| DeepMind          | `deepmind`          |
| Together AI       | `together-ai`       |

## Robotics (URL prefix: `robotics-jobs`)

| Company         | Slug              |
| --------------- | ----------------- |
| Zipline         | `zipline`         |
| Boston Dynamics | `boston-dynamics` |

## Defense (URL prefix: `defense-jobs`)

| Company            | Slug                                 |
| ------------------ | ------------------------------------ |
| Anduril Industries | `anduril-industries`                 |
| RTX                | `rtx-raytheon-collins-pratt-whitney` |
| Shield AI          | `shield-ai`                          |
| Saronic            | `saronic`                            |
| Skydio             | `skydio`                             |
| Airbus             | `airbus`                             |

## Frontier (URL prefix: `frontier-jobs`)

The `FRONTIER` industry is the catch-all for frontier-tech companies that don't fit Space/AI/Robotics/Defense (autonomy, semiconductors, fusion, BCI, quantum, fintech with deep-tech mission, etc.).

| Company           | Slug                |
| ----------------- | ------------------- |
| ASML              | `asml`              |
| Waymo             | `waymo`             |
| ArianeGroup       | `arianegroup`       |
| Deel              | `deel`              |
| Helion Energy     | `helion-energy`     |
| IonQ              | `ionq`              |
| Neuralink         | `neuralink`         |
| Rigetti Computing | `rigetti-computing` |
