# Memoid

> [!WARNING]
> This is experimental and it's being tested.

Memoid is a markdown-first memory system for AI agents that merges [Karpathy's LLM Wiki approach](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) and [MemPalace](https://github.com/MemPalace/mempalace).

It maintains a persistent wiki that compounds over time, adding operational discipline to ensure the wiki stays useful as a grounded memory layer instead of an ungrounded pile of summaries.

```mermaid
graph TD
    User([User])
    Agent{AI Agent}
    Memory[(memory/)]
    Protocols{protocols/}

    User --> Agent
    Agent --> Protocols
    Agent --> Memory

    Memory -- "Raw Sources" --> Agent
    Memory -- "Maintained Synthesis" --> Agent
    Memory -- "Chronology & Proof" --> Agent
    Memory -- "Specialist Continuity" --> Agent
    Protocols -- "Operating Rules" --> Agent
```

## Two Ways to Use Memoid

Memoid is designed to be flexible, supporting everything from a single project to a multi-workspace fleet.

### 1. Direct Clone (The "Template" Model)

If you only need one memory system for one project:

1. `git clone https://github.com/prods/memoid.git my-project`
2. `cd my-project && uv sync`
3. Start your prefered AI agent on the cloned repo path. 
   *The repo comes pre-configured with a clean `memory/wiki/` and `memory/agents/` structure.*

### 2. Managed Workspaces (The "CLI" Model)

If you want to manage multiple isolated knowledge bases (workspaces):

1. Run the [One-Line Install](#installation--upgrades) to create your first workspace and install the `memoid` CLI.
2. Use `memoid new <name>` to create additional workspaces.
3. Use `memoid ls` to list your workspaces.
4. Use `memoid <workspace> <agent>` to launch an agent (like `claude` , `codex` or `gemini`) directly inside a specific workspace.

```mermaid
graph TD
    CLI[memoid CLI]
    WS1[Workspace 1]
    WS2[Workspace 2]
    WSN[Workspace N]

    CLI -- "new / ls / update" --> WS1
    CLI -- "new / ls / update" --> WS2
    CLI -- "new / ls / update" --> WSN

    subgraph "Independent Repositories"
    WS1 --- D1(memory/)
    WS2 --- D2(memory/)
    WSN --- DN(memory/)
    end
```

## Installation & Upgrades

> [!IMPORTANT]
> This step is optional. The `memoid` script is just a way to simplify updating, creating workspaces, and running the AI agents on them, but the same can be achieved by just cloning the repo in different folders and starting the AI agent on it.

### One-Line Install (Linux/macOS)

```bash
curl -sSL https://raw.githubusercontent.com/prods/memoid/main/scripts/install.sh | bash -s my-workspace
```

### One-Line Install (Windows PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -c "& { $(irm https://raw.githubusercontent.com/prods/memoid/main/scripts/install.ps1) } my-workspace"
```

### CLI Commands

| Command                                | Description                                                         |
|:-------------------------------------- |:------------------------------------------------------------------- |
| `memoid <workspace> <agent> [args...]` | Launches any agent within a workspace.                              |
| `memoid new <name>`                    | Creates a new isolated workspace by cloning the repo.               |
| `memoid ls`                            | List all available workspaces.                                      |
| `memoid update [name]`                 | Pulls the latest changes for a workspace (defaults to current dir). |
| `memoid version [name]`                | Displays the version of a workspace (defaults to current dir).      |

- **Mechanism**: Automatically symlinks `memoid` into `~/.local/bin/memoid` (Linux/macOS) or `memoid.ps1` (Windows) for global access.
- **Developer Mode**: Use `--local` with the install scripts to clone from your local engine copy instead of GitHub.
- **Dependencies**: Requires `git` and [uv](https://github.com/astral-sh/uv) (required to support Python-based skills).

## Repository Layout

```text
memory/
  raw/        immutable source material
  wiki/       maintained knowledge surface (templates only in repo)
  evidence/   support records and chronology
  agents/     specialist memory streams
protocols/    operating rules for the agent
```

Key files:

- [memory/wiki/IDENTITY.md](./memory/wiki/IDENTITY.md): who the main agent is and how it should behave
- [memory/wiki/ESSENTIAL_STORY.md](./memory/wiki/ESSENTIAL_STORY.md): bounded current-state brief
- [memory/wiki/INDEX.md](./memory/wiki/INDEX.md): main navigation page
- [memory/wiki/LOG.md](./memory/wiki/LOG.md): chronology of major ingests and changes
- [protocols/WAKE_UP.md](./protocols/WAKE_UP.md): minimal startup behavior
- [protocols/RETRIEVAL.md](./protocols/RETRIEVAL.md): how the agent should answer questions
- [protocols/INGEST.md](./protocols/INGEST.md): how to add new knowledge
- [protocols/FILING.md](./protocols/FILING.md): what deserves persistence
- [protocols/COMPACTION.md](./protocols/COMPACTION.md): what to preserve before context loss

## Why This Exists

This repository exists to bring MemPalace-style discipline into the Karpathy wiki approach.

Karpathy's pattern is the architectural foundation: use immutable raw sources plus a maintained markdown wiki so knowledge compounds over time instead of being rediscovered from scratch on every query.

MemPalace contributes the discipline layer:

- bounded wake-up context
- layered retrieval
- evidence preservation
- compaction and filing discipline
- specialist continuity
- current-vs-history fact handling

The result is a memory system that compounds instead of resetting.

## Automated AI Orchestration

Memoid is designed to be "self-starting" when used with a compatible AI agent (like Claude Code or Gemini CLI). 

When you open an agent on a Memoid workspace, the agent is instructed to automatically:
1. **Verify Initialization**: Check if the environment and knowledge base are ready.
2. **Auto-Initialize**: Run `uv sync` and `post_init_check.py` if needed.
3. **Wake-Up**: Read core identity and status files to reconstruct the current state.

This means you can usually just start your agent and begin working immediately.

---

## How It Works (Manual Steps)

While orchestration is automated for agents, you can still perform these operations manually if needed.

### 0. Initialization

Prepare the repo for first use. **Note: [uv](https://github.com/astral-sh/uv) is required to manage the environment and support Python-based skills.**

1. `uv sync`
2. `uv run python scripts/post_init_check.py`

### 1. Wake-Up

At the beginning of a session, reconstruct the state by reading:

- `memory/wiki/IDENTITY.md`
- `memory/wiki/ESSENTIAL_STORY.md`
- `AGENTS.md`

```mermaid
graph LR
    Agent{Agent}
    WU[protocols/WAKE_UP.md]
    ID[memory/wiki/IDENTITY.md]
    ES[memory/wiki/ESSENTIAL_STORY.md]
    
    Agent --> WU
    Agent --> ID
    Agent --> ES
    
    subgraph "Minimal Startup Context"
    WU
    ID
    ES
    end
```

### 2. Retrieval

When a question arrives, the agent uses this ladder:

1. `memory/wiki/INDEX.md`
2. Relevant wiki pages
3. Linked evidence pages
4. Raw sources

```mermaid
graph TD
    Q[Question] --> Index[1. memory/wiki/INDEX.md]
    Index --> Wiki[2. Relevant wiki pages]
    Wiki --> Evidence[3. Linked evidence pages]
    Evidence --> Raw[4. Raw sources]
    
    subgraph "The Retrieval Ladder"
    Index
    Wiki
    Evidence
    Raw
    end
```

### 3. Ingest

When adding a new source:

1. Store it under `memory/raw/`
2. Create a source note under `memory/evidence/source-notes/`
3. Update relevant wiki pages and the index/log.

```mermaid
sequenceDiagram
    participant User
    participant Agent
    participant Raw
    participant Evidence
    participant Wiki
    
    User->>Raw: Store source in memory/raw/
    Agent->>Raw: Read source
    Agent->>Evidence: Create source note
    Agent->>Wiki: Update relevant pages
    Agent->>Wiki: Update INDEX.md & LOG.md
```

### 4. Codebase Ingestion

When ingesting a local solution or codebase:

1. Provide the filesystem path to the agent.
2. The agent extracts architecture, project structure, and key flows.
3. Durable knowledge is filed into `memory/evidence/source-notes/` and `memory/wiki/`.

```mermaid
graph LR
    Path[Codebase Path] --> Agent{AI Agent}
    Agent --> Arch[Extract Architecture]
    Agent --> Flows[Trace Key Flows]
    Arch --> Memory[(memory/)]
    Flows --> Memory
```

## Included Skills

Project-local skills are provided under `skills/`:

- `skills/init/`: Prepare the repo for first use.
- `skills/download-urls/`: Download URLs/YouTube transcripts into `memory/raw/`.
- `skills/wake-up/`: Initialize from bounded context.
- `skills/ingest/`: Turn raw sources into wiki knowledge.
- `skills/ingest-solution-code/`: Ingest a codebase by extracting its architecture and patterns.
- `skills/retrieval/`: Answer from maintained knowledge first.
- `skills/filing/`: Preserve durable knowledge from a session.
- `skills/compaction/`: Write a handoff before context loss.
- `skills/lint/`: Audit the repo for drift and missing structure.

## Best Practices

- **Version Control your Memory**: Your `memory/` directory is where your knowledge compounds. We highly recommend version controlling this entire folder. This allows you to audit agent changes, revert "hallucinations," and sync your memory across machines.
  > **Tip**: The default `.gitignore` prevents engine artifacts from being tracked. To track your own knowledge, remove the `/memory/*` ignore rules in your local `.gitignore`.
- **Keep `memory/raw/` immutable**: Never edit files in `memory/raw/`. They are your "ground truth."
- **Link wiki claims to evidence**: Use citations to point from the wiki back to session or source notes.
- **Use `Current` and `History` sections**: For facts that change (like project status or entity roles), keep the old data in a `History` section.
- **Run periodic lint passes**: Use `memoid <workspace> lint` to find orphan pages or contradictions.

```mermaid
graph LR
    Agent[Agent Updates Wiki] --> Commit[User Reviews & Commits]
    Commit --> Truth[Durable Knowledge]
    Truth --> Agent
    
    subgraph "Knowledge Audit Loop"
    Agent
    Commit
    Truth
    end
```

## Related Files

- [SPEC.md](./SPEC.md): formal architecture and rationale
- [protocols/SCHEMA.md](./protocols/SCHEMA.md): page and naming conventions
- [memory/wiki/INDEX.md](./memory/wiki/INDEX.md): current navigation entry point

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
