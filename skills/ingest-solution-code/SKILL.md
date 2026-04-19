---
name: ingest-solution-code
description: Ingest a local solution or codebase by providing a filesystem path, then extract durable knowledge such as name, purpose, description, architecture, project structure, major functionality, key flows, and implementation patterns into this repo's evidence and wiki.
---

# Ingest Solution Code

Use this skill when a local source tree should become durable knowledge in the memory system.

## Required Inputs

- one local filesystem path to a solution, project, service, or repository

## Read First

- `protocols/INGEST.md`
- `protocols/SCHEMA.md`
- `protocols/FILING.md`

## Goal

Turn a codebase path into durable, navigable knowledge without copying large amounts of source code into the wiki.

## What To Extract

At minimum, extract:

- solution or project name
- purpose and high-level description
- architecture and major subsystems
- project structure and important directories
- main functionality and responsibilities
- important flows
  authentication, request handling, jobs, data flow, ingestion flow, build flow, deployment flow, or equivalent
- key technologies and dependencies when they matter to understanding
- notable conventions, patterns, or risks that are durable enough to keep

## Process

1. Read the target path at a high level before diving deep.
2. Inspect root files first:
   `README`, manifests, lockfiles, build files, compose files, CI files, framework config, and entrypoints.
3. Map the top-level structure with `rg --files`, `find`, or targeted directory listing.
4. Identify the main runtime boundaries:
   apps, services, packages, modules, workers, APIs, CLIs, jobs, databases, and infrastructure.
5. Trace the highest-value flows end to end.
6. Create one evidence record under `memory/evidence/source-notes/` for the code solution.
7. Update or create the relevant canonical wiki pages under `memory/wiki/`.
8. Update `memory/wiki/INDEX.md` if navigation changed.
9. Append an ingest entry to `memory/wiki/LOG.md`.

## Evidence Record

Create a source note that preserves provenance for the analyzed path.

Include:

- analyzed path
- solution name
- analysis date
- optional revision marker if visible
  git branch, commit SHA, version file, release tag
- summary
- extracted architecture
- important directories and roles
- key flows inspected
- caveats
- affected pages

## Preferred Wiki Shape

Prefer updating a small number of canonical pages over creating many narrow summaries.

Good default shapes:

- domain page for the broader system area
- entity page for the solution or service
- concept page for architecture, workflows, or shared patterns

## Heuristics

- Prefer durable synthesis over file-by-file restatement.
- Summarize modules by responsibility, not by every filename.
- Name components as the codebase names them when possible.
- When a codebase is large, prioritize entrypoints, orchestration layers, data boundaries, and cross-cutting patterns.
- Use tests to confirm intended behavior when the implementation is ambiguous.
- Record uncertainty explicitly when a flow was inferred rather than directly confirmed.

## Rules

- Do not copy large source excerpts into the wiki.
- Keep the analyzed code where it is; do not move or mutate it unless explicitly asked.
- Preserve provenance by linking claims back to the evidence note.
- Prefer canonical pages over scattered one-off summaries.
- If the codebase contradicts existing wiki claims, update the affected pages and note the contradiction explicitly.
