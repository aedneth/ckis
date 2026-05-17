---
name: url-processor
description: Fetch a web URL via Jina Reader, extract a clean literature note (title, key insights, quotes, actionability score), file it under 04-resources/articles/, and promote any novel insights into permanent notes. Use when [OWNER] says "process URL [url]", "process this article [url]", "procesa este artículo [url]", or pastes a non-YouTube link to read.
---

# URL Processor

Turn a raw web URL into a structured literature note in seconds, and promote anything genuinely new into a permanent note. Optimize for *retrievable* notes — Eduardo should be able to find the insight 6 months from now without re-reading the article.

## Workflow

1. **Validate the URL.** If it's a YouTube link, hand off to `youtube-processor` instead.
2. **Fetch clean markdown.** Try in this order:
   - `defuddle parse <url> --md` (preferred — local CLI, faster, less clutter)
   - Fallback: `curl -sL "https://r.jina.ai/<url>"` (Jina Reader, free)
   - Last resort: WebFetch
3. **Extract the essentials**:
   - **Title** (prefer the article's actual title, not the page `<title>`)
   - **Author** if available
   - **Publication / domain**
   - **Publication date** if available
   - **3-7 key insights** (full sentences, not bullet fragments)
   - **2-5 quotes worth keeping verbatim** (only if quotable — skip if nothing stands out)
   - **Actionability score 1-5**: 1 = pure entertainment, 3 = useful reference, 5 = changes how Eduardo will work this week
4. **Generate a clean filename**: `<descriptive-kebab-slug>.md`. Avoid dates in the filename — `created` lives in frontmatter.
5. **Write the literature note** to `04-resources/articles/` using the template below.
6. **Decide on permanent note promotion**: if the article delivers at least one *genuinely new* insight (not already in [OWNER]'s vault — quick Grep check), create a permanent note in `03-knowledge/permanent-notes/` that captures the atomic idea in [OWNER]'s voice (not a quote dump).
7. **Update relevant MOCs** in `03-knowledge/maps-of-content/` — add `[[wikilink]]` to the new note under the right section. Don't create new MOCs from a single article; that's `monthly-consolidation`'s job.
8. **Echo a 3-line summary** to [OWNER]: title, actionability score, where it was filed, whether a permanent note was created.

## Literature note template

```markdown
---
type: literature-note
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: "{{full URL}}"
author: "{{author or empty}}"
publication: "{{site / publication}}"
published: "{{YYYY-MM-DD or empty}}"
status: active
actionability: {{1-5}}
related: []
---

# {{Article Title}}

> **Source:** {{domain}} · **Author:** {{author}} · **Published:** {{date}}
> **Actionability:** {{score}}/5 — {{one-line justification}}

## Key insights
1. {{insight stated as a complete idea}}
2. ...

## Quotes worth keeping
> "{{quote}}" — only if genuinely quotable

## How this connects
- Relates to: [[existing note]] — because {{...}}
- Contradicts / extends: [[other note]] — because {{...}}

## Action implications
- {{what Eduardo should actually DO with this, if anything}}
```

## Permanent note promotion criteria

Promote to a permanent note ONLY if:
- The insight is atomic (one idea, not five)
- Grep doesn't find an existing permanent note saying the same thing
- Eduardo could use this insight in a decision *without* re-reading the source

## Rules

- Bilingual: write notes in the article's original language. Don't translate Spanish articles to English or vice versa.
- Never paste the entire article body into the note. The point is distillation.
- If `defuddle`, `r.jina.ai`, and WebFetch all fail (paywall, JS-only site), tell Eduardo and ask if he wants to paste the content manually.
- If actionability is 1, still file the note but skip permanent-note promotion.
- Keep quotes short — if you need more than ~3 lines from the article, you're summarizing, not quoting.

## Example invocation

```
[OWNER]: process URL https://www.example.com/the-tao-of-pricing
→ defuddle parse https://www.example.com/the-tao-of-pricing --md
→ Extract title, insights, quotes, score
→ Write 04-resources/articles/tao-of-pricing.md
→ Grep for "value-based pricing" in vault → no existing note → create
   03-knowledge/permanent-notes/value-based-pricing-anchors-perception.md
→ Update [[MOC-Business-Strategy]] with new wikilinks
→ Echo: "Filed 'Tao of Pricing' (4/5). Promoted 1 insight to permanent note."
```
