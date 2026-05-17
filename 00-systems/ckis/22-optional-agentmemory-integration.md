---
type: system
created: 2026-05-17
modified: 2026-05-17
tags: [ckis, memory, integrations, optional]
status: reference
---

# 22 — Optional: agentmemory Integration

> Status: **Reference only** — evaluated 2026-05-17. Not a core CKIS dependency.

━━━

## What agentmemory is

[agentmemory](https://github.com/rohitg00/agentmemory) is a persistent memory system for AI agents. It auto-captures tool use via 12 lifecycle hooks, compresses observations into structured facts, and injects relevant context at session start via MCP. Claims 92% token reduction and 95% retrieval accuracy.

Architecture: `capture (hooks) → compress (LLM) → index (BM25 + vector + graph) → retrieve → inject at SessionStart`.

Uses neuroscience-inspired memory tiers: working, episodic, semantic, procedural — with automatic decay and contradiction resolution.

━━━

## Why CKIS doesn't depend on it (and you probably don't need it either)

| agentmemory feature | CKIS equivalent |
|---|---|
| Auto-capture from 12 hook events | `.brain/` PostToolUse + Stop hooks (coding repos) + SessionStop (vault) |
| AI-compress to structured facts | Cron 5: Memory Consolidation — rewrites `_MEMORY.md` every 2h via `claude -p` |
| BM25 search over session history | `grep` + `graphify query` from Dev Brain |
| Vector retrieval at SessionStart | Auto-memory (`~/.claude/projects/<vault>/memory/MEMORY.md`) injected every session |
| Knowledge graph decay flags | `weekly-review` health checks + manual review |

CKIS memory is **human-readable markdown in Obsidian** — you can open it, edit it, and understand it without tooling. agentmemory is a **runtime vector/SQLite store for agent recall** — optimized for machine retrieval.

The genuine gaps agentmemory fills — vector semantic search over the full vault, automated decay scoring — are not worth the operational complexity at a typical vault scale (<2,000 notes, single user).

━━━

## When to revisit

Consider agentmemory (or mempalace — see `18-memory-architecture.md`) when **any two** of these are true:

- Vault exceeds 2,000 notes and `synthesize` skill returns noisy, slow results
- CKIS is deployed for a team (multi-user shared memory becomes valuable)
- Hermes multi-agent integration is live (a shared MCP memory backend becomes load-bearing)
- The `graphify query` + Dev Brain pipeline doesn't cover your code-knowledge needs

━━━

## Reference integration patterns (for future use)

If you do integrate agentmemory, the best entry points for CKIS are:

1. **Vault synthesis layer** — replace grep-based `synthesize` skill with agentmemory's hybrid BM25+vector search for richer recall across 1000+ notes
2. **Decay-driven health checks** — feed agentmemory's staleness scores into the `ckis-vault-maintenance` skill to surface old decisions or orphaned notes
3. **Cross-model session handoff** — agentmemory's agent-to-agent handoff (roadmap) would complement `ckis-cross-model-handoff` by making context injection automatic instead of manual

━━━

## See also

- `18-memory-architecture.md` — full memory stack evaluation (claude-mem, mempalace, auto-memory)
- `17-crons-architecture.md` — Cron 5 (Memory Consolidation) — current automated memory solution
- `09-cross-model-shared-context-protocol.md` — current Claude ↔ ChatGPT handoff protocol
