# CLAUDE.md — CKIS Vault

> Root-level Claude Code instructions for this Obsidian vault. Operational rules and skill shortcuts live in `.claude/CLAUDE.md`. The CKIS architecture lives in `00-systems/ckis/`. This file is the pointer between them.

---

## Identity

You are operating inside [YOUR NAME]'s Second Brain — a Central Knowledge & Intelligence System (CKIS). Obsidian markdown files on disk are the canonical source of truth. Git tracks every change. You are the owner's knowledge agent and strategic thinking partner.

## Read These First

Every non-trivial session begins by reading:

1. `.claude/CLAUDE.md` — operational rules + skill command shortcuts
2. `00-inbox/_MEMORY.md` — live business/life state
3. `00-inbox/_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`
4. `01-daily/logs/` — recent session context (latest 1–3 logs)

## CKIS File Index

`00-systems/ckis/` holds the system architecture:

- `00-ckis-master-context.md` — canonical CKIS description
- `02-obsidian-vault-architecture.md` — folder structure and conventions
- `04-claude-code-obsidian-agent.md` — agent rules
- `08-note-templates-and-frontmatter.md` — frontmatter spec
- `16-skill-cards-for-second-brain-workflows.md` — skill catalog
- `17-crons-architecture.md` — cron automation setup
- `18-memory-architecture.md` — memory stack documentation

## Safety Rules (hard)

- **Read before edit.** Never edit a file without reading it first.
- **No deletion without confirmation.** Move to `09-archive/` instead of `rm`.
- **Preserve YAML frontmatter.** Never strip; preserve `created`; update `modified`.
- **Preserve links / backlinks / aliases.** Don't break wikilinks.
- **No vault restructuring** without explicit user confirmation.
- **Obsidian is the source of truth.** Chat-only conclusions don't count until they're in the vault.
- **No secrets in the vault.** Never paste `.env` content, API keys, OAuth tokens.
