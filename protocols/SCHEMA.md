# Schema

## Purpose

This file defines the conventions the agent should follow when creating and maintaining the wiki.

## Core Layers

- `raw/`: immutable source files
- `wiki/`: maintained synthesis and navigation
- `evidence/`: supporting records and chronology
- `agents/`: specialist continuity
- `protocols/`: operating rules

## Page Types

### Wiki Pages

Use for:

- entities
- concepts
- domains
- comparisons
- syntheses

These pages may be rewritten as understanding improves.

### Evidence Pages

Use for:

- sessions
- decisions
- source notes
- audits

These should be more stable and chronological.

## Naming

- Use lowercase kebab-case for filenames.
- Prefix time-sensitive evidence files with ISO dates.
- Prefer singular nouns for entity pages.

Examples:

- `wiki/entities/andrej-karpathy.md`
- `wiki/concepts/retrieval-discipline.md`
- `evidence/decisions/2026-04-21-example-decision.md`

## Section Conventions

### Entity Pages

- Summary
- Current
- History
- Relationships
- Sources

### Concept Pages

- Summary
- Key Ideas
- Variants
- Tradeoffs
- Sources

### Session Pages

- Context
- Events
- Findings
- Decisions
- Follow-ups
- Affected Pages

### Decision Pages

- Decision
- Date
- Context
- Rationale
- Alternatives
- Consequences
- Sources

## Linking Rules

- Link wiki pages to other wiki pages whenever concepts or entities are related.
- Link wiki pages to evidence pages when claims benefit from support.
- Link evidence pages back to affected wiki pages.

## Editing Rules

- Do not edit files under `raw/`.
- Prefer updating existing canonical pages over creating duplicates.
- When facts change, move old facts into `History` instead of deleting them silently.
- When a question produces durable synthesis, file it back into the wiki.
