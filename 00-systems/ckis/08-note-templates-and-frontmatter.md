---
type: system
created: 2026-05-02
modified: 2026-06-06
tags: [ckis, templates, frontmatter]
status: active
related: ["[[02-obsidian-vault-architecture]]", "[[04-claude-code-obsidian-agent]]"]
---

# 08 — Note Templates & Frontmatter

> Reference for every note template and the standard frontmatter spec. Copy from here when scaffolding new notes; if a real file under `08-templates/` exists, prefer that.

━━━

## 1. Frontmatter Standard

```yaml
---
type: [permanent-note | literature-note | project | archive-note | daily | resource | capture | area | goal | person | system | sop]
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: ""
status: [inbox | processing | active | complete | archived]
related: []
---
```

Field rules:

- `type` — required; one of the enum. `sop` for Standard Operating Procedures (see §14).
- `created` — required; never overwrite.
- `modified` — required; should equal the latest git commit date (`git log` is authoritative, not filesystem `mtime`).
- `tags` — kebab-case strings without leading `#`.
- `source` — URL or citation string for sourced material; empty for original notes.
- `status` — required; aligns with the note's lifecycle.
- `related` — array of wikilink strings: `["[[Note Name]]"]`.

## 2. Daily Note Template

```markdown
---
type: daily
created: {{date:YYYY-MM-DD}}
modified: {{date:YYYY-MM-DD}}
tags: [daily]
status: active
related: []
---

# {{date:YYYY-MM-DD}}

## Top 3 priorities
- [ ]
- [ ]
- [ ]

## Notes


## Tasks
- [ ]

## Captures
(items routed to inbox during the day will be linked here by process-inbox if relevant)

## Session log
(linked from `01-daily/logs/{{date}}.md` when applicable)
```

## 3. Project Overview Template (`_overview.md`)

```markdown
---
type: project
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [project, <project-name>]
status: active
related: []
---

# <Project Name>

## Status
<one-line status>

## Strategy / Purpose
<what this project is for; lock once, revise rarely>

## Recent progress
- YYYY-MM-DD — …

## Open decisions
- …

## Blockers
- …

## Key files
- [[02-projects/<project>/<file>]]
```

`Recent progress` is **append-only** — never rewrite history. `sync overviews` adds new bullets at the top of this section.

## 4. Permanent Note Template

```markdown
---
type: permanent-note
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: ""
status: active
related: []
---

# <One-sentence claim or concept>

<Body — develop the single idea. Aim for self-contained, atomic. End with links to related permanent notes and at least one MOC if a relevant one exists.>

## Related
- [[…]]
```

One concept per file. If two distinct ideas appear, split the file.

## 5. Literature Note Template

```markdown
---
type: literature-note
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: "<URL or citation>"
status: processing
related: []
---

# <Title of source>

- Author / channel:
- Date:
- Format: article | video | podcast | book | thread

## Summary (≤5 bullets)
- …

## Key insights
- …

## Quotes / passages worth keeping
> …

## Promote to permanent notes
- [ ] <candidate idea> → permanent note
```

When a "Promote to permanent notes" item is acted on, create the permanent note and link it back.

## 6. Capture Template (`00-inbox/quick-capture/`)

```markdown
---
type: capture
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [inbox]
status: inbox
related: []
---

# <Working title>

<Raw content. Do not classify or link at capture time.>
```

## 7. Area Template (`05-areas/<area>.md`)

```markdown
---
type: area
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [area, <area-tag>]
status: active
related: []
---

# <Area Name>

## North star
<One paragraph describing what "good" looks like in this area.>

## Current focus
<Top 1–3 things you're investing in right now.>

## Log
- YYYY-MM-DD — …
```

## 8. Goal Template (Annual / Quarterly)

```markdown
---
type: goal
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [goal, 2026, q2]
status: active
related: []
---

# 2026 — Annual

## Vision
<One paragraph.>

## Q1 / Q2 / Q3 / Q4 targets
- Q2:
  - …

## Areas-of-life alignment
- [YOUR_PROJECT] / Programación: …
- Aprendizaje ([YOUR_UNIVERSITY]): …
- Bienestar: …
```

## 9. Weekly Review Template (`06-goals/weekly/YYYY-MM-DD-weekly-review.md`)

```markdown
---
type: goal
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [weekly-review]
status: active
related: []
---

# Weekly Review — YYYY-MM-DD

## What shipped
- …

## What slipped
- …

## Patterns noticed
- …

## Inbox state
- Items processed:
- Items still pending:
- Stale items flagged for deletion:

## Goal check
- [[06-goals/2026-annual]] alignment: …

## Next week — top 3 priorities
1.
2.
3.
```

## 10. Person Template (`07-people/<sub>/`)

```markdown
---
type: person
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [person]
status: active
related: []
---

# <First Last>

- Role:
- Org:
- First contact:
- Last contact:
- Channels:

## Context
<What this relationship is for.>

## History
- YYYY-MM-DD — …
```

For prospective [YOUR_PROJECT] clients, prefer `08-templates/client-note.md` (richer onboarding template).

## 11. Decision-Log Block (drop into any note)

```markdown
## Decision: <one-line title>
- Date: YYYY-MM-DD
- Project / area:
- Status: proposed | adopted | superseded | reverted
- Decision:
- Why:
- Alternatives considered:
- Trade-offs accepted:
- Reversal cost: low | medium | high
- Review-by:
- Linked notes: [[…]]
```

## 12. Session Log Template (`01-daily/logs/<date>.md`)

```markdown
---
type: daily
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [session-log]
status: active
related: []
---

# Session — YYYY-MM-DD

## Context loaded
- _MEMORY.md, …

## What was done


## Decisions
- …

## Files touched
- …

## Blockers / open questions
- …

## Next step
- …
```

## 13. CKIS System File Template

```markdown
---
type: system
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [ckis, <topic>]
status: active
related: []
---

# NN — <Topic>

> One-sentence purpose statement.

━━━

## 1. <Section>
…
```

Used for files in `00-system/ckis/`. Keeps tone and structure consistent across the system folder.

## 14. SOP Template

For Standard Operating Procedures in `00-systems/sops/` or `<project>/processes/`. Canonical convention: [[00-systems/sops/_convention]].

```yaml
---
type: sop
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [sop, <domain>, ...]
status: active            # active | draft | deprecated
sop_domain: <domain>      # ckis | dev | os-hardware | [your-project] | content ...
trigger: ""               # invocation phrase if agent-invokable, else empty
related: []
---
```

```markdown
# SOP — <Process Name>
> One-line purpose · who runs this · when.

## 1. Purpose & Scope
## 2. When to Execute
## 3. Prerequisites
## 4. Steps
## 5. Verification / Expected Output
## 6. Troubleshooting        (optional — symptom | cause | fix table)
## 7. Notes & Exceptions / Lessons Learned   (optional)
## 8. Agent-Delegatable Summary   (optional — paste block to hand an agent)

*SOP v<x> — <author> — <date>*
```
