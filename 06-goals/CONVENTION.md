---
type: system
subtype: convention
folder: 06-goals
created: 2026-05-29
modified: 2026-06-06
status: active
tags: [convention, systems, ckis]
---

# 06-goals — Unified Goal System

**Purpose:** One place for all goal tracking. Annual vision → quarterly targets → weekly focus. No duplication.

## What goes here

- `annual/` — one file per year: `YYYY-annual.md` with annual vision + quarterly targets
- `quarterly/` — `YYYY-QN-quarterly.md` with 90-day targets per area
- `monthly/` — monthly review outputs: `YYYY-MM-monthly-review.md`
- `weekly/` — weekly review outputs: `YYYY-MM-DD-weekly-review.md`

## What doesn't go here

- Daily tasks → daily notes (`01-daily/`)
- Project milestones → `02-projects/<project>/_overview.md`
- Area-level habits → `05-areas/`

## The one-system rule

Don't track goals in multiple places. If it's a goal (outcome-oriented, time-bound), it goes here. If it's a task (action, can be completed today), it goes in a daily note or project file.

## Annual note structure

```markdown
---
type: goal
subtype: annual
year: YYYY
---

# YYYY — Annual Vision

## The one big thing
[What would make this year a success?]

## Q1 targets
- [Area]: [specific outcome]

## Q2 targets
...

## Q3 targets
...

## Q4 targets
...
```

## Weekly review output (from `weekly review` skill)

Saved automatically to `06-goals/weekly/YYYY-MM-DD-weekly-review.md`. Do not edit manually — run the skill.

## Naming

- Annual: `2026-annual.md`
- Quarterly: `2026-Q2-quarterly.md`
- Monthly: `2026-05-monthly-review.md`
- Weekly: `2026-05-17-weekly-review.md`
