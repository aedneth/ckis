---
name: social-media-processor
description: Read items dropped into 00-inbox/social-media-queue/, strip engagement bait, classify each as actionable knowledge or entertainment, and either promote (literature note → permanent note) or recommend discard. Apply the 90-day utility filter. Use when Eduardo says "process social", "procesa el social queue", or after dropping new files into 00-inbox/social-media-queue/.
---

# Social Media Processor

Social media is mostly noise with occasional signal. The processor's job is to ruthlessly separate the two so the vault doesn't fill up with screenshot dumps Eduardo will never use. Default action is *discard*; survival requires justification.

## Workflow

1. **List the queue.** Glob `00-inbox/social-media-queue/**/*` (markdown, images, screenshots, .txt). If empty, tell Eduardo and stop.
2. **For each item**, read the content (use Read on markdown/text; for images, describe what's visible).
3. **Strip the bait** — mentally delete:
   - Hooks ("Nobody talks about this but...", "I went from $0 to $10k...")
   - Threads numbering ("1/12", "Thread 🧵")
   - Self-promo CTAs ("DM me 'GROW' for...")
   - Emoji clutter and engagement-farming questions
4. **Classify** what remains:
   - **Actionable knowledge** — a concrete idea, framework, technique, tool, or insight Eduardo could use
   - **Entertainment / commentary** — opinion, take, joke, news commentary with no transferable lesson
5. **Apply the 90-day utility filter**: *"Will Eduardo realistically use this in the next 90 days?"* If no → recommend discard.
6. **For each surviving (actionable) item**:
   - Create a **literature note** in `04-resources/social-captures/` using the template below
   - If the insight is novel (Grep check), create a **permanent note** in `03-knowledge/permanent-notes/`
   - Update relevant MOCs
   - Move the original from `00-inbox/social-media-queue/` to `09-archive/social-originals/{{YYYY-MM}}/` (don't delete — Eduardo's source-of-truth audit trail)
7. **For discarded items**: list them in the report. Do NOT auto-delete — Eduardo confirms.
8. **Output the processing report** (format below).

## Literature note template

```markdown
---
type: literature-note
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: "{{platform: instagram | x | tiktok | linkedin | reddit}}"
source_url: "{{URL if known, else empty}}"
author: "{{handle / name}}"
status: active
actionability: {{1-5}}
related: []
---

# {{Concise title — what the insight IS, not what the post said}}

> **Platform:** {{platform}} · **Author:** @{{handle}}
> **Actionability:** {{score}}/5

## The insight (stripped)
{{1-2 paragraphs in plain language. NOT a transcript of the post. The idea, in Eduardo's voice.}}

## How Eduardo could use it
- {{specific application within 90 days}}

## Original
{{optional 2-3 line excerpt of the original post for context — only if useful}}
```

## Processing report format

```markdown
# Social Queue Processing — YYYY-MM-DD

**Items reviewed:** N
**Promoted to knowledge:** N
**Recommended discard:** N

## ✅ Promoted
- `original-name.png` → `04-resources/social-captures/insight-name.md` (4/5)
  → permanent note: `03-knowledge/permanent-notes/atomic-idea.md`
- ...

## 🗑️ Recommended discard (awaiting Eduardo's confirmation)
- `screenshot-1.png` — generic motivation post, no actionable content
- `tweet-2.md` — opinion take, no transferable framework
- ...

## 🤔 Borderline
- `carousel-3.md` — interesting angle on Korvex pricing but author has no credibility signal; promote anyway?
```

## Rules

- Default = discard. The bar for survival is "Eduardo would actually act on this within 90 days."
- Never auto-delete. Recommend discard, let Eduardo confirm.
- Strip the bait BEFORE writing the note. The note should read like Eduardo wrote it, not like a screenshot caption.
- Bilingual: Spanish posts → Spanish notes; English posts → English notes.
- Originals get archived to `09-archive/social-originals/{{YYYY-MM}}/`, not deleted.
- If an item is just a link to a longer article or video, don't process it here — move it to `00-inbox/url-dumps/` or `00-inbox/youtube-queue/` and tell Eduardo.

## Example invocation

```
Eduardo: process social
→ Glob 00-inbox/social-media-queue/**/*
→ For each: read, strip bait, classify, apply 90-day filter
→ Promote 3 items, recommend discard for 8, flag 1 borderline
→ Output report
```
