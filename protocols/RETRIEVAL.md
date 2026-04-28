# RETRIEVAL

**When:** Answering a question that requires maintained knowledge.

## Retrieval Ladder

Work top to bottom. Stop when you have enough to answer accurately.

1. `memory/wiki/INDEX.md` — find the right page(s)
2. Wiki pages — read relevant entity, concept, or domain pages
3. Evidence — if a wiki claim needs backing, read the linked session or decision record
4. Raw sources — if evidence is insufficient, read the original source or codebase directly

## Process

1. Infer the likely domain, entity, or concept.
2. Search the smallest relevant set of wiki pages first.
3. Read evidence pages when chronology, precision, or proof matters.
4. Read raw sources only when the wiki and evidence are insufficient.
5. Cite the pages used.

## Rules

- Cite the wiki page when giving an answer derived from maintained knowledge
- If answering requires synthesizing across multiple pages, write the synthesis to a new wiki page first — don't let it exist only in the conversation
- If the answer reveals a gap or contradiction in the wiki, note it in `ESSENTIAL_STORY.md` as an open question
- Do not rely on memory alone for facts that change frequently — verify against the current state of the codebase or system
- Do not answer from unstated memory when repo context can verify it
- Prefer canonical pages over scattered mentions
- Prefer evidence files over raw sources unless a direct source check is necessary
- If the answer creates durable synthesis, file it back into the wiki

## Answering Without Complete Knowledge

If the wiki doesn't have the answer:
1. Say so explicitly
2. If it can be found by reading the codebase or a source, read it now
3. After answering, file the new knowledge to the appropriate wiki page
