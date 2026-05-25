# Journalist Plugin

Newspaper prose discipline plus narrative craft for any extended writing — drafting, editing, polishing. Story-shaped, gripping, research-woven.

## How it works

The skill auto-triggers when you ask Claude to write, draft, edit, polish, or revise any extended prose. It applies two disciplines together:

1. **Newspaper rules** — grounded in NYT, AP, and WSJ traditions: active voice, plain words, *said* attribution, no clichés, no editorializing, proper numbers/dates/punctuation.
2. **Narrative craft** — the longform-feature tradition: show don't dump, voice, cliff-hangers, the reveal, research woven into story.

## What it covers

The SKILL.md (loaded when the skill triggers) is organized into five buckets:

**Workflow**
- Apply prose rules before copy-editing
- The self-edit pass (manual + parallel subagent review)

**Principles**
- Do not insult the reader
- Every piece is a journey

**Prose craft**
- Voice and sentence construction
- The lede
- Structure and flow (incl. inverted pyramid for hard news)
- The kicker
- Anti-patterns (fact lists, manifest paragraphs, hedging, throat-clearing, adjective pile-up, clichés, editorializing)
- The underlying voice

**Sources and attribution**
- Names and attribution
- Citation and sourcing
- Writing about AI

**Copy-editing mechanics**
- Numbers, dates, and measurements
- Capitalization
- Punctuation (serial comma, em dashes, quotes, possessives, hyphenation, composition titles)

Loaded on demand:

- `references/narrative-craft.md` — deep dive on show/tell/earn, the Chekhov principle, the reveal, building tension, connective tissue, marrying research and prose, the wiki test, patterns from masters.

Subagent dispatch templates (for parallel fresh-eyes review of longer drafts):

- `prompts/prose-reviewer-prompt.md` — runs the prose pass
- `prompts/copy-editor-prompt.md` — runs the copy-editing pass
- `prompts/narrative-reviewer-prompt.md` — runs the narrative checks (wiki test, reveal, voice, connective tissue)

## Usage

The skill auto-triggers. Say things like:

```
write a feature about <topic>
edit this draft
polish the opening
run a self-edit pass on my essay
review this for AP style
```

For drafts longer than ~500 words, ask Claude to "dispatch a parallel review" and the three reviewer subagents will run concurrently, returning structured critiques.

## Sources

- *The New York Times Manual of Style and Usage, 5th Edition.* Allan M. Siegal and William G. Connolly. Three Rivers Press, 2015. ISBN 978-1-101-90544-9.
- *The Associated Press Stylebook 2024-2026.* The Associated Press. Basic Books, 2024. ISBN 978-1-5416-0511-4.
- *The Art and Craft of Feature Writing.* William E. Blundell. Plume, 1988. (The Wall Street Journal's classic guide to page-one feature writing.)

The narrative-craft material (SKILL.md "Every piece is a journey" and `references/narrative-craft.md`) is original synthesis informed by the longform-feature tradition. It does not carry an authoritative citation; treat the patterns as field-tested heuristics rather than canonical rules.

## Install

```
/plugin marketplace add mishafyi/claudus-maximus
/plugin install journalist@claudus-maximus
```

## Structure

```
journalist/
├── .claude-plugin/
│   └── plugin.json
├── README.md
└── skills/
    └── journalist/
        ├── SKILL.md
        ├── references/
        │   └── narrative-craft.md
        └── prompts/
            ├── prose-reviewer-prompt.md
            ├── copy-editor-prompt.md
            └── narrative-reviewer-prompt.md
```
