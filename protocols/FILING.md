# Filing

## Goal

Preserve only durable knowledge and keep the main wiki coherent.

## File When

- a decision was made
- a reusable insight was discovered
- a durable fact changed
- a source was ingested
- a specialist agent learned a recurring pattern
- an unresolved thread should survive this session

## Process

1. **Audit**: Run a subset of the `LINT.md` checks on the modified pages to ensure no new contradictions were introduced.
2. **Record**: Update or create a session record under `memory/evidence/sessions/`.
3. **Persist**: Update affected wiki pages.
4. **Learn**: Update an agent diary if the lesson is specialized.
5. **Update State**: Update current/history facts when reality changed.
6. **Refresh Context**: Update `memory/wiki/ESSENTIAL_STORY.md` only if startup context should change.

## Avoid Filing

- transient chatter
- duplicate summaries
- low-confidence guesses
- ephemeral implementation noise with no future value

