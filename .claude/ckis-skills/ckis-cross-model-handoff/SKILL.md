---
name: ckis-cross-model-handoff
description: Build a copy-pasteable briefing for Claude Chat or ChatGPT. Pulls 14-active-working-slot.md, relevant project _overview.md files, and CKIS file pointers; flags content NOT to paste (secrets, full _MEMORY.md). Use when Eduardo says "cross-model handoff <claude-chat|chatgpt> <topic>" or wants to brief another model without dumping the vault. Read-only — never writes to the vault.
---

# CKIS Cross-Model Handoff

Prepare a single block Eduardo can paste into Claude Chat or ChatGPT. Goal: maximum context-density per token, no leakage.

## Trigger

`cross-model handoff <destination> <topic>`

Where `<destination>` is one of:

- `claude-chat` — full Claude Project (more context budget).
- `chatgpt` — ChatGPT Project (smaller per-message budget; relies on uploaded package).

## Workflow

1. **Read context:**
   - `00-system/ckis/14-active-working-slot.md` (in full).
   - `00-system/ckis/09-cross-model-shared-context-protocol.md` (sections 4, 5, 7).
   - For each project mentioned in the working slot or topic: `02-projects/<project>/_overview.md`.

2. **Identify the ask.** From the working slot's `Current Task` and `Goal`. If the task is unclear, ask Eduardo a single question; otherwise proceed.

3. **List CKIS file pointers** that ground the topic. Format: numeric prefix + topic name, e.g., `06 - Decision · Execution · Review Protocol §3`.

4. **Render the briefing block** (≤300 words for ChatGPT, ≤500 for Claude Chat):

```
# Briefing — <topic>

## Context
<2–4 sentence overview of what's going on. Pull from working slot Current Task + Goal.>

## Relevant CKIS files (you already have these uploaded/attached)
- 00 — Master Context
- <other relevant CKIS files by number + topic>

## Project state (compact)
- Project: <name>
- Status: <one line>
- Open decisions: <bulleted, terse>
- Blockers: <bulleted, terse>

## Constraints
<from working slot §4>

## What I'm asking for
<single, specific ask>

## Format wanted
<bullet list / decision-log block / draft / etc.>
```

5. **Add a "Do NOT paste" note.** List things Eduardo should not paste (or that the skill specifically excluded):
   - Full `_MEMORY.md` (only summarized fields — Open decisions, Blockers).
   - Anything resembling secrets / tokens.
   - Full client PII.

6. **Output the block + the do-not-paste note.** That's it.

## Rules

- **Read-only.** Never write to the vault from this skill.
- **No secrets.** If the working slot or `_overview.md` contains a secret-looking string (regex `(?i)(token|key|secret|password|sk-)\\W`), strip it and flag.
- **Compact.** ChatGPT briefings ≤300 words. Claude Chat briefings ≤500 words.
- **Concrete ask.** Don't produce a briefing for "thoughts on X" — push Eduardo to a specific deliverable shape.
- **Don't dump `_MEMORY.md`.** Pull only the fields relevant to the topic.

## Output Example

```
# Briefing — Korvex pricing for Bloque 3

## Context
We're shipping Bloque 3 of the 7-bloque framework next month. Need to lock pricing before launch. Current market positioning is mid-tier; competitor X just dropped to $X.

## Relevant CKIS files
- 06 - Decision · Execution · Review Protocol
- 07 - Projects / Areas / Resources / Archives Map (Korvex section)
- 09 - Cross-Model Shared Context Protocol

## Project state
- Project: Korvex
- Status: Bloque 2/7 launched; Bloque 3 in design.
- Open decisions: pricing for Bloque 3; productized vs custom split.
- Blockers: no validated lead source.

## Constraints
- Stack locked (Next.js 16 / Supabase / Vercel).
- Single operator — no team.
- Latin American pricing context.

## What I'm asking for
A ranked shortlist of 3 pricing structures, each with a 1-line trade-off, evaluated against the constraints.

## Format wanted
Decision-log block per CKIS file 06 §1, with `Status: proposed`.

---
Do NOT paste:
- Any client-specific revenue numbers.
- Full _MEMORY.md (only the fields above are summarized).
```

## QA Checklist

- [ ] Briefing fits the word budget for the destination.
- [ ] No secrets in the output.
- [ ] CKIS file pointers cited (not duplicated).
- [ ] Specific ask + format wanted.
- [ ] Do-not-paste section present.

## Do Not

- Write to any file.
- Quote `_MEMORY.md` verbatim.
- Translate the briefing — preserve language of the working slot.
- Add motivational filler.
