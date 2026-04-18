# Init

## Goal

Prepare the repository for first use so the local environment and bundled workflows are ready.

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
3. Report any missing dependencies, broken imports, or missing files.

## Successful Outcome

Initialization is complete when:

- the `uv` environment is synced
- key project dependencies import successfully
- required repo directories exist
- the downloader script passes a syntax check

## Rules

- Run from the repository root.
- Do not ingest or mutate `raw/` content during init.
- If `uv sync` fails because dependencies cannot be downloaded, report that clearly and stop.

