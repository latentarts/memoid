# Session: 2026-04-21 Bootstrap

## Context

Initial design and scaffolding for the hybrid wiki memory agent.

## Events

- analyzed the local `mempalace` repository
- wrote an initial reproduction-oriented spec
- compared that direction with Karpathy's LLM wiki note
- revised the design toward a hybrid architecture
- scaffolded the repository

## Findings

- Karpathy's wiki pattern is the better foundation
- MemPalace contributes stronger operational discipline than architectural simplicity
- the best v1 is wiki-first, not database-first

## Decisions

- use the Karpathy wiki model as the base
- add evidence, bounded wake-up, specialist diaries, and fact discipline from MemPalace
- keep v1 markdown-first and low-complexity

## Follow-Ups

- ingest real sources into `raw/`
- create additional domain/entity/concept pages as work continues
- define concrete skill behavior from the protocol files

## Affected Pages

- `SPEC.md`
- `README.md`
- `protocols/*`
- `wiki/*`

