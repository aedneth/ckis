---
type: system
created: 2026-05-02
modified: 2026-05-13
tags: [ckis, skills, catalog]
status: active
related: ["[[00-ckis-master-context]]", "[[03-capture-processing-retrieval-workflow]]"]
---

# 16 — Skill Cards for Second-Brain Workflows

> Catalog of reusable CKIS workflows. Two layers:
>
> 1. **Operational skills** — already implemented under `.claude/skills/`. Listed here for reference.
> 2. **CKIS-specific skills** — new, scaffolded under `.claude/skills/ckis-*/SKILL.md` as part of this generation.

━━━

## 1. Layer A — Operational Skills (existing)

These are the 13 skills referenced in `.claude/CLAUDE.md` Commands. They already exist and are operational. CKIS depends on them but does not redefine them — the source of truth is each skill's `skill.md`.

| Skill | Trigger phrase | File |
|---|---|---|
| daily-brief | `daily brief` | `.claude/skills/daily-brief/skill.md` |
| process-inbox | `process inbox` | `.claude/skills/process-inbox/skill.md` |
| braindump | `braindump` | `.claude/skills/braindump/skill.md` |
| weekly-review | `weekly review` | `.claude/skills/weekly-review/skill.md` |
| monthly-consolidation | `knowledge consolidation` | `.claude/skills/monthly-consolidation/skill.md` |
| url-processor | `process URL` | `.claude/skills/url-processor/skill.md` |
| youtube-processor | `process YouTube` | `.claude/skills/youtube-processor/skill.md` |
| social-media-processor | `process social` | `.claude/skills/social-media-processor/skill.md` |
| knowledge-synthesis | `synthesize` | `.claude/skills/knowledge-synthesis/skill.md` |
| project-context | `project context` | `.claude/skills/project-context/skill.md` |
| client-onboarding | `onboard client` | `.claude/skills/client-onboarding/skill.md` |
| convert-to-md | `convert files` | `.claude/skills/convert-to-md/skill.md` |
| sync-overviews | `sync overviews` | `.claude/skills/sync-overviews/skill.md` |

(Plus 5 imported obsidian-skills: `obsidian-cli`, `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `defuddle`.)

## 2. Layer B — CKIS Workflow Skills (new)

The six CKIS-specific skills below sit alongside the operational set. They orchestrate CKIS-level concerns (system maintenance, cross-model handoff, decision logging) rather than vault-content processing.

Each lives at `.claude/skills/<skill-name>/SKILL.md`. Skill format follows the existing convention: YAML frontmatter (`name`, `description`) + structured workflow.

### 2.1 ckis-capture-triage

- **Name:** ckis-capture-triage
- **Description:** Lighter-weight pre-`process-inbox` triage. Identifies obvious mis-routes in `00-inbox/` (screenshots in the wrong subfolder, URL dumps not in `url-dumps/`, PDFs not in `convert-queue/`) and corrects them without classifying or moving to final folders.
- **Trigger:** `triage inbox`
- **Inputs:** none (operates on `00-inbox/` directly).
- **Workflow:**
  1. Glob `00-inbox/**/*` (excluding system files and subfolders' `processed/`).
  2. For each file, infer source from filename / extension / first-line markers.
  3. Move into the right inbox subfolder; never to a final folder.
  4. Output a triage report (counts and a per-file list).
- **Tools:** Glob, Read (frontmatter only), Bash (`mv`).
- **Output:** triage report (no further action).
- **QA checklist:** No file moved out of `00-inbox/`. No file deleted. System files (`_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`) untouched.
- **Do not:** classify, normalize frontmatter, or run `process-inbox` — those are separate skills.

### 2.2 ckis-vault-maintenance

- **Name:** ckis-vault-maintenance
- **Description:** Targeted maintenance operations: add/archive a project, refresh stale `_overview.md`, normalize a folder's frontmatter, run the monthly health check.
- **Trigger:** `vault maintenance` followed by an action verb (`add-project`, `archive-project`, `health-check`, `normalize-frontmatter <folder>`).
- **Inputs:** action verb + relevant slug or folder.
- **Workflow:**
  1. Parse the action verb.
  2. Read the relevant CKIS files (`13-maintenance-and-update-protocol.md`, `02-obsidian-vault-architecture.md`).
  3. Confirm the action with Eduardo if it touches >5 files.
  4. Execute. Each action has a sub-workflow:
     - `add-project <slug>` — scaffold `02-projects/<slug>/_overview.md`, update `_ACTIVE-PROJECTS.md`.
     - `archive-project <slug>` — move folder to `09-archive/<slug>/`, update `_ACTIVE-PROJECTS.md` and `_MEMORY.md`.
     - `health-check` — runs the checklist in CKIS file 13 §8, outputs a report. No edits.
     - `normalize-frontmatter <folder>` — reads each file, fixes frontmatter to spec, leaves body untouched.
  5. CHANGELOG entry for non-trivial changes.
- **Tools:** Read, Write, Edit, Bash (`mv`), Grep.
- **Output:** action report + CHANGELOG entry.
- **QA checklist:** Confirmed before bulk moves. No files deleted. Existing wikilinks preserved.
- **Do not:** restructure folder taxonomy without explicit user approval.

### 2.3 ckis-decision-log

- **Name:** ckis-decision-log
- **Description:** Capture a decision in the CKIS decision-log format and route it to the correct destination (project `_overview.md`, permanent note, or `CHANGELOG.md`).
- **Trigger:** `log decision`
- **Inputs:** decision title (one line), free-form context.
- **Workflow:**
  1. Read CKIS file 06 §1 for the format.
  2. Ask one clarifying question only if a load-bearing field is missing (decision, why, alternatives, reversal cost).
  3. Render the decision-log block.
  4. Suggest destination:
     - Project-specific → that project's `_overview.md` under `## Decisions`.
     - System-level → `00-system/ckis/CHANGELOG.md` + a CKIS file edit if applicable.
     - Cross-cutting → new permanent note in `03-knowledge/permanent-notes/decision-<slug>.md`.
  5. Write the entry. Update `_MEMORY.md` "Open decisions" if status is `proposed`, or remove from there if status is `adopted`.
- **Tools:** Read, Write, Edit.
- **Output:** decision-log entry + updated `_MEMORY.md`.
- **QA checklist:** Status, reversal cost, alternatives all populated. Linked notes use wikilinks.
- **Do not:** rewrite or delete previous decision entries.

### 2.4 ckis-weekly-review

- **Name:** ckis-weekly-review
- **Description:** CKIS-aware weekly review. Wraps the operational `weekly-review` skill with CKIS-specific health checks and `_MEMORY.md` refresh prompts.
- **Trigger:** `ckis weekly review`
- **Inputs:** none.
- **Workflow:**
  1. Run `weekly-review` skill (or replicate its logic).
  2. Append CKIS health items per CKIS file 13 §8 — only the lightweight ones for weekly cadence.
  3. List `_MEMORY.md` fields likely needing edits based on the past week's activity.
  4. Save to `06-goals/weekly/YYYY-MM-DD-weekly-review.md`.
  5. Surface to [OWNER]: "Update `_MEMORY.md` now with these proposed edits? (y/n)" — never write to `_MEMORY.md` automatically.
- **Tools:** Read, Glob, Grep, Write.
- **Output:** weekly review note + suggested `_MEMORY.md` edits.
- **QA checklist:** No automatic edits to `_MEMORY.md`. All CKIS file references use wikilinks.
- **Do not:** duplicate the existing `weekly-review` skill — wrap it.

### 2.5 ckis-cross-model-handoff

- **Name:** ckis-cross-model-handoff
- **Description:** Prepare a briefing artifact to paste into Claude Chat or ChatGPT. Pulls the active working slot, relevant `_overview.md` files, and a focused excerpt list, then formats per CKIS file 09.
- **Trigger:** `cross-model handoff` followed by destination (`claude-chat` or `chatgpt`) and topic.
- **Inputs:** destination + topic.
- **Workflow:**
  1. Read `[[14-active-working-slot]]` (latest version).
  2. Identify project(s) implicated; read each `_overview.md`.
  3. For ChatGPT: also list which files in the upload package ground the question.
  4. Output a single block ready to paste, with: problem statement (≤300 words), relevant CKIS file pointers, and the exact ask.
  5. Mark anything Eduardo should NOT paste (sensitive content, full `_MEMORY.md`).
- **Tools:** Read, Glob.
- **Output:** copy-pasteable briefing block.
- **QA checklist:** No secrets. No full `_MEMORY.md` paste. Briefing fits in ~300 words.
- **Do not:** write to the vault — this skill is read-only.

### 2.6 ckis-context-export

- **Name:** ckis-context-export
- **Description:** Regenerate the ChatGPT upload package under `00-system/ckis/chatgpt-project-upload/` from the latest CKIS files. Diff against the previous version.
- **Trigger:** `export context`
- **Inputs:** none (operates on the spec in CKIS file 11).
- **Workflow:**
  1. Read the file list from CKIS file 11 §1.
  2. Copy each file from `00-system/ckis/<file>` to `00-system/ckis/chatgpt-project-upload/<file>`.
  3. Run `git diff --stat -- 00-system/ckis/chatgpt-project-upload/` to summarize changes.
  4. Append entry to `CHANGELOG.md`: package regenerated, files updated, brief rationale.
  5. Output a short report listing what changed.
- **Tools:** Read, Write, Bash (`cp`, `git diff`).
- **Output:** regenerated upload folder + CHANGELOG entry.
- **QA checklist:** File list matches CKIS file 11 §1. No extra files in upload folder. CHANGELOG entry present.
- **Do not:** modify the source CKIS files — copy-only.

## 3. Skill Format Convention

For consistency with existing skills under `.claude/skills/<name>/skill.md`:

```markdown
---
name: <kebab-case-name>
description: <one paragraph; include trigger phrases verbatim>
---

# <Title>

<Body — workflow steps, rules, output spec>
```

The new CKIS skills follow this format. They use `SKILL.md` (uppercase) per the spec; existing operational skills use `skill.md` (lowercase). [OWNER]: pick one casing for the CKIS skills and rename if you prefer the existing `skill.md` convention.

## 4. Composition

CKIS skills compose with operational skills. Examples:

- `ckis-weekly-review` → wraps `weekly-review`.
- `ckis-vault-maintenance health-check` → uses `sync-overviews` discovery internally.
- `ckis-cross-model-handoff` → reads outputs from any operational skill.

Avoid duplicating logic. If a skill already does something, call it. If it doesn't, write it once and let everyone else call it.

## 5. Open Skills (proposed but not built here)

- `ckis-decision-review` — quarterly review of past decisions, mark `superseded` where applicable.
- `ckis-knowledge-graph-audit` — find orphan permanent notes (no inbound or outbound links).
- `ckis-template-audit` — diff `08-templates/` against `[[08-note-templates-and-frontmatter]]`.

Build when needed; don't pre-build.

━━━

## 6. Skills Directory Architecture

> Adopted 2026-05-13. Canonical rule for where skills live and how to install them.

### Two buckets — hard rule

| Bucket | Path | What goes here |
|---|---|---|
| **Global** | `~/.claude/skills/` | All downloaded / general-purpose skills — available in every project session |
| **Vault-specific** | `.claude/ckis-skills/` | CKIS workflow skills only — vault-aware, reference vault paths |

**The vault must never contain** `.claude/skills/` or `.agents/` as directories. These are created by `npx skills add` as a side-effect and must be cleaned up after every install (see below).

### Current global skills inventory (`~/.claude/skills/`)

| Skill | Source | Purpose |
|---|---|---|
| `graphify` | internal | Code/doc → knowledge graph |
| `wiki-brain` | internal | Compounding personal wiki (Dev Brain) |
| `gstack` | downloaded | Headless browser QA + site dogfooding |
| `marketingskills` | downloaded | Marketing copy and strategy |
| `find-skills` | `vercel-labs/agent-skills` | Discover and install skills from the registry |
| `privacy-policy` | `phuryn/pm-skills` | Draft and review privacy policy / legal compliance |

### `npx skills add` post-install procedure

`npx skills add` always installs to `~/.agents/skills/<name>/` and creates a symlink in `~/.claude/skills/<name>`. After every install:

```bash
# 1. Convert symlink to real directory
rm ~/.claude/skills/<name>
cp -r ~/.agents/skills/<name> ~/.claude/skills/<name>

# 2. Remove ~/.agents
rm -rf ~/.agents/skills/<name>
rmdir ~/.agents/skills 2>/dev/null
rmdir ~/.agents 2>/dev/null

# 3. If installing from inside the vault, also clean vault artifacts
rm -rf "$(pwd)/.claude/skills"
rm -rf "$(pwd)/.agents"
```

### How to invoke a globally installed skill in a project session

Global skills (`~/.claude/skills/`) are automatically available in all Claude Code sessions — no project-level configuration needed. Invoke via the Skill tool or the trigger phrase defined in each skill's `SKILL.md`.

### Why this split

- **Global skills** are project-agnostic tools (QA, marketing, legal review, skill discovery). Installing them globally avoids duplicating them per project and keeps the vault `.claude/` clean.
- **CKIS skills** are vault-specific by design — they reference Obsidian paths, CKIS file numbers, and vault conventions. They must live alongside the vault's `.claude/CLAUDE.md` so context is co-located.
