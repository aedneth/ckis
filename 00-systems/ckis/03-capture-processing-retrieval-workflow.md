---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, workflow, capture, processing, retrieval]
status: active
related: ["[[00-ckis-master-context]]", "[[04-claude-code-obsidian-agent]]", "[[16-skill-cards-for-second-brain-workflows]]"]
---

# 03 — Capture · Processing · Retrieval Workflow

> The core CKIS pipeline: **Capture → Process → Synthesize → Act → Review.** Every other workflow in CKIS is a specialization of this one. Capture is not progress — it must be processed to count.

━━━

## 1. Capture

Goal: zero-friction entry. Never organize at capture time.

| Source | Channel | Lands in |
|---|---|---|
| Raw thought | `braindump` skill | `00-inbox/quick-capture/` |
| Web URL | Obsidian Web Clipper | `00-inbox/` (with frontmatter) |
| YouTube video | `process YouTube [url]` skill | `00-inbox/youtube-queue/` then `04-resources/youtube/` |
| Social post / image | screenshot → drop | `00-inbox/social-media-queue/` |
| PDF / DOCX / RTF | drop file | `00-inbox/convert-queue/` (auto-converted to .md) |
| Mobile capture | Obsidian Mobile / Share-to-Obsidian | `00-inbox/quick-capture/` |
| Session insight | end-of-session summary | `01-daily/logs/` |

Rules:

- Everything enters `00-inbox/` first — never directly into a final folder.
- Capture in the language it occurred in (ES or EN). No translation at capture.
- Don't tag, link, or classify at capture time.
- Web Clipper is configured to land in `00-inbox/` with frontmatter scaffolded.

## 2. Triage (light, fast)

Inside `00-inbox/`, an item may be triaged before full processing:

- Move screenshots into `social-media-queue/` if they came from social.
- Move articles into `url-dumps/` if they came from Web Clipper.
- Triage is light: at most rename the file, drop it in the right subfolder. Frontmatter and full classification happen during *Processing*.

## 3. Processing

Trigger: `process inbox` (skill: `.claude/skills/process-inbox/skill.md`).

Step 0 — auto-convert non-markdown files (PDF, DOCX, RTF) via `convert-to-md` skill (pandoc + pdftotext).

For each `.md` file in `00-inbox/`:

1. Read the file.
2. Add or fix frontmatter (see `[[08-note-templates-and-frontmatter]]`).
3. Classify type: `permanent-note`, `literature-note`, `project`, `resource`, `area`, `goal`, `person`.
4. Suggest at least 2 kebab-case tags.
5. Search the vault (Grep) for related existing notes; insert `[[wikilinks]]` inline at natural mentions; update `related:`.
6. Rename to clean kebab-case (strip Notion hashes, timestamps, "Untitled").
7. Move to the destination folder (see routing table in `process-inbox/skill.md`).
8. Flag any item older than 7 days as `⚠️ stale — review for deletion` in the report. Never auto-delete.

System files **never move**: `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`.

## 4. Linking & Synthesis

After processing, knowledge needs to *connect*:

- Permanent notes are atomic — one idea per file. They link to other permanent notes and to MOCs.
- Literature notes summarize a single source and link to any permanent notes they spawned.
- MOCs (`03-knowledge/maps-of-content/MOC-*.md`) are topic-level hub pages. Updated when 5+ permanent notes share a theme.
- Projects' `_overview.md` files surface relevant permanent/literature notes via links.

Trigger: `synthesize [topic]` (skill: `.claude/skills/knowledge-synthesis/skill.md`) — vault-wide search, finds patterns, gaps, contradictions, creates or updates the MOC, promotes new permanent notes.

## 5. Retrieval

Patterns:

- **Pre-coding context** — `project context [name]` reads `_overview.md`, recent daily notes mentioning the project, all tagged notes, and outputs a compact brief.
- **Topic dive** — `synthesize [topic]` does a vault-wide compile.
- **Live state** — read `00-inbox/_MEMORY.md` first.
- **Direct lookup** — Obsidian search + graph view.

Token-efficiency rules (mandatory for Claude Code):

- NEVER scan the full vault. Use surgical `@file` references or Glob+Grep.
- `sync overviews` uses `git log --name-only --since="<modified>"` — zero tokens on unchanged projects.
- Haiku for simple processing (process-inbox, braindump, daily-brief).
- Sonnet for synthesis (weekly-review, knowledge-synthesis).
- Opus for strategy and architecture only.

## 6. Output / Act

CKIS exists to drive action. Outputs that close the loop:

- A permanent note is created.
- An MOC is updated.
- A decision is logged (see `[[06-decision-execution-and-review-protocol]]`).
- A daily note records what was done.
- A project `_overview.md` advances (Recent progress, Status, Blockers).
- A skill is updated to reduce future friction.
- Code is shipped in a project repo (and the decision is back-linked to the vault).

## 7. Review Cadence

| Cadence | Trigger | Skill | Output |
|---|---|---|---|
| Daily — morning | `daily brief` | `daily-brief` | Step 0 runs `sync overviews`; outputs top-3 priorities into today's daily note |
| Daily — end of day | `process inbox` | `process-inbox` | Inbox emptied; processing report |
| Weekly — Sunday | `weekly review` | `weekly-review` | `06-goals/weekly/YYYY-MM-DD-weekly-review.md`; Eduardo updates `_MEMORY.md` |
| Monthly — last Sunday | `knowledge consolidation` | `monthly-consolidation` | `06-goals/monthly/YYYY-MM-monthly-report.md` + MOC updates |

## 8. Pipeline Summary

```
   Capture ──► 00-inbox/ ──► Triage ──► Processing ──► Linking/Synthesis
      │                                       │              │
      │                                       ▼              ▼
      │                                    move to     03-knowledge/
      │                                  02-projects/   permanent-notes/
      │                                  04-resources/  literature-notes/
      │                                  05-areas/      maps-of-content/
      │                                  07-people/
      │                                       │
      ▼                                       ▼
   ━━━━━━━━━━━━━━━━━━━━ Review (daily / weekly / monthly) ━━━━━━━━━━━━━━━━━━
                                              │
                                              ▼
                                            Act
                                  (decision · code · output)
```

## 9. Anti-patterns

- "I'll organize it later" without putting it in `00-inbox/`. → Lost capture.
- Editing a synthesis directly in chat without writing it back to the vault. → Phantom knowledge.
- Creating empty shell files for "future use." → Notion failure mode.
- Translating notes from their captured language. → Loss of nuance.
- Hard-deleting unprocessed inbox items. → Violates "never delete without backup."
