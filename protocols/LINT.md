# LINT

**When:** Verifying memory integrity — before filing a session, when something seems off, or on demand ("run a lint check").

Run all checks in order. Report each result as you go; do not stop early.

---

## Checks

### 1. Orphan detection
- List every `.md` file under `memory/wiki/` (skip `.gitkeep`, `INDEX.md`, `LOG.md`, `IDENTITY.md`, `ESSENTIAL_STORY.md`)
- For each, confirm its filename or relative path appears as a link in `memory/wiki/INDEX.md`
- **FAIL** for any wiki page absent from the index

### 2. Broken links
- For each wiki page, extract every relative link of the form `[text](path)` — skip `http://` and `https://` URLs
- Strip any `#anchor` fragment, then resolve the path relative to the linking file
- **FAIL** if the resolved file does not exist

### 3. LOG.md format
- Read `memory/wiki/LOG.md`
- Ignore everything up to and including the `<!-- entries below -->` marker
- Ignore blank lines, `#` headings, `---` dividers, and `<!-- -->` comments
- **FAIL** if any remaining line does not match the pattern `YYYY-MM-DD: <non-empty text>`

### 4. ESSENTIAL_STORY.md currency
- **WARN** if `memory/wiki/ESSENTIAL_STORY.md` contains the literal string `[date]` (placeholder not replaced)

### 5. IDENTITY.md completeness
- **WARN** if `memory/wiki/IDENTITY.md` contains the literal string `[Replace with` (placeholder not replaced)

### 6. Unlinked evidence
- List every `.md` file under `memory/evidence/` (skip `.gitkeep`)
- For each, check whether its filename stem appears anywhere in the wiki pages
- **WARN** if an evidence file is not referenced by any wiki page

### 7. Entity page structure
- For each page under `memory/wiki/entities/`, verify it contains `## Current`, `## History`, and `## Sources` sections
- **FAIL** if an entity page is missing any of these required sections

### 8. Evidence page backlinks
- For each page under `memory/evidence/sessions/` and `memory/evidence/decisions/`, verify it contains `## Affected Pages`
- **WARN** if an evidence page is missing affected-pages backlinks

### 9. Protocol precision and bounded output
- For each `.md` file under `protocols/` (skip `CONVENTIONS.md`, `SCHEMA.md`, `FACTS.md` — these are reference documents, not executable protocols), verify it contains a concrete trigger line (`**When:**`)
- **WARN** if an executable protocol lacks an explicit trigger
- Read `scripts/mcp_server.py` and verify `memoid_recall` uses `_render_bounded_excerpts` (not bare `_render_file_dump`) for wiki/evidence content
- **ERR** if recall dumps full wiki or evidence files without bounded excerpts
- Verify `memoid_wake_up` output is compact (no `--- File:` verbose headers in detail sections)
- **WARN** if wake-up contains verbose file-path headers

---

## Output Format

Print one line per result:

```
OK   <check name>
ERR  <check name>: <specific file or line> — <reason>
WRN  <check name>: <specific file> — <reason>
```

End with a one-line summary:

```
N error(s), N warning(s).
```

or, if everything passed:

```
All checks passed.
```

---

## Rules

- All `ERR` items must be resolved before closing a filing
- `WRN` items are advisory — resolve when convenient
- If a check cannot be run (e.g., a directory doesn't exist yet), skip it and note it as `SKIP`
