---
name: init
description: Initialize Memo for first use by syncing the local uv environment and running the post-init checks. Use when the user says init, initialize it, initialize the repo, or set up the repo.
---

# Init

Use this skill to prepare Memoid for first use.

## Read First

- `protocols/INIT.md`

## Commands

Run from the repository root:

```bash
uv sync
uv run python scripts/post_init_check.py
```

## Output

Report:

- whether `uv sync` succeeded
- whether runtime directories were created
- whether the verification checks passed
- what, if anything, still needs manual attention

## Rules

- Treat `init` and `initialize it` as direct triggers for this workflow.
- Stop and report clearly if dependency installation fails.
- Do not ingest sources as part of init.

