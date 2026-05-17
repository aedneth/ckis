---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, decisions, review]
status: active
related: ["[[00-ckis-master-context]]", "[[05-ckis-memory-and-context-rules]]", "[[16-skill-cards-for-second-brain-workflows]]"]
---

# 06 — Decision · Execution · Review Protocol

> Decisions are the highest-value durable artifact in CKIS. Without decision logs, the vault decays into a pile of notes. This file specifies how decisions are captured, reviewed, and revisited across cadences.

━━━

## 1. Decision Log Entry

A decision log entry is a permanent note (or a section of a project `_overview.md`) with this shape:

```markdown
## Decision: <one-line title>

- Date: YYYY-MM-DD
- Project / area: [your-project] | brisas | [archived-project] | university | personal | …
- Status: proposed | adopted | superseded | reverted
- Decision: <what was decided>
- Why: <rationale, max 3 bullets>
- Alternatives considered: <bulleted list>
- Trade-offs accepted: <bulleted list>
- Reversal cost: low | medium | high
- Review-by: YYYY-MM-DD (optional)
- Linked notes: [[…]]
```

Where it lives:

- Project-specific decisions → inside that project's `_overview.md` under a `## Decisions` section, **or** a dedicated note in the project folder for heavyweight decisions.
- Cross-cutting / personal decisions → `03-knowledge/permanent-notes/` with `tags: [decision, …]`.
- System-level decisions about CKIS itself → in `[[00-system/ckis/CHANGELOG]]` plus a CKIS file edit.

## 2. When to Log a Decision

Mandatory:

- Choosing or replacing a tool, framework, or service.
- Locking pricing, packaging, or service catalog for [YOUR_PROJECT].
- Pausing or reactivating a project.
- Architecture changes to CKIS or to a code repo.
- Anything you'd hate to re-debate in 3 months.

Optional but encouraged:

- Naming and branding choices.
- Bigger time-allocation choices ("Q3 focus is X, not Y").

## 3. Action Items

Action items are lower-weight than decisions. They live:

- In today's `01-daily/<date>.md` under `## Tasks`.
- Or in the project's `_overview.md` under `## Open Action Items`.
- Or in `06-goals/weekly/<date>-weekly-review.md` for the current week.

Format: `- [ ] verb-led task — owner — by date`. The owner is almost always Eduardo, but writing it forces clarity.

## 4. Project Reviews

Trigger: end of a project phase, or every 4 weeks for active projects.

Procedure:

1. Read the full project `_overview.md` and the most recent 2 weeks of daily notes mentioning the project.
2. Re-evaluate Status, Blockers, Open Decisions.
3. Add a `## Phase Review — YYYY-MM-DD` section with: what shipped, what slipped, what changed, what's next.
4. Promote any new permanent insights into `03-knowledge/permanent-notes/`.
5. Update `_MEMORY.md` with any change in stage or focus.

## 5. Weekly Review (Sunday — 30 min)

Trigger: `weekly review` skill.

Procedure:

1. Skill scans daily notes for the past 7 days.
2. Checks `06-goals/2026-annual.md` and current quarter goals.
3. Detects patterns and flags unprocessed inbox items.
4. Generates `06-goals/weekly/YYYY-MM-DD-weekly-review.md`.
5. Eduardo manually updates `_MEMORY.md` with any state changes.
6. Eduardo plans next week's top 3 priorities.

The weekly review is the ritual that keeps `_MEMORY.md` from drifting.

## 6. Monthly Consolidation (last Sunday — ~1 hour)

Trigger: `knowledge consolidation` skill.

Procedure:

1. Scan all permanent notes from the month.
2. Detect recurring themes and patterns.
3. Update or create MOCs (`03-knowledge/maps-of-content/`).
4. Write a pattern note in `03-knowledge/patterns/`.
5. Generate `06-goals/monthly/YYYY-MM-monthly-report.md` (intelligence report).
6. Suggest `_MEMORY.md` edits; Eduardo accepts/edits.

## 7. Retrospectives

Run a retrospective when:

- A project ships (e.g., [CLIENT_SITE] postmortem already exists).
- A project is paused ([ARCHIVED_PROJECT]).
- A quarterly target is hit or missed.

Format: ship/skip/learn or "what worked / what didn't / what to change." Save under the project folder as `<project>_postmortem.md` or similar.

## 8. Cross-Model Review

For high-stakes decisions: get a second opinion from a different model.

- Primary: Claude Code execution + Claude Chat planning.
- Second opinion: ChatGPT (uses CKIS upload package — see `[[11-chatgpt-project-instructions]]`).
- Procedure: write a ≤300-word problem statement in the active working slot, paste into ChatGPT, capture the response into `00-inbox/url-dumps/` as a literature note, then synthesize against Claude's view.

Goal: surface blind spots, not adjudicate. Eduardo decides; the vault records the rationale.

## 9. Reversal & Supersession

When a decision is reversed or superseded:

- Do **not** delete or rewrite the original entry.
- Add a new decision entry referencing the original via wikilink.
- Update the original entry's `Status:` to `superseded` or `reverted`.
- Briefly note *why* in the new entry's `Why:` field.

This produces a readable decision history that survives memory churn.

## 10. Execution Loop (zoomed out)

```
Decide ─► Log ─► Execute ─► Review (daily/weekly/monthly) ─► Revise or Reaffirm
   ▲                                                                  │
   └──────────────────── feedback into next decision ◄────────────────┘
```

Decisions feed reviews. Reviews feed the next round of decisions. Without writing decisions down, the loop never closes.
