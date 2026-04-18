# Hybrid Wiki Memory Agent

This repository is a markdown-first memory system for AI agents.

It is designed for a simple problem: most LLM workflows either keep too little memory or rely on retrieval from raw documents every time. This repo takes a different approach. It maintains a persistent wiki that compounds over time, but adds enough operational discipline that the wiki stays useful as an agent memory layer instead of turning into an ungrounded pile of summaries.

The architecture is defined in [SPEC.md](./SPEC.md). This README is the user guide.

## What This Is

This system combines two ideas:

- Karpathy's LLM wiki pattern as the base architecture
- selected MemPalace ideas as operational discipline

The result is a hybrid:

- `raw/` stores immutable source material
- `wiki/` stores maintained synthesis pages
- `evidence/` stores session, decision, and source-support records
- `agents/` stores specialist-agent continuity
- `protocols/` tells the agent how to behave

The wiki is the main artifact. The evidence layer keeps the wiki honest.

## Why This Exists

This repository exists to bring MemPalace-style discipline into the Karpathy wiki approach.

Karpathy's pattern is the architectural foundation: use immutable raw sources plus a maintained markdown wiki so knowledge compounds over time instead of being rediscovered from scratch on every query.

That approach has major benefits:

- the wiki becomes the main durable artifact
- synthesis compounds over time
- the system stays simple, local, and markdown-native
- humans can browse and edit the result directly

But on its own, it can also be too loose for reliable agent memory:

- the wiki can drift away from source evidence
- summaries can overwrite chronology and nuance
- the agent may not have a bounded startup path
- fact changes may be merged away instead of tracked clearly

MemPalace contributes the discipline layer that helps address those weaknesses:

- bounded wake-up context
- layered retrieval
- evidence preservation
- compaction and filing discipline
- specialist continuity
- current-vs-history fact handling

MemPalace also has real strengths:

- it is stronger as a retrieval and memory-discipline system
- it preserves evidence and chronology more explicitly
- it gives the agent a clearer operational model

But taken directly, it is heavier than needed for a markdown-first wiki:

- more architectural complexity
- more storage and retrieval machinery
- less natural as a simple git/markdown knowledge base

This repository exists because the combination is better than either extreme for this use case:

- use Karpathy's wiki model as the main knowledge surface
- use MemPalace's discipline to make that wiki reliable as agent memory

The agent is expected to:

- ingest sources into durable wiki pages
- answer from maintained pages first
- drill into evidence when precision matters
- update the wiki when new knowledge becomes durable

That gives you a memory system that compounds instead of resetting.

So the relationship is:

- Karpathy provides the architectural foundation and primary inspiration
- MemPalace provides most of the discipline layer
- this repo combines both into a markdown-first agent memory system

## How It Compares

## Compared to Karpathy's LLM Wiki

Karpathy's pattern is the foundation here.

Shared ideas:

- raw sources are immutable
- the wiki is LLM-maintained
- an index and log help the agent navigate
- markdown files are the main substrate

What this repo adds:

- bounded wake-up files so the agent does not preload the entire wiki
- explicit retrieval rules
- a separate evidence layer for chronology and proof
- specialist agent diaries
- explicit current vs history handling for facts
- compaction and filing discipline

In short:

- Karpathy wiki is better as a general knowledge-maintenance pattern
- this repo is better when you want that wiki to also function as reliable agent memory

Reference:

- Karpathy note: <https://gist.githubusercontent.com/karpathy/442a6bf555914893e9891c11519de94f/raw/ac46de1ad27f92b28ac95459c782c07f6b8c964a/llm-wiki.md>

## Compared to MemPalace

MemPalace is not the base architecture here. It is the source of the discipline layer.

Borrowed from MemPalace:

- bounded startup context
- layered retrieval
- evidence preservation
- specialist continuity
- fact-maintenance discipline

Not borrowed in v1:

- vector database retrieval
- MCP tools as the center of the design
- temporal graph database
- ingestion pipeline complexity

In short:

- MemPalace is stronger as a structured retrieval system
- this repo is simpler, more inspectable, and more natural as a git/markdown workspace

## Benefits

- Local-first and inspectable. Everything important is plain markdown on disk.
- Human-readable. You can browse and edit it without special tooling.
- Compounding knowledge. Good answers and ingests can be filed back into the wiki.
- Bounded context. The agent wakes up from a small set of files instead of loading the world.
- Evidence-backed synthesis. The wiki is primary, but evidence remains available when precision matters.
- Extensible. You can add skills and small tools later without changing the conceptual model.

## Limitations

- This is not a full semantic retrieval system in v1.
- At large scale, plain file search will be weaker than a dedicated index.
- The system depends on discipline. If the agent updates summaries but never maintains evidence, quality will drift.
- The wiki can become over-structured if you add too many page types too early.
- The wiki can become unreliable if you keep it too loose and ignore the protocol files.

This system is intentionally optimized for clarity, portability, and maintainability before scale or benchmark performance.

## Repository Layout

```text
raw/        immutable source material
wiki/       maintained knowledge surface
evidence/   support records and chronology
agents/     specialist memory streams
protocols/  operating rules for the agent
```

Key files:

- [wiki/IDENTITY.md](./wiki/IDENTITY.md): who the main agent is and how it should behave
- [wiki/ESSENTIAL_STORY.md](./wiki/ESSENTIAL_STORY.md): bounded current-state brief
- [wiki/INDEX.md](./wiki/INDEX.md): main navigation page
- [wiki/LOG.md](./wiki/LOG.md): chronology of major ingests and changes
- [protocols/INIT.md](./protocols/INIT.md): first-run setup and environment preparation
- [protocols/WAKE_UP.md](./protocols/WAKE_UP.md): minimal startup behavior
- [protocols/RETRIEVAL.md](./protocols/RETRIEVAL.md): how the agent should answer questions
- [protocols/INGEST.md](./protocols/INGEST.md): how to add new knowledge
- [protocols/FILING.md](./protocols/FILING.md): what deserves persistence
- [protocols/COMPACTION.md](./protocols/COMPACTION.md): what to preserve before context loss
- [protocols/FACTS.md](./protocols/FACTS.md): how to handle changing facts
- [protocols/LINT.md](./protocols/LINT.md): how to audit the repo for drift and missing structure

## How It Works

## 0. Initialization

On first use, initialize the repo before doing anything else.

The direct phrases:

- `init`
- `initialize it`
- `initialize the repo`

should map to:

1. `uv sync`
2. `uv run python scripts/post_init_check.py`

This prepares the local `uv` environment, checks the required imports, and verifies that the repo structure is ready.

## 1. Wake-Up

At the beginning of a session, the agent should read only:

1. [protocols/WAKE_UP.md](./protocols/WAKE_UP.md)
2. [wiki/IDENTITY.md](./wiki/IDENTITY.md)
3. [wiki/ESSENTIAL_STORY.md](./wiki/ESSENTIAL_STORY.md)
4. optionally [wiki/INDEX.md](./wiki/INDEX.md) if needed

This gives the agent enough context to orient itself without wasting context on the entire repository.

## 2. Retrieval

When a question arrives, the agent should use this ladder:

1. `wiki/INDEX.md`
2. relevant wiki pages
3. linked evidence pages
4. raw sources

The wiki is used first for speed. Evidence is used when support matters. Raw sources are used when the maintained layers are insufficient.

## 3. Ingest

When you add a new source, the agent should:

1. store it under `raw/`
2. read it
3. create a source note under `evidence/source-notes/`
4. update one or more relevant wiki pages
5. update `wiki/INDEX.md` if needed
6. append a log entry to `wiki/LOG.md`

This is what makes knowledge compound instead of being rediscovered later.

## 4. Filing

Not every conversation deserves persistence.

The agent should file:

- decisions
- reusable insights
- durable facts
- source ingests
- meaningful specialist lessons
- unresolved threads worth preserving

The agent should not file:

- chatter
- duplicates
- unstable guesses
- transient implementation noise

## 5. Compaction

Before context is lost, the agent should write:

- a session note
- unresolved items
- decisions and rationale
- affected pages
- agent diary updates if relevant

This is the markdown equivalent of a save-before-forgetting hook.

## Practical Workflow

## Starting a Session

Tell the agent to:

1. read the wake-up files
2. summarize current state
3. confirm the likely domain before deeper work

Example:

```text
Read the wake-up files for this repo and summarize the current state.
```

## Asking Questions

Ask questions against the wiki, not only against the chat history.

Examples:

```text
What architecture did we choose for this repo, and why?
```

```text
What are the main risks in the hybrid approach? Cite the relevant pages.
```

```text
What is currently missing from the v1 scaffold?
```

Good answers should point to the pages used.

## Adding Knowledge

Add a source to `raw/`, then ask the agent to ingest it.

Example:

```text
I added a new transcript under raw/transcripts/. Ingest it using the repo protocol.
```

Expected outcome:

- new source note in `evidence/source-notes/`
- updates to one or more canonical wiki pages
- index updates if needed
- a log entry

## Filing a Useful Analysis Back Into the Wiki

If the agent produces a good comparison, synthesis, or conclusion, it should not disappear into chat history.

Example:

```text
Take the analysis we just produced and file it back into the wiki as durable knowledge.
```

Expected outcome:

- a concept page, comparison page, or updated domain page
- supporting evidence links if needed
- a log entry if the update was significant

## Proper Compartmentalization

This system works only if knowledge is stored in the right layer.

## Put Things in `raw/` When

- the file is a source document
- the content should remain immutable
- you may need to audit the original later

Examples:

- articles
- transcripts
- notes imported from elsewhere
- downloaded assets

## Put Things in `wiki/` When

- the content is maintained synthesis
- the page should stay current as understanding improves
- the page is a canonical place to answer future questions from

Examples:

- entity pages
- concept pages
- domain pages
- comparisons
- overviews

## Put Things in `evidence/` When

- chronology matters
- rationale matters
- the wiki should point back to support
- the record should be more stable than a synthesis page

Examples:

- session notes
- decision records
- source notes
- audits

## Put Things in `agents/` When

- the memory is role-specific
- the lesson is useful mainly to one specialist mode of work
- you want a stable stream for reviewer, researcher, architect, or operator behaviors

Examples:

- recurring review mistakes
- research heuristics
- deployment patterns

## Rule of Thumb

If you are unsure where something belongs:

- original material goes in `raw/`
- maintained understanding goes in `wiki/`
- support and chronology go in `evidence/`
- role-specific continuity goes in `agents/`

## Extending With Skills

The repo is designed to be extended gradually.

Start with a few skills that map directly to the protocol files:

- wake-up skill
- ingest skill
- retrieval skill
- filing skill
- compaction skill
- lint skill

Each skill should be narrow and procedural.

## Example Skill Responsibilities

### Wake-Up Skill

- read startup files
- summarize current state
- identify which additional page, if any, should be read next

### Ingest Skill

- read a new raw source
- write a source note
- update affected wiki pages
- update the index and log

### Retrieval Skill

- search the smallest relevant page set
- answer with citations
- drill into evidence only as needed

### Filing Skill

- decide what deserves persistence
- update session, wiki, and diary files

### Lint Skill

- check for contradictions
- find missing links
- find stale claims
- detect unsupported summaries

## When to Add More Tooling

Do not add infrastructure just because you can.

Add more tooling only when the markdown workflow is clearly straining.

Good reasons to extend:

- the wiki has grown large enough that manual navigation is slow
- `rg` and filename search are no longer enough
- you want repeatable audits or page generation
- you want stronger retrieval without changing the repo model

Possible extensions:

- local markdown search scripts
- frontmatter-aware indexing
- backlink generation
- audit scripts
- optional local embedding or hybrid search

The important rule is: extend the repo, do not replace the repo.

## Included Skills

Project-local skills are provided under `skills/`:

- `skills/init/`
- `skills/download-urls/`
- `skills/wake-up/`
- `skills/ingest/`
- `skills/retrieval/`
- `skills/filing/`
- `skills/compaction/`
- `skills/lint/`

These are thin procedural wrappers over the protocol files. Their purpose is to make the operating model reusable and easy to trigger, not to introduce a second architecture.

## What Each Skill Does

### `init`

Purpose:

- prepare the repo for first use
- sync the local `uv` environment
- verify that key imports and project files are available

What it does:

- runs `uv sync`
- runs `uv run python scripts/post_init_check.py`
- reports any setup issues clearly

When to use it:

- right after cloning the repo
- on the first run on a new machine
- after rebuilding or repairing the local environment

Example:

```text
init
```

```text
initialize it
```

### `download-urls`

Purpose:

- download remote URLs into local markdown files under `raw/`
- prepare web content for later ingestion
- fetch YouTube transcripts when YouTube video URLs are provided

What it does:

- downloads normal web pages into `raw/articles/`
- downloads YouTube transcript records into `raw/transcripts/`
- stores source URL and retrieval metadata in the saved markdown
- runs through the local `uv` project environment

How it runs:

```bash
uv run python skills/download-urls/scripts/download_urls.py <url> [<url> ...]
```

When to use it:

- when you have URLs instead of local files
- when you want to archive article content before ingestion
- when you want transcript text from YouTube videos in the repo

Example:

```text
download new articles from these urls
```

```text
download youtube transcripts for these videos
```

### `wake-up`

Purpose:

- initialize from bounded context
- reconstruct current state quickly
- avoid reading the whole repo at startup

What it reads:

- `protocols/WAKE_UP.md`
- `wiki/IDENTITY.md`
- `wiki/ESSENTIAL_STORY.md`
- optionally `wiki/INDEX.md`

What it should produce:

- a brief orientation summary
- the main active threads
- the next most relevant page to read, if any

When to use it:

- at the start of a session
- after losing context
- before switching back into this repo after working elsewhere

Example:

```text
wake up and summarize the current state of this repo
```

### `ingest`

Purpose:

- turn a new raw source into durable repo knowledge
- create support records and update canonical wiki pages

What it does:

- reads source files under `raw/`
- creates a source note in `evidence/source-notes/`
- updates relevant pages in `wiki/`
- updates `wiki/INDEX.md` if navigation changed
- appends to `wiki/LOG.md`

When to use it:

- after adding a transcript, article, note, or imported document under `raw/`
- when you want the repo to learn from a new source instead of keeping it as dead storage

Example:

```text
ingest new transcripts
```

### `retrieval`

Purpose:

- answer from maintained knowledge first
- use evidence and raw sources only when needed

What it does:

- starts from `wiki/INDEX.md`
- finds the smallest relevant set of wiki pages
- drills into evidence when precision matters
- cites the pages used

When to use it:

- when asking about prior decisions, concepts, entities, or open threads in the repo
- when you want a source-backed answer rather than a reply from chat memory alone

Example:

```text
retrieve the chosen architecture for this repo and cite the relevant pages
```

### `filing`

Purpose:

- preserve durable knowledge from a session
- ensure useful work does not remain only in chat history

What it does:

- updates or creates a session note in `evidence/sessions/`
- updates canonical wiki pages
- updates agent diaries when the lesson is specialist-specific
- updates fact pages when reality changed
- updates `wiki/ESSENTIAL_STORY.md` when startup context changed

When to use it:

- after a useful design discussion
- after a comparison or synthesis worth keeping
- after decisions, findings, or durable conclusions emerge

Example:

```text
file the conclusions from this discussion back into the repo
```

### `compaction`

Purpose:

- preserve continuity before context is lost
- write a short but accurate handoff

What it does:

- writes or updates a session note
- records unresolved items
- records decisions and rationale
- notes affected pages
- updates relevant agent diaries if needed

When to use it:

- before ending a long session
- before context-window compression
- before handing work off to another future session

Example:

```text
compact this session and leave a clean handoff
```

### `lint`

Purpose:

- audit the repo for drift, contradictions, and missing structure

What it does:

- starts from `wiki/INDEX.md` and `wiki/LOG.md`
- checks active pages for contradictions or unsupported claims
- looks for stale `Current` sections, missing links, and orphan pages
- writes findings to `evidence/audits/`
- optionally logs significant audits in `wiki/LOG.md`

When to use it:

- periodically as maintenance
- after several ingests or major wiki edits
- when the repo feels messy or inconsistent

Example:

```text
lint the repo and record concrete maintenance findings
```

## How to Use the Skills

There are two practical ways to use these skills.

### 1. Use Direct Action Phrases

Prefer direct task phrases over meta-instructions about skills.

Examples:

```text
init
```

```text
wake up
```

```text
ingest new articles
```

```text
lint the repo
```

This is the preferred style.

For initialization and ingest, direct phrases should map to the repo workflow automatically:

- `init` -> run repository setup
- `initialize it` -> run repository setup
- `download new articles from these urls` -> download into `raw/articles/`
- `download youtube transcripts for these videos` -> download into `raw/transcripts/`
- `ingest new articles` -> ingest from `raw/articles/`
- `ingest new transcripts` -> ingest from `raw/transcripts/`
- `ingest new assets` -> ingest from `raw/assets/` when applicable
- `ingest new sources from inbox` -> ingest from `raw/inbox/`

### 2. Ask by Intent

You can also ask in plain language, as long as the intent matches the workflow clearly.

Examples:

```text
Read the startup files and orient yourself.
```

```text
Turn this new transcript into wiki knowledge.
```

```text
Preserve the important conclusions from this session.
```

```text
Audit the repo for contradictions and stale pages.
```

### Avoid Meta Phrasing

Prefer:

```text
ingest new articles
```

over:

```text
use the ingest skill
```

Prefer:

```text
compact this session
```

over:

```text
use the compaction skill
```

The skill layer exists to support the workflow. It should not dominate the interface.

## Best Practices

- Keep `raw/` immutable.
- Prefer updating canonical pages over creating duplicates.
- Link important wiki claims to evidence pages.
- Use `Current` and `History` sections for facts that can change.
- Keep `ESSENTIAL_STORY.md` short and current.
- Update `wiki/LOG.md` for meaningful ingests and structural changes.
- Run periodic lint passes to catch drift.

## Common Failure Modes

### Summary Drift

The wiki becomes clean but unreliable because the agent stops linking back to evidence.

Fix:

- add evidence links
- create decision records
- run audits

### Over-Structuring

The repo becomes bureaucratic and slow to maintain.

Fix:

- remove unused page types
- keep v1 small
- add structure only after repeated need

### Under-Structuring

The repo becomes a generic markdown pile and the agent stops behaving consistently.

Fix:

- use the protocol files
- maintain canonical pages
- keep the wake-up path stable

## Recommended Starting Pattern

If you are using this repo for a new domain:

1. put one or two real sources under `raw/`
2. ingest them
3. create or update the relevant wiki pages
4. ask a few retrieval questions against the wiki
5. file any useful synthesis back into the repo
6. run a small lint pass

That is enough to validate whether the system is working.

## Related Files

- [SPEC.md](./SPEC.md): formal architecture and rationale
- [protocols/SCHEMA.md](./protocols/SCHEMA.md): page and naming conventions
- [wiki/INDEX.md](./wiki/INDEX.md): current navigation entry point
