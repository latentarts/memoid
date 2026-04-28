# SEARCH

**When:** Finding information across the memory system — answering "do we have anything on X?" or locating a specific fact.

---

## Steps

Work top to bottom. Stop when you have enough to answer.

### 1. Index scan
- Read `memory/wiki/INDEX.md`
- If a section heading or link label directly matches the query topic, follow that link and read the page in full — this is a direct hit, skip remaining steps

### 2. Wiki scan
- Search all `.md` files under `memory/wiki/` for the query terms (case-insensitive)
- For each match, note: file path, section heading the match falls under, and the matching line

### 3. Evidence scan
- If the wiki scan is insufficient, search `memory/evidence/sessions/` and `memory/evidence/decisions/` the same way
- Evidence files contain raw session detail; prefer citing the wiki page that synthesizes them

### 4. Source note scan
- If still insufficient, search `memory/evidence/source-notes/`
- These are raw captures — treat any claim here as unverified until reflected in a wiki page

---

## Output Format

Group results by file. For each match:

```
memory/wiki/entities/my-entity.md § Current
  L12  matching line text here

memory/evidence/sessions/2026-04-23-setup.md § Findings
  L34  another matching line
```

If nothing found:

```
No results for '<query>'.
```

---

## After Searching

- If the answer came from a wiki page → cite it: `(source: wiki/entities/my-entity.md)`
- If the answer required reading evidence directly → write the synthesized fact to the appropriate wiki page so future searches find it in one step
- If the search reveals a gap → add an open question to `memory/wiki/ESSENTIAL_STORY.md`
