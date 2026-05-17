---
name: monthly-consolidation
description: Run the monthly knowledge consolidation — analyze permanent notes from the past month, detect recurring patterns, update or create MOCs, write pattern notes, identify knowledge gaps, and produce a monthly intelligence report. Use when [OWNER] says "knowledge consolidation", "monthly consolidation", "consolidación mensual", or "reporte mensual". Saves report to 06-goals/monthly/.
---

# Monthly Consolidation

Where the second brain stops being a notebook and becomes an intelligence engine. Once a month, look across all the atomic notes captured this month, find the patterns Eduardo couldn't see day-to-day, and promote those patterns into reusable knowledge structures (MOCs and pattern notes).

> The goal isn't a pretty report — it's *new knowledge that didn't exist before this run*. If the consolidation doesn't surface at least one non-obvious pattern, dig deeper.

## Workflow

1. **Compute month range.** Default = previous calendar month if today is in the first 7 days, otherwise the current month-to-date. Confirm with Eduardo if ambiguous.
2. **Gather permanent notes from this month**: Glob `03-knowledge/permanent-notes/**/*.md`, filter by frontmatter `created` within the month range. Read each.
3. **Gather literature notes from this month**: same approach for `03-knowledge/literature-notes/**/*.md` and `04-resources/**/*.md`.
4. **Read existing MOCs** in `03-knowledge/maps-of-content/` so you know what's already mapped.
5. **Pattern detection** — identify:
   - Topics that show up in 3+ permanent notes from this month
   - Tag clusters that didn't exist last month
   - Contradictions or evolutions in [OWNER]'s thinking on a topic
   - Cross-domain links (e.g., a [YOUR_PROJECT] insight that also applies to University)
6. **For each detected pattern (≥ 3 supporting notes)**:
   - If a relevant MOC exists in `03-knowledge/maps-of-content/`, **update it** — add the new wikilinks under the right section, bump `modified` in frontmatter.
   - If no MOC exists, **create** `MOC-{{Topic}}.md` using the MOC template (see below).
   - If the pattern is itself an insight (not just a topic), create a pattern note in `03-knowledge/patterns/{{pattern-name}}.md`.
7. **Identify knowledge gaps** — topics Eduardo *captured raw* this month (in inbox or resources) but never processed into permanent notes. These are debt.
8. **Write the monthly report** to `06-goals/monthly/YYYY-MM-monthly-report.md` (use the month being consolidated, not today).
9. **Echo a compact summary** to [OWNER]: # patterns found, # MOCs updated/created, # gaps flagged.

## MOC template

```markdown
---
type: permanent-note
subtype: moc
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#moc]
status: active
related: []
---

# MOC: {{Topic}}

{{1-2 sentences on what this MOC organizes and why the topic matters to Eduardo}}

## Core notes
- [[note]] — one-line description
- [[note]] — ...

## Sub-themes
### {{sub-theme 1}}
- [[note]]

## Open questions
- {{things Eduardo hasn't answered yet}}
```

## Pattern note template

```markdown
---
type: permanent-note
subtype: pattern
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#pattern]
status: active
related: []
---

# Pattern: {{Name}}

**Observed in:** [[note1]], [[note2]], [[note3]]

## The pattern
{{1-2 paragraph description}}

## Why it matters
{{what this enables Eduardo to do or decide differently}}

## Counter-examples
{{when does this NOT apply}}
```

## Monthly report format

```markdown
---
type: goal
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#monthly-report]
status: complete
related: []
---

# Monthly Intelligence Report — YYYY-MM

## 📊 By the numbers
- Permanent notes created: N
- Literature notes created: N
- MOCs updated: N · created: N
- Pattern notes created: N

## 🔁 Patterns detected
### {{pattern name}}
{{description}} · supported by [[note1]] [[note2]] [[note3]] → see [[Pattern: name]]

## 🗺️ MOC changes
- **[[MOC-Topic]]** — added N notes, new sub-theme: {{x}}
- **[[MOC-NewTopic]]** — created this month

## 🕳️ Knowledge gaps
- {{topic captured but unprocessed}} — N raw notes in inbox/resources, no permanent note yet
- {{...}}

## 🧭 Direction signal
{{2-4 sentences on what these patterns reveal about where [OWNER]'s thinking is heading and what to lean into next month}}
```

## Rules

- A "pattern" needs **3+ supporting notes**. Less than that is an observation, not a pattern — leave it for next month.
- Never delete or rewrite existing permanent notes. You may *link* to them, *update MOC indexes*, and *create new* notes.
- Bilingual: write the report in the language most of the source notes used.
- Keep the report under 600 words. The intelligence should be in the new MOCs and pattern notes, not in the report itself.

## Example invocation

```
[OWNER]: knowledge consolidation
→ Glob 03-knowledge/permanent-notes/, filter by created in 2026-04
→ Read all, detect patterns with ≥3 supporting notes
→ Update existing MOCs, create new ones, write pattern notes
→ Write 06-goals/monthly/2026-04-monthly-report.md
→ Echo: "Found 3 patterns, updated 2 MOCs, created 1 new MOC, flagged 4 gaps"
```
