---
name: ckis-vault-maintenance
description: Targeted CKIS maintenance operations — add a new project, archive a project, run the monthly health check, or normalize frontmatter across a folder. Use when Eduardo says "vault maintenance <action>" with one of: add-project <slug>, archive-project <slug>, health-check, normalize-frontmatter <folder>. Confirms before bulk moves; never deletes; CHANGELOG entry for non-trivial changes.
---

# CKIS Vault Maintenance

Routine, targeted maintenance. Single dispatcher, multiple actions. Does not handle inbox processing, decisions, or cross-model handoff — those have their own skills.

## Trigger format

`vault maintenance <action> [args]`

Actions:

- `add-project <slug>`
- `archive-project <slug>`
- `health-check`
- `normalize-frontmatter <folder>`

## Pre-flight

1. Read `00-systems/ckis/13-maintenance-and-update-protocol.md` (full).
2. Read `00-systems/ckis/02-obsidian-vault-architecture.md` (sections 1–5).
3. If the action will touch >5 existing files, **confirm with Eduardo** before proceeding.

## Action: add-project

1. Verify `02-projects/<slug>/` does not exist. If it does, ask Eduardo whether to overwrite or pick a new slug.
2. Create `02-projects/<slug>/`.
3. Scaffold `_overview.md` from CKIS file 08 §3. Frontmatter `created` and `modified` = today; `tags: [project, <slug>]`; `status: active`; empty Recent progress / Open decisions / Blockers / Key files.
4. Append to `00-inbox/_ACTIVE-PROJECTS.md` under 🟢 **Active** with type, status, vault link.
5. **Do not** modify `_MEMORY.md` automatically — surface a suggested edit in the report.
6. CHANGELOG entry: `feat: add <slug> project`.
7. Output the report. Do not commit — Eduardo commits.

## Action: archive-project

1. Verify `02-projects/<slug>/` exists.
2. **Confirm** with Eduardo before moving (always — archiving is high-impact).
3. Move the entire folder via `mv 02-projects/<slug>/ 09-archive/<slug>/`.
4. Update `_ACTIVE-PROJECTS.md`: remove from 🟢 **Active**, optionally add a brief note under an Archived section.
5. Surface a suggested `_MEMORY.md` edit (don't write it).
6. Search the vault for inbound wikilinks to the project's notes; report any that may now be broken (do not auto-fix).
7. CHANGELOG entry: `chore: archive <slug>`.

## Action: health-check

Read-only. Runs the checklist from CKIS file 13 §8:

- All active projects in `_ACTIVE-PROJECTS.md` actually active (any project folder silent ≥30 days)?
- Inbox items older than 7 days?
- CKIS file list under `00-systems/ckis/` matches the index in CKIS file 00 §10?
- Are CKIS files 17 (`17-crons-architecture.md`), 18 (`18-memory-architecture.md`), and 19 (`19-agent-habits-guide.md`) present in `00-systems/ckis/`? Flag any that are missing.
- ChatGPT upload package matches CKIS file 11 §1?
  - Sub-check: does the package under `00-systems/ckis/chatgpt-project-upload/` include files 17, 18, and 19? If not, flag: "run `ckis-context-export` to refresh."
- Are Cron 5 (memory-consolidation) outputs current? Check `00-inbox/_MEMORY.md` `modified:` date — if >35 days old, flag for manual consolidation.
- Does `_MEMORY.md` still reflect reality? (heuristic only — surface for Eduardo)
- Templates in `08-templates/` consistent with CKIS file 08?

Output a report; **make no changes**.

## Action: normalize-frontmatter <folder>

1. Glob `<folder>/**/*.md`.
2. For each file:
   - Read.
   - If frontmatter is missing or malformed, scaffold from CKIS file 08 §1 (preserve `created` if any non-empty creation hint exists; otherwise use git first-commit date if available, else today).
   - Update `modified` to today only if frontmatter actually changed.
   - Preserve unknown fields.
   - Write back.
3. Confirm with Eduardo before processing >20 files.
4. CHANGELOG entry: `chore: normalize frontmatter in <folder>`.

## Rules

- **Never** delete a file or folder.
- **Never** restructure folder taxonomy (rename a top-level folder, etc.).
- **Never** modify `.obsidian/`.
- **Always** read before editing.
- **Always** add a CHANGELOG entry for `add-project`, `archive-project`, `normalize-frontmatter`.
- `health-check` is read-only — no CHANGELOG entry needed.

## QA Checklist

- [ ] Pre-flight confirmation completed if >5 files affected.
- [ ] No deletions.
- [ ] CHANGELOG entry written when applicable.
- [ ] Wikilinks preserved (or breakage reported).
- [ ] Eduardo notified of any `_MEMORY.md` edit suggestions.

## Do Not

- Process inbox content.
- Log decisions (use `ckis-decision-log`).
- Run the weekly review (use `ckis-weekly-review` or `weekly-review`).
- Touch project content beyond `_overview.md` scaffolding.
