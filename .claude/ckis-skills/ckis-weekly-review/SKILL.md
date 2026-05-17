---
name: ckis-weekly-review
description: CKIS-aware weekly review. Wraps the operational weekly-review skill with CKIS-specific health checks and proposed _MEMORY.md edits. Use when Eduardo says "ckis weekly review" or runs the Sunday cadence. Never writes to _MEMORY.md automatically; surfaces edits for confirmation.
---

# CKIS Weekly Review

Sunday cadence. Wraps the existing `weekly-review` skill (`.claude/skills/weekly-review/skill.md`) and adds a CKIS-specific layer: lightweight health checks and proposed `_MEMORY.md` edits.

## Workflow

1. **Run the operational `weekly-review` skill.** Either invoke it (if the harness supports nested skills) or replicate its core logic:
   - Scan daily notes for the past 7 days (`01-daily/2026-MM-DD.md`).
   - Check `06-goals/2026-annual.md` and current quarter targets.
   - Detect patterns: recurring themes, repeated blockers, unmet commitments.
   - Flag unprocessed inbox items (>7 days old).
   - Generate a "what shipped / slipped / patterns" summary.

2. **Append CKIS health items.** Lightweight subset of CKIS file 13 §8:
   - Inbox items older than 7 days — count.
   - Active projects silent ≥14 days — list.
   - Open decisions in `_MEMORY.md` older than 14 days — list.
   - Blockers unchanged across 2+ weekly reviews — list (compare to last weekly review file).
   - CKIS file index integrity — does `00-system/ckis/00-ckis-master-context.md` §10 still match what's in the folder?

3. **Propose `_MEMORY.md` edits.** Read the current `_MEMORY.md`, then:
   - For each section (Business state, Active focus, Open Decisions, Blockers, Financial state, University, System state) — produce a *proposed* edit only if the past week's activity warrants one.
   - Render each proposed edit as a unified-diff-style block (don't write it).
   - Keep proposals concise; if no change needed, say so.

4. **Save the review** to `06-goals/weekly/YYYY-MM-DD-weekly-review.md` using the template from CKIS file 08 §9.

5. **Surface to Eduardo.** Output:
   - The path to the saved review.
   - The CKIS health items.
   - The proposed `_MEMORY.md` edits.
   - Top 3 priorities for next week.
   - Single explicit ask: "Apply these `_MEMORY.md` edits? (y/n)"

6. **Apply `_MEMORY.md` edits only if Eduardo says yes.** Never silent-apply.

## Rules

- **Never** write to `_MEMORY.md` without explicit confirmation.
- **Never** modify a previous weekly review file.
- **Always** save to `06-goals/weekly/YYYY-MM-DD-weekly-review.md`.
- **Always** preserve the daily-note files; this skill is read-only on `01-daily/`.
- Limit the review file to ~150 lines. If patterns sprawl, link out to a permanent note in `03-knowledge/patterns/` instead of inlining everything.

## Output Shape

```markdown
# Weekly Review — YYYY-MM-DD

## What shipped
- …

## What slipped
- …

## Patterns noticed
- …

## Inbox state
- Processed: N
- Pending: N
- Stale flagged: N

## Goal check
- [[06-goals/2026-annual]] alignment: …

## CKIS health
- Inbox >7d: N items
- Silent active projects: <list>
- Stale open decisions (>14d): <list>
- Persistent blockers: <list>
- CKIS index integrity: ok | drift detected

## Proposed _MEMORY.md edits
- (diff-style block per section needing changes; "no change" otherwise)

## Next week — top 3 priorities
1.
2.
3.
```

## QA Checklist

- [ ] Review saved to correct path.
- [ ] No `_MEMORY.md` writes without confirmation.
- [ ] Top 3 priorities are concrete (not "work on Korvex").
- [ ] CKIS health checked.
- [ ] Stale items surfaced, not auto-deleted.

## Do Not

- Auto-delete stale inbox items.
- Edit `_PROFILE.md` or `_INTERESTS.md`.
- Run a knowledge-synthesis pass — that's `monthly-consolidation`'s job.
- Touch CKIS architecture files.
