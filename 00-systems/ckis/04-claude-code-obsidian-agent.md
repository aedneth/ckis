---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, claude-code, agent-rules]
status: active
related: ["[[00-ckis-master-context]]", "[[03-capture-processing-retrieval-workflow]]", "[[10-claude-project-instructions]]"]
---

# 04 — Claude Code · Obsidian Agent Rules

> Operational rules for any Claude Code instance acting on this vault. These rules sit on top of `.claude/CLAUDE.md` (which holds session protocol + skill command shortcuts) and override it on conflict.

━━━

## 1. Read Before Editing

- Always `Read` a file before `Edit` or `Write`. Never edit blind.
- For larger files, read the relevant region first; do not assume the rest.
- For `_overview.md` files: read the **first 15 lines** to grab frontmatter `modified` date before deciding whether to refresh.
- For `_MEMORY.md`: read in full at the start of every non-trivial session.

## 2. Confirmation Boundaries

Confirm before:

- Deleting any file (always — no exceptions).
- Moving or renaming any existing note, folder, or `_overview.md`.
- Restructuring folders or changing the vault taxonomy.
- Modifying `.obsidian/` settings.
- Bulk operations affecting more than ~10 files.
- Force-pushing, hard-resetting, or rewriting git history.

Do not confirm before:

- Reading any file.
- Creating a new note in `00-inbox/` (capture path).
- Updating `_overview.md` Recent progress / Status / Blockers via `sync overviews`.
- Routine processing as part of the `process inbox` skill (move + frontmatter normalize), provided the routing rules are followed.

## 3. YAML Frontmatter Preservation

- Never strip frontmatter when editing.
- Preserve `created`. Update `modified` to today (`YYYY-MM-DD`).
- Preserve unknown fields rather than deleting them — they may be plugin-specific.
- For new notes: scaffold the standard frontmatter from `[[08-note-templates-and-frontmatter]]`.
- Tags inside YAML are kebab-case strings without leading `#`.

## 4. Backlinks & Wikilinks

- Use `[[wikilinks]]` (Obsidian convention), never raw paths in body text.
- Before renaming a note, search the vault for inbound links and update them.
- When inserting wikilinks, prefer the **note's display name**, not the path.
- Do not break or orphan existing links to satisfy a refactor — confirm first.

## 5. Note Creation Discipline

- No empty shells. A new file gets created only when it has real content.
- One idea per permanent note. If a note grows two distinct ideas, split it.
- Use the matching template under `08-templates/` if one exists; otherwise scaffold from `[[08-note-templates-and-frontmatter]]`.
- Filenames: kebab-case, descriptive, no hashes, no timestamps (except daily notes).

## 6. Search Strategy

- Default to surgical search: Grep with a tight pattern, scoped to the most likely folder.
- Use Glob to enumerate candidates, then Read selectively.
- Avoid full-vault `find` or recursive reads — the laptop is memory-constrained and the vault is large enough to make naive scans expensive.
- For change detection, prefer `git log --name-only --since="<date>" -- <path>` over filesystem `mtime` (modified date in frontmatter must match git history).

## 7. Backups Before Overwriting

- Before overwriting a CKIS file or any other system file, copy the current version to `.claude/backups/ckis-migration/<filename>.bak` (or a similarly named subfolder for non-CKIS overwrites).
- Backups are commit-tracked too — running `git log` against `.claude/backups/` recovers older versions.
- Never delete a backup. Stale backups are preferable to lost work.

## 8. Validation

After any non-trivial set of writes:

1. Re-read at least one written file to confirm the content landed correctly.
2. Run `git status` to confirm only the intended files changed.
3. If frontmatter was touched, eyeball the YAML for syntax (no smart quotes, no missing `---`).
4. Surface any side-effects in the response (e.g., "I also updated `MOC-AI-Agents.md` to reflect the new note").

## 9. Change Logs

- Significant CKIS changes get a new entry in `00-system/ckis/CHANGELOG.md`.
- Each entry: date, files created, files updated, sources used, open questions, next recommended action.
- Routine inbox processing is logged in `01-daily/logs/<date>.md`, not in CKIS CHANGELOG.

## 10. Token Efficiency

- Skills > MCPs (~60 vs ~20,000 token baseline).
- Surgical `@file` references over "process the whole vault."
- Spawn parallel subagents (one per project) for `sync overviews` instead of serial scans.
- Stop pushing context when degraded — start a fresh session and load `_MEMORY.md` plus the relevant `_overview.md`.

## 11. Bilingual Behavior

- Detect the dominant language of a note before responding inside it.
- Process and respond in that language.
- Vault-level meta-files (CKIS, skill descriptions, frontmatter spec) are in English by default. Body content stays in the captured language.

## 12. Forbidden Actions

- Hard-deleting any file (`rm`) without explicit confirmation.
- Modifying `.obsidian/` settings without explicit instruction.
- Mass-renaming notes.
- Reorganizing folders without confirmation.
- Storing secrets in any file in the vault.
- Force-pushing or rewriting git history without explicit instruction.
- Skipping `sync overviews` and writing directly into `_overview.md` Recent progress without reading the source files that drove the change.

## 13. Session Protocol Quick-Ref

(See `.claude/CLAUDE.md` for the canonical session protocol.)

1. Read `.claude/CLAUDE.md`.
2. Read `00-inbox/_MEMORY.md`.
3. Read `00-inbox/_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`.
4. Read `01-daily/logs/` for recent context.
5. Search the vault for relevant existing notes before answering.
6. Log session summary to `01-daily/logs/` after significant work.
