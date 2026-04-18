---
name: ingest
description: Ingest a new raw source into this repo by creating a source note, updating the relevant wiki pages, and logging the change. Use when a new article, transcript, note, or other source has been added under raw/.
---

# Ingest

Use this skill when new source material should become durable knowledge.

## Required Inputs

- one or more files under `raw/`

## Process

1. Read `protocols/INGEST.md`.
2. Read the source material under `raw/`.
3. Create a source note in `evidence/source-notes/`.
4. Update or create the relevant pages in `wiki/`.
5. Update `wiki/INDEX.md` if the new knowledge changes navigation.
6. Append a meaningful entry to `wiki/LOG.md`.

## Rules

- Keep `raw/` immutable.
- Prefer updating canonical pages over creating isolated summaries.
- Preserve provenance in the source note and in any important wiki claims.

