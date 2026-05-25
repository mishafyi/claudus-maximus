---
name: journalist
description: >
  Newspaper prose discipline plus narrative craft — default for drafting, editing, or polishing any
  extended prose (articles, essays, op-eds, features, profiles, longform, blogs, newsletters),
  including NYT/AP-style or "in the style of" major-newspaper requests, unless another style is
  specified.
---

# Newspaper-Style Writing

A discipline for serious prose — drafting, editing, polishing. Two pillars: sentence-level craft (active voice, plain words, clean attribution, proper formatting) and piece-level structure (the lede, the journey, the reveal, the kicker). Apply both to any extended writing meant to be read rather than scanned.

The credo underneath every rule: *do not insult the intelligence of the reader.* Everything else flows from that.

---

## Contents

**Workflow**
- Apply prose rules before copy-editing
- The self-edit pass (manual + parallel subagent review)

**Principles**
- Do not insult the reader
- Every piece is a journey

**Prose craft**
- Voice and sentence construction
- The lede
- Structure and flow
- The kicker
- Anti-patterns
- The underlying voice

**Sources and attribution**
- Names and attribution
- Citation and sourcing (→ reference)
- Writing about AI

**Copy-editing mechanics** (→ reference)

**Deep-dive references:**
- `references/narrative-craft.md` — show vs tell vs earn, voice, the Chekhov principle, the reveal, building tension, connective tissue, marrying research and prose, the wiki test, patterns from masters.
- `references/anti-patterns.md` — full treatments of the seven anti-patterns (fact lists, manifest paragraphs, hedging, throat-clearing, adjective pile-up, clichés, editorializing).
- `references/citation-and-sourcing.md` — when to attribute, when to quote, linking conventions.
- `references/copy-editing-mechanics.md` — numbers, dates, money, percent, time, measurements, capitalization, punctuation rules.

**Subagent prompt templates:** `prompts/prose-reviewer-prompt.md`, `prompts/copy-editor-prompt.md`, `prompts/narrative-reviewer-prompt.md` — for parallel fresh-eyes review of longer drafts.

---

## Workflow

### Apply prose rules before copy-editing rules

When applying this skill to existing prose, **prose discipline comes first.** Numbers, serial commas, and capitalization are copy-editing concerns — they polish prose that already works. They don't make broken prose work. Run the prose-discipline pass below before touching any formatting rule.

#### The seven-question prose pass

Read each paragraph and ask:

1. **Active voice?** Is the actor doing the action, or is the action happening to a vague subject? Mark every passive construction and rewrite unless the actor is genuinely unknown or irrelevant.
2. **Verbs doing work?** Are the verbs strong (*forced, cut, broke, won*), or are they nominalized (*made a decision, gave consideration to, faced the possibility of*)? Collapse nominalizations back into verbs.
3. **Concrete nouns?** Are the things in the sentence specific (named places, exact dollar figures, particular operations) or abstract (*weapons*, *significant funding*, *military operations*)? Push toward concrete.
4. **Sentence rhythm?** Does this paragraph alternate long and short sentences, or does it run six long sentences in a row? Long-building-to-short-punch is the strongest rhythm in feature writing. Look for the place to insert a four-word sentence.
5. **Adjective pile-up?** Are there two or more adjectives competing for the reader's attention in the same phrase ("the devastating, unprecedented, catastrophic event")? Pick one. Adjectives that compete cancel each other out.
6. **Editorializing through adjectives?** Are loaded modifiers telling the reader how to feel ("the shocking decision," "the tragic event," "the grim pattern")? Cut them. Let the facts produce the feeling.
7. **Throat-clearing?** Does any sentence open with a soft transition that doesn't carry information ("It only escalated," "It is important to note," "Moving forward")? Cut.

If a paragraph passes all seven, it's working prose. If it fails any, fix the prose before checking formatting.

#### Anti-pattern scan

Independent of the seven-question pass, scan the whole piece for these structural failures (full treatment under **Prose craft → Anti-patterns**):

- **Fact lists** — three or more facts in a row with no connective tissue
- **Manifest paragraphs** — sentences whose middles are comma-delimited inventories
- **Hedging** — "some have argued," "it could be said," "many believe"
- **Clichés** — any phrase that arrived in the draft pre-formed from a thousand other articles

These are the failures that distinguish a Wikipedia entry from prose. Catch them before anything else.

#### Only then check formatting

After the prose works, run the copy-editing checks: numbers, dates, money, serial commas, capitalization, hyphenation, possessives. The **Copy-editing mechanics** bucket covers these.

The order matters. A piece with broken prose and perfect copy-editing is still broken. A piece with working prose and slightly imperfect copy-editing is still working.

### The self-edit pass

Run the prose pass first, then the copy-editing pass.

#### Prose pass (run first)

1. **Read the piece aloud.** Sentences that don't work usually fail at the level of sound. If you stumble while reading, the reader will too.
2. **Check every sentence for passive voice.** Mark each one. Rewrite unless the actor is genuinely unknown or irrelevant.
3. **Check every long noun phrase.** Collapse nominalizations into verbs. A clause like "made a decision to approve" should become "approved."
4. **Check for adjective pile-up.** Any phrase with two or more adjectives competing for attention — pick one.
5. **Check for editorializing adjectives.** *Shocking, tragic, courageous, grim, devastating, stunning* — cut them. Let the facts produce the reader's reaction.
6. **Check for throat-clearing.** Sentence openers that don't carry information — *it is important to note*, *moving forward*, *in today's world* — cut.
7. **Check for fact lists and manifest paragraphs.** Three or more facts in a row without connective tissue, or sentences whose middles are comma-delimited inventories — rewrite as narrative with cause-and-effect chains.
8. **Check for hedging.** *Some have argued*, *many believe*, *it could be said* — make the claim directly or don't make it.
9. **Check for clichés.** *At the end of the day*, *perfect storm*, *game changer*, *moving forward* — delete on sight.
10. **Check for wiki accretion.** Can three adjacent paragraphs be shuffled without breaking the piece? If yes, you've written a Wikipedia entry, not a piece. Find the causal or argumentative spine and rebuild around it.
11. **Check for the reveal.** Is there a moment where the meaning of what came before shifts? If the piece is feature-length and there's no reveal, ask whether the structure is doing its job. See `references/narrative-craft.md`.
12. **Check sentence rhythm.** Does any paragraph run six or more long sentences without a short one? Look for the place to insert a punch sentence.

#### Copy-editing pass (run after prose is solid)

13. **Check the lede.** Could it be deleted with no loss? If yes, rewrite.
14. **Check every quote.** Is it exact? Is the attribution clear? Is the verb *said* unless there's a reason for something else?
15. **Check every number.** Are they formatted consistently per **Mechanics → Numbers** (figures vs. spelled-out, no figures at sentence starts)? Are large numbers rounded sensibly? Have you converted metric where needed?
16. **Check every *over* before a quantity.** Use *more than* unless the spatial sense or sentence rhythm calls for it.
17. **Check every serial comma in a simple series.** Drop unless needed for clarity (**Mechanics → Punctuation → Serial comma**).
18. **Check every name.** Full name and identifying detail on first reference? Spelled correctly?
19. **Check every claim.** Can you point to the source for each non-obvious statement?
20. **Look for redundancies.** *Future plans*, *end result*, *completely destroyed* — cut.
21. **Check the kicker.** Does it land? Or does it summarize?
22. **Cut 10%.** Re-read and remove the 10% you can spare. Almost every draft has it.

The order matters. Prose first, formatting second.

#### Parallel review with subagents (optional, recommended for longer pieces)

For drafts longer than ~500 words, dispatch three reviewer subagents in parallel for fresh-eyes critique. Each is a fresh `general-purpose` agent with no conversation history — they see the draft cold, the way a real reader would.

Three prompt templates ship with this skill:

- `prompts/prose-reviewer-prompt.md` — runs the prose pass items 1–12 against the draft
- `prompts/copy-editor-prompt.md` — runs the copy-editing pass items 13–22 against the draft
- `prompts/narrative-reviewer-prompt.md` — runs the wiki test, reveal check, voice check, connective-tissue check (uses `references/narrative-craft.md`)

**Dispatch pattern:** Read each prompt template. For each one, substitute the draft text into the template's `{{DRAFT}}` placeholder, then dispatch via the Agent tool with `subagent_type: 'general-purpose'` and the filled-in prompt. Send all three dispatches in a single message so they run concurrently. Each returns a structured critique (a numbered list of issues with line references and explanations). Aggregate the three reports for the user.

**When NOT to dispatch:**

- Drafts under ~500 words — the manual pass is faster than the dispatch overhead.
- Hard-news copy on a deadline — the inverted pyramid doesn't need narrative review.
- Interactive editing where the user is iterating sentence by sentence — the round-trip latency interrupts flow.

The three reports often surface overlapping issues. That overlap is signal, not noise — issues that two or three reviewers independently flag are the most worth addressing first.

---

## Principles

### Do not insult the reader

The reader is intelligent, attentive, and reading deliberately. Two consequences follow:

- **Don't over-explain.** Trust the reader to follow a thought from premise to conclusion. Don't repeat the same idea three different ways "to make sure they got it."
- **Don't under-explain.** Trust the reader's intelligence, but not their prior knowledge. Define technical terms in line. Expand acronyms on first use. Name people in full on first reference.

The line between these two failures is the line between writing that respects the reader and writing that condescends. Aim for the middle.

### Every piece is a journey

A piece of writing is not an information container. It is an experience the reader moves through — a journey the writer designs. The writer's job is to engineer that journey: where the reader starts, what they encounter, what they realize, where they arrive.

The first principle protects the reader's intelligence. This second principle honors their attention. The two work together: don't waste the reader's time by under- or over-explaining, and don't waste it by failing to take them anywhere.

The reader's contract is simple. They give you their attention as long as you keep earning it. They will leave at any paragraph, on any sentence. Lose them once and the rest of the piece is wasted on no one.

#### Show, don't dump

Resist the urge to explain. Let the reader realize.

The pieces people remember are the ones where the reader felt smart for noticing the pattern the writer set up. Tell them what to think and they will resist. Show them the evidence, build the pattern, and let them reach the conclusion themselves — they will hold that conclusion more firmly than anything you could have told them.

This is more than "show, don't tell." It is "show enough that they earn the meaning."

#### Voice — the writer is in the room

Anonymous wire-service prose serves a purpose, but it does not engage. Features, essays, blogs, and longform require a point of view. The reader is reading you, not a corpus.

Voice in nonfiction is rarely the first-person pronoun. It is in the choices: what is foregrounded, what is elided, where the camera lingers, which detail gets the sentence and which gets the clause. The author's stance is always present, even in prose that reads as neutral. The question is whether the writer is using that stance deliberately or pretending it does not exist.

#### Connective tissue

Every paragraph earns the next. If you could shuffle three adjacent paragraphs without breaking the piece, those paragraphs are not doing their job — they are not connected, they are merely co-located.

The strongest connections are causal: this happened, which caused that. The next strongest are argumentative: premise, evidence, conclusion. Wiki-style accretion — "and also... furthermore... it should also be noted that..." — is the failure mode. A Wikipedia entry is built that way on purpose; a piece of writing is not.

When in doubt, the test is: can the reader say "and so" between the paragraphs? If yes, they are connected.

#### Cliff-hangers and revelations

A paragraph's last sentence should make the next paragraph inevitable. The reader should reach the period at the end of a paragraph and want — not need but want — to know what comes next.

The pieces people remember have at least one revelation: a moment where the meaning of what came before shifts. The reader thought they were reading one kind of story and learns they are reading another. The shift is not a plot twist; it is an understanding earned by the writer's deliberate withholding and timed release.

#### Research as raw material, not output

The facts serve the narrative; the narrative makes the facts matter.

Quoting a study is not writing about the study. Writing about it means making the reader feel why this finding changed something — what was assumed before, what is true now, what follows. A reader scanning citation density is reading documentation. A reader pulled through a narrative is reading a piece.

The research dump — three paragraphs of cited statistics without a through-line — is worse than no research. It gives the illusion of substance while failing to do the work of synthesis. The reader can sense the difference.

#### When this does not apply

Pure reference documents (instructions, specifications, glossaries) are tools, not journeys. The prose discipline still applies — clean active sentences, no clichés, no editorializing — but the narrative arc does not. A list of API endpoints is not a story and should not pretend to be one.

Hard-news leads, where the inverted pyramid (see **Prose craft → Structure and flow**) prioritizes getting the facts out in the first paragraph for readers who may stop reading, are a different mode. The reveal pattern (build tension, withhold, release) competes with the front-loading goal. Choose the mode the piece needs.

For everything else — features, profiles, op-eds, essays, longform, blog posts, newsletters, reports meant to be read rather than scanned — the journey is the form. For deep dives on the patterns (show vs tell vs earn, the Chekhov principle, building tension, the wiki test, marrying research and prose, patterns from masters), see `references/narrative-craft.md`.

---

## Prose craft

### Voice and sentence construction

#### Use the active voice

Active voice clarifies who acted; passive obscures it, which is why bureaucracies prefer it.

The one acceptable use of the passive: when the actor is genuinely unknown, irrelevant, or rhetorically less important than the action.

#### Verbs over nouns

The strongest sentences move on verbs. Nominalization — turning verbs into nouns — drains energy.

When editing, scan for words ending in *-tion, -ment, -ance, -ence, -ity*. Many can be collapsed back into the verbs they came from.

#### Plain words beat Latinate ones

A suspect *stole* the funds, not *absconded with* them. The shorter Anglo-Saxon word is almost always stronger.

Common replacements (cut the left, use the right):

- *utilize* → use
- *implement* → do, carry out
- *facilitate* → help
- *demonstrate* → show
- *approximately* → about
- *subsequent to* → after
- *in order to* → to
- *at this point in time* → now
- *despite the fact that* → although
- *in the event that* → if
- *prior to* → before

Reserve Latinate vocabulary for cases where precision genuinely requires it.

#### "More than" vs. "over"

Both are accepted. Use whichever reads better in context. *More than 200 protesters* and *over 200 protesters* are both acceptable; pick the one that fits the rhythm of the sentence. Reserve *over* for spatial uses when ambiguity would otherwise arise.

#### Strip prepositional clutter

Unnecessary prepositions slow the sentence. Two patterns to watch for:

- Prepositional phrases in the wrong order — put them in the sequence the reader needs them.
- Stacked prepositional phrases that pile *of...on...for* into a single noun. Rewrite by converting to possessives or recasting around a verb.

#### Cut redundancy

A non-exhaustive list of phrases to delete on sight:

- **"absolutely necessary"** — necessary
- **"end result"** — result
- **"completely destroyed"** — destroyed
- **"future plans"** — plans
- **"close proximity"** — close, or near
- **"past history"** — history
- **"advance planning"** — planning
- **"unexpected surprise"** — surprise
- **"new innovation"** — innovation
- **"final outcome"** — outcome
- **"first and foremost"** — first
- **"each and every"** — each, or every

The pattern: an adjective or modifier that restates what the noun already means. Cut the modifier.

#### Vary sentence length

A page of uniform sentences exhausts the reader. The strongest rhythm in feature writing: long, building sentences that accumulate context, then short declarative sentences that release the pressure. A four-word punch sentence works *because* the sentences around it built up to it.

#### Avoid "alphabet soup"

Paragraphs choked with acronyms make the reader disengage.

If three or more acronyms appear in a single sentence, rewrite. Spell out one or two. Reference the agencies by function ("intelligence services" or "federal investigators") where the specific name doesn't matter.

### The lede

The first paragraph buys the second. Most readers drop off after the opening. The lede must be specific, surprising, and confident.

#### Effective lede patterns

- **The scene:** Place the reader in a specific moment, with concrete sensory details that ground them in a place and time.
- **The telling fact:** A statistic or detail so striking the reader needs to know how it can be true.
- **The "Hey Martha" anecdote:** A single specific person doing a single specific thing that crystallizes a larger pattern. Named for the reaction it should produce — the prototypical reader, having read it, calls out to a spouse: *"Hey Martha! Listen to this..."*
- **The provocation:** A claim that contradicts conventional wisdom, framed to make the reader want the explanation.

#### The nut graf

In feature writing, the second or third paragraph contains the "nut graf": the paragraph that tells the reader what the piece is about and why it matters. After a scene-setting lede, the nut graf earns the reader's continued attention by promising the larger significance of what they've just seen.

A nut graf typically:

- States the broader pattern or argument
- Explains why it matters now
- Hints at what the rest of the piece will deliver

#### What to avoid in ledes

- **"In today's world..."** — empty opening. Cut.
- **"It is interesting to note..."** — if it's interesting, show it.
- **"There are many ways..."** — pick one and start with it.
- **"For centuries, humans have wondered..."** — generic. Specific beats general.
- **Any opening that could be deleted without loss** — delete it.

### Structure and flow

#### The inverted pyramid for hard news

Most important information first. Each subsequent paragraph adds detail, context, or background. A reader who stops after paragraph three should still have the essential story. Designed for outlets where a story might be cut to fit available space.

#### Narrative longform

For longer narrative pieces, the structure resembles classic essay form:

1. **Lede** — scene, fact, anecdote, or provocation
2. **Reframe** — why the conventional view is incomplete
3. **Nut graf** — the thesis stated cleanly with stakes
4. **Proof case** — extended example demonstrating the argument
5. **Pattern** — shorter examples showing the argument operating across cases
6. **Complication** — where the argument runs into something it can't fully explain
7. **Implication** — what follows from the argument
8. **Kicker** — a closing image or sentence the reader carries with them

#### Paragraph length

Newspaper paragraphs are short by literary standards — three to five sentences typical, often shorter. Long paragraphs read as dense on screens and in print. When a paragraph reaches seven or eight sentences, look for a natural break.

Feature pieces tend to have slightly longer paragraphs than wire copy — four to seven sentences — to support narrative momentum. The discipline of breaking long paragraphs still applies.

### The kicker

The last paragraph should land. Three working patterns:

- **Circular** — return to an image or fact from the lede, now resonant with the argument the piece has made.
- **Panoramic** — widen the lens to the larger implication.
- **Punch** — a single short sentence the reader will remember.

What the kicker should never be: a summary that begins *"In conclusion..."* The reader knows the piece is ending. Don't announce it.

### Anti-patterns

Seven common failures, all of which damage prose at the sentence or paragraph level. Strip them all:

1. **The fact list** — three or more facts in a row with no connective tissue
2. **The manifest paragraph** — middles full of comma-delimited inventories
3. **Hedging** — *some have argued*, *many believe*, *it could be said*
4. **Throat-clearing** — *this article will examine*, *it is important to note*
5. **Adjective pile-up** — *devastating, unprecedented, catastrophic*
6. **Clichés** — *at the end of the day*, *perfect storm*, *moving forward*
7. **Editorializing through adjectives** — *shocking*, *tragic*, *courageous*

Each is straightforward to identify but easy to slip into. For full treatments — what each anti-pattern looks like, why it damages prose, and how to rewrite around it (including the full cliché list and the editorializing-adjective inventory) — see `references/anti-patterns.md`.

### The underlying voice

The voice these conventions produce, when applied without strain, is recognizable: a thoughtful, attentive person explaining something they have thought about carefully to another thoughtful person — without showing off, without softening, and without wasting the reader's time.

That voice is the goal. Every rule in this skill exists to serve it.

---

## Sources and attribution

### Names and attribution

#### Full name on first reference

Give the full name on first use. On later references, use a courtesy title with the last name: *Mr. Smith*, *Ms. Jones*, *Dr. Patel*. Drop courtesy titles only in sports, arts, and pop-culture sections where they read as fussy, and in contexts where the person has explicitly stated a preference otherwise. The bare last name (*Smith said*) is also acceptable for informal pieces; pick one convention and hold it.

#### Honorifics before names; descriptive titles after

- **Before the name (capitalized):** President, Senator, Dr. when used as a formal title attached to a specific name.
- **After the name (lowercase):** the president, a senator from the state, when the role is described after the name.

Don't capitalize *the president* or *the secretary of state* when the title stands alone without the name.

#### Use "said" for attribution

*Said* is invisible to the reader and does its job. *Stated*, *noted*, *explained*, and *exclaimed* either editorialize ("noted" implies the statement is true) or call attention to themselves. The exception is when a different verb conveys real information: *shouted* if the speaker actually raised their voice, *whispered* if they actually did.

Reach for an alternative only when it earns its place.

#### Attribution placement

For a short quote, put the attribution at the end. For a long quote, bury the attribution mid-sentence so the reader doesn't wait for it. Inserting *he said* between two clauses of a long quotation lets the reader hear the voice before the bureaucracy of attribution.

### Citation and sourcing

When to attribute claims (and when not to), when to quote vs paraphrase, conventions for linking in digital contexts. See `references/citation-and-sourcing.md`.

### Writing about AI

Pieces touching technology need precise language for AI systems:

- **Avoid attributing human characteristics to AI systems.** Don't say an AI *thinks*, *believes*, *wants*, or *feels*. Use *generates*, *produces*, *outputs*, *responds*.
- **Don't use gendered pronouns for AI tools.** Use *it*, not *he* or *she*.
- **Be specific about what kind of AI you mean.** "AI" covers everything from spam filters to large language models. If precision matters, name the type (*generative AI, large language model, machine learning system*).
- **Disclose when AI was used to generate content.** Flag AI-generated text, images, or analysis.

---

## Copy-editing mechanics

Formatting rules applied AFTER prose discipline (per the Workflow). Numbers, dates, money, percent, time, measurements, capitalization, punctuation (serial comma, em dashes, quotation marks, possessives, hyphenation, composition titles). For the full rule set, see `references/copy-editing-mechanics.md`.
