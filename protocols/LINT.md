# Lint

## Goal

Audit the repo for drift, inconsistency, and missing structure.

## Check For

- contradictions between wiki pages
- unsupported claims that should point to evidence
- stale `Current` sections that should move material to `History`
- orphan pages that are not linked from the index or related pages
- duplicated concepts that should be merged into canonical pages
- missing follow-up updates implied by recent session or decision records

## Process

1. Start from `memory/wiki/INDEX.md` and `memory/wiki/LOG.md`.
2. Sample the most active wiki pages.
3. Cross-check linked evidence pages where important claims appear.
4. Identify inconsistencies, omissions, and maintenance work.
5. Write findings to `memory/evidence/audits/`.
6. Add a short summary to `memory/wiki/LOG.md` if the audit was significant.

## Rules

- Prefer concrete findings over vague quality comments.
- Do not rewrite large parts of the wiki during the audit unless explicitly asked.
- Record proposed follow-ups clearly.

