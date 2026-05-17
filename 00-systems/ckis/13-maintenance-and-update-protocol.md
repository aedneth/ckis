---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, maintenance, updates]
status: active
related: ["[[00-ckis-master-context]]", "[[09-cross-model-shared-context-protocol]]"]
---

# 13 — Maintenance & Update Protocol

> CKIS is a living system. This file specifies how it gets updated without drifting.

━━━

## 1. Triggers for Maintenance

| Trigger | What to update |
|---|---|
| New active project | `_ACTIVE-PROJECTS.md`, `_MEMORY.md`, `02-projects/<new>/_overview.md` |
| Project paused or archived | `_ACTIVE-PROJECTS.md`, `_MEMORY.md`, move folder to `09-archive/` if archived |
| Quarterly transition | `06-goals/2026-annual.md`, `_MEMORY.md`, monthly report |
| Stack change (new tool, dropped tool) | `[[01-ckis-user-profile-and-operating-context]]`, optionally `04-resources/tools/` |
| New skill or skill change | `.claude/skills/<skill>/skill.md`, `[[16-skill-cards-for-second-brain-workflows]]`, root `CLAUDE.md` shortcuts if applicable |
| CKIS architecture change | the relevant `00-system/ckis/<file>.md`, `CHANGELOG.md`, ChatGPT upload package |
| New decision protocol | `[[06-decision-execution-and-review-protocol]]` |
| Frontmatter / template change | `[[02-obsidian-vault-architecture]]` §5, `[[08-note-templates-and-frontmatter]]` |

## 2. Adding a New Project

1. Create `02-projects/<slug>/`.
2. Scaffold `_overview.md` from `[[08-note-templates-and-frontmatter]]` §3.
3. Add the project to `_ACTIVE-PROJECTS.md` under 🟢 **Active**.
4. If load-bearing: mention in `_MEMORY.md` under "Active focus" or "Open Decisions."
5. If a project repository exists at `~/<slug>/`, plan the project-level `CLAUDE.md` bridge (open question — see `[[00-ckis-master-context]]` §9 #3).
6. First commit: `feat: add <slug> project`.

## 3. Updating Context Files

System files in `00-inbox/` (`_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`):

- Edited manually by [OWNER] (typically during the weekly review).
- Update `modified` to today.
- Don't truncate. Append new state, retire stale entries by editing in place.
- `_MEMORY.md` has a 150-line cap — if it exceeds, compress by promoting durable items to permanent notes and demoting the rest.

## 4. Revising Templates

1. Edit `08-templates/<template>.md` (or scaffold one if missing).
2. Mirror the change in `[[08-note-templates-and-frontmatter]]`.
3. Note the change in `CHANGELOG.md`.
4. Do **not** retroactively rewrite existing notes to match — only new notes use the new template.

## 5. Archiving Outdated CKIS Sections

When part of a CKIS file becomes outdated:

1. Do not delete the section.
2. Move the outdated content to a `## Deprecated` block at the bottom of the file with a date.
3. Replace it with the new content.
4. CHANGELOG entry: which file, which section, brief reason.

For whole files that are obsolete:

1. Move to `00-system/ckis/_deprecated/` (folder created on first use).
2. Update `[[00-ckis-master-context]]` index to remove the link or strike it through.

## 6. Regenerating the ChatGPT Upload Package

Trigger: any material change to the CKIS files listed in the package (see `[[11-chatgpt-project-instructions]]`).

Procedure:

1. Run `ckis-context-export` skill (or manually copy the listed files into `00-system/ckis/chatgpt-project-upload/`).
2. Verify file list matches the spec.
3. Diff against the previous version (`git diff -- 00-system/ckis/chatgpt-project-upload/`).
4. Re-upload to ChatGPT Project.
5. CHANGELOG entry: package regenerated, file list, brief rationale.

## 7. Logging Changes

`00-system/ckis/CHANGELOG.md` is the single change log for CKIS. Required entries:

- Date.
- Files created.
- Files updated.
- Source files used (for material rewrites).
- Open questions.
- Next recommended action.

Routine inbox processing and daily-note creation are **not** CHANGELOG events. Skill changes, architecture changes, and new CKIS files are.

## 8. Health Check (monthly)

Run during the monthly consolidation:

- [ ] Are all active projects in `_ACTIVE-PROJECTS.md` actually active (any folder been silent ≥30 days)?
- [ ] Are there any `00-inbox/` items older than 7 days? (`process inbox` should have flagged these.)
- [ ] Does the file list under `00-system/ckis/` match the index in `[[00-ckis-master-context]]` §10?
- [ ] Does the ChatGPT upload package match the spec in `[[11-chatgpt-project-instructions]]`?
- [ ] Does `_MEMORY.md` reflect reality (read it; ask: am I working on these things this week)?
- [ ] Are templates in `08-templates/` consistent with `[[08-note-templates-and-frontmatter]]`?

Surface drift in the monthly intelligence report.

## 9. Versioning

CKIS does not use semver. Versioning lives in:

- Git history (every commit is a version).
- `CHANGELOG.md` (human-readable summary).
- `modified` dates in frontmatter (per-file recency).

Avoid baking version numbers into filenames or section titles. Use git for history.

## 10. Restoration After a Mistake

If a CKIS file gets clobbered:

1. Restore from `.claude/backups/ckis-migration/<file>.bak` if recent.
2. Otherwise: `git log -- <path>` to find a good version, `git show <commit>:<path> > <path>` to restore.
3. Add a CHANGELOG entry: what was clobbered, how it was restored.

The `.claude/backups/` folder is part of the safety net; never empty it.
