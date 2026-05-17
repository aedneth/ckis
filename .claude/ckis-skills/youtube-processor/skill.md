---
name: youtube-processor
description: Extract a YouTube transcript via the youtube-transcript CLI, distill it into a literature note (key concepts, frameworks, actionable insights), file it under 04-resources/youtube/, and promote novel insights to permanent notes. Use when [OWNER] says "process YouTube [url]", "process this video [url]", or "procesa este video [url]".
---

# YouTube Processor

YouTube videos are high-density knowledge but low-density information per minute watched. The processor's job is to compress an hour of video into a 5-minute readable note that [OWNER] can revisit and link to.

## Workflow

1. **Validate the URL** is a YouTube link (`youtube.com/watch`, `youtu.be/`, `youtube.com/shorts/`).
2. **Extract the transcript**:
   - Try: `npx youtube-transcript <url>`
   - If it fails (no captions, age-gated, region-blocked): tell Eduardo and ask him to paste the transcript manually.
3. **Fetch metadata** if possible: title, channel, duration, publish date. If the CLI doesn't return them, scrape via `defuddle parse <url> --md` or ask Eduardo.
4. **Process the transcript** — read it end to end and extract:
   - **3-7 key concepts** (named ideas, models, frameworks)
   - **Frameworks / step-by-step processes** if the video teaches one
   - **5-10 actionable insights** (things Eduardo could *do* this week)
   - **Notable quotes** (timestamps if available)
   - **Actionability score 1-5** (same scale as `url-processor`)
5. **Generate a clean filename**: `<descriptive-kebab-slug>.md` (no video IDs, no dates).
6. **Write the literature note** to `04-resources/youtube/` using the template below.
7. **Promote novel insights** to permanent notes in `03-knowledge/permanent-notes/`. Same criterion as `url-processor`: atomic, not duplicated in vault (Grep first), usable without re-watching.
8. **Update relevant MOCs** with `[[wikilinks]]`.
9. **Echo a 3-line summary** to [OWNER]: title, channel, score, where filed, # permanent notes promoted.

## Literature note template

```markdown
---
type: literature-note
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: "{{full YouTube URL}}"
channel: "{{channel name}}"
duration: "{{HH:MM:SS or empty}}"
published: "{{YYYY-MM-DD or empty}}"
status: active
actionability: {{1-5}}
related: []
---

# {{Video Title}}

> **Channel:** {{channel}} · **Duration:** {{duration}} · **Published:** {{date}}
> **Actionability:** {{score}}/5 — {{one-line justification}}

## TL;DR
{{2-3 sentences. Eduardo should know if it's worth re-watching after reading just this.}}

## Key concepts
1. **{{concept}}** — {{1-2 lines}}
2. ...

## Frameworks / processes
{{only if the video teaches a structured process — otherwise omit this section}}

1. Step one — ...
2. Step two — ...

## Actionable insights
- [ ] {{thing Eduardo could do this week}}
- [ ] ...

## Quotes
> "{{quote}}" — {{HH:MM if known}}

## How this connects
- Relates to: [[existing note]] — because {{...}}
- Builds on: [[other note]]
```

## Rules

- Bilingual: English videos → English notes; Spanish videos → Spanish notes. Don't translate.
- Skip the TL;DR only if the video is < 5 minutes — otherwise it's required.
- If the transcript is auto-generated and full of errors, note it: `> ⚠️ Transcript auto-generated, some terms may be misspelled.`
- Never paste the full transcript into the note. The literature note is a *replacement* for the transcript, not an addition to it.
- If actionability is 1, file the note but skip permanent-note promotion.
- If `npx youtube-transcript` isn't installed, run `npm install -g youtube-transcript` only with [OWNER]'s confirmation.

## Example invocation

```
[OWNER]: process YouTube https://www.youtube.com/watch?v=abc123
→ npx youtube-transcript https://www.youtube.com/watch?v=abc123
→ Extract concepts, frameworks, insights, score
→ Write 04-resources/youtube/how-to-price-saas-products.md
→ Grep "willingness to pay" → not found → create
   03-knowledge/permanent-notes/wtp-research-precedes-pricing.md
→ Update [[MOC-Business-Strategy]]
→ Echo: "Filed 'How to Price SaaS Products' (5/5). 2 permanent notes promoted."
```
