# AGENTS.md: The Memoid Agent System

This file is the single source of truth for all agents (external Orchestrators and internal Specialists) working within the Memoid system.

---
## 1. The Orchestrator (You)

The Orchestrator is the primary LLM interface (Claude, Gemini, etc.) responsible for managing the session and coordinating specialized tasks.

### Session Start Sequence (Mandatory First Action)
To ensure the workspace is ready, the Orchestrator **must** execute this sequence as its very first turn:

1. **Pre-flight Check**: Check if `memory/wiki/IDENTITY.md` exists.
2. **Conditional Initialization**: If the file is missing or the `memory/` directory is empty:
   - Run `uv sync`
   - Run `uv run python scripts/post_init_check.py`
3. **Wake-Up Protocol**: Once initialized, read the core state:
   - `memory/wiki/IDENTITY.md`
   - `memory/wiki/ESSENTIAL_STORY.md`
   - `AGENTS.md` (This file)

*Note: Do not preload the entire wiki. These three files provide the necessary "seed" context to then use the Retrieval Skill effectively.*

### The Work Lifecycle
...
1. **Research**: Use `mcp_cocoindex-code_search` or `grep` to find existing knowledge.
2. **Execute**: Follow the relevant **Skill** (`skills/`) based on the **Protocol** (`protocols/`).
3. **Persist**: 
   - **Decisions** → `memory/evidence/decisions/`
   - **Knowledge** → `memory/wiki/` (Update entity/concept pages + `INDEX.md` + `LOG.md`)
   - **Lessons** → Agent Diaries in `memory/agents/`

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

## 3. Protocols vs. Skills

| Protocol (`protocols/`) | Skill (`skills/`) | Goal |
| --- | --- | --- |
| `WAKE_UP.md` | `wake-up` | Bounded context state reconstruction. |
| `INGEST.md` | `ingest` | Raw → Evidence → Wiki pipeline. |
| `RETRIEVAL.md` | `retrieval` | Efficient, grounded answer discovery. |
| `FILING.md` | `filing` | Saving session work into durable memory. |
| `COMPACTION.md` | `compaction` | Handoff generation for the next session. |
| `LINT.md` | `lint` | System health and consistency check. |

---

## 4. Operational Rules

1. **Immutable Raw**: Never edit files in `memory/raw/`.
2. **Fact Lifecycle**: Facts live in entity pages. Move old facts to `History`, never delete.
3. **Linkage**: All durable claims in the Wiki *should* link back to `memory/evidence/`.
4. **Context Discipline**: Do not preload the entire wiki. Drill down only when needed.
