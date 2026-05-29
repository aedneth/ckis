# CHANGELOG

All notable changes to the CKIS template are documented here.
Format: `[vX.Y.Z] YYYY-MM-DD — Description`

---

## v2.3.24 — System Layer Updates (2026-05-28)

### New Skills
- `ckis-qc-pass` — 13-point vault quality control checklist (conventions, YAML, wikilinks, git, CHANGELOG)
- `yaml-graph-audit` v1.1.0 — YAML frontmatter scanner + auto-fixer; now supports `type: archive-note`
- `workflow-extend-pattern-a` — Extend stub workflows to full Pattern A standard (12-15 files)
- `instagram-capture-process` — Full pipeline for processing Instagram saves (naming → frontmatter → index → MOC)

### New System Files
- `.claude/GUARDRAILS.md` — 5-section guardrails framework loaded on every session (Safety Rails, File Operations, Git Operations, Knowledge System Integrity, Agent Behavior)

### YAML Standard Extension
- `08-note-templates-and-frontmatter.md` — `type: archive-note` added to the type enum
  - `archive-note`: retrospective documentation created *about* a past project (distinct from `type: project` + `status: archived`, which are working files moved to archive)

### Skipped (v2.3.6–v2.3.23)
Intermediate versions were private vault knowledge processing sessions (G5 sprint, GATE YC, GATE PI) — no system-layer changes relevant to the public template.

---

## [v2.3.5] 2026-05-19 — Compact Bridge Documentation + Skills Usage Guide Update

**Goal:** `20-ckis-skills-usage-guide.md` now fully documents the compact routing layer — what the skills read, how compacts flow to Dev Brain, and how to diagnose when context is missing.

### Changed
- `20-ckis-skills-usage-guide.md` — `daily brief` step 2 now explicitly references `01-daily/logs/compacts/` as the source (NOT raw session logs in `01-daily/logs/`)
- `20-ckis-skills-usage-guide.md` — added troubleshooting: `daily brief` shows empty context → diagnostic for missing compacts directory
- `20-ckis-skills-usage-guide.md` — added troubleshooting: `project context` compact lookup commands
- `20-ckis-skills-usage-guide.md` — added compact routing row to Section 11 automation table (Stop hook catch-all + UserPromptSubmit eager `/compact`)

---

## [v2.3.4] 2026-05-18 — Compact Bridge + Second Brain Registration + Graph Connectivity

**Goal:** Every `/compact` command is now a first-class knowledge artifact — autonomously routed to Dev Brain and wikilinked for graph connectivity.

### Added
- `compact-routing.sh` now injects `[[wiki/<project>]] · [[sessions/index]]` footer into Dev Brain copies — all compact files become connected nodes in the Obsidian graph
- Second Brain vault registered as `second-brain` project in Dev Brain — CKIS conversations now compound alongside code project sessions
- `second-brain/.brain/scripts/log-compact.sh` — UserPromptSubmit eager extractor for vault sessions (mirrors korvex pattern)
- `second-brain/.brain/config.sh` — project config for vault `.brain/` layer
- `second-brain/.brain/scripts/lib/compact-routing.sh` — shared routing lib for vault compact bridge
- `UserPromptSubmit` hook added to vault `.claude/settings.json` — fires `log-compact.sh` on every `/compact`
- `Dev Brain/sessions/compacts/second-brain/` — new project slot for vault session compacts

### Changed
- `vault-session-stop.sh` — upgraded: uses `textify` jq function (handles string or array content), proper frontmatter, Dev Brain routing (catch-all path)
- `Dev Brain/projects.json` — added `second-brain` entry with `graph_json: null` (no code graph for vault)

### Fixed
- Backfilled 119 existing korvex compact files with wikilinks footer → graph was fully disconnected before

---

## [v2.3.3] 2026-05-18 — README Rewrite + Dev Brain raw/ Removal

**Goal:** Dev Brain is fully autonomous — no human drops files there. Remove `raw/` and all references; rewrite human-facing README.

### Added
- `Dev Brain/README.md` — comprehensive human-readable rewrite explaining three-layer stack, folder structure, query patterns, and "what NOT to do"
- `Dev Brain/sessions/compacts/<project>/` — documented in AGENT_README as queryable cross-project compact layer

### Removed
- `Dev Brain/raw/` folder and all references (AGENT_README, CLAUDE.md, CKIS docs, per-project-second-brain.md) — philosophically wrong for an autonomous system

### Changed
- `~/.claude/CLAUDE.md` — added `compacts/` to "Do NOT write" list; removed `raw/` reference

---

## [v2.3.2] 2026-05-18 — CKIS Rename: Custom → Central

**Goal:** Full name is now "Central Knowledge and Intelligence System." Acronym CKIS unchanged.

### Changed
- Updated all vault files and public template: every occurrence of "Custom" → "Central"
- README header and description updated to reflect the new name

---

## [v2.3.1] 2026-05-17 — Public Repo Launch

**Goal:** CKIS public repo launched at `github.com/aedneth/ckis`.

### Added
- Security audit: all personal project names, paths, and locale references replaced with generic placeholders across 20+ files
- Public-safe CHANGELOG, README, and skill template files

---

## [v2.3.0] 2026-05-17 — Plug-and-Play Template + 3D Graph + Apache 2.0

**Goal:** Make the public template truly plug-and-play — any developer should be able to clone and immediately have a functioning agentic knowledge system.

### Added
- Full folder skeleton with `CONVENTION.md` in every folder — purpose, naming, frontmatter, anti-patterns
- `00-inbox/` subcarpetas: `quick-capture/`, `url-dumps/`, `youtube-queue/`, `social-media-queue/`, `convert-queue/`
- `02-projects/_TEMPLATE/` — starter folder with `_overview.md`, `clients/`, `processes/`
- `03-knowledge/` subfolders: `frameworks/`, `guides/`, `literature-notes/`, `maps-of-content/`, `patterns/`
- `04-resources/` subfolders with social-captures CONVENTION.md for 5 platforms (LinkedIn, X, Instagram, TikTok, YouTube Shorts)
- `05-areas/` seed notes: personal-brand, finance (personal+business), health-fitness, learning, relationships, wellbeing
- `06-goals/` subfolders: `annual/`, `quarterly/`, `monthly/`, `weekly/`
- `07-people/` subfolders: `clients/`, `mentors/`, `network/`
- `08-templates/`: permanent-note, literature-note, project-overview, weekly-review, goal-quarterly, session-log
- `00-systems/ckis/21-obsidian-3d-graph-guide.md` — plugin install, settings, color scheme, growth metrics, troubleshooting
- `00-systems/ckis/22-optional-agentmemory-integration.md` — evaluation of agentmemory; reference-only verdict
- `docs/images/` — two 3D graph screenshots (connected + dispersed) for README and file 21
- `00-systems/workflows/CONVENTION.md` — workflow documentation convention
- README: complete rewrite with hero screenshots, evolution story, architecture diagram, skill tables, agent habits section, 3D graph section, related tools table

### Changed
- License: MIT → Apache 2.0 (patent grant + "CKIS" trademark protection; maximizes adoption)
- README: product-first structure, screenshots at top, full skill catalog

### Fixed
- Security audit: all personal project names, university, locale references replaced with generic placeholders across 20 files — repo is now safe for public cloning

---

## [v2.2.0] 2026-05-17 — Dev Brain Autonomous Architecture

**CKIS System:** Dev Brain autonomous pipeline — any agent can now query [OWNER]'s codebases.

### Added
- `AGENT_README.md` in Dev Brain — agent entry point with query patterns and registered project table
- `projects.json` — central registry of connected projects (slug, repo_root, graph_json, sessions_dir)
- `sessions/index.md` — append-only session feed across all projects
- `scripts/query-all.sh` — cross-project query via `graphify merge-graphs`
- `scripts/register-project.sh` — upserts project in registry (idempotent)
- `scripts/build-wiki-page.sh` — builds `wiki/<slug>.md` digest from GRAPH_REPORT + sessions
- Per-project `register-to-dev-brain.sh` — wrapper to register new repos in Dev Brain

### Changed
- `log-session.sh` — now appends to Dev Brain `sessions/index.md` + writes per-session pointer file
- `sync-obsidian-graph.sh` — now calls `build-wiki-page.sh` after Obsidian export

### Fixed
- `~/.claude/CLAUDE.md` — corrected "Dev Brain RETIRED" error from Phase 2; proper agent query docs restored

---

## [v2.1.0] 2026-05-17 — Memory System Audit + Fixes

### Added
- `vault-session-stop.sh` — complete rewrite; reads JSONL transcript via `jq` to extract last assistant message as automatic session summary
- `assemble-vault-context.sh` — profile update protocol injected at every SessionStart
- `19-agent-habits-guide.md` — structured daily/weekly habits guide for terminal use with agents

### Changed
- Cron 5 (memory-consolidation) extended — now reads `.brain/sessions/` from coding projects AND updates both `_MEMORY.md` AND `_ACTIVE-PROJECTS.md`
- `~/.claude/settings.json` — removed SessionEnd hook (wiki-brain) to avoid Dev Brain confusion; per-project Stop hooks own session indexing

---

## [v2.0.0] 2026-05-17 — CKIS v2: Rename + Multi-Agent Architecture

### Breaking
- **PERMANENT RENAME**: "Custom Knowledge & Intelligence System" → "Central Knowledge & Intelligence System". Acronym CKIS unchanged. All vault files updated.

### Added
- `17-crons-architecture.md` — 5-cron system architecture spec
- `18-memory-architecture.md` — three-layer memory stack documentation (auto-memory + vault hooks + Dev Brain)
- 18 Matt Pocock skills installed (`~/.claude/skills/mattpocock/`)
- 4 crons created: vault-git-sync, crm-sort, weekly-review, memory-consolidation

### Changed
- Multi-agent orchestration architecture: Opus 4.7 as orchestrator, Sonnet 4.6 as executor

---

## [v1.0.0] 2026-05-03 — Initial Architecture

- Three-layer memory stack designed and documented
- Per-project `.brain/` piloted on [your-project] and [client-site]
- Graphify v0.6.7 selected (MIT license, Obsidian-native)
- 5 Claude Code hooks wired in all coding repos
- Dev Brain vault created with 376 code-graph nodes across 2 projects
