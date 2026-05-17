# CKIS Schema — Architecture Reference

This document explains the complete architecture of the Central Knowledge & Intelligence System (CKIS). Read this to understand how the pieces fit together before customizing.

---

## Three-Layer Memory Stack

CKIS uses three distinct memory layers, each with a clear scope:

### Layer 3 — CKIS Vault (Strategic Memory)
**This repo.** What you are, what you're building, decisions made, knowledge processed.
- Human-curated + Claude-assisted
- Markdown files on disk, under Git, opened with Obsidian
- Contains: projects, permanent notes, daily logs, goals, skills

### Layer 2 — Dev Brain (Engineering Memory)
**`~/Documents/Dev Brain/`** — a separate Obsidian vault.
- Agent-queryable code knowledge database
- Populated automatically by Graphify via git post-commit hooks
- Contains: code-graph/ (one .md per code node), sessions/index.md, wiki/ digests
- Any agent (Claude, Codex, Hermes) can plug in and query the entire codebase history

### Layer 1 — Per-Project `.brain/` (Session Memory)
**`<repo>/.brain/`** — lives inside each coding repo.
- Session logs, decision records, bug lessons, code graph
- Injected automatically at every Claude Code session start via hooks
- Bridges back to CKIS vault via graph-report sync

---

## Vault Folder Convention

| Folder | Purpose | Filing rule |
|---|---|---|
| `00-systems/` | Architecture docs — CKIS system files, workflows | Only system files; never personal content |
| `00-inbox/` | Raw capture zone | Everything enters here first |
| `01-daily/` | Daily notes + session logs | Timestamped; auto-created by daily brief skill |
| `02-projects/` | Active project folders | One subfolder per project; `_overview.md` required |
| `03-knowledge/` | Permanent notes, MOCs, guides | Only processed, synthesized content |
| `04-resources/` | Reference material | Articles, videos, books, tools |
| `05-areas/` | Life areas | Health, finance, relationships, learning |
| `06-goals/` | Goal hierarchy | Annual → quarterly → weekly |
| `07-people/` | Relationship notes | One file per person |
| `08-templates/` | Note templates | Frontmatter starters |
| `09-archive/` | Inactive items | Never delete — move here |

---

## Frontmatter Spec

Every note requires YAML frontmatter:

```yaml
---
type: <capture|permanent-note|project|decision|system|guide|daily|weekly>
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [tag-one, tag-two]
status: <active|draft|evergreen|archived>
related: ["[[linked-note]]", "[[another-note]]"]
---
```

Rules:
- Never strip frontmatter when editing
- Always update `modified:` on any change
- `created:` is immutable
- Tags: kebab-case only

---

## Skill System

Skills are Claude Code skill files in `.claude/ckis-skills/<skill-name>/skill.md`. They are invoked by natural language triggers in the Claude Code chat.

Trigger format: the skill name (or phrase) → Claude reads `skill.md` and executes.

Adding a skill:
1. Create `.claude/ckis-skills/<your-skill>/skill.md`
2. Add the trigger phrase to `.claude/CLAUDE.md` Commands section

---

## Hook Architecture

Five Claude Code hooks power the automatic context system:

| Hook | When | What it does |
|---|---|---|
| `SessionStart` | On every `claude` open | Assembles and injects full context into Claude's window |
| `PostToolUse(Bash)` | After every Bash call | Logs build/test/lint/commit events |
| `UserPromptSubmit` | On every user message | Detects `/compact` invocations |
| `Stop` | On session end | Writes session log, indexes to Dev Brain |
| *(global)* `SessionEnd` | On session end | Checks if Dev Brain Graphify rebuild is due |

Configured in `.claude/settings.json` (vault-level) and `<repo>/.claude/settings.json` (project-level).

---

## Cron Architecture

Five crons extend the system with scheduled automation. All use `claude -p` (headless Claude).

| Cron | Schedule | What it does |
|---|---|---|
| 1 — vault-git-sync | Every 6h | Commits + pushes vault changes |
| 2 — crm-sort | Daily 07:30 | Triages contact notes, flags stale leads |
| 3 — content-discovery | Weekly Mon 08:00 | Aggregates content from saved sources |
| 4 — weekly-review | Friday 17:00 | Prompts full weekly review |
| 5 — memory-consolidation | Monthly 1st | Refreshes _MEMORY.md + _ACTIVE-PROJECTS.md |

Full spec: `00-systems/ckis/17-crons-architecture.md`

---

## Per-Project `.brain/` Setup

To attach the memory layer to a coding repo:

1. Copy `.brain/` skeleton from reference repo
2. Create `config.sh` with project slug + paths
3. Add `.gitignore` entries for sessions/, graph/, _CONTEXT.md
4. Create `.claude/settings.json` with 5 hooks
5. Run `graphify update .` and install hooks
6. Run `bash .brain/scripts/register-to-dev-brain.sh`
7. Make first commit to confirm the chain

Full guide: `03-knowledge/permanent-notes/per-project-second-brain.md`

---

## Naming Conventions

- Vault files: `kebab-case.md`
- Folders: `kebab-case/`
- Tags: `#kebab-case`
- Project slugs: short, lowercase, no spaces (matches `02-projects/<slug>/`)
- Frontmatter type values: lowercase single-word or hyphenated

---

## What Belongs Where

| Content type | Destination |
|---|---|
| Raw capture, URL, document | `00-inbox/` first |
| Code decision (this repo) | `<repo>/.brain/decisions/` |
| Bug lesson | `<repo>/.brain/bugs/` |
| Reusable insight | `03-knowledge/permanent-notes/` |
| Business state | `00-inbox/_MEMORY.md` |
| Cross-project pattern | `03-knowledge/permanent-notes/` + CKIS CHANGELOG |
| Secrets, API keys | **Never in vault** |
