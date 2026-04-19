# Init

## Goal

Prepare the repository for first use so the local environment and bundled workflows are ready.

This initializes Memoid in the current workspace.

## When To Use

Use this after cloning the repo, on first run, or whenever the local environment needs to be rebuilt.

Direct phrases that should map to this workflow:

- `init`
- `initialize it`
- `initialize the repo`
- `set up the repo`

## Process

1. Run `uv sync` in the repository root.
2. Run `uv run python scripts/post_init_check.py`.
3. Let the post-init check create the runtime directory structure if it is missing.
3. Report any missing dependencies, broken imports, or missing files.

## Successful Outcome

Initialization is complete when:

- the `uv` environment is synced
- the runtime directories have been created
- key project dependencies import successfully
- required repo directories exist after bootstrap
- the downloader script passes a syntax check

## Rules

- Run from the repository root.
- Do not ingest or mutate `memory/raw/` content during init.
- If `uv sync` fails because dependencies cannot be downloaded, report that clearly and stop.
