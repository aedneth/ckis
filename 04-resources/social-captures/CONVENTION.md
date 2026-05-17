# social-captures — Social Media Content

**Purpose:** Store captured social content for later synthesis. Strip engagement bait; keep signal.

## Subfolders by platform

```
social-captures/
├── linkedin/
├── x-twitter/
├── instagram/
├── tiktok/
└── youtube-shorts/
```

## Filename convention

`YYYY-MM-DD_author-handle_topic-slug.md`

Example: `2026-05-17_naval_specific-knowledge.md`

## Frontmatter (required)

```yaml
---
type: resource
subtype: social-capture
platform: [linkedin | x-twitter | instagram | tiktok | youtube-shorts]
author: "@handle"
source: "https://..."
captured: YYYY-MM-DD
tags: []
status: raw
related: []
---
```

## Per-platform body format

### LinkedIn
```markdown
**Post text** (verbatim or paraphrased):
> [post content]

**Author:** [Name], [Title at Company]
**Engagement:** ~[N] reactions · [N] comments
**Your takeaway:** [why you saved this]
```

### X / Twitter
```markdown
**Thread** (reconstructed top-to-bottom):
> [tweet 1]
> → [tweet 2]
>   → [quote-tweet if any]

**Your takeaway:** [why you saved this]
```

### Instagram
```markdown
**Caption:** [text from post]
**Visual:** [describe what the image/carousel shows — images don't live here]
**Slides (if carousel):** [slide 1 topic] · [slide 2 topic] · ...
**Your takeaway:** [why you saved this]
```

### TikTok
```markdown
**Transcript / key points:**
- Hook: [first 3 seconds]
- Payoff: [main insight]
- CTA: [what they asked viewers to do]

**Sound/trend:** [if relevant]
**Your takeaway:** [why you saved this]
```

### YouTube Shorts
```markdown
**Channel:** [channel name]
**Duration:** [MM:SS]
**Transcript / key points:**
- [point 1]
- [point 2]

**Your takeaway:** [why you saved this]
```

## Processing rule

`status: raw` → triggers `process social` skill → promoted to literature note in `03-knowledge/literature-notes/` with backlink to this capture.

## Anti-patterns

- Never dump raw URLs here — those go to `00-inbox/url-dumps/`
- Never save entertainment content — only save if it has durable knowledge value
- Never save duplicate insights you already have in `03-knowledge/`
