---
type: system
subtype: convention
folder: 04-resources
created: 2026-05-29
modified: 2026-06-06
status: active
tags: [convention, systems, ckis]
---

# 04-resources — Raw Reference Material

**Purpose:** Source material in its processed-but-not-synthesized form. One step above raw capture, one step below permanent knowledge.

## Subfolders

| Folder | What goes here | Processing skill |
|---|---|---|
| `articles/` | Web articles, blog posts, newsletters | `process URL` |
| `books/` | Book notes, highlights, summaries | manual or `process inbox` |
| `courses/` | Course notes, lesson summaries | manual |
| `youtube/` | Processed video transcripts + key points | `process YouTube` |
| `social-captures/` | Posts from LinkedIn, X, Instagram, TikTok | `process social` |
| `tools/` | Tool documentation, comparisons, setup notes | manual |

## What doesn't go here

- Raw URLs or unprocessed screenshots → `00-inbox/`
- Synthesized insights extracted from these sources → `03-knowledge/permanent-notes/`
- Active project reference docs → `02-projects/<project>/`

## The flow

```
Source → 00-inbox/ → processing skill → 04-resources/<subfolder>/ → extract insights → 03-knowledge/permanent-notes/
```

Notes in `04-resources/` have frontmatter with `status: processed` but aren't yet synthesized into permanent knowledge.

## Frontmatter standard

```yaml
---
type: resource
subtype: [article | book | youtube | social-capture | tool | course]
created: YYYY-MM-DD
source: "[URL or citation]"
author: ""
tags: []
status: processed
related: []
---
```
