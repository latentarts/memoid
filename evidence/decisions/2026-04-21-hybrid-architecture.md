# Decision: Hybrid Architecture

## Date

2026-04-21

## Context

The repository needed a durable architecture for an agent memory system. Two candidate frames emerged:

- a markdown translation of MemPalace
- a Karpathy-style LLM wiki with added discipline

## Decision

Use a Karpathy-style wiki as the main architecture, then add selected MemPalace ideas for reliability.

## Rationale

- the wiki should be the primary human-facing artifact
- raw sources should remain immutable
- bounded wake-up and evidence files improve agent reliability
- the result stays simpler than a database-first system

## Alternatives

### Direct MemPalace Translation

Rejected because it imports too much architectural heaviness into a v1 markdown system.

### Pure Karpathy Wiki

Rejected because it lacks enough built-in discipline for evidence, wake-up control, and fact maintenance.

## Consequences

- the repo needs explicit protocol files
- the repo needs a separate `evidence/` layer
- the repo can stay markdown-first without losing operational rigor

## Sources

- `SPEC.md`
- `evidence/sessions/2026-04-21-bootstrap.md`

