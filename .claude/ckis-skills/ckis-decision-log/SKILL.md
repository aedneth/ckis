---
name: ckis-decision-log
description: Capture a decision in the CKIS decision-log format and route it to the right destination (project _overview.md, permanent note, or CHANGELOG). Use when [OWNER] says "log decision <title>" or "I'm deciding to <X> — log it." Asks at most one clarifying question; outputs a copy-pasteable block; updates _MEMORY.md Open Decisions.
---

# CKIS Decision Log

Capture decisions in a consistent, reviewable format. Route them to the correct durable home.

## When to invoke

[OWNER] says one of:

- `log decision <title>`
- "Capture this as a decision."
- "Log this in the decision log."

If the user is just *thinking out loud*, do NOT invoke this skill — that's a daily-note or quick-capture concern.

## Workflow

1. **Read** `00-systems/ckis/06-decision-execution-and-review-protocol.md` §1 and §9.
2. **Identify required fields**:
   - Date — today by default.
   - Project / area — infer from context; ask if ambiguous.
   - Status — `proposed` unless [OWNER] says it's already adopted.
   - Decision — verbatim from Eduardo (one line).
   - Why — at most 3 bullets.
   - Alternatives considered — bulleted; ask if missing.
   - Trade-offs accepted — bulleted; ask if missing.
   - Reversal cost — `low` | `medium` | `high`. Ask if missing.
   - Review-by — optional.
   - Linked notes — wikilinks to anything cited.
3. **Ask at most one clarifying question** — pick the most load-bearing missing field. Don't ask a flurry of questions.
4. **Render** the decision-log block:

```markdown
## Decision: <title>

- Date: YYYY-MM-DD
- Project / area: <project>
- Status: <status>
- Decision: <one-line summary>
- Why:
  - <reason 1>
  - <reason 2>
- Alternatives considered:
  - <alt 1>
  - <alt 2>
- Trade-offs accepted:
  - <trade-off>
- Reversal cost: <low | medium | high>
- Review-by: <YYYY-MM-DD or empty>
- Linked notes: [[…]]
```

5. **Pick destination**:
   - Project-specific → append to `02-projects/<project>/_overview.md` under a `## Decisions` section (create the section if missing).
   - System-level (touches CKIS itself) → entry in `00-systems/ckis/CHANGELOG.md` AND edit the relevant CKIS file.
   - Cross-cutting / personal / strategic → new permanent note `03-knowledge/permanent-notes/decision-<slug>.md`.
6. **Write** the entry to the chosen destination.
7. **Update `_MEMORY.md`**:
   - If `Status: proposed` → add to "Open decisions" (avoid duplicates).
   - If `Status: adopted` and a matching item exists in "Open decisions" → remove it from there.
   - If reverting/superseding → keep both entries; cross-link.
8. **Output**: confirm path written, show the rendered block, list `_MEMORY.md` edits made.

## Rules

- **Never** rewrite or delete a previous decision entry. Add a new one and mark the old as `superseded`.
- **Never** silently change `_MEMORY.md` beyond the Open decisions list — surface other suggested edits in the report.
- **Always** use wikilinks for `Linked notes`, not raw paths.
- **Always** include `Reversal cost` — it's the field that matters most when reviewing decisions later.

## QA Checklist

- [ ] All required fields populated (decision, why, alternatives, trade-offs, reversal cost).
- [ ] Status correct.
- [ ] Destination matches scope (project / system / cross-cutting).
- [ ] `_MEMORY.md` Open decisions updated.
- [ ] Linked notes use wikilinks.
- [ ] No previous decision entry rewritten.

## Do Not

- Make the decision *for* Eduardo. Capture, don't decide.
- Pad with explanation Eduardo didn't ask for.
- Auto-promote a `proposed` decision to `adopted` without confirmation.
