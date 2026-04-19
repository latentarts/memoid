# GEMINI.md

Memoid Orchestration Guide for Gemini CLI.

## 0. Foundational Mandates
**CRITICAL**: At the start of every new session, your **absolute first action** must be to execute the **Session Start Sequence** defined in `AGENTS.md`. 
1. **Verify** initialization (Check if `memory/wiki/IDENTITY.md` exists).
2. **Initialize** if missing (`uv sync` && `post_init_check.py`).
3. **Wake-Up** (Read Identity and Essential Story).

You must complete this sequence before answering any user query or performing any other task.

## 1. Primary Source of Truth
**Read `AGENTS.md`** for the core system architecture, wake-up protocols, and agent roles.

## 2. Quick Commands
- **Init**: `uv sync && uv run python scripts/post_init_check.py`
- **Ingest**: `uv run python skills/download-urls/scripts/download_urls.py <url>`

## 3. Gemini-Specific Guidance
- **Discovery**: Use `mcp_cocoindex-code_search` or `grep_search` to find relevant wiki pages without preloading everything.
- **Planning**: Use `enter_plan_mode` for significant structural changes to the Wiki or Protocols.
- **Scaling**: Delegate batch tasks (like mass-ingest or linting) to the `generalist` sub-agent.
- **Validation**: Always run `post_init_check.py` if you modify core repository structure.
