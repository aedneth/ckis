---
type: system
subtype: convention
folder: 00-inbox
created: 2026-05-29
modified: 2026-06-06
status: active
tags: [convention, systems, ckis]
---

# 00-inbox — Capture Zone

**Purpose:** Everything enters the vault here first. Never organize in the moment — capture now, process later.

## What goes here

- Raw thoughts, ideas, voice-to-text dumps → `quick-capture/`
- URLs to read/process later → `url-dumps/`
- YouTube videos to extract knowledge from → `youtube-queue/`
- Social media posts, threads, screenshots → `social-media-queue/`
- Files needing conversion to markdown → `convert-queue/`
- System files (prefixed with `_`): `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`

## What doesn't go here

- Processed notes — those belong in `03-knowledge/`, `04-resources/`, or `02-projects/`
- Daily notes — those go in `01-daily/`
- Anything with final frontmatter and links — it's already processed

## The 7-Day Rule

Any item in inbox older than 7 days is a liability. Either process it or delete it. The `process inbox` skill flags stale items automatically.

## Naming

- Captures: `YYYY-MM-DD-HHMM-topic-slug.md`
- URLs: `YYYY-MM-DD-domain-slug.md` or just paste raw URL into a `.txt`
- No spaces, no emojis, no Notion-style hashes

## Frontmatter (for quick-capture items)

```yaml
---
type: capture
created: YYYY-MM-DD
tags: []
status: inbox
---
```

## Processing flow

`00-inbox/` → `process inbox` skill → categorized + tagged + linked → moved to correct folder → committed to git
