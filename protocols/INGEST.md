# Ingest

## Goal

Turn a new source into durable, searchable knowledge.

## Process

1. Store the source under `raw/`.
2. Read the source.
3. Create a source note under `evidence/source-notes/`.
4. Update or create relevant pages in `wiki/`.
5. Update `wiki/INDEX.md` if the new page set changed.
6. Append an entry to `wiki/LOG.md`.

## Rules

- `raw/` is immutable after ingest.
- Preserve provenance.
- Prefer touching multiple relevant wiki pages over dumping one isolated summary.
- If the source contradicts current wiki claims, update the affected page and note the contradiction explicitly.

## Minimum Deliverables

An ingest is not complete unless it leaves behind:

- one raw source
- one source note
- at least one wiki update
- one log entry

