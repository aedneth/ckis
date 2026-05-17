# CHANGELOG

All notable changes to the CKIS template are documented here.
Format: `[vX.Y.Z] YYYY-MM-DD — Description`

---

## [v2.2.0] 2026-05-17 — Dev Brain Autonomous Architecture

**CKIS System:** Dev Brain autonomous pipeline — any agent can now query Eduardo's codebases.

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
- Per-project `.brain/` piloted on korvex-web and brisas-del-golfo
- Graphify v0.6.7 selected (MIT license, Obsidian-native)
- 5 Claude Code hooks wired in all coding repos
- Dev Brain vault created with 376 code-graph nodes across 2 projects
