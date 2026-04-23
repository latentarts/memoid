# SPEC: Memoid

## Purpose

This document defines a hybrid memory architecture for an AI agent that combines:

- the Karpathy LLM wiki pattern as the base system
- selected MemPalace ideas as operational discipline

The target is a local, markdown-first knowledge system that is easy to inspect, easy to edit, and strong enough to serve as an agent memory layer without requiring a database-first architecture.

## Design Position

The right abstraction is a **Unified Brain**:

- One central repository for all knowledge compounding.
- Use domain folders (e.g., `wiki/domains/work/`) for organization rather than repository isolation.
- Raw sources remain immutable.
- The agent incrementally maintains synthesis pages.
- A small set of protocol files governs how the agent wakes up, retrieves, files, and preserves evidence.

## Future Roadmap: The Fleet Model

While v1 focuses on a single unified repository, future versions may re-introduce "The Fleet":
- Isolated workspaces for strict legal/privacy boundaries (e.g., Client A vs Client B).
- A workspace manager CLI (`memoid new`, `memoid ls`).
- Multi-workspace awareness in the MCP server.

For now, these are excluded to prioritize simplicity and the compounding of knowledge.


## Source Models

### Karpathy Wiki Pattern

Core architecture:

- `raw/`: immutable source documents
- `wiki/`: LLM-maintained markdown knowledge base
- `schema`: instructions that tell the LLM how to maintain the wiki

Core strengths:

- compounding synthesis
- interlinked markdown pages
- low tooling complexity
- good human browsing experience
- strong fit for Obsidian/git workflows

Core weakness:

- unless disciplined, the wiki can drift away from source evidence
- summaries can silently overwrite nuance
- there is no built-in agent memory protocol

Source:

- <https://gist.githubusercontent.com/karpathy/442a6bf555914893e9891c11519de94f/raw/ac46de1ad27f92b28ac95459c782c07f6b8c964a/llm-wiki.md>

### MemPalace Pattern

Core architecture:

- durable mined records
- scoped retrieval by wing/room
- bounded wake-up context
- diary capture
- optional structured facts and temporal history

Core strengths:

- retrieval discipline
- evidence preservation
- startup context control
- specialized agent continuity
- clear distinction between current facts and historical facts

Core weakness:

- heavier architecture
- more operational complexity
- less elegant as a plain markdown knowledge base

## Chosen Hybrid

The hybrid system should adopt:

### From Karpathy

- raw sources as immutable truth
- wiki as the primary maintained artifact
- schema/protocol docs as the controlling interface
- index and log as first-class navigation tools
- markdown and git as the default substrate

### From MemPalace

- bounded wake-up files
- layered retrieval rather than full preload
- canonical topic domains
- separate evidence/session records
- specialist agent diaries
- current-vs-history fact maintenance
- explicit save/compaction process

## Core Architecture

The system has four layers instead of Karpathy’s minimal three, all housed within a single `memory/` directory to ensure portability and ease of version control.

### 1. Raw Sources (`memory/raw/`)

Immutable source material.

Examples:

- clipped articles
- transcripts
- notes
- PDFs converted to markdown
- imported documents

Rules:

- never edited by the agent after ingest
- always available for evidence checks

### 2. Wiki (`memory/wiki/`)

The maintained synthesis layer.

This is the primary human-facing artifact.

Examples:

- entity pages
- concept pages
- project pages
- comparison pages
- room pages
- overview pages

Rules:

- the agent is allowed to create and revise these freely
- all durable synthesis belongs here

### 3. Evidence Layer (`memory/evidence/`)

A markdown record of session-level or source-level evidence that backs the wiki.

This is the main MemPalace addition.

Examples:

- session files
- ingest notes
- decision records
- extracted source notes

Rules:

- summaries should point back here when claims matter
- this layer is more stable and chronological than the wiki pages

### 4. Protocol Layer

The operating instructions for the agent.

Examples:

- wake-up rules
- retrieval rules
- filing rules
- compaction rules
- fact maintenance rules

Rules:

- these files define behavior, not domain knowledge
- they are the markdown replacement for a memory tool protocol

## Directory Layout

```text
memory/
  raw/
    inbox/
    articles/
    transcripts/
    assets/
  wiki/
    INDEX.md
    LOG.md
    IDENTITY.md
    ESSENTIAL_STORY.md
    entities/
    concepts/
    domains/
  evidence/
    sessions/
    decisions/
    source-notes/
    audits/
  agents/
    reviewer/
      IDENTITY.md
      DIARY.md
      PATTERNS.md
    researcher/
      IDENTITY.md
      DIARY.md
protocols/
  SCHEMA.md
  WAKE_UP.md
  INGEST.md
  RETRIEVAL.md
  FILING.md
  COMPACTION.md
  FACTS.md
```

## The Key Hybrid Decision

The Karpathy wiki is the main knowledge surface.

But it should not stand alone.

To make it reliable for an AI agent, the system must distinguish between:

- synthesis pages in `memory/wiki/`
- evidence records in `memory/evidence/`
- operating rules in `protocols/`

Without that distinction, the agent risks treating its own evolving summaries as if they were ground truth.

## Memory Model

## Default Context

The agent should not load the whole wiki by default.

On wake-up it should read only:

1. `protocols/WAKE_UP.md`
2. `memory/wiki/IDENTITY.md`
3. `memory/wiki/ESSENTIAL_STORY.md`
4. optionally `memory/wiki/INDEX.md` or one domain index if relevant

This preserves MemPalace’s bounded startup behavior.

## Retrieval Model

When a question arrives:

1. inspect the wiki index or domain indexes first
2. open a small number of relevant wiki pages
3. if a claim needs stronger grounding, open linked evidence files
4. if still unresolved, consult raw sources

This is the intended retrieval ladder:

- wiki first for speed
- evidence second for support
- raw sources last for truth checks

## Persistence Model

Not every chat exchange becomes memory.

The agent should persist:

- source ingests
- important decisions
- reusable analyses
- durable facts
- specialist lessons
- unresolved questions worth revisiting

The agent should avoid persisting:

- transient chatter
- duplicate summaries
- unstable interpretations with no source support

## Core Files

### `wiki/IDENTITY.md`

Small self-definition for the main agent:

- role
- scope
- default behavior
- key owner/user relationships

This is startup context, not a general wiki page.

### `wiki/ESSENTIAL_STORY.md`

A bounded current-state brief.

Should include:

- active themes
- ongoing projects
- important people/entities
- unresolved threads
- what changed recently

This is the hybrid equivalent of MemPalace Layer 1.

### `wiki/INDEX.md`

The main navigation file.

Should list:

- major pages
- short descriptions
- page categories
- priority areas

This is directly aligned with Karpathy’s index concept.

### `wiki/LOG.md`

Append-only chronology of:

- ingests
- major edits
- analyses
- lint/audit passes

This is directly aligned with Karpathy’s log concept.

### `evidence/sessions/*.md`

Chronological session memory.

Should include:

- context
- events
- findings
- decisions
- follow-ups
- links to affected wiki pages

This is the closest markdown equivalent to durable drawers.

### `evidence/decisions/*.md`

Structured decision records.

Should include:

- decision
- rationale
- alternatives considered
- date
- sources
- impacted wiki pages

This prevents important rationale from being washed out by later summary edits.

### `agents/<name>/DIARY.md`

Persistent memory for specialist agents.

Should include:

- notable patterns
- recurring failure modes
- work habits
- useful heuristics

This is a direct MemPalace-inspired addition and should remain separate from the main wiki.

## Fact Handling

The hybrid system should not use a full temporal graph in v1.

But it should preserve the MemPalace fact discipline:

- current facts should be explicit
- outdated facts should move to history, not disappear
- contradictions should be noted, not silently merged away

Recommended pattern:

- entity pages in `memory/wiki/entities/`
- each page has `Current`, `History`, and `Sources` sections

This is enough to capture most of the value of the MemPalace knowledge graph without introducing a database.

## Operating Processes

## 1. Ingest

When a new source is added:

1. store it under `memory/raw/`
2. read it
3. create a source note in `memory/evidence/source-notes/`
4. update or create relevant wiki pages
5. update `memory/wiki/INDEX.md` if needed
6. append to `memory/wiki/LOG.md`

Unlike naive RAG, the knowledge should be compiled into the wiki, not rediscovered later from scratch.

## 2. Query

When answering a question:

1. search the index and relevant wiki pages
2. synthesize an answer from maintained pages
3. check evidence files when chronology or precision matters
4. cite the wiki pages and evidence pages used
5. if the answer produced new durable knowledge, file it back into the wiki

This keeps Karpathy’s compounding artifact model while adding stronger answer discipline.

## 3. Filing

At the end of meaningful work:

1. create or update an evidence session file
2. update affected wiki pages
3. update agent diaries if the lesson is specialized
4. update current/history facts if reality changed
5. update `ESSENTIAL_STORY.md` only when startup context should change

This is the markdown replacement for MemPalace save hooks.

## 4. Compaction

Before context is lost:

1. write a short session record
2. capture unresolved items
3. capture decisions and rationale
4. record which pages need follow-up edits

This should be mandatory agent behavior, documented in `protocols/COMPACTION.md`.

## 5. Lint / Health Check

This comes directly from the Karpathy pattern and should be retained.

Periodic lint passes should check for:

- contradictions between pages
- stale claims
- orphan pages
- missing cross-links
- unsupported claims
- high-value topics lacking canonical pages

Results should be written to `memory/evidence/audits/` and optionally summarized in `memory/wiki/LOG.md`.

## Skills Required

The hybrid system only needs a few skills.

### Wake-Up Skill

Reads the minimal startup set and reconstructs current state.

### Ingest Skill

Processes a new raw source into:

- source notes
- wiki updates
- index/log updates

### Ingest Solution Code Skill

Processes a local codebase path into:

- architecture and project structure maps
- key flow and functionality synthesis
- source notes and wiki updates

### Retrieval Skill

Finds the smallest relevant set of wiki and evidence pages before answering.

### Filing Skill

Turns important work from a session into durable updates.

### Compaction Skill

Writes a minimal handoff before context loss.

### Lint Skill

Audits consistency and proposes maintenance actions.

## Better Than Pure Karpathy Wiki

This hybrid is better than a pure Karpathy implementation when:

- you want the system to act as an agent memory, not only a knowledge base
- you care about bounded startup context
- you need evidence-backed answers
- you want specialist agents with durable continuity
- you need fact updates without silent overwrites

## Better Than Pure MemPalace Translation

This hybrid is better than a markdown clone of MemPalace when:

- you want the wiki itself to be the primary artifact
- you value simplicity and browsability
- you want a git/Obsidian-native workflow
- you do not want to start with a retrieval/database stack

## Main Risks

### Risk 1: Summary Drift

If the agent updates wiki pages aggressively but does not maintain evidence links, the wiki will become clean but untrustworthy.

Mitigation:

- require evidence references on important claims
- preserve decision and session records

### Risk 2: Over-Structuring

If too many folders and page types are introduced too early, the system becomes bureaucratic.

Mitigation:

- keep v1 small
- add page types only after repeated need

### Risk 3: Under-Structuring

If the system stays too close to a freeform wiki, the agent will not know how to wake up, retrieve, or file reliably.

Mitigation:

- keep protocol docs explicit
- keep startup files bounded and stable

## Recommended V1

V1 should include only:

- `memory/raw/`
- `memory/wiki/IDENTITY.md`
- `memory/wiki/ESSENTIAL_STORY.md`
- `memory/wiki/INDEX.md`
- `memory/wiki/LOG.md`
- a few canonical page directories
- `memory/evidence/sessions/`
- `memory/evidence/decisions/`
- `memory/agents/<name>/DIARY.md`
- `protocols/` files for wake-up, retrieval, filing, compaction

V1 should not include:

- embeddings
- MCP tools
- automatic graph generation
- full ontology systems
- large-scale automation

## Acceptance Criteria

The hybrid system is successful if the agent can:

1. wake up from a very small default context
2. answer questions primarily from maintained wiki pages
3. drill into evidence when precision matters
4. ingest a new source and update multiple wiki pages coherently
5. preserve specialist agent continuity across sessions
6. keep current facts separate from historical facts
7. keep the wiki browsable for humans

## Bottom Line

The Karpathy wiki pattern should be the foundation.

The MemPalace contribution should be operational discipline, not architectural heaviness.

So the intended system is:

- a persistent markdown wiki as the main knowledge artifact
- fed by immutable raw sources
- backed by evidence records
- governed by protocol files
- maintained by a small set of explicit skills

That gives you a wiki that is not just informative, but reliable enough to function as an AI agent’s long-term memory.
