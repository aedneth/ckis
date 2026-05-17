---
type: system
created: 2026-05-17
modified: 2026-05-17
tags: [ckis, obsidian, visualization, 3d-graph]
status: active
---

# 21 — Obsidian 3D Graph Guide

> Visualize how your knowledge compounds. The 3D graph turns your vault from a flat file system into a living, navigable knowledge network.

━━━

## What you're looking at

Two states of a vault:

**Dispersed** (inbox-heavy, few connections):

![Dispersed graph](../../docs/images/graph-dispersed.png)

Isolated nodes = unprocessed captures. No links, no compounding. This is what a vault looks like in week 1 or after an inbox backlog accumulates.

**Connected** (processed, linked knowledge):

![Connected graph](../../docs/images/graph-connected.png)

Clusters emerge around topics. Central nodes (god-nodes) link across clusters. This is compounding knowledge — each new note strengthens the whole structure.

The graph is a diagnostic. If it looks dispersed: run `process inbox`. If it looks dense and connected: your knowledge is compounding.

━━━

## Installing the 3D Graph Plugin

1. Open Obsidian → **Settings → Community plugins**
2. Click **Browse** → search **"3D Graph"** (by Alexander Weichart, also listed as "Open 3D Graph")
3. Click **Install** → **Enable**
4. Access via: **View → Open 3D graph** or ribbon icon

> The plugin is free and open-source. No account required.

━━━

## Recommended Settings

Open the 3D graph settings panel (gear icon in the graph view):

### Display
| Setting | Value | Why |
|---|---|---|
| Node size | By backlinks | Nodes with more inbound links appear larger — reveals god-nodes |
| Node color | By folder | Color-codes your vault structure at a glance |
| Link opacity | 0.3–0.5 | Prevents visual noise with 100+ links |
| Show orphans | Yes (initially) | Identify unlinked notes to connect |

### Physics
| Setting | Value | Why |
|---|---|---|
| Force decay | 0.4 | Keeps clusters stable without collapsing |
| Link force | 0.8 | Strong enough pull to form visible clusters |
| Center force | 0.05 | Gentle pull toward center, prevents explosion |

### Colors (folder-based)
```
00-inbox     → #F59E0B  (amber — capture zone)
01-daily     → #6B7280  (gray — operational)
02-projects  → #3B82F6  (blue — active work)
03-knowledge → #10B981  (emerald — processed knowledge)
04-resources → #8B5CF6  (purple — source material)
05-areas     → #EC4899  (pink — life areas)
06-goals     → #EF4444  (red — goals)
07-people    → #F97316  (orange — relationships)
```

### Performance tips for large vaults (500+ notes)
- Reduce **Simulation duration** to 5s to avoid lag
- Disable **Show attachments** (images/PDFs clutter the graph)
- Use **Filters → Hide tags** to reduce visual noise
- At 1000+ notes: increase **Max zoom** and use filter to show one cluster at a time

━━━

## Reading the Graph

### God-nodes
Large, central nodes with many inbound links. These are your most-connected ideas — often MOCs, frameworks, or core project overviews. If a god-node is in `00-inbox`, it means something important is still unprocessed.

### Clusters
Groups of tightly connected nodes. Each cluster represents a knowledge domain. Cross-cluster links (edges bridging two clusters) are often your most valuable insights — they represent transfer of knowledge between domains.

### Isolated nodes
Nodes with zero connections. Either they're brand new captures (fine) or they're orphaned notes that should be linked or deleted.

### The spine
A chain of nodes linking multiple clusters. In a healthy vault, `03-knowledge/maps-of-content/` MOCs serve as the spine.

━━━

## Dev Brain Graph vs Vault Graph

CKIS maintains two separate graphs:

| | **Vault graph** (Obsidian 3D Graph) | **Dev Brain graph** (graphify / `~/Documents/Dev Brain/`) |
|---|---|---|
| **What's indexed** | Markdown notes, ideas, decisions | Code files, functions, imports, classes |
| **Node = ?** | One concept, note, or document | One code entity (function, component, module) |
| **Links = ?** | Wikilinks `[[...]]` between notes | Import/call relationships between code |
| **Query method** | 3D Graph plugin, Dataview | `graphify query "<question>"` in project dir |
| **Updates** | On vault save + git commit | On every `git commit` via post-commit hook |
| **Goal** | Understand how ideas connect | Understand how code connects |

Both graphs compound separately. Both get more useful over time. They share context through the `project-context` skill, which surfaces Dev Brain session data inside the vault's project brief.

━━━

## Interpreting Growth

Track your graph's density monthly during the `knowledge consolidation` skill run:

| Metric | Week 1 | Month 1 | Month 3 |
|---|---|---|---|
| Nodes | 20–50 | 150+ | 400+ |
| Avg links per node | <1 | 2–3 | 4–6 |
| Clusters visible | 0–1 | 3–5 | 8+ |
| God-nodes | 0 | 1–3 | 5+ |

When clusters start bridging (you see links between the blue project cluster and the emerald knowledge cluster), CKIS is working: your project decisions are grounding in processed knowledge, not just intuition.

━━━

## Troubleshooting

**Graph won't open:** Restart Obsidian. First launch may take 5–10s to render.

**Everything is gray:** Color-by-folder setting isn't enabled. Re-open settings → Color → select "By folder path."

**Too many nodes, can't navigate:** Use the **Search** filter in the graph panel to show only notes matching a keyword or folder. Start with `path:03-knowledge` to see just your processed knowledge.

**Nodes flying off screen:** Reduce Center force to 0.02 and Force decay to 0.3 until the simulation stabilizes.

**Plugin not found:** Search for "3D Graph" (exact) or "Open 3D Graph" in community plugins. If still missing, ensure community plugins are enabled in Settings → Community plugins → toggle on.
