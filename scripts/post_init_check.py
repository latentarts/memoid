#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_DIRS = [
    ROOT / "memory" / "raw" / "articles",
    ROOT / "memory" / "raw" / "transcripts",
    ROOT / "memory" / "raw" / "assets",
    ROOT / "memory" / "raw" / "inbox",
    ROOT / "memory" / "wiki",
    ROOT / "memory" / "evidence" / "sessions",
    ROOT / "memory" / "evidence" / "decisions",
    ROOT / "memory" / "evidence" / "source-notes",
    ROOT / "memory" / "evidence" / "audits",
]

def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 1

def ensure_directories() -> None:
    for path in REQUIRED_DIRS:
        path.mkdir(parents=True, exist_ok=True)

def main() -> int:
    try:
        ensure_directories()
    except Exception as e:
        return fail(f"Failed to create directories: {e}")

    print("Memoid initialized; runtime directories are ready")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
