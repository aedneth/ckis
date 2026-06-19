---
type: system
created: 2026-05-02
modified: 2026-06-18
tags: [ckis, vault, architecture]
status: active
related: ["[[00-ckis-master-context]]", "[[07-projects-areas-resources-archives-map]]", "[[08-note-templates-and-frontmatter]]"]
---

# 02 — Obsidian Vault Architecture

> Confirmed structure as it exists on disk in `~/Documents/Second Brain/`. Folder taxonomy and naming rules are **locked** — do not reorganize without explicit confirmation from Eduardo.

━━━

## 1. Vault Root

`~/Documents/Second Brain/`

## 2. Folder Tree (confirmed)

```
~/Documents/Second Brain/
├── 00-inbox/                    # Capture zone — everything enters here first
│   ├── _PROFILE.md              # Who Eduardo is
│   ├── _INTERESTS.md            # Topics and priorities
│   ├── _ACTIVE-PROJECTS.md      # Current projects roster
│   ├── _MEMORY.md               # Live business state (read every session)
│   ├── quick-capture/
│   ├── url-dumps/
│   ├── youtube-queue/
│   ├── social-media-queue/
│   └── convert-queue/
│       └── processed/           # Originals after .pdf/.docx conversion
├── 01-daily/                    # YYYY-MM-DD.md daily notes
│   └── logs/                    # Claude Code session logs
├── 02-projects/                 # Active projects
│   ├── [your-project]/
│   ├── [client-site]/
│   ├── [archived-project]/
│   ├── university/
│   ├── personal-brand/
│   └── (hidroplus/ — referenced in extract; verify)
├── 03-knowledge/                # Processed knowledge
│   ├── permanent-notes/         # Atomic, evergreen insights
│   ├── literature-notes/        # Source-based notes
│   ├── maps-of-content/         # MOC-Topic-Name.md
│   ├── frameworks/              # Mental models
│   ├── guides/                  # Master guides, ops docs
│   └── patterns/                # AI-detected patterns
├── 04-resources/                # Reference material
│   ├── articles/
│   ├── books/
│   ├── courses/
│   ├── social-captures/
│   ├── tools/
│   └── youtube/
├── 05-areas/                    # Life areas (one .md per area)
│   ├── health-fitness.md
│   ├── finance-personal.md
│   ├── finance-business.md
│   ├── relationships.md
│   ├── learning.md
│   └── wellbeing.md
├── 06-goals/                    # Unified goal system
│   ├── 2026-annual.md
│   ├── monthly/
│   └── weekly/
├── 07-people/                   # Relationship intelligence
│   ├── clients/
│   ├── mentors/
│   └── network/
├── 08-templates/                # Note templates
│   └── client-note.md
├── 09-archive/                  # Completed or inactive
├── 00-system/                   # CKIS system files (this folder)
│   ├── CKIS/
│   │   ├── 00-ckis-master-context.md
│   │   ├── 01-ckis-user-profile-and-operating-context.md
│   │   └── ...
│   └── sops/                    # SOPs — executable, repeatable procedures (_index.md + _convention.md)
├── .claude/
│   ├── CLAUDE.md                # Master instructions + command shortcuts
│   ├── ckis-skills/             # Vault-specific CKIS workflow skills (25 skills)
│   ├── roles/
│   └── backups/
│       └── ckis-migration/      # Backups taken before CKIS regeneration
│   # NOTE: .claude/skills/ and .agents/ must NOT exist here — see [[16-skill-cards-for-second-brain-workflows]] §6
│   # Global / downloaded skills live in ~/.claude/skills/ (outside the vault)
└── .obsidian/                   # Obsidian app config — DO NOT MODIFY
```

## 3. Folder Conventions

- Folders use `kebab-case` with a numeric prefix (`00-inbox`, `01-daily`, …, `09-archive`). The numeric prefix forces deterministic ordering.
- One exception: `00-system/ckis/` uses `_System` because it holds system meta-files about CKIS itself, not vault content. Marked as inferred — see `[[15-source-map-and-generation-audit]]` open question.
- Subfolders inside content folders (`02-projects/[your-project]/`, `07-people/clients/`) are also kebab-case.

## 4. File Naming

| Kind | Convention | Example |
|---|---|---|
| Daily note | `YYYY-MM-DD.md` | `2026-05-02.md` |
| MOC | `MOC-Topic-Name.md` | `MOC-AI-Agents.md` |
| Project meta | `_overview.md` (underscore prefix) | `02-projects/[your-project]/_overview.md` |
| System file | `_NAME.md` (underscore + caps) | `_PROFILE.md`, `_MEMORY.md` |
| Folder routing table | `_CONVENTION.md` (underscore + caps, one per folder) | `03-knowledge/_CONVENTION.md` |
| Permanent note | `descriptive-name.md` (kebab-case, no hashes) | `jackson-steele-alter-ego.md` |
| Literature note | `source-or-topic-name.md` | `lex-fridman-ep-300.md` |
| Person | `firstname-lastname.md` | `juan-perez.md` |
| CKIS system file | `NN-kebab-name.md` | `04-claude-code-obsidian-agent.md` |

Hard rules:

- No Notion hash suffixes (`Untitled abc123.md`). Strip on import.
- No timestamps in filenames except daily notes.
- No empty shell files. A file exists only when it has real content.

## 5. Frontmatter Standard

Every note has YAML frontmatter:

```yaml
---
type: [permanent-note | literature-note | project | daily | resource | capture | area | goal | person | system | sop]
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: ""
status: [inbox | processing | active | complete | archived]
related: []
---
```

Notes:

- `modified` should reflect the **git commit date**, not filesystem `mtime`. Use `git log` for diff detection.
- `system` is added to the `type` enum for CKIS files in `00-system/ckis/`. Other types remain as conversation-confirmed.
- `related` is an array of wikilink strings (not raw paths).
- `tags` are kebab-case; no spaces; no leading `#` inside the YAML array.

## 6. Tags

- Format: `#kebab-case` in note body, `kebab-case` (no `#`) in frontmatter `tags:` array.
- Tag families in active use: `#[your-project]`, `#your-project-tag`, `#[archived-project]`, `#university`, `#ai-agents`, `#vibe-coding`, `#claude-code`, `#automation`, `#looksmaxxing`, `#hormone-optimization`, `#viral-scripts`.
- Avoid creating new tag families lightly. Prefer reusing an existing one.

## 7. Links

- `[[wikilinks]]` — preferred over folder paths. Notes can exist in multiple contexts via links.
- Links over hierarchy: a note's *folder* answers "where does it live"; its *links* answer "what does it relate to."
- Maintain backlinks by always linking the related note name (Obsidian indexes the rest automatically).
- Do not break existing links. If renaming, use Obsidian's rename-with-link-update or update wikilinks manually first.

## 8. Note Types

| Type | Lives in | Purpose |
|---|---|---|
| `permanent-note` | `03-knowledge/permanent-notes/` | Atomic, evergreen idea — one concept per file |
| `literature-note` | `03-knowledge/literature-notes/` or `04-resources/<sub>/` | Source-based notes (book, article, video) |
| `project` | `02-projects/<project>/` | Project-state files including `_overview.md` |
| `daily` | `01-daily/` | Daily notes |
| `resource` | `04-resources/<sub>/` | Reference material |
| `capture` | `00-inbox/` | Raw, unprocessed captures |
| `area` | `05-areas/` | Life-area summary files (append-only) |
| `goal` | `06-goals/` | Annual / monthly / weekly goal notes |
| `person` | `07-people/<sub>/` | Relationship notes |
| `system` | `00-system/ckis/` | CKIS architecture and operating rules |
| `sop` | `00-systems/sops/` or `<project>/processes/` | Executable, repeatable step-by-step procedure (SOP) |

## 9. Dashboards & Indexes

- `00-inbox/_MEMORY.md` — live state, read first every session.
- `00-inbox/_ACTIVE-PROJECTS.md` — project roster.
- `02-projects/<project>/_overview.md` — per-project canonical state.
- `03-knowledge/maps-of-content/MOC-*.md` — topic indexes; serve as graph hub-nodes.
- `_CONVENTION.md` (one per folder/subfolder, **every** folder has one) — the universal routing table: purpose, internal structure tree, what goes/doesn't go here, naming rules, related folders. Read this first when an agent enters a folder it hasn't worked in recently — it answers "what's here and where do I look" without needing to read the folder's contents.
- This file (`02-obsidian-vault-architecture.md`) is the architecture index.

**Note:** keep `_CONVENTION.md` casing consistent vault-wide (uppercase). A mixed-case vault is harmless to Obsidian (link resolution is case-insensitive) but breaks any script/skill that checks for the file by exact name — `ckis-qc-pass` Check 1 now does this check dynamically across the whole vault, excluding tooling/scratch dirs and leaf folders that already have an `_overview.md`.

## 10. Archive Rules

- Move (do not delete) completed or inactive items to `09-archive/`.
- Preserve folder structure under `09-archive/` to ease restoration.
- For projects: archive the entire project subfolder, not individual files.
- `convert-queue/processed/` holds originals of converted PDFs/DOCX — also a kind of archive.

## 11. What Lives Outside the Vault

- Transaction-level financial accounting (spreadsheet / Wave).
- Secrets, API keys, OAuth tokens (env files outside the vault, gitignored).
- Real-time communication (WhatsApp, email).
- Code repositories for actual projects (`~/[your-project]/`, `~/[client-site]/`, etc.) — these reference the vault but are stored separately.
