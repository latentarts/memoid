---
name: wake-up
description: Read the minimal startup files for this repo, reconstruct current state, and identify the next most relevant page to read. Use when starting work in this hybrid wiki memory system or when re-orienting after losing context.
---

# Wake-Up

Use this skill to initialize from bounded context instead of reading the whole repo.

## Read Order

1. `protocols/WAKE_UP.md`
2. `wiki/IDENTITY.md`
3. `wiki/ESSENTIAL_STORY.md`
4. `wiki/INDEX.md` only if needed

## Output

State briefly:

- what this repo is
- what is currently active
- what the main unresolved threads are
- which additional page should be read next, if any

## Rules

- Do not preload the whole wiki.
- If the task is obviously domain-specific, recommend one next page instead of opening many.
- Follow `protocols/WAKE_UP.md` for the canonical behavior.

