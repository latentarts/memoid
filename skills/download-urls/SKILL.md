---
name: download-urls
description: Download URL content into the memory/raw/ folder so it can be ingested later. Use for web articles, documentation pages, and YouTube URLs. For YouTube URLs, fetch video metadata and save the transcript into memory/raw/transcripts/ when available.
---

# Download URLs

Use this skill to turn remote URLs into local markdown files under `memory/raw/`.

## When To Use

Use when the user wants to:

- download one or more web pages for later ingestion
- archive article or documentation content into `memory/raw/articles/`
- fetch YouTube transcripts into `memory/raw/transcripts/`

## Output Locations

- general web pages -> `memory/raw/articles/`
- YouTube transcripts -> `memory/raw/transcripts/`

## Command

Run the bundled script through the local `uv` project environment:

```bash
uv run python skills/download-urls/scripts/download_urls.py <url> [<url> ...]
```

## Behavior

- saves downloaded content as markdown
- includes source URL and retrieval metadata in the saved file
- uses article extraction for normal web pages
- uses YouTube metadata plus transcript download for YouTube URLs
- if a YouTube transcript is unavailable, still saves a markdown record with metadata and the failure note

## Rules

- downloaded material belongs under `memory/raw/` only
- do not ingest automatically unless explicitly asked
- after downloading, the next natural step is `ingest new articles` or `ingest new transcripts`

## Example Phrases

```text
download these urls into raw
```

```text
download new articles from these links
```

```text
download youtube transcripts for these videos
```

