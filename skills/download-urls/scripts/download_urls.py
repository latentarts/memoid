#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from urllib.parse import urlparse

import trafilatura
from youtube_transcript_api import (
    NoTranscriptFound,
    TranscriptsDisabled,
    YouTubeTranscriptApi,
)
from yt_dlp import YoutubeDL


ROOT = Path(__file__).resolve().parents[3]
RAW_ARTICLES = ROOT / "raw" / "articles"
RAW_TRANSCRIPTS = ROOT / "raw" / "transcripts"


@dataclass
class DownloadResult:
    url: str
    path: Path
    kind: str


def slugify(text: str) -> str:
    text = text.strip().lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    text = re.sub(r"-{2,}", "-", text)
    return text.strip("-") or "item"


def is_youtube_url(url: str) -> bool:
    host = urlparse(url).netloc.lower()
    return "youtube.com" in host or "youtu.be" in host


def utc_now() -> str:
    return datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ")


def unique_path(directory: Path, stem: str) -> Path:
    candidate = directory / f"{stem}.md"
    if not candidate.exists():
        return candidate
    counter = 2
    while True:
        candidate = directory / f"{stem}-{counter}.md"
        if not candidate.exists():
            return candidate
        counter += 1


def write_markdown(path: Path, body: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body.strip() + "\n", encoding="utf-8")


def frontmatter_block(kind: str, url: str, title: str, extra: dict[str, str]) -> str:
    lines = [
        "---",
        f"type: {kind}",
        f"source_url: {url}",
        f"title: {title!r}",
        f"downloaded_at: {utc_now()}",
    ]
    for key, value in extra.items():
        safe = value.replace("\n", " ").strip()
        lines.append(f"{key}: {safe!r}")
    lines.append("---")
    return "\n".join(lines)


def download_article(url: str) -> DownloadResult:
    downloaded = trafilatura.fetch_url(url)
    if not downloaded:
        raise RuntimeError("failed to fetch URL")

    markdown = trafilatura.extract(
        downloaded,
        url=url,
        output_format="markdown",
        include_links=True,
        include_formatting=True,
    )
    if not markdown:
        raise RuntimeError("failed to extract article text")

    metadata = trafilatura.extract_metadata(downloaded)
    title = metadata.title if metadata and metadata.title else urlparse(url).path.strip("/") or "article"
    stem = slugify(title)
    path = unique_path(RAW_ARTICLES, stem)
    body = "\n\n".join(
        [
            frontmatter_block(
                "article",
                url,
                title,
                {
                    "site": metadata.sitename if metadata and metadata.sitename else "",
                    "author": metadata.author if metadata and metadata.author else "",
                    "date": metadata.date if metadata and metadata.date else "",
                },
            ),
            f"# {title}",
            markdown,
        ]
    )
    write_markdown(path, body)
    return DownloadResult(url=url, path=path, kind="article")


def extract_youtube_video_id(url: str) -> str | None:
    parsed = urlparse(url)
    host = parsed.netloc.lower()
    if "youtu.be" in host:
        return parsed.path.strip("/") or None
    if "youtube.com" in host:
        if parsed.path == "/watch":
            params = dict(part.split("=", 1) for part in parsed.query.split("&") if "=" in part)
            return params.get("v")
        if parsed.path.startswith("/shorts/") or parsed.path.startswith("/embed/"):
            return parsed.path.rstrip("/").split("/")[-1]
    return None


def get_youtube_metadata(url: str) -> dict[str, str]:
    with YoutubeDL({"quiet": True, "no_warnings": True, "extract_flat": True}) as ydl:
        info = ydl.extract_info(url, download=False)
    return {
        "title": info.get("title") or "youtube-video",
        "channel": info.get("channel") or info.get("uploader") or "",
        "upload_date": info.get("upload_date") or "",
        "duration_string": info.get("duration_string") or "",
        "webpage_url": info.get("webpage_url") or url,
    }


def get_youtube_transcript(video_id: str) -> str:
    api = YouTubeTranscriptApi()
    fetched = api.fetch(video_id)
    chunks = []
    for item in fetched:
        text = item.text.strip()
        if text:
            chunks.append(text)
    if not chunks:
        raise RuntimeError("empty transcript")
    return "\n".join(chunks)


def download_youtube(url: str) -> DownloadResult:
    video_id = extract_youtube_video_id(url)
    if not video_id:
        raise RuntimeError("could not determine YouTube video id")

    metadata = get_youtube_metadata(url)
    title = metadata["title"]
    stem = slugify(title)
    path = unique_path(RAW_TRANSCRIPTS, stem)

    transcript = ""
    transcript_error = ""
    try:
        transcript = get_youtube_transcript(video_id)
    except (NoTranscriptFound, TranscriptsDisabled) as exc:
        transcript_error = str(exc)
    except Exception as exc:  # noqa: BLE001
        transcript_error = str(exc)

    sections = [
        frontmatter_block(
            "youtube-transcript",
            metadata["webpage_url"],
            title,
            {
                "video_id": video_id,
                "channel": metadata["channel"],
                "upload_date": metadata["upload_date"],
                "duration": metadata["duration_string"],
                "transcript_status": "available" if transcript else "unavailable",
            },
        ),
        f"# {title}",
        "## Video Metadata",
        f"- URL: {metadata['webpage_url']}",
        f"- Channel: {metadata['channel'] or 'unknown'}",
        f"- Upload date: {metadata['upload_date'] or 'unknown'}",
        f"- Duration: {metadata['duration_string'] or 'unknown'}",
    ]

    if transcript:
        sections.extend(["## Transcript", transcript])
    else:
        sections.extend(
            [
                "## Transcript",
                "Transcript unavailable.",
                "",
                f"Reason: {transcript_error or 'unknown'}",
            ]
        )

    write_markdown(path, "\n\n".join(sections))
    return DownloadResult(url=url, path=path, kind="youtube-transcript")


def download_one(url: str) -> DownloadResult:
    if is_youtube_url(url):
        return download_youtube(url)
    return download_article(url)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download URLs into raw/ as markdown for later ingestion."
    )
    parser.add_argument("urls", nargs="+", help="One or more URLs to download")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    results: list[DownloadResult] = []

    for url in args.urls:
        try:
            result = download_one(url)
            results.append(result)
            print(f"saved {result.kind}: {result.path.relative_to(ROOT)}")
        except Exception as exc:  # noqa: BLE001
            print(f"failed {url}: {exc}", file=sys.stderr)
            return 1

    print(f"downloaded {len(results)} source(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
