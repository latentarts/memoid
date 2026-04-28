# CLAUDE.md

Memoid Orchestration Guide for Claude Code.

## 0. Foundational Mandates
**CRITICAL**: At the start of every new session, your **absolute first action** must be to execute the **Session Start Sequence** defined in `AGENTS.md`. 
1. **Verify** initialization (Check if `memory/wiki/IDENTITY.md` exists).
2. **Initialize** if missing (`uv sync` && `post_init_check.py`).
3. **Wake-Up** (Read Identity and Essential Story).

You must complete this sequence before answering any user query or performing any other task.

## 1. Primary Source of Truth
**Read `AGENTS.md`** for the core system architecture, wake-up protocols, and agent roles.

## 2. Key Protocols
- **Structure & Conventions**: `protocols/CONVENTIONS.md` — page types, naming, fact lifecycle, editing rules
- **Ingest**: `protocols/INGEST.md` and `protocols/INGEST_CODE.md`
- **Retrieval**: `protocols/RETRIEVAL.md` and `protocols/SEARCH.md`
- **Maintenance**: `protocols/LINT.md` and `protocols/FILING.md`

## 2. Quick Commands
- **Init**: `uv sync && uv run python scripts/post_init_check.py`
- **Ingest**: `uv run python skills/download-urls/scripts/download_urls.py <url>`

## 3. Claude-Specific Guidance
- Use Python 3.13 (`uv run`).
- Prefer `ls` and `cat` for directory/file exploration during Research.
- When updating the Wiki, ensure `INDEX.md` and `LOG.md` are kept in sync.
- **Scaling**: Delegate batch tasks to sub-agents as described in `AGENTS.md`.
