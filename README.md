# CKIS — Central Knowledge & Intelligence System

> A developer knowledge operating system that compounds over time.
> Obsidian + Claude Code + Git — your second brain, built for engineers.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Template](https://img.shields.io/badge/Use%20as-Template-blue)](https://github.com/aedneth/ckis/generate)
[![Claude Code](https://img.shields.io/badge/Powered%20by-Claude%20Code-orange)](https://claude.ai/code)

---

## The Problem

Every Claude Code session starts cold. You re-explain your projects. Decisions evaporate. Insights from last week are unreachable. Your AI assistant is brilliant in the moment but amnesiac across sessions.

## The Solution

CKIS is a structured Obsidian vault + Claude Code skill system that:

- **Injects full context automatically** at every session start — project state, recent decisions, code architecture
- **Compounds knowledge** across sessions — every conversation builds on the last
- **Bridges code ↔ knowledge** — your codebases are queryable knowledge graphs, not just files
- **Runs itself** — crons handle weekly reviews, memory consolidation, and git sync

You stop managing your second brain. It manages itself.

---

## Quick Start

**Works on any OS with Obsidian + Claude Code installed.**

```bash
# 1. Clone this template (or use GitHub's "Use this template" button)
gh repo create my-second-brain --template aedneth/ckis --private --clone
cd my-second-brain

# 2. Open the vault in Obsidian
# File → Open Vault → select this folder

# 3. Open Claude Code in this directory
claude

# 4. Run the initial setup skill
# In Claude Code prompt: "daily brief"
```

That's it. Claude now has full context of your system and can start processing knowledge immediately.

---

## Core Features

**Automatic session context** — Claude Code reads your project state, recent decisions, and code architecture before your first message every session.

**Skill system** — 20+ built-in skills triggered by natural language commands (`braindump`, `process inbox`, `weekly review`, `synthesize [topic]`, and more).

**Per-project `.brain/`** — attach a `.brain/` memory layer to any coding repo. Session logs, decision records, code graphs — all auto-maintained via git hooks.

**Dev Brain** — a separate agent-queryable vault of your codebases. Any AI agent can query your code structure, session history, and cross-project patterns.

**Cron-powered maintenance** — 5 automated crons handle git sync, CRM triage, weekly review prompts, and memory consolidation.

---

## Architecture

```
┌────────────────────────────────────────────────────┐
│  CKIS Vault (this repo)                            │
│  Strategic layer — who you are, what you're        │
│  building, decisions made, knowledge processed.    │
└─────────────────────┬──────────────────────────────┘
                      │  auto-sync (post-commit hooks)
┌─────────────────────▼──────────────────────────────┐
│  Dev Brain (~/ Documents/Dev Brain/)               │
│  Engineering layer — queryable code graphs,        │
│  session history, cross-project agent queries.     │
└─────────────────────┬──────────────────────────────┘
                      │  .brain/ bridge
┌─────────────────────▼──────────────────────────────┐
│  Per-Project .brain/ (in each coding repo)         │
│  Tactical layer — session logs, decisions, bugs,   │
│  code graph, injected at every Claude Code open.   │
└────────────────────────────────────────────────────┘
```

Full architecture spec: [`00-systems/ckis/00-ckis-master-context.md`](00-systems/ckis/00-ckis-master-context.md)

Per-project `.brain/` spec: [`03-knowledge/permanent-notes/per-project-second-brain.md`](03-knowledge/permanent-notes/per-project-second-brain.md)

---

## Folder Structure

```
00-systems/    → CKIS architecture + reusable workflows
00-inbox/      → Capture zone — everything enters here first
01-daily/      → Daily notes and session logs
02-projects/   → Active projects
03-knowledge/  → Permanent notes, MOCs, guides
04-resources/  → Reference material
05-areas/      → Life areas (health, finance, learning)
06-goals/      → Annual + quarterly + weekly goals
07-people/     → Relationship notes
08-templates/  → Note templates
09-archive/    → Completed or inactive items
.claude/       → Vault-specific Claude Code skills
```

---

## Skill Commands

Trigger these in Claude Code chat:

| Command | What it does |
|---|---|
| `braindump` | Capture raw thoughts with automatic classification |
| `process inbox` | Categorize, tag, link, and route inbox items |
| `daily brief` | Morning context brief with priorities |
| `weekly review` | Analyze week, check goals, flag gaps |
| `synthesize [topic]` | Find all notes on topic, create synthesis |
| `process URL [url]` | Extract, summarize, store web content |
| `process YouTube [url]` | Transcript → synthesis → permanent note |
| `knowledge consolidation` | Monthly pattern detection |

Full skill catalog: [`00-systems/ckis/16-skill-cards-for-second-brain-workflows.md`](00-systems/ckis/16-skill-cards-for-second-brain-workflows.md)

---

## Crons (Optional Automation)

5 automated crons extend the system:

1. **vault-git-sync** — commits vault changes every 6 hours
2. **crm-sort** — triages contact notes daily
3. **content-discovery** — weekly content aggregation *(requires API credits)*
4. **weekly-review** — auto-prompts Friday review via Claude
5. **memory-consolidation** — monthly _MEMORY.md + _ACTIVE-PROJECTS.md refresh

Setup: [`00-systems/ckis/17-crons-architecture.md`](00-systems/ckis/17-crons-architecture.md)

---

## Requirements

- [Obsidian](https://obsidian.md/) — free, offline markdown editor
- [Claude Code](https://claude.ai/code) — AI coding agent (Anthropic)
- Git
- bash (Linux/macOS native; Windows: WSL2)

Optional (for Dev Brain + `.brain/` layers):
- [`graphifyy`](https://pypi.org/project/graphifyy/) — `uv tool install graphifyy==0.6.7`
- Python 3.10+

---

## Roadmap

- [ ] Obsidian community plugin compatibility list
- [ ] Windows native support (PowerShell hooks)
- [ ] `ckis init` CLI scaffolding script
- [ ] mempalace integration (ChromaDB semantic search)
- [ ] Hermes orchestrator integration

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Issues and PRs welcome — especially for:
- New skill templates
- Hook examples for non-bash shells
- Workflow adaptations (solo dev → team use)

---

## License

MIT — see [LICENSE](LICENSE)

Built by [@aedneth](https://github.com/aedneth) — Korvex founder, systems builder.
