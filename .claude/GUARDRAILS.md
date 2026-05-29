# CKIS Guardrails — Claude Code

> These are hard behavioral rules for Claude Code when operating in this vault.
> Add new rules whenever Claude Code misbehaves. Connected to CLAUDE.md.
> Framework source: agentic.james guardrails.md methodology.

━━━

## Safety Rails

- **Never delete files.** Move to `09-archive/` instead. `rm` is banned in this vault. No exceptions.
- **Never modify `.obsidian/`** without an explicit instruction from [OWNER] in the current session.
- **Never paste secrets into vault files.** No `.env` content, API keys, OAuth tokens, passwords, or credentials — in any file.
- **Never restructure the vault folder taxonomy** (rename folders, move entire sections, change the 00–09 numbering scheme) without explicit confirmation from [OWNER].
- **No chat-only conclusions.** Insights and decisions don't count as captured until they exist as a vault file. Always write it down.

━━━

## File Operations

- **Read before edit.** Every file must be read before it is modified. Never assume current content — read it.
- **Preserve YAML frontmatter.** Never strip it. Always preserve `created`. Always update `modified` when the body changes.
- **Preserve wikilinks and aliases.** Never rename a note without updating all `[[wikilinks]]` that point to it. Never delete an alias silently.
- **Minimum-touch edits.** Only change what the task requires. Do not reformat adjacent content, normalize prose style, or "improve" sections not part of the request.
- **Match the captured language.** Spanish notes stay in Spanish. English notes stay in English. Never translate body content unless [OWNER] explicitly requests it.
- **INBOX only for new captures.** New material always enters `00-inbox/` first. Never route a capture directly to a permanent folder.
- **`processing: index-only` is immutable.** Never remove this frontmatter field from a social-capture note. Promotion to permanent note is a manual decision by [OWNER].
- **Backups before overwriting CKIS or system files.** Put backups in `.claude/backups/` before editing any file under `00-systems/ckis/` or `.claude/`.

━━━

## Git Operations

- **Never run `git push --force` to main/master.** Warn [OWNER] if requested.
- **Never skip hooks** (`--no-verify`, `--no-gpg-sign`) unless [OWNER] explicitly requests it in the session.
- **Never amend a previous commit** after a pre-commit hook failure — create a new commit instead.
- **Stage specific files.** Prefer `git add <file>` over `git add -A` or `git add .` to avoid accidentally committing secrets or binaries.
- **Never commit without being asked.** Commit only when [OWNER] explicitly requests it.

━━━

## Knowledge System Integrity

- **Update the CKIS CHANGELOG** (`00-systems/ckis/CHANGELOG.md`) after any non-trivial CKIS architecture change.
- **Do not duplicate CKIS content.** Reference files by path instead of copying their content across files. Single source of truth.
- **Index entries are mandatory.** Every new social-capture note must have a corresponding row in `instagram-saved-posts-index.md` (or the relevant index) before the session closes.
- **7-day inbox rule.** Flag inbox items that have been sitting unprocessed for 7+ days — surface to [OWNER] rather than silently deleting or auto-processing.
- **CKIS rule conflicts.** If `.claude/CLAUDE.md` conflicts with `CLAUDE.md` (root), the more specific or more recently updated file wins. Surface the conflict to [OWNER] and resolve it via a CHANGELOG entry — never silently pick one.
- **Obsidian is the source of truth.** Code project files, chat conclusions, and session notes are secondary. The vault markdown files are canonical.

━━━

## Agent Behavior

- **Ask before destructive or restructuring actions.** When in doubt, surface the question to [OWNER] rather than acting unilaterally.
- **State assumptions before bulk operations.** For multi-step vault workflows (process-inbox, weekly-review, ckis-vault-maintenance), state a brief plan with success criteria before executing.
- **Prefer surgical reads.** Use targeted file reads (specific path + line range) over broad vault scans. Avoid reading the entire vault to answer a focused question.
- **Session log after significant work.** After non-trivial vault operations, log a session summary to `01-daily/logs/` with what was created, moved, or changed.
- **Always enter plan mode first.** Before executing any non-trivial multi-step task in a coding project, switch to plan mode and confirm the plan before execution.
- **`/rewind` before corrections.** When Claude makes a mistake mid-session, rewind to the prior good state and re-prompt with the learned insight — don't pollute context with failed attempts and inline corrections.

━━━

## Claude Code Session Hygiene

- **Context dumb zone at 30-40%.** Performance degrades measurably at ~40% context utilization; experienced use targets <30%. Proactively run `/compact <hint>` before hitting 40% — do not wait for auto-compact.
- **Subagents absorb exploratory work.** Intermediate file reads, greps, and research tasks go to a child/subagent context. Only the conclusion returns to the parent context to keep it under threshold.
- **CLAUDE.md 200-line cap.** Keep any `CLAUDE.md` file under 200 lines (60 lines ideal). When it grows beyond that, split domain-specific rules into `.claude/rules/<domain>.md` files that load lazily.
- **Vertical slices over horizontal phases.** When implementing features across a codebase, implement each feature fully (DB → service → UI) before starting the next — never phase by layer. Horizontal phasing delays end-to-end feedback until the final phase.
- **Skill Gotchas section.** Every skill file (`.claude/skills/*/SKILL.md`, `.claude/ckis-skills/*/skill.md`) should include a `## Gotchas` section documenting discovered failure modes for that skill.
