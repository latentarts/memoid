# CONVENTIONS

Reference rules for page structure, naming, and fact lifecycle. Apply when creating or editing any memory file. Supersedes `SCHEMA.md` and `FACTS.md`.

## Page Types

| Type | Location | Purpose |
|------|----------|---------|
| Entity | `memory/wiki/entities/<name>.md` | A person, project, system, or tool |
| Concept | `memory/wiki/concepts/<name>.md` | A pattern, discipline, approach, or idea |
| Domain | `memory/wiki/domains/<name>.md` | An overview of a subject area |
| Session | `memory/evidence/sessions/YYYY-MM-DD-<slug>.md` | Work record for one session |
| Decision | `memory/evidence/decisions/YYYY-MM-DD-<slug>.md` | Rationale for a significant decision |

## Naming Rules

- kebab-case for all filenames: `my-entity-name.md`
- Dates in ISO 8601: `2026-04-23`
- Slugs: short, lowercase, hyphenated description of the subject
- No spaces, underscores, or special characters in filenames

## Entity Page Structure

```markdown
# Entity Name

One-sentence description.

## Current

| Field | Value |
|-------|-------|
| Status | ... |
| [key field] | [value] |

## History

| Date | Field | Old Value | Reason |
|------|-------|-----------|--------|

## Notes

Freeform context, patterns, caveats.

## Sources

- [session or decision record](../evidence/...)
```

## Concept Page Structure

```markdown
# Concept Name

One-sentence definition.

## Summary

2–4 sentences explaining the core idea.

## When to Apply

Conditions or contexts where this pattern is useful.

## When Not to Apply

Edge cases or anti-patterns.

## Sources

- [session or decision record](../evidence/...)
```

## Fact Lifecycle

- **New fact** → add to `Current` section
- **Fact changes** → move old row to `History` with date and reason; update `Current`
- **Fact removed** → move to `History` with date and reason "removed"; never delete the row
- **Never silently overwrite** — always preserve history so temporal understanding survives

## Linking Rules

- Link wiki pages to each other with relative paths: `[page name](../entities/page.md)`
- Link to evidence when making specific claims: `[session 2026-04-23](../evidence/sessions/2026-04-23-setup.md)`
- `INDEX.md` must link to every wiki page — an unlinked page is an orphan

## Editing Rules

- **Wiki pages**: edit freely, but always update `History` when facts change
- **Evidence files**: treat as append-only; add new sections, do not revise past entries
- **LOG.md**: append-only; never edit past entries
- **ESSENTIAL_STORY.md**: replace content freely — it reflects current state, not history
- **IDENTITY.md**: update only when the system's core purpose or values change
