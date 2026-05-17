---
name: weekly-review
description: Run [OWNER]'s Sunday weekly review — scan the past 7 days of daily notes, check goal progress, audit knowledge captured vs processed, flag stale inbox, surface recurring themes, and write next week's focus. Use when [OWNER] says "weekly review", "review semanal", or "revisión de la semana". Saves report to 06-goals/weekly/.
---

# Weekly Review

The 30-minute Sunday ritual that closes the loop on the week. This is where the second brain becomes a planning instrument: not just storage, but a feedback signal on whether Eduardo is moving in the direction he committed to.

## Workflow

1. **Compute date range.** Today = Sunday (or whichever day Eduardo runs it). Pull the last 7 dates.
2. **Read all daily notes** in that window: Glob `01-daily/YYYY-MM-DD.md` for each date. Read every one that exists.
3. **Read session logs** in `01-daily/logs/` from the same window (Glob + filter by mtime).
4. **Read current goals**: `06-goals/2026-annual.md` and the most recent file in `06-goals/weekly/` (last week's review, for continuity).
5. **Audit the inbox**: Glob `00-inbox/**/*.md`, separate items < 7 days from items ≥ 7 days. Old items are a yellow flag.
6. **Audit knowledge flow**: count files created this week in `00-inbox/` (captured) vs files in `03-knowledge/permanent-notes/` and `03-knowledge/literature-notes/` modified this week (processed). A capture-heavy ratio means processing is falling behind.
7. **Detect recurring themes**: scan the week's notes and session logs for repeated topics, tags, frustrations, or wins. 3+ mentions = a theme worth naming.
8. **Synthesize the review** in the format below.
9. **Write to** `06-goals/weekly/YYYY-MM-DD-weekly-review.md` (today's date).
10. **Echo a compact summary** to Eduardo (top wins, top gaps, next-week focus). Don't dump the whole file inline.

## Report format

```markdown
---
type: goal
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#weekly-review]
status: complete
related: []
---

# Weekly Review — YYYY-MM-DD (week of YYYY-MM-DD to YYYY-MM-DD)

## 🏆 Wins
- {{shipped, learned, completed}}

## 🚧 Gaps & misses
- {{didn't happen, fell behind, dropped}}

## 🎯 Goal check-in
- **{{goal from 2026-annual.md}}** — {{progress this week}}
- ...

## 🧠 Knowledge flow
- Captured: N notes into inbox
- Processed: N notes promoted to knowledge/
- Ratio: {{healthy | capture-heavy | processing-light}}

## 📥 Inbox health
- N total · N stale (>7 days) ⚠️
- {{action — process this week, or accept and delete}}

## 🔁 Recurring themes
- **{{theme}}** — appeared in: [[note1]], [[note2]], [[note3]]
- {{1-line interpretation: opportunity, friction point, or signal}}

## 🎯 Next week's focus
1. {{single most important thing}}
2. {{second}}
3. {{third}}

## 🪞 Reflection
{{2-4 sentences — what did this week teach Eduardo about himself, his work, or his system}}
```

## Rules

- Write the review in Spanish if the week's notes are mostly Spanish; otherwise English.
- Recurring themes must cite at least 2 wikilinks each. No vague themes.
- "Next week's focus" is **3 items max**. If Eduardo over-committed last week, point that out in Reflection.
- Do NOT modify daily notes, project overviews, or goal files. The review is read-only on its inputs.
- If goals in `2026-annual.md` are still empty (fresh setup), say so in the goal check-in section instead of fabricating progress.

## Example invocation

```
[OWNER]: weekly review
→ Read all 01-daily/2026-03-30.md through 2026-04-05.md, logs from same window
→ Read 06-goals/2026-annual.md, last weekly review
→ Glob 00-inbox/, count knowledge/ modifications
→ Synthesize → write 06-goals/weekly/2026-04-06-weekly-review.md
→ Echo wins/gaps/focus to Eduardo
```
