---
type: system
created: 2026-05-17
modified: 2026-05-17
tags: [ckis, memory, architecture, agentic-os, system]
status: active
related: ["[[00-ckis-master-context]]", "[[04-claude-code-obsidian-agent]]", "[[17-crons-architecture]]", "[[wiki-brain]]"]
---

# 18 — CKIS Memory Architecture

> Unified design for persistent, queryable, compounding memory across all Claude Code sessions. Synthesizes: built-in auto-memory, wiki-brain/graphify, CKIS logs, and evaluated third-party tools (claude-mem, mempalace).

━━━

## 1. The Problem This Solves

Every Claude Code session starts cold. Without a memory layer, Eduardo must re-explain project context, past decisions, and active state every single session — losing compounding advantage. CKIS solves this with a **three-layer memory stack**.

━━━

## 2. The Three-Layer Stack (Active)

```
Layer 1 — CKIS Session Hooks (immediate)
  └─ SessionStart: injects _MEMORY.md + _ACTIVE-PROJECTS.md + last session log
  └─ SessionEnd: appends summary to 01-daily/logs/YYYY-MM-DD.md

Layer 2 — Auto-Memory (cross-session, semantic)
  └─ ~/.claude/projects/<vault>/memory/*.md
  └─ MEMORY.md index (auto-loaded every session)
  └─ Types: user, feedback, project, reference

Layer 3 — Dev Brain / Wiki-Brain (long-term knowledge graph)
  └─ ~/Documents/Dev Brain/wiki/
  └─ Powered by graphify + Chroma embeddings
  └─ Query: `graphify query "your question"` from Dev Brain root
```

### Why three layers?

| Layer | TTL | Format | Query method |
|---|---|---|---|
| Session hooks | Per-session | Markdown inject | Auto (SessionStart hook) |
| Auto-memory | Permanent | Typed .md files | MEMORY.md index |
| Dev Brain wiki | Permanent | Structured wiki pages | `graphify query` |

━━━

## 3. CKIS Obsidian Vault — Memory Roles

Within the vault itself, certain files serve as **live memory state**:

| File | Role | Update cadence |
|---|---|---|
| `00-inbox/_MEMORY.md` | Business state — ≤150 lines, no fluff | Weekly review (manual) or Cron 5 (auto, every 2h) |
| `00-inbox/_ACTIVE-PROJECTS.md` | Project roster | When project status changes |
| `01-daily/YYYY-MM-DD.md` | Daily state + decisions | Per session |
| `01-daily/logs/` | Session summaries | Per session (SessionStop hook) |
| `02-projects/<project>/_overview.md` | Canonical per-project state | After significant project events |

━━━

## 4. Third-Party Tools — Evaluation & Decision

### 4.1 claude-mem (github.com/thedotmack/claude-mem)
- **What**: Session capture via lifecycle hooks → SQLite + Chroma vector DB → semantic search across session history
- **License**: Apache 2.0
- **Install**: `npx claude-mem install`
- **Verdict: DEFER** — the owner's existing auto-memory already covers cross-session persistence. claude-mem would add a separate SQLite+Chroma stack (port 37777 worker service) for marginal gain over what's already built in. Re-evaluate when the CKIS public repo needs a standalone memory backend for users who don't have the built-in auto-memory.

### 4.2 mempalace (github.com/mempalace/mempalace)
- **What**: Local-first verbatim memory with hierarchical "palace" metaphor (individuals→wings, subjects→rooms, content→drawers), 96.6% recall@5, MCP server with 29 tools
- **License**: MIT
- **Install**: `uv tool install mempalace` (Python 3.9+, ~300 MB)
- **Architecture fit**: EXCELLENT — the palace hierarchy (wings=projects, rooms=topics, drawers=notes) maps directly to [OWNER]'s vault structure (02-projects, 03-knowledge, per-folder files)
- **Verdict: INTEGRATE IN v2** — Best long-term architectural fit for CKIS public. The Python dependency and ChromaDB setup requires dedicated infrastructure time. Target: integrate when building the CKIS public repo's backend. MCP server approach means it can serve all agents (Claude Code, Hermes, Codex) equally.

### 4.3 Max Mitcham's Three-Layer Architecture (agentic-os-compound-memory)
- **raw** = source material (immutable) → maps to `00-inbox/` + `04-resources/`
- **wiki** = agent-compiled knowledge → maps to `03-knowledge/` + Dev Brain
- **output** = deliverables → maps to `02-projects/` outputs
- **Verdict: ALREADY IMPLEMENTED** — CKIS structure already follows this pattern. Confirmed.

━━━

## 5. Integration Map — Tool → CKIS Layer

```
External tool                 CKIS equivalent
─────────────────────────────────────────────
Hermes (orchestrator)    →    Claude Code (Opus 4.7) — current orchestrator
claude -p crons          →    ~/.claude/scripts/ cron jobs (see [[17-crons-architecture]])
~/memory/daily/          →    01-daily/ vault notes
~/MEMORY.md              →    00-inbox/_MEMORY.md
mempalace wings          →    02-projects/<project>/
mempalace rooms          →    03-knowledge/
graphify wiki            →    ~/Documents/Dev Brain/wiki/
```

━━━

## 6. Future: Hermes Integration

Max Mitcham's guide uses **Hermes** as the main orchestration controller (with Claude Code as one of many execution agents). [OWNER]'s current setup uses Claude Code as both orchestrator and executor.

**Plan**: When [OWNER] acquires Hermes:
1. Claude Code → execution role (coding tasks, vault writes)
2. Hermes → orchestration role (task routing, cross-agent coordination)
3. mempalace MCP → shared memory backend for both

**Note as permanent decision**: Until Hermes is integrated, Claude Code (Opus 4.7 model) serves as the orchestrator brain for complex multi-step tasks.

━━━

## 7. Memory Quality Rules

1. **Don't let useful work die in chat.** Every session decision → auto-memory or vault note.
2. **Raw is immutable.** Never edit source files in `00-inbox/` after ingestion — process them into `03-knowledge/`.
3. **No duplicate pages.** Search before creating. Agent must grep vault before writing a new note.
4. **MEMORY.md ≤ 150 lines.** Cron 5 enforces this. If it grows, the cron compresses.
5. **Stale memories get updated or deleted.** A memory that names a file/function must be verified before use.

━━━

## 8. Session Startup Protocol (Memory Loading Order)

When a new CKIS session starts, Claude Code loads context in this order:

1. `MEMORY.md` (auto-memory index) — always loaded
2. `CLAUDE.md` (root) + `.claude/CLAUDE.md` — operational rules
3. SessionStart hook injects: `_MEMORY.md`, `_ACTIVE-PROJECTS.md`, last session log
4. Task-specific CKIS file (the file most relevant to the current task)
5. `00-systems/ckis/14-active-working-slot.md` — for focused work sessions

━━━

**Decision log:**
- 2026-05-17: claude-mem deferred — existing auto-memory sufficient for current scale
- 2026-05-17: mempalace targeted for CKIS public repo v2 backend
- 2026-05-17: Three-layer architecture (raw/wiki/output) confirmed implemented in current CKIS structure
- 2026-05-17: Claude Code (Opus 4.7) = orchestrator until Hermes integration
