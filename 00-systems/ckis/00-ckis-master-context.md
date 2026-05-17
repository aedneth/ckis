---
type: system
created: 2026-05-02
modified: 2026-05-04
tags: [ckis, system, master-context]
status: active
related: ["[[01-ckis-user-profile-and-operating-context]]", "[[02-obsidian-vault-architecture]]"]
---

# 00 — CKIS Master Context

> Canonical, single-source description of Eduardo's **Central Knowledge & Intelligence System (CKIS)** — also referred to verbatim as "My Second Brain" or "Personal Vault." All other CKIS files extend or reference this one. If a fact in another CKIS file contradicts this one, this file wins until it is updated.

━━━

## 1. Identity

CKIS is [OWNER]'s AI-powered personal knowledge and business operating system. Acceptable verbatim names: **CKIS**, **My Second Brain**, **Personal Vault**, "the vault." CKIS is **not** a note-taking app — it is a self-evolving system that captures, processes, synthesizes, and acts on knowledge across professional work (Korvex), university (UGB), and personal development.

Korvex is **not** a "web agency." Eduardo's vision for Korvex goes beyond that simplicity — treat it as a software / digitalization startup. Do not introduce "agency" framing in new CKIS content.

Stored as: plain markdown files on disk, under Git, opened with Obsidian.

Operated by: Claude Code (primary execution agent), Claude Chat (planning/synthesis), ChatGPT (secondary research and writing review), Eduardo (final decision-maker).

## 2. Purpose

CKIS exists to:

- Eliminate cognitive load from organizing, filing, and connecting information.
- Maintain persistent context across Claude Code sessions so Eduardo never re-explains his projects.
- Keep project overviews automatically current as new files are added.
- Process raw captures (notes, docs, URLs, videos, social posts) into structured, linked knowledge.
- Surface patterns, connections, and insights Eduardo would miss manually.
- Serve as the single source of truth for Korvex business state, university progress, and personal goals.

## 3. Scope

In scope:

- Knowledge capture, processing, and synthesis.
- Project state for Korvex, Brisas del Golfo, University, Personal Brand. Tourdy and HidroPlus archived (`09-archive/`).
- Decision logs, weekly reviews, monthly consolidations.
- Cross-model handoff (Claude ↔ ChatGPT) with Obsidian as canonical store.
- Reusable Claude Code skills for the workflows above.

Out of scope:

- Transaction-level financial accounting (lives in spreadsheet / Wave; only summaries enter the vault).
- Real-time team collaboration (single-user system).
- Anything that needs a database — markdown files only.
- Secrets, API keys, credentials, OAuth tokens — never stored in the vault.

## 4. High-level Architecture

```
                     ┌──────────────────────────────┐
                     │       Eduardo (operator)     │
                     └──────────────┬───────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
       ┌──────▼──────┐       ┌──────▼──────┐       ┌──────▼──────┐
       │ Claude Code │       │ Claude Chat │       │   ChatGPT   │
       │ (execution) │       │ (planning)  │       │ (research)  │
       └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
              │                     │                     │
              ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Layer 3 · CKIS Vault (Strategic) — Git-tracked                     │
│  ~/Documents/Second Brain/                                          │
│  00-inbox · 01-daily · 02-projects · 03-knowledge · 04-resources    │
│  05-areas · 06-goals · 07-people · 08-templates · 09-archive        │
│  00-system/ckis/                                                    │
└───────────────────────────┬─────────────────────────────────────────┘
                            │  graph-report.md (auto, every commit)
                            │  _overview.md (curated, sync-overviews)
┌───────────────────────────▼─────────────────────────────────────────┐
│  Layer 2 · Dev Brain (Engineering Knowledge)                        │
│  ~/Documents/Dev Brain/                                             │
│  code-graph/<slug>/ · wiki/ · raw/ · timeline/                      │
│  Separate Obsidian vault — 3D Graph plugin — wiki-brain skill       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │  _CONTEXT.md injected at SessionStart
                            │  decisions/ · bugs/ (committed)
┌───────────────────────────▼─────────────────────────────────────────┐
│  Layer 1 · .brain/ (Per-Repo Tactical) — inside each coding repo    │
│  sessions/ · decisions/ · bugs/ · graph/ · scripts/                 │
│  Claude Code hooks: SessionStart · Stop · PostToolUse · UserPrompt  │
└─────────────────────────────────────────────────────────────────────┘
```

The CKIS vault is the **canonical source of truth** for strategic knowledge. Everything generated by Claude Chat or ChatGPT must be written back into the vault to count as "real." Layer 1 (`.brain/`) and Layer 2 (Dev Brain) feed upward automatically — the agent decides what to escalate.

## 5. Source of Truth Hierarchy

1. **Files on disk in the Obsidian vault** (highest authority).
2. **Git history of the vault** (truth about *when* something changed, including `modified` dates derived from `git log`).
3. **`00-inbox/_MEMORY.md`** — live business state, read at the start of every session.
4. **`02-projects/<project>/_overview.md`** — per-project canonical state, append-only progress.
5. **CKIS files in `00-system/ckis/`** — architecture and operating rules (this file and its peers).
6. Chat transcripts (Claude.ai, ChatGPT). Authoritative only until the relevant insight is written to the vault.

## 6. Platform Roles

| System | Role |
|---|---|
| Claude Code | Primary execution agent — reads/writes vault, runs skills, processes inbox, updates overviews, commits to git |
| Claude Chat (Sonnet/Opus) | Planning, architecture, prompt design, strategic decisions — outputs fed back to vault manually |
| ChatGPT | Secondary research, exploration, writing review — outputs extracted into vault, never canonical |
| Obsidian (CKIS vault) | Strategic storage and visualization — plain `.md` files, graph view, plugins |
| Obsidian (Dev Brain vault) | Engineering code graph + wiki — separate vault at `~/Documents/Dev Brain/`, 3D Graph plugin |
| Graphify (`graphifyy==0.6.7`) | Code graph indexer — runs on `git commit`, writes `graph.json` + `GRAPH_REPORT.md` per repo |
| wiki-brain skill | Compounding engineering knowledge — Claude writes `wiki/` in Dev Brain from `raw/` sources |
| Git | Version control + change-detection backbone (sync-overviews uses `git log` diffs) |
| Gemini Flash | Cheap processing for simple tasks (YouTube transcripts, classification) |

## 7. Operating Modes

- **Capture mode** — raw input lands in `00-inbox/`. No organizing in the moment.
- **Processing mode** — `process inbox` skill normalizes, classifies, links, and routes inbox items.
- **Synthesis mode** — `synthesize [topic]` and `knowledge-synthesis` skill compile cross-vault knowledge into MOCs and permanent notes.
- **Decision mode** — decision logs (see `06-decision-execution-and-review-protocol.md`).
- **Review mode** — daily brief, weekly review, monthly consolidation.
- **Maintenance mode** — `sync overviews`, archive, template updates (see `13-maintenance-and-update-protocol.md`).

## 8. Confirmed Facts

Confirmed (sourced from `CKIS_CONVERSATION_EXTRACT.md`, `Second_Brain_Final_Execution_Plan.md`, `Second_Brain_Context_Transfer.md`, observed vault state, Eduardo's resolutions on 2026-05-02, and full `.brain/` deployment on 2026-05-03/04):

- Vault structure, folder names, frontmatter spec, naming conventions.
- Skill list (13 operational skills + 6 CKIS skills under `.claude/skills/`; plus global `graphify` and `wiki-brain` skills at `~/.claude/skills/`).
- Platform division of labor (three-layer memory: CKIS → Dev Brain → `.brain/`).
- Active project set: **Korvex, Brisas del Golfo, University, Personal Brand**. Tourdy and HidroPlus archived (2026-05-02).
- "NEVER delete files without backup" rule.
- 7-day inbox rule.
- `_MEMORY.md` is read every session.
- **CKIS** is the canonical acronym: "Central Knowledge & Intelligence System." Aliases "My Second Brain" / "Personal Vault" are acceptable verbatim.
- Folder name is `00-system/ckis/` (kebab-case, consistent with vault convention).
- Korvex is **not** a web agency — treat it as a software / digitalization startup.
- Web Clipper = Obsidian Web Clipper Firefox extension (configured); Claude API Interpreter is **not** used.
- Per-project `.brain/` second brain: deployed on korvex-web (122 nodes) and brisas-del-golfo (190 nodes) as of 2026-05-03/04. Spec at `[[per-project-second-brain]]`.
- Dev Brain vault at `~/Documents/Dev Brain/` — separate from CKIS, holds code graphs + engineering wiki.
- Graphify pinned at `graphifyy==0.6.7`. CLI `update` does NOT have `--obsidian`; Obsidian export via Python API only.
- wiki-brain skill at `~/.claude/skills/wiki-brain/`; `SessionEnd` global hook wired in `~/.claude/settings.json`.

## 9. Resolved Open Questions (2026-05-02)

1. **Folder name** → `00-system/ckis/` (kebab-case adopted for consistency with the rest of the vault).
2. **CKIS acronym** → **adopted** as canonical. Aliases "My Second Brain" / "Personal Vault" acceptable.
3. **Project-level `.brain/` + Graphify per-repo second brain** → **FULLY DEPLOYED (2026-05-03/04).** korvex-web (122 nodes) and brisas-del-golfo (190 nodes) live. korvex-crm pending soak. Full spec: `[[per-project-second-brain]]`.
4. **Obsidian Mobile + sync** → not implemented. Deferred.
5. **Gemini API key (YouTube fallback)** → not implemented. Pipeline incomplete; deferred until project work allows.
6. **AssemblyAI replacement (social-video transcription)** → no replacement; deferred. Project work takes priority.
7. **Web Clipper** → Obsidian Web Clipper Firefox extension configured. Claude API Interpreter **not** used.
8. **Tourdy reactivation trigger** → manual ("when Eduardo says so"). Tourdy archived 2026-05-02 (`09-archive/tourdy/`). HidroPlus already archived.
9. **YAML `tags:` on existing 13 skills** → no. Skills are agent-only and don't appear in the Obsidian graph; the existing `name:` + `description:` frontmatter is sufficient.

Newer open items (post-resolution):

- **Korvex full positioning statement** — what *is* Korvex precisely, beyond "not a web agency"? Capture in `02-projects/korvex/_overview.md` when Eduardo decides.
- **korvex-crm `.brain/` replication** — pending 1-week soak on korvex-web + brisas-del-golfo.
- **Dev Brain Obsidian UI setup** — open vault → BRAT → 3D Graph plugin (v2.4.1, Aryan Gupta) → color groups. Must be done manually.
- **wiki-brain first ingest** — drop source into `~/Documents/Dev Brain/raw/` and run `/wiki-brain ingest`.

## 10. Index of CKIS Files

- [[00-ckis-master-context]] — this file
- [[01-ckis-user-profile-and-operating-context]]
- [[02-obsidian-vault-architecture]]
- [[03-capture-processing-retrieval-workflow]]
- [[04-claude-code-obsidian-agent]]
- [[05-ckis-memory-and-context-rules]]
- [[06-decision-execution-and-review-protocol]]
- [[07-projects-areas-resources-archives-map]]
- [[08-note-templates-and-frontmatter]]
- [[09-cross-model-shared-context-protocol]]
- [[10-claude-project-instructions]]
- [[11-chatgpt-project-instructions]]
- [[12-first-message-and-usage-guide]]
- [[13-maintenance-and-update-protocol]]
- [[14-active-working-slot]]
- [[15-source-map-and-generation-audit]]
- [[16-skill-cards-for-second-brain-workflows]]
