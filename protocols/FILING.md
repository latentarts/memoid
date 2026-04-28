# FILING

**When:** End of a work session, before hitting context limits, or after significant decisions.

## File When

- a decision was made
- a reusable insight was discovered
- a durable fact changed
- a source was ingested
- a specialist agent learned a recurring pattern
- an unresolved thread should survive this session

## Steps

1. **Write a session record**
   - Location: `memory/evidence/sessions/YYYY-MM-DD-<slug>.md`
   - Sections: Context, Events, Findings, Decisions, Follow-ups
   - Keep it concise — a reader should understand what happened in 2 minutes

2. **Update wiki pages**
   - Update any entity, concept, or domain pages touched during the session
   - New facts in `Current`, old facts moved to `History`
   - Link to the session record when a claim originated in this session

3. **Record significant decisions**
   - Location: `memory/evidence/decisions/YYYY-MM-DD-<slug>.md`
   - Include: decision made, rationale, alternatives considered, expected consequences
   - Link from relevant wiki pages

4. **Update ESSENTIAL_STORY.md**
   - Reflect new current state, close resolved threads, add new open questions
   - Keep it bounded — 10–20 lines max

5. **Append LOG.md**
   - One line: `YYYY-MM-DD: <what happened>`

## Pre-Context-Limit Compaction

If context is running out before a proper filing:
1. Write a minimal session note: current state + unresolved items + key decisions made
2. Note which wiki pages are affected but not yet updated
3. Prefer short and accurate over comprehensive and rushed — the goal is a clean handoff

## Avoid Filing

- transient chatter
- duplicate summaries
- low-confidence guesses
- ephemeral implementation noise with no future value

## Rules

- Never skip filing after a session where decisions were made — knowledge loss is permanent
- Session records are evidence, not summaries — include specific facts, not just "we discussed X"
- A wiki update without a session record is acceptable for small edits; a session record without a wiki update is not
- Filing is the last step before closing a session, not the first step of the next one
