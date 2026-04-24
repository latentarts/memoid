# AGENTS.md: The Memoid Agent System

This file is the single source of truth for all agents (external Orchestrators and internal Specialists) working within the Memoid system.

---
## 1. The Orchestrator (You)

The Orchestrator is the primary LLM interface (Claude, Gemini, etc.) responsible for managing the session and coordinating specialized tasks.

### Session Start Sequence (Mandatory First Action)
To ensure the workspace is ready, the Orchestrator **must** execute this sequence as its very first turn:

1. **Pre-flight Check**: Check if `memory/wiki/IDENTITY.md` exists.
2. **Conditional Initialization**: If the file is missing or the `memory/` directory is empty:
   - Run `memoid init` (or `uv run python scripts/post_init_check.py`).
3. **Wake-Up Protocol**: Once initialized, read the core state:
   - `memory/wiki/IDENTITY.md`
   - `memory/wiki/ESSENTIAL_STORY.md`
   - `AGENTS.md` (This file)

*Note: Do not preload the entire wiki. These three files provide the necessary "seed" context to then use the Retrieval Protocol effectively.*

### The Work Lifecycle

1. **Research**: When working inside the Memoid repository directory, use native local tools available in the repo/environment (for example `rg`, `grep`, `find`, local scripts, and direct file reads). Do **not** use the Memoid MCP from inside this repository. Outside the repo, use the best available retrieval path for the task.
2. **Execute**: Follow the relevant **Protocol** in `protocols/`.
3. **Audit**: Run the `LINT.md` protocol to ensure consistency, especially after significant changes.
4. **Persist**: 
   - **Decisions** → `memory/evidence/decisions/`
   - **Knowledge** → `memory/wiki/` (Update entity/concept pages + `INDEX.md` + `LOG.md`)
   - **Lessons** → Agent Diaries in `memory/agents/`

### Operational Strategies
- **Scaling**: For high-volume or batch tasks (e.g., mass-ingesting 10+ sources, repo-wide consistency audits), delegate to a `generalist` or specialized sub-agent to preserve the main orchestrator's context.
- **Verification**: Always run `scripts/post_init_check.py` after modifying the core repository structure or protocols.

---

## 2. Specialized Internal Agents

These are internal personas with dedicated continuity folders in `memory/agents/`.

| Agent | Core Focus | Location |
| --- | --- | --- |
| **Researcher** | Ingesting sources, extracting insights, updating wiki pages. | `memory/agents/researcher/` |
| **Reviewer** | Critiquing structure, consistency audits, and evidence verification. | `memory/agents/reviewer/` |

### Continuity Patterns (The Diary)
Each specialized agent maintains a `DIARY.md`. This is for **meta-learning**, not task logs. Record:
- Successes/failures in specific workflows.
- Heuristics (e.g., "When summarizing transcripts, always preserve technical jargon").
- Discovered contradictions in the wiki hierarchy.

---

## 3. Protocols

| Protocol (`protocols/`) | Goal |
| --- | --- |
| `WAKE_UP.md` | Bounded context state reconstruction. |
| `INGEST.md` | Raw → Evidence → Wiki pipeline. |
| `RETRIEVAL.md` | Efficient, grounded answer discovery. |
| `FILING.md` | Saving session work into durable memory. |
| `COMPACTION.md` | Handoff generation for the next session. |
| `LINT.md` | System health and consistency check. |
| `INIT.md` | Prepare the repo for first use. |

*Note: Operational logic lives in the Protocols. When the current working directory is the Memoid repository, execute them with native local tools rather than the Memoid MCP. Only use the Memoid MCP from outside the repo when native repo access is not the operating context.*

---

## 4. Operational Rules

1. **Immutable Raw**: Never edit files in `memory/raw/`.
2. **Fact Lifecycle**: Facts live in entity pages. Move old facts to `History`, never delete.
3. **Linkage**: All durable claims in the Wiki *should* link back to `memory/evidence/`.
4. **Context Discipline**: Do not preload the entire wiki. Drill down only when needed.
5. **Repo-Local Tooling Rule**: If the agent is operating from within the Memoid repository directory, do not use the Memoid MCP. Prefer the native tools available in the repository and local environment.
6. **Feature Triage**: Engine enhancement ideas that are being researched but **not yet committed** to implementation should be placed in `.feature-triage/`. This folder is excluded from the main wiki, evidence, and LOG entries. Structure: `.feature-triage/<idea-name>/` containing independent analysis, proposed solutions, and supporting research.
7. **Feature Promotion**: Notes in `.feature-triage/` remain private exploration by default. They may only be promoted into GitHub issues when the user explicitly asks for it. Eligible notes should use the triage template, include a clear status such as `draft`, `ready-for-issue`, or `filed`, and be checked for duplicates before filing. When creating an issue from a triage note, prefer promoting only notes marked `ready-for-issue`, create one intentional issue per note unless the user asks otherwise, and write the resulting GitHub issue number or URL back into the note so future agents can see that it has already been filed.
