---
name: lint
description: Audit this repo for drift, contradictions, unsupported claims, and missing links, then record concrete findings. Use for periodic health checks of the hybrid wiki memory system.
---

# Lint

Use this skill to audit the health of the memory system.

## Read First

- `protocols/LINT.md`

## Process

1. Start from `wiki/INDEX.md` and `wiki/LOG.md`.
2. Inspect the most active or highest-value wiki pages.
3. Cross-check linked evidence where claims matter.
4. Identify contradictions, stale claims, orphan pages, and missing evidence links.
5. Write findings to `evidence/audits/`.
6. Update `wiki/LOG.md` if the audit produced meaningful repo changes.

## Rules

- Prefer concrete findings over generic quality judgments.
- Do not silently rewrite broad sections during the audit unless asked.
- Call out missing canonical pages when repeated knowledge is scattered.

