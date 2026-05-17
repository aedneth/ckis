---
name: daily-brief
description: Generate [OWNER]'s morning brief — top 3 priorities, blockers, inbox status — by reading yesterday's daily note, recent session logs, and active project overviews. Use when [OWNER] says "daily brief", "morning brief", "brief del día", or "qué hago hoy". Writes the brief into today's daily note.
---

# Daily Brief

A 2-minute morning ritual. Pull together what Eduardo left open yesterday, what's queued, and what matters most today. The output is a focused, actionable brief written into today's daily note — not a wall of context.

## Workflow

0. **Sync overviews (Step 0):** Run the `sync-overviews` skill (`@.claude/ckis-skills/sync-overviews/skill.md`) before reading any project data. This ensures `_overview.md` files reflect the latest committed changes. If no projects were updated, proceed silently. If any were updated, include the sync report in the brief as a collapsed `<details>` block.
   - **Cron 1 coordination:** Cron 1 (vault-git-sync) commits + pushes the vault every 6h. Before running this step, check the most recent commit: `git log --oneline -1`. If the commit message contains `auto-sync` (the Cron 1 marker), the vault is already current — skip the explicit `sync-overviews` invocation and note "Step 0 skipped — Cron 1 sync within window" in the brief.
1. **Determine today's date** and yesterday's date.
2. **Read recent context** in parallel:
   - Yesterday's daily note: `01-daily/{{yesterday}}.md` (if it exists)
   - The 2 most recent files in `01-daily/logs/` (Glob, sort by mtime)
   - `00-inbox/_ACTIVE-PROJECTS.md` for the current project roster
3. **Scan the inbox**: Glob `00-inbox/**/*.md` (excluding `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`). Count items and flag any > 7 days old.
4. **Read each active project's `_overview.md`** in `02-projects/<project>/_overview.md`. Look for `status:`, open decisions, blockers.
   - **Source the project list dynamically from `00-inbox/_ACTIVE-PROJECTS.md` 🟢 section** — do NOT hardcode project names. The brief's "Project pulse" must reflect whatever is currently 🟢 Active in that file (e.g. as of 2026-05: [YOUR_PROJECT], [CLIENT_SITE], recmp3-cli, University). If a project listed there has no `_overview.md`, surface that as a gap in the brief instead of skipping it silently.
5. **Synthesize** the brief in the format below. Be ruthless — top 3 priorities only. If you can't justify why something is in the top 3, drop it.
6. **Write to today's daily note**: `01-daily/{{today}}.md`.
   - If the file exists, prepend the brief under a `## Morning Brief — HH:MM` heading.
   - If it doesn't exist, create it from the daily-note template (`08-templates/daily-note.md` if present) and insert the brief.
7. **Echo the brief inline** to Eduardo so he sees it without opening Obsidian.

## Brief format

```markdown
## Morning Brief — YYYY-MM-DD

### 🎯 Top 3 priorities
1. **{{priority}}** — {{why it matters today, in one line}}
2. **{{priority}}** — {{...}}
3. **{{priority}}** — {{...}}

### 🚧 Blockers / open decisions
- {{blocker or decision waiting on Eduardo}} ({{which project}})

### 📥 Inbox status
- N items pending · M older than 7 days ⚠️

### 🔁 Carryover from yesterday
- {{anything not finished yesterday that should roll forward, or "Nothing carried over"}}

### 📌 Project pulse
<!-- One bullet per project in `00-inbox/_ACTIVE-PROJECTS.md` 🟢 Active. Do NOT hardcode — read the file at brief time. -->
- **{{project name}}** — {{one line from its _overview.md status / latest activity}}
- ...
```

## Rules

- Top 3 priorities means **exactly 3**, never 5, never 7. Force the prioritization.
- If yesterday's daily note doesn't exist, say so explicitly under "Carryover" instead of fabricating.
- Bilingual: if recent notes are in Spanish, write the brief in Spanish. Default to Spanish unless context is overwhelmingly English.
- Don't summarize the entire week — that's `weekly-review`'s job.
- Don't move or modify any files other than today's daily note.

## Example invocation

```
[OWNER]: daily brief
→ Read 01-daily/2026-04-05.md, 01-daily/logs/ (2 latest), _ACTIVE-PROJECTS.md, all _overview.md files
→ Glob 00-inbox/ to count
→ Synthesize and write Morning Brief into 01-daily/2026-04-06.md
→ Echo the brief to Eduardo
```
