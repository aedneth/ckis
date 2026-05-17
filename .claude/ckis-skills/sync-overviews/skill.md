---
name: sync-overviews
description: Keep all 02-projects/ _overview.md files current using parallel subagents — one per project with changes. Orchestrator handles discovery and git diff; subagents read ALL new files and update overviews concurrently. Zero tokens spent on projects with no changes.
---

# Sync Overviews

Keep project overviews accurate without burning tokens. The key insight: the `modified` date in each `_overview.md` frontmatter is the high-water mark — git tells us exactly which project files changed since then. Projects with no changes are skipped entirely. Projects with changes get a dedicated subagent that reads ALL new files in parallel.

## Architecture

```
Orchestrator
  ├── Step 1: Discovery (sequential, cheap)
  │     ├── Scan 02-projects/ for folders
  │     ├── Read each _overview.md frontmatter (first 15 lines)
  │     └── git log --name-only --since="<modified>" per project
  │
  ├── Step 2: Spawn subagents in parallel (one per project with changes)
  │     ├── Subagent: korvex    → reads N new files → returns updated overview
  │     ├── Subagent: brisas    → reads M new files → returns updated overview
  │     └── Subagent: ...
  │
  └── Step 3: Write + commit
        ├── Write all updated _overview.md files to disk
        ├── Generate sync report
        └── git commit
```

━━━

## STEP 1 — DISCOVERY (orchestrator executes this)

### 1a. Find all project folders

```bash
ls 02-projects/
```

### 1b. For each folder, check for _overview.md

Read only the first 15 lines to get the frontmatter `modified` date.

### 1c. Run git log per project

```bash
git log --name-only --since="<modified>" --pretty=format: -- 02-projects/<project>/
```

Filter empty lines. Filter out `_overview.md` itself from results.

**Decision:**
- Zero files returned → skip this project entirely. Log: "✓ <project> — no changes"
- One or more files returned → spawn a subagent for this project

### 1d. For projects WITHOUT an _overview.md

```bash
git log --name-only --diff-filter=A --pretty=format: -- 02-projects/<project>/
```

Take up to 5 most recently committed files. Spawn a subagent to create a new overview from scratch.

━━━

## STEP 2 — PARALLEL SUBAGENTS

Spawn all project subagents **in a single message** (parallel tool calls). Do not wait for one to finish before spawning the next.

### What each subagent receives (include all of this in the subagent prompt)

```
You are updating the _overview.md for the project: <project-name>

Project folder: 02-projects/<project>/
Overview path: 02-projects/<project>/_overview.md

Current _overview.md content:
<paste full current content>

Files changed since last overview update (from git log):
<list of file paths, one per line>

Your task:
1. Read ALL files in the changed files list above.
2. Extract key updates: status changes, decisions made, blockers 
   resolved, new deliverables, anything notable.
3. Update ONLY the relevant sections of _overview.md:
   - Status: update if the project state changed
   - Where it stands: update if scope or progress changed
   - Open decisions: add new ones, resolve closed ones
   - Recent progress: APPEND new entries (YYYY-MM-DD format), never 
     delete existing entries
   - Blockers: add new ones, remove resolved ones
   - Key files: add [[links]] to any new important files
   - Strategy/Notes: add if strategic context changed
4. Update frontmatter: modified: <today's date>
5. Preserve all existing content not affected by the new files.
   Never overwrite or delete existing overview history.
6. Match the language of the existing overview (Spanish/English).

Return:
- The complete updated _overview.md content (full file, ready to write)
- One-line summary: "<project> — N files read · sections updated: [list]"
```

### For NEW overviews (no existing _overview.md)

```
You are creating a new _overview.md for: <project-name>

Project folder: 02-projects/<project>/
Most recently committed files:
<list of up to 5 file paths>

1. Read all files listed above.
2. Create _overview.md using this template:

---
type: project-overview
project: <name>
status: active
created: <today>
modified: <today>
tags: [project, <name>]
---

# <Project Name> — Overview

## Status
<!-- Current state in one sentence -->

## Where it stands
<!-- 2-4 sentences: what exists, what's in progress, what's next -->

## 📌 Open decisions
- <!-- decisions waiting on Eduardo -->

## ✅ Recent progress
- <!-- YYYY-MM-DD — what happened -->

## 🚧 Blockers
- <!-- what's stopping forward progress -->

## 🔗 Key files
- <!-- [[file]] — purpose -->

## Strategy / Notes
<!-- Anything that doesn't fit above -->

Return:
- The complete _overview.md content (full file, ready to write)
- One-line summary: "<project> — created from N files"
```

━━━

## STEP 3 — WRITE + COMMIT (orchestrator executes after all subagents return)

### 3a. Write files

For each subagent result, write the returned content to disk:

```
02-projects/<project>/_overview.md
```

### 3b. Generate sync report

```markdown
## Sync Overviews — YYYY-MM-DD

### Updated
- **<project>** — N files read · sections updated: [status, recent progress, ...]

### New overviews created
- **<project>** — created from N source files

### Skipped (no changes)
- **<project>** — last modified <date>
```

### 3c. Commit

```bash
git add -A && git commit -m "sync: overviews updated YYYY-MM-DD"
```

━━━

## Rules

- **Never read files committed before the `modified` date** — only the git log delta matters.
- **Subagents read ALL new files** — no per-project cap. The parallel architecture makes this affordable.
- **Never overwrite existing overview content** — append to Recent progress, update Status/Blockers in place. History is permanent.
- **Preserve editorial voice** — don't paraphrase Eduardo's language. Append raw facts; he'll synthesize.
- **Modified date = commit date, not file mtime** — use git, not filesystem timestamps.
- **If git is not available**, fall back to Glob `02-projects/<project>/**/*.md` sorted by mtime, compare against `modified` date manually.
- **This skill is write-only on `_overview.md` files** — subagents never touch other project files.
- **Bilingual:** each subagent matches the language of the overview it is updating.
- **Spawn all subagents in one message** — parallel tool calls, not sequential spawning.

━━━

## When called from daily-brief

Run as Step 0. Append the sync report to the brief under a collapsed section:

```markdown
<details>
<summary>🔄 Overview sync — N projects updated, M skipped</summary>

[sync report here]

</details>
```

If no projects had changes, omit the section entirely.

━━━

## Example invocation

```
Eduardo: sync overviews
→ Orchestrator scans 02-projects/: korvex, brisas, university, tourdy, personal-brand
→ git log for each:
    korvex: 8 new files → spawn subagent
    brisas: 1 new file → spawn subagent
    university: 0 new files → skip
    tourdy: 0 new files → skip
    personal-brand: 0 new files → skip
→ Spawn korvex subagent + brisas subagent IN PARALLEL (single message)
→ korvex subagent: reads 8 files → updates status + recent progress + blockers
→ brisas subagent: reads 1 file → updates open decisions + recent progress
→ Both return → orchestrator writes both _overview.md files
→ git commit
→ Output sync report
```
