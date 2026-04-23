#!/usr/bin/env python3
import os
import datetime
from pathlib import Path
from typing import Optional, List, Dict, Any
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP server
mcp = FastMCP("Memoid")

# Root directory of the Memoid repository
ROOT = Path(__file__).resolve().parents[1]
MEMORY_DIR = ROOT / "memory"
RAW_DIR = MEMORY_DIR / "raw"
WIKI_DIR = MEMORY_DIR / "wiki"
EVIDENCE_DIR = MEMORY_DIR / "evidence"

@mcp.tool()
def memoid_recall(query: str, limit: int = 10) -> str:
    """
    Searches the Memoid wiki and evidence directories for the given query.
    Returns the content of matching markdown files.
    """
    results = []
    # Search in wiki and evidence
    search_paths = [WIKI_DIR, EVIDENCE_DIR]
    
    for search_path in search_paths:
        if not search_path.exists():
            continue
        for md_file in search_path.glob("**/*.md"):
            try:
                content = md_file.read_text(encoding="utf-8")
                if query.lower() in content.lower() or query.lower() in md_file.name.lower():
                    rel_path = md_file.relative_to(ROOT)
                    results.append(f"--- File: {rel_path} ---\n{content}\n")
                    if len(results) >= limit:
                        break
            except Exception as e:
                continue
        if len(results) >= limit:
            break
            
    if not results:
        return f"No results found for query: '{query}'"
    
    return "\n".join(results)

@mcp.tool()
def memoid_ingest(content: str, source_name: str, metadata: Optional[Dict[str, Any]] = None) -> str:
    """
    Ingests new content into Memoid.
    Saves the raw content, creates a source note, and logs the action.
    """
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    safe_name = source_name.replace(" ", "_").replace("/", "_")
    
    # 1. Save Raw Source
    raw_file = RAW_DIR / "inbox" / f"{safe_name}.md"
    raw_file.parent.mkdir(parents=True, exist_ok=True)
    raw_file.write_text(content, encoding="utf-8")
    
    # 2. Create Source Note
    source_note_path = EVIDENCE_DIR / "source-notes" / f"{safe_name}.md"
    source_note_path.parent.mkdir(parents=True, exist_ok=True)
    
    meta_str = ""
    if metadata:
        for k, v in metadata.items():
            meta_str += f"- **{k}**: {v}\n"
            
    source_note_content = f"""# Source Note: {source_name}

- **Ingested At**: {timestamp}
- **Raw Path**: memory/raw/inbox/{safe_name}.md
{meta_str}

## Summary
(Auto-generated from ingest)
{content[:500]}...
"""
    source_note_path.write_text(source_note_content, encoding="utf-8")
    
    # 3. Log the action
    log_file = WIKI_DIR / "LOG.md"
    log_entry = f"\n- {timestamp}: Ingested '{source_name}' via MCP."
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(log_entry)
        
    return f"Successfully ingested '{source_name}'.\nRaw: {raw_file.relative_to(ROOT)}\nNote: {source_note_path.relative_to(ROOT)}"

@mcp.tool()
def memoid_log(entry: str, category: str = "session") -> str:
    """
    Appends a log entry to Memoid's LOG.md and a session file.
    """
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    date_str = datetime.datetime.now().strftime("%Y-%m-%d")
    
    # 1. Update LOG.md
    log_file = WIKI_DIR / "LOG.md"
    log_entry = f"\n- {timestamp} [{category}]: {entry}"
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(log_entry)
        
    # 2. Update Session Log
    session_file = EVIDENCE_DIR / "sessions" / f"{date_str}.md"
    session_file.parent.mkdir(parents=True, exist_ok=True)
    
    if not session_file.exists():
        session_file.write_text(f"# Session Log: {date_str}\n", encoding="utf-8")
        
    with open(session_file, "a", encoding="utf-8") as f:
        f.write(f"\n## {timestamp} ({category})\n{entry}\n")
        
    return f"Log entry added to {log_file.relative_to(ROOT)} and {session_file.relative_to(ROOT)}"

@mcp.tool()
def memoid_edit_wiki(page_path: str, content: str) -> str:
    """
    Creates or updates a wiki page in memory/wiki/.
    page_path should be relative to memory/wiki/ (e.g., 'concepts/mcp.md').
    """
    target_path = WIKI_DIR / page_path
    if not target_path.suffix == ".md":
        target_path = target_path.with_suffix(".md")
        
    target_path.parent.mkdir(parents=True, exist_ok=True)
    
    action = "Updated" if target_path.exists() else "Created"
    target_path.write_text(content, encoding="utf-8")
    
    # Log the edit
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_file = WIKI_DIR / "LOG.md"
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"\n- {timestamp}: {action} wiki page '{page_path}' via MCP.")
        
    return f"{action} wiki page at {target_path.relative_to(ROOT)}"

if __name__ == "__main__":
    mcp.run()
