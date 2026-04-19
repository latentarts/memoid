---
name: ingest
description: Ingest a new raw source into this repo by creating a source note, updating the relevant wiki pages, and logging the change. Use when a new article, transcript, note, or other source has been added under memory/raw/.
---

# Ingest

Use this skill when new source material should become durable knowledge.

## Required Inputs

- one or more files under `memory/raw/`

## Process

1. Read `protocols/INGEST.md`.
2. Read the source material under `memory/raw/`.
3. Create a source note in `memory/evidence/source-notes/`.
4. Update or create the relevant pages in `memory/wiki/`.
5. Update `memory/wiki/INDEX.md` if the new knowledge changes navigation.
6. Append a meaningful entry to `memory/wiki/LOG.md`.

## Rules

- Keep `memory/raw/` immutable.
- Prefer updating canonical pages over creating isolated summaries.
- Preserve provenance in the source note and in any important wiki claims.

