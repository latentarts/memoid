#!/usr/bin/env python3
from __future__ import annotations

import importlib
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_DIRS = [
    ROOT / "raw" / "articles",
    ROOT / "raw" / "transcripts",
    ROOT / "raw" / "assets",
    ROOT / "raw" / "inbox",
    ROOT / "wiki",
    ROOT / "evidence" / "sessions",
    ROOT / "evidence" / "source-notes",
    ROOT / "evidence" / "audits",
    ROOT / "skills" / "download-urls" / "scripts",
]

REQUIRED_IMPORTS = [
    "trafilatura",
    "youtube_transcript_api",
    "yt_dlp",
]

CHECK_FILES = [
    ROOT / "README.md",
    ROOT / "SPEC.md",
    ROOT / "skills" / "download-urls" / "scripts" / "download_urls.py",
]


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 1


def main() -> int:
    missing_dirs = [str(path.relative_to(ROOT)) for path in REQUIRED_DIRS if not path.exists()]
    if missing_dirs:
        return fail("missing required directories:\n- " + "\n- ".join(missing_dirs))

    missing_files = [str(path.relative_to(ROOT)) for path in CHECK_FILES if not path.exists()]
    if missing_files:
        return fail("missing required files:\n- " + "\n- ".join(missing_files))

    failed_imports = []
    for module_name in REQUIRED_IMPORTS:
        try:
            importlib.import_module(module_name)
        except Exception as exc:  # noqa: BLE001
            failed_imports.append(f"{module_name}: {exc}")
    if failed_imports:
        return fail("failed imports:\n- " + "\n- ".join(failed_imports))

    downloader = ROOT / "skills" / "download-urls" / "scripts" / "download_urls.py"
    try:
        source = downloader.read_text(encoding="utf-8")
        compile(source, str(downloader), "exec")
    except Exception as exc:  # noqa: BLE001
        return fail(f"download_urls.py failed syntax check: {exc}")

    print("post-init check passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
