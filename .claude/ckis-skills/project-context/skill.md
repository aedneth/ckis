---
name: project-context
description: Compile a compact context brief for a project — read its _overview.md, scan recent daily notes for mentions, gather all tagged notes, and surface current status, open decisions, recent progress, and blockers. Use when Eduardo says "project context [name]", "contexto del proyecto [nombre]", or at the start of any coding session on Korvex / Brisas / Tourdy / University.
---

# Project Context

Before Eduardo starts a coding session on a project, he needs the project paged into his head: where things stood last time, what's open, what's blocked. This skill produces that brief from the vault so the coding session starts with full situational awareness — not a cold start.

## Workflow

1. **Identify the project.** Match Eduardo's input against `02-projects/` folders. Common shortcuts:
   - "korvex" → `02-projects/korvex/`
   - "brisas" / "brisas del golfo" → `02-projects/brisas-del-golfo/`
   - "tourdy" → `02-projects/tourdy/`
   - "uni" / "university" / "ugb" → `02-projects/university/`
   - "personal brand" / "marca" → `02-projects/personal-brand/`
   - If no match, list available projects and ask.
2. **Read the overview**: `02-projects/<project>/_overview.md`. This is the source of truth on status, strategy, and links.
3. **Read project sub-files** as relevant: `services.md`, `pipeline.md`, files in `clients/`, etc. Use Glob `02-projects/<project>/**/*.md`.
4. **Scan recent daily notes** for project mentions:
   - Glob `01-daily/*.md`, sort by mtime desc, take the 14 most recent
   - Grep them for the project name and any associated tags (e.g., `#korvex`, `#brisas`)
   - Read the matching sections
5. **Scan session logs** in `01-daily/logs/` (last 14 by mtime) for project mentions.
6. **Search the wider vault** for tagged notes: Grep for `#<project>` across `03-knowledge/`, `00-inbox/`.
7. **Check `00-inbox/_ACTIVE-PROJECTS.md`** for the project's current status line.
8. **Compile the context brief** using the format below.
9. **Optionally log the session start** to `01-daily/logs/{{YYYY-MM-DD-HHMM}}-{{project}}-session-start.md` if Eduardo confirms (or if invoked at the start of an actual coding session — ask).
10. **Output the brief inline**. Make it scannable in under 60 seconds.

## Context brief format

```markdown
# 🎯 Project Context: {{Project Name}}

**Status:** {{from _overview.md or _ACTIVE-PROJECTS.md}}
**Last touched:** {{date of most recent mention in daily notes / logs}}

## Where it stands
{{2-4 sentences synthesizing current state from _overview.md and recent activity}}

## 📌 Open decisions
- {{decision waiting on Eduardo, with context}}
- ...

## ✅ Recent progress (last 14 days)
- {{YYYY-MM-DD}} — {{what happened}} ([[daily note]])
- ...

## 🚧 Blockers
- {{what's stopping forward progress}}
- ...

## 🔗 Key files
- [[_overview]] · [[services]] · [[pipeline]] · ...

## 🧠 Relevant knowledge from vault
- [[permanent note]] — why it's relevant
- ...

## ▶ Suggested next action
{{one concrete next step Eduardo could take in this session}}
```

## Rules

- Brief must be **scannable in under 60 seconds**. Hard cap: ~300 words. If the project has too much state to fit, point to the longest doc and stop.
- Bilingual: Korvex/Brisas notes are mostly Spanish → write the brief in Spanish. University/personal-brand may be English. Match the source.
- Never modify project files. The skill is read-only on `02-projects/`.
- "Suggested next action" must be concrete (not "continue working on Korvex"). One thing, doable today.
- If `_overview.md` doesn't exist, say so and offer to create one from the template.
- The session-start log is opt-in — don't write it unless invoked in a session-start context or Eduardo says so.

## Example invocation

```
Eduardo: project context brisas
→ Read 02-projects/brisas-del-golfo/_overview.md and all sub-files
→ Glob 01-daily/, take last 14, Grep for "brisas" and "#brisas"
→ Grep 03-knowledge/ for #brisas tag
→ Compile brief → output inline
→ Ask: "Want me to log this as a session start?"
```
