# Memoid

Memoid is a markdown-first memory system for AI agents that merges [Karpathy's LLM Wiki approach](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) and [MemPalace](https://github.com/MemPalace/mempalace).

It is designed to be your **"Global Second Brain"**—accessible by any AI agent (Claude, Gemini, Codex, Cursor, OpenCode) regardless of which project you are currently working on.

---

## 🧠 Philosophy & Rationale

Memoid was built to solve the "Agentic Amnesia" problem. While most RAG (Retrieval-Augmented Generation) systems treat memory as a hidden vector database, Memoid treats memory as a **transparent, human-readable wiki**.

### The Hybrid Advantage

By combining **Karpathy’s LLM Wiki** and **MemPalace**, Memoid offers:

- **Compounding Synthesis**: Knowledge isn't just "found"; it is compiled. The more you work, the more the Wiki improves.
- **Operational Discipline**: Explicit protocols (Wake-Up, Ingest, Filing) prevent the "pile of summaries" problem found in unmanaged wikis.
- **Evidence-Backed**: Every wiki claim is linked to an immutable raw source or a session record, ensuring you can always audit *why* the AI remembers something.
- **Zero Lock-in**: Your memory is just Markdown and Git. You can browse it in Obsidian, edit it in VS Code, or version control it like code.

### Feature Comparison

| Feature                          | Karpathy Wiki | MemPalace | Memoid (Hybrid) |
|:-------------------------------- |:-------------:|:---------:|:---------------:|
| **Markdown-First**               | ✅             | ❌         | ✅               |
| **Git-Native**                   | ✅             | ❌         | ✅               |
| **Immutable Raw Sources**        | ✅             | ✅         | ✅               |
| **Maintained Wiki Synthesis**    | ✅             | ❌         | ✅               |
| **Evidence & Session Records**   | ❌             | ✅         | ✅               |
| **Specialist Agent Continuity**  | ❌             | ✅         | ✅               |
| **Bounded Wake-Up Context**      | ❌             | ✅         | ✅               |
| **Explicit Operating Protocols** | ⚠️            | ✅         | ✅               |
| **MCP / Global Tool Access**     | ❌             | ❌         | ✅               |
| **Low Tooling Complexity**       | ✅             | ❌         | ✅               |

### Feature Glossary

- **Markdown-First**: Knowledge is stored in human-readable `.md` files, making it easy to browse in Obsidian, VS Code, or a terminal.
- **Git-Native**: Uses standard Git for version control. **Note**: The `memory/` folder is excluded from the core Memoid engine repo by default, allowing you to initialize it as its own independent Git repository for private, versioned knowledge.
- **Immutable Raw Sources**: Original documents (articles, transcripts) are never edited, serving as the permanent "ground truth" to back up wiki claims.
- **Maintained Wiki Synthesis**: Instead of just searching documents, the agent compiles and improves high-level "Entity" and "Concept" pages over time.
- **Evidence & Session Records**: A durable trail of session logs and source notes that explains exactly *how* and *why* a piece of knowledge was added.
- **Specialist Agent Continuity**: Persistent diaries for specialized agent roles (Researcher, Reviewer), allowing them to learn and improve their habits over time.
- **Bounded Wake-Up Context**: A "minimalist" startup protocol that prevents the agent from being overwhelmed by too much data at the start of a session.
- **Explicit Operating Protocols**: Clear Markdown instructions (`protocols/`) that define the agent's behavior, ensuring consistent ingestion and retrieval.
- **MCP / Global Tool Access**: Integration via Model Context Protocol, allowing any agent to access your brain from a different project's directory.
- **Low Tooling Complexity**: No specialized databases or vector stores required; if you can edit a text file, you can maintain Memoid.

### ⚠️ Limitations

- **Not a Vector DB**: It relies on text search and agent-led navigation. It is optimized for quality and context, not for millisecond-latency searches over millions of documents.
- **Agent Effort**: It requires the AI to perform "work" (following protocols) to maintain the memory. It is a system for high-quality synthesis, not low-effort data dumping.
- **Git Discipline**: To keep your memory synced across machines, you must manage your own Git pushes/pulls.

---

## 🏗️ Architecture

Memoid is 100% transparent. No databases, just interlinked Markdown files.

- **`memory/`**: The Data. Your compounding knowledge base (Raw sources, Wiki, Evidence).
- **`protocols/`**: The Rules. Markdown instructions that tell the AI how to Ingest, Retrieve, and File.
- **`scripts/`**: The Tools. A lean CLI for maintenance and an MCP server for global connectivity.

---

## 🚀 Quick Start

### 1. Unified Installation (Recommended)

Run the one-line installer to clone and initialize Memoid on your system.

**Linux / macOS:**

```bash
curl -sSL https://raw.githubusercontent.com/latentarts/memoid/main/scripts/install.sh | bash
```

**Windows (PowerShell):**

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/latentarts/memoid/main/scripts/install.ps1 | iex"
```

*The installer will ask for your preferred path and install `uv` if missing. Once installed, proceed to the [MCP Setup](#-mcp-setup) section to connect your agents.*

---

### 2. Manual Setup (Alternative)

If you prefer to do it yourself:

1. **Clone**: `git clone https://github.com/latentarts/memoid.git ~/memoid`
2. **Initialize**: `cd ~/memoid && ./scripts/memoid init`
3. **Update**: Keep your brain up to date with `./scripts/memoid update`
4. **Direct Access (Local)**: To work **inside** your knowledge base repo (e.g., to reorganize the wiki), run: `memoid gemini`
5. **Global Access (Cross-Project)**: Set up the [MCP Server](#-mcp-setup) in your agent's config.

---

## 💡 Usage Examples

### Coexistence: Local CLI vs. MCP

You may find yourself running an AI agent (like Gemini CLI) directly inside the Memoid repository while *also* having the Memoid MCP server enabled in your agent's configuration.

**Do they compete?** No. They are designed to coexist:

- **No Technical Conflict**: There is no file-locking or process competition that will cause crashes.
- **Functional Cooperation**: The MCP server provides high-level "Memoid-native" tools (`memoid_ingest`, `memoid_recall`) that automate several manual steps.
- **Converged Workflow**: When both are available, use the **MCP tools** for standard memory operations (ingesting, logging, searching) and use your **native agent tools** (read, write, grep) for low-level repository maintenance or structural refactoring.

---

### Case A: Working in another project (via MCP)

*Scenario: You are in `~/projects/my-app` and need help.*

**Prompt:** "Search my Memoid for that OAuth2 pattern we used last month."

> **AI Action:** Calls `memoid_recall` to find the code in your brain.

**Prompt:** "Document this bug fix in my Memoid."

> **AI Action:** Calls `memoid_ingest` to save the logic into your brain's `raw/` and `evidence/` folders.

### Case B: Maintaining your Brain (Direct CLI)

*Scenario: You are in `~/memoid` and want to clean up.*

**Prompt:** "Audit the wiki for any contradictions and update the Index."

> **AI Action:** Follows `protocols/LINT.md` to check consistency.

---

## 🛠️ CLI Commands

| Command          | Description                                                                                                             |
|:---------------- |:----------------------------------------------------------------------------------------------------------------------- |
| `memoid init`    | Prepares the directory structure. Safe to run multiple times; it will not delete existing data.                         |
| `memoid update`  | Updates the engine and protocols. **Never** overwrites your knowledge base (`memory/` folder).                          |
| `memoid <agent>` | Launches an agent (e.g., `gemini`, `claude`, `codex`) inside the brain. Shortcut for running the agent in the `~/memoid` folder. |
| `memoid version` | Displays the current version.                                                                                           |

---

## 🔄 Core Workflows

Memoid is governed by simple, repeatable workflows. Here is how the AI interacts with your files.

### 1. Wake-Up (Context Reconstruction)

When you start a session, the AI doesn't read the whole wiki. It follows a "minimalist" sequence to understand who it is and what you are working on.

```mermaid
graph LR
    A[Agent] --> B[protocols/WAKE_UP.md]
    B --> C[memory/wiki/IDENTITY.md]
    C --> D[memory/wiki/ESSENTIAL_STORY.md]
    D --> E[Reconstructed Context]
```

1. **`WAKE_UP.md`**: The AI reads its "bootstrap" instructions.
2. **`IDENTITY.md`**: It learns its role and your personal preferences.
3. **`ESSENTIAL_STORY.md`**: It gets up to speed on active projects and recent changes.

### 2. Search (The Retrieval Ladder)

To provide accurate, grounded answers, the AI climbs a "ladder" from high-level summaries down to the raw ground truth.

```mermaid
graph TD
    Q[Question] --> L1[1. memory/wiki/INDEX.md]
    L1 --> L2[2. Relevant Wiki Pages]
    L2 --> L3[3. Evidence Source Notes]
    L3 --> L4[4. Raw Source Files]
```

1. **Index**: Finds which pages might have the answer.
2. **Wiki**: Reads the compiled synthesis for a quick, high-quality answer.
3. **Evidence**: Checks the source notes to verify the "how" and "when."
4. **Raw**: Consults the original immutable document if absolute precision is required.

### 3. Ingest (The Knowledge Pipeline)

When you add new information, the AI follows a strict pipeline to ensure the knowledge is synthesized and logged, not just dumped.

```mermaid
sequenceDiagram
    participant R as Raw Source
    participant E as Evidence Note
    participant W as Wiki Pages
    participant L as LOG.md

    Note over R: 1. Store original file
    R->>E: 2. Extract metadata & summary
    E->>W: 3. Update or create concept pages
    W->>L: 4. Record the change
```

1. **Raw**: The original file is stored permanently in `memory/raw/`.
2. **Evidence**: A "Source Note" is created in `memory/evidence/source-notes/` to preserve provenance.
3. **Wiki**: The AI updates one or more canonical pages in `memory/wiki/` with the new insights.
4. **Log**: The action is recorded in `memory/wiki/LOG.md` for a clear audit trail.

### 4. Audit (Consistency & Health)

To prevent drift and contradictions, the system undergoes regular audits to maintain the integrity of the second brain.

```mermaid
graph LR
    A['memory/wiki/LOG.md'] --> B[Sample Active Pages]
    B --> C['memory/evidence/audits/']
    C --> D[System Health Report]
```

1. **Review**: Sample recent logs and active pages to identify drift or missing structure.
2. **Cross-Check**: Verify that wiki claims still align with their evidence notes.
3. **Log Findings**: Record maintenance tasks and inconsistencies in `memory/evidence/audits/`.
4. **Prune**: Move stale information to `History` sections to keep current pages focused.

---

## 📖 Key Protocols

Memoid doesn't use complex code for logic; it uses Markdown instructions in the `protocols/` folder:

- **`INGEST.md`**: How to turn a source into a Wiki page.
- **`RETRIEVAL.md`**: How to find the most accurate answer.
- **`FILING.md`**: What deserves to be saved permanently.
- **`LINT.md`**: How to perform consistency audits.
- **`WAKE_UP.md`**: How the agent reconstructs its context at the start of a session.

---

## 🔌 MCP Setup

Memoid uses the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) to provide your global brain to any AI agent. To enable this, you must add Memoid as a server in your agent's configuration.

### 1. Identify your Install Path
The standard installation path is `~/memoid`. Replace `FULL_PATH_TO_MEMOID` in the examples below with your actual absolute path (e.g., `/home/user/memoid`).

### 2. Configuration for AI Agents

#### **Claude Desktop**
Edit your `claude_desktop_config.json` (usually at `~/.config/Claude/claude_desktop_config.json` on Linux or `~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "memoid": {
      "command": "uv",
      "args": ["--directory", "FULL_PATH_TO_MEMOID", "run", "scripts/mcp_server.py"]
    }
  }
}
```

#### **OpenCode**
Edit your `opencode.json` (usually at `~/.config/opencode/opencode.json`):

```json
{
  "mcp": {
    "memoid": {
      "type": "local",
      "command": ["uv", "--directory", "FULL_PATH_TO_MEMOID", "run", "scripts/mcp_server.py"],
      "enabled": true
    }
  }
}
```

#### **Gemini CLI / Codex CLI**
These CLIs typically use a `~/.gemini/settings.json` file. Ensure they are configured to point to the Memoid MCP server:

```json
{
  "mcpServers": {
    "memoid": {
      "command": "uv",
      "args": ["--directory", "FULL_PATH_TO_MEMOID", "run", "scripts/mcp_server.py"]
    }
  }
}
```

---

## 🔧 Troubleshooting

### Agent Command Not Found
If you get an error like `Error: Agent command 'gemini' not found in PATH`, ensure that the agent CLI is installed globally on your system.

**For npm-based CLIs (Gemini, Codex, etc.):**
```bash
sudo npm install -g @google/gemini-cli
sudo npm install -g @openai/codex
```

**For other CLIs:**
Ensure the binary is in your `$PATH` (e.g., in `/usr/local/bin` or `~/.local/bin`). You can verify this by running `command -v <agent_name>` in your terminal.

---

## 📜 License

MIT - Created by [prods](https://github.com/latentarts)
