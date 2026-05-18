---
type: permanent-note
created: 2026-05-03
modified: 2026-05-18
tags: [architecture, ckis, claude-code, brain, graphify, wiki-brain, dev-brain, open-source]
status: evergreen
related: ["[[00-ckis-master-context]]", "[[02-obsidian-vault-architecture]]", "[[04-claude-code-obsidian-agent]]", "[[06-decision-execution-and-review-protocol]]", "[[09-cross-model-shared-context-protocol]]", "[[02-projects/[your-project]/_overview]]", "[[02-projects/[client-site]/_overview]]", "[[ai-specialization-automation-engineering]]"]
---

# Per-Project Second Brain
## Graphify + `.brain/` + Dev Brain + Wiki-Brain Architecture

> **Version:** 2026-05-18 (v2.4) — `/compact` bridge: summaries route to Dev Brain automatically; eager extraction via `log-compact.sh`; `raw/` folder removed from Dev Brain (fully autonomous — no human drops).
> Previous: 2026-05-17 (v2.3) — Dev Brain UX overhaul: `scripts/` → `.scripts/`, session pointer stubs removed, wiki Graph Digest fixed, compaction preamble filtered.
> Previous: 2026-05-04 (v2.0) — full implementation across [your-project] and [client-site].
> This note is the canonical spec. Future changes start here, then propagate to the CKIS CHANGELOG.

CKIS solves the *strategic* memory problem — who Eduardo is, what projects exist, what's been decided at the business level. It deliberately does **not** solve the *tactical* problem inside a coding repo: every Claude Code session loses the thread of what happened in the previous one. Bug fixes evaporate. Decisions made mid-session never reach the vault. The codebase grows opaque.

This note specifies the three-layer architecture that fixes that — and how it bridges back to CKIS.

━━━

## 1. The Three Layers

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Layer 3 · CKIS (Strategic)                                             │
│  ~/Documents/Second Brain/                                              │
│  Who Eduardo is, what projects mean, cross-project patterns,            │
│  business state, goals, people. Human-curated + Claude-assisted.        │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │  graph-report.md (auto-synced per commit)
                            │  02-projects/<slug>/_overview.md (curated)
                            │
┌───────────────────────────▼─────────────────────────────────────────────┐
│  Layer 2 · Dev Brain (Engineering Knowledge)                            │
│  ~/Documents/Dev Brain/                                                 │
│  Queryable code graphs (one .md per node), compounding engineering      │
│  wiki (wiki-brain skill), raw source material. Claude-written + Graphify│
│  Opened as a separate Obsidian vault with the 3D Graph plugin.          │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │  code-graph/<slug>/ (every N commits)
                            │  wiki/ (session-end, on demand)
                            │
┌───────────────────────────▼─────────────────────────────────────────────┐
│  Layer 1 · .brain/ (Per-Session Tactical)                               │
│  <repo>/.brain/                                                         │
│  Lives inside each coding repo. Session logs, decisions, bug lessons,   │
│  code graph. Injected automatically at every Claude Code session start. │
│  Committed (decisions/, bugs/, scripts/) + gitignored (sessions/, graph/)│
└─────────────────────────────────────────────────────────────────────────┘
```

Each layer has a clear owner and scope. Nothing crosses boundaries upward without deliberate action. The system self-maintains downward automatically.

━━━

## 2. Layer 1 — `.brain/` Per-Project Tactical Memory

### 2.1 Directory structure

```
<repo>/
├── .brain/
│   ├── BRAIN.md              # agent workflow rules (Claude reads this via @-import)
│   ├── README.md             # human-readable directory guide
│   ├── config.sh             # project-specific config (paths, slug, cadence)
│   ├── _CONTEXT.md           # GITIGNORED — auto-assembled at session start
│   ├── .session-state        # GITIGNORED — start SHA/time for Stop hook
│   ├── decisions/
│   │   └── README.md         # COMMITTED — decision-log index + format spec
│   ├── bugs/
│   │   └── README.md         # COMMITTED — bug log index + format spec
│   ├── sessions/             # GITIGNORED — per-session logs, never committed
│   │   └── compacts/         # GITIGNORED — /compact summary extracts
│   ├── graph/                # GITIGNORED — Graphify output (regenerable)
│   │   ├── graph.json        # serialized NetworkX graph
│   │   ├── GRAPH_REPORT.md   # plain-text god-nodes + surprising connections
│   │   └── graph.html        # interactive D3 visualization
│   └── scripts/
│       ├── assemble-context.sh    # SessionStart hook — builds _CONTEXT.md
│       ├── log-session.sh         # Stop hook — writes per-session log
│       ├── log-tool-event.sh      # PostToolUse hook — records builds/commits
│       ├── log-compact.sh         # UserPromptSubmit hook — eager compact extractor → Dev Brain
│       ├── sync-graph-to-vault.sh # copies GRAPH_REPORT to CKIS (every commit)
│       ├── sync-obsidian-graph.sh # writes Dev Brain .md nodes (every N commits)
│       └── lib/
│           └── compact-routing.sh # shared: route compact .md to Dev Brain (idempotent)
├── .claude/
│   ├── settings.json         # 5 Claude Code hooks wired here
│   └── CLAUDE.md             # project rules (CKIS + .brain/ section appended)
├── .git/hooks/
│   ├── post-commit           # wrapper: chains .graphify then .brain
│   ├── post-commit.graphify  # Graphify's original hook (preserved verbatim)
│   └── post-commit.brain     # brain hook: sync-graph-to-vault + cadenced obsidian
└── graphify-out -> .brain/graph/  # symlink (so graphify finds its expected output path)
```

**Commit boundary** — committed (team-shareable, versioned): `decisions/`, `bugs/`, `scripts/`, `BRAIN.md`, `README.md`, `config.sh`. Gitignored (regenerable or personal): `_CONTEXT.md`, `.session-state`, `sessions/`, `graph/`.

### 2.2 `config.sh` — project identity

Every script sources `config.sh` first. The minimal fields:

```bash
PROJECT_SLUG="[your-project]"           # must match 02-projects/<slug>/ in CKIS vault
PROJECT_NAME="[YOUR_PROJECT] Web"
CKIS_VAULT="$HOME/Documents/Second Brain"
CKIS_MEMORY="$CKIS_VAULT/00-inbox/_MEMORY.md"
CKIS_PROJECT_OVERVIEW="$CKIS_VAULT/02-projects/$PROJECT_SLUG/_overview.md"
CKIS_ARCHITECTURE_NOTE="$CKIS_VAULT/03-knowledge/permanent-notes/per-project-second-brain.md"
BRAIN_DIR=".brain"
SESSIONS_DIR="$BRAIN_DIR/sessions"
DECISIONS_DIR="$BRAIN_DIR/decisions"
BUGS_DIR="$BRAIN_DIR/bugs"
GRAPH_DIR="$BRAIN_DIR/graph"
CONTEXT_FILE="$BRAIN_DIR/_CONTEXT.md"
SESSION_STATE="$BRAIN_DIR/.session-state"
RECENT_SESSIONS_LIMIT=3
DEV_BRAIN_VAULT="$HOME/Documents/Dev Brain"
OBSIDIAN_GRAPH_CADENCE=10       # rebuild Dev Brain notes every N commits
```

### 2.3 The 6 scripts

#### `assemble-context.sh` — `SessionStart` hook

Runs automatically when Claude Code opens a session in this repo. It:

1. Records session start to `.session-state` (UTC timestamp, branch, HEAD SHA).
2. Rotates any orphaned `_active.md` from a crashed previous session.
3. Calls `sync-graph-to-vault.sh` as a catch-up in case the post-commit hook missed it.
4. Builds `_CONTEXT.md` by assembling:
   - CKIS pointer block (paths to `_MEMORY.md`, `_overview.md`, architecture spec)
   - Last N session summaries (full content, newest first)
   - Open decisions (frontmatter `status: proposed`)
   - Open bugs (frontmatter `status: open`)
   - God-nodes and Surprising-connections sections from `GRAPH_REPORT.md` (capped at 80 lines)
5. Emits `_CONTEXT.md` to stdout — Claude Code `SessionStart` hooks inject stdout into the agent's context window.

The agent does not need to read `_CONTEXT.md` again — it's already in context before the first user prompt.

#### `log-session.sh` — `Stop` hook

Runs automatically when Claude Code ends a session. It:

1. Reads `.session-state` to compute duration and git diff vs. start.
2. Extracts `/compact` summaries from the JSONL transcript: finds entries with `isCompactSummary: true` and `timestamp >= SESSION_START_UTC`, extracts text via polymorphic `textify` jq filter, writes each to `sessions/compacts/<ts>-compact.md` with YAML frontmatter.
3. **Dev Brain compact routing** (v2.4): mirrors each compact `.md` to `~/Documents/Dev Brain/sessions/compacts/<project>/` via `lib/compact-routing.sh` (idempotent, atomic copy).
4. Writes `sessions/<DATE_TAG>-session.md` with sections:
   - `## Iterations` — build/test/lint/commit events from `_active.md`
   - `## Compactions` — pointer + 200-char excerpt per compact
   - `## Commits made` — `git log --oneline` since start SHA
   - `## Files changed` — `git diff --name-only` + diffstat
   - `## Working tree at end` — `git status --short`
5. **Dev Brain session index**: appends one line to `~/Documents/Dev Brain/sessions/index.md` (format: `UTC | slug | duration | sha | summary | source_path`). Summary uses 4-tier fallback: compact excerpt → commit subject → last assistant turn → diffstat.
6. Cleans up `.session-state`, `_active.md`, `.compacts-this-session`.

The result: every Claude Code session leaves a complete, searchable, machine-readable log. Compaction summaries are never lost.

#### `log-tool-event.sh` — `PostToolUse (Bash)` hook

Fires after every Bash tool call. Checks if the command matches objectively important patterns:
- `npm run build` / `npm run dev` / `npm test` / `npm run lint`
- `git commit`

On match, appends one timestamped line to `sessions/_active.md`. On failure, appends the last ~8 lines of output so the error is preserved for the next session.

Everything else is ignored — no noise from routine file reads or trivial shell calls.

#### `log-compact.sh` — `UserPromptSubmit` hook

Fires when the user submits `/compact` (bare or with focus text). Acts as an **eager extractor**: at this moment, the NEW compact hasn't been generated yet, but any prior compact from the same session is already in the JSONL transcript. The script:

1. Reads `transcript_path` from the hook payload.
2. Extracts the most recent prior `isCompactSummary: true` entry.
3. Writes it to `sessions/compacts/<ts>-compact.md` if not already on disk (idempotent).
4. Routes it to Dev Brain via `lib/compact-routing.sh`.

The Stop hook (`log-session.sh`) is the final catch-all — it captures any final compact after the session ends. Both paths share the same idempotent routing helper, so duplicate calls are safe.

No stdout — `UserPromptSubmit` hooks must not inject context.

#### `sync-graph-to-vault.sh` — called from `post-commit.brain` + `assemble-context.sh`

Copies `.brain/graph/GRAPH_REPORT.md` into `$CKIS_VAULT/02-projects/<slug>/graph-report.md` wrapped in CKIS-standard YAML frontmatter. Skips if content is identical (no Obsidian re-index churn). The CKIS file has `auto: true` in frontmatter — do not hand-edit it.

#### `sync-obsidian-graph.sh` — called from `post-commit.brain` (cadence-gated)

Reads `.brain/graph/graph.json` and calls the Graphify Python API directly to generate one `.md` file per code node in `~/Documents/Dev Brain/code-graph/<slug>/`. Called every `OBSIDIAN_GRAPH_CADENCE` commits. After Obsidian export completes, calls `~/Documents/Dev Brain/.scripts/build-wiki-page.sh <slug>` to regenerate the wiki digest at `wiki/<slug>.md` (v2.2).

#### `register-to-dev-brain.sh` — run once per project (idempotent)

5-line wrapper that sources `config.sh` and calls `~/Documents/Dev Brain/.scripts/register-project.sh <slug> <name> <repo_root>`. Updates `projects.json` and the `<!-- projects:auto -->` block in `AGENT_README.md`. Run after initial `.brain/` setup or whenever project metadata changes.

**Critical implementation note:** The Graphify CLI's `update` subcommand does NOT expose `--obsidian`. The Obsidian export function (`graphify.export.to_obsidian`) is only accessible via the Python API. The script calls Python inline:

```python
G = nx.node_link_graph(json.loads(graph_path.read_text()), edges="links")
communities = {}
for node, data in G.nodes(data=True):
    c = data.get("community", 0)
    communities.setdefault(c, []).append(node)
from graphify.export import to_obsidian
n = to_obsidian(G, communities, obs_dir)
```

The `edges="links"` kwarg is required (NetworkX FutureWarning becomes error without it).

### 2.4 Claude Code hooks (`.claude/settings.json`)

Hook commands use `git rev-parse --show-toplevel` to resolve the project root before running any script. This makes them work correctly regardless of which directory `claude` was launched from.

```json
{
  "permissions": {
    "allow": ["Bash(npm run build)", "Bash(npm run dev)", "Bash(npm run lint)",
              "Bash(git *)", "Bash(bash .brain/scripts/*)", "Bash(graphify *)",
              "Bash(bash .brain/scripts/sync-obsidian-graph.sh)"]
  },
  "hooks": {
    "SessionStart": [
      {"hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/assemble-context.sh'"}]}
    ],
    "PostToolUse": [
      {"matcher": "Bash", "hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/log-tool-event.sh'"}]}
    ],
    "UserPromptSubmit": [
      {"hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/log-compact.sh'"}]}
    ],
    "Stop": [
      {"hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/log-session.sh'"}]}
    ]
  }
}
```

### 2.5 Git hook chain

Graphify installs a `post-commit` hook. To preserve it while adding brain behavior:

```
.git/hooks/post-commit          # wrapper — chains both sub-hooks
.git/hooks/post-commit.graphify # graphify's original (renamed, never edited)
.git/hooks/post-commit.brain    # brain hook
```

`post-commit` wrapper:
```sh
HOOK_DIR="$(dirname "$0")"
[ -x "$HOOK_DIR/post-commit.graphify" ] && "$HOOK_DIR/post-commit.graphify" "$@"
[ -x "$HOOK_DIR/post-commit.brain" ]    && "$HOOK_DIR/post-commit.brain" "$@"
exit 0
```

`post-commit.brain`:
- Waits up to 5 min for `~/.cache/graphify-rebuild.log` to settle (graph.json stabilizes).
- Calls `sync-graph-to-vault.sh` (every commit → CKIS always has latest report).
- Every `OBSIDIAN_GRAPH_CADENCE` commits: calls `sync-obsidian-graph.sh` (Dev Brain refresh).
- Both async (`&` + `disown`) — never blocks the commit.

━━━

## 3. Layer 2 — Dev Brain Vault (Engineering Knowledge)

### 3.1 Directory structure

```
~/Documents/Dev Brain/
├── AGENT_README.md       # entry point for any agent — query patterns, registered projects
├── projects.json         # central registry: slug, repo_root, graph_json, sessions_dir
├── code-graph/
│   ├── [your-project]/           # 376 .md notes — one per [your-project] code node (v2.2)
│   └── [client-site]/ # 190 .md notes — one per brisas node
├── sessions/
│   ├── index.md          # append-only feed: UTC | slug | duration | sha | summary | path
│   └── compacts/
│       ├── [your-project]/   # LLM-distilled /compact summaries from [your-project]
│       └── [client-site]/    # same for [client-site]
├── wiki/
│   ├── index.md          # auto-rebuilt by build-wiki-page.sh after each Obsidian sync
│   ├── [your-project].md         # god-nodes + communities + recent sessions digest
│   └── [client-site].md
├── .scripts/             # hidden from Obsidian sidebar (dot-prefix)
│   ├── query-all.sh          # cross-project query via graphify merge-graphs
│   ├── register-project.sh   # upserts project in projects.json + AGENT_README.md
│   └── build-wiki-page.sh    # reads GRAPH_REPORT + sessions → wiki/<slug>.md
├── timeline/             # chronological context (wiki-brain managed)
└── .gitignore            # code-graph/ + .obsidian/workspace*
```

### 3.2 Code graph — Graphify Obsidian export

Each code node becomes a `.md` file with YAML frontmatter generated by `graphify.export.to_obsidian()`:

```yaml
---
id: src/app/page.tsx
community: 3
degree: 12
---
```

Body contains wikilinks to related nodes. Community numbers correspond to Graphify's detected clusters. In Obsidian's graph view, these clusters become the visual color groups.

Rebuilt every `OBSIDIAN_GRAPH_CADENCE` commits (default: 10). The cost is ~1–2 seconds of Python; the benefit is a live, navigable graph of every file/symbol in the codebase.

### 3.3 Wiki-Brain skill

**Source:** `tenfoldmarc/wiki-brain-skill` at `~/.claude/skills/wiki-brain/`

Wiki-brain turns the Dev Brain vault into a compounding knowledge base. Claude is the only writer. The workflow:

1. Run `/wiki-brain ingest <url-or-source>` in any Claude Code session — pass a URL, file path, or inline content directly (Dev Brain has no human-drop folder).
2. Claude reads the source, summarizes, creates/updates wiki pages under `wiki/`, cross-links aggressively with `[[wikilinks]]`, updates `wiki/index.md`.
3. `SessionEnd` global hook (`~/.claude/skills/wiki-brain/hooks/session-end.sh`) checks rebuild cadence and runs Graphify if due.

Commands:
- `/wiki-brain` — status menu
- `/wiki-brain ingest <file>` — ingest a raw source
- `/wiki-brain query "<q>"` — query the graph + wiki
- `/wiki-brain lint` — health-check the wiki for orphan pages
- `/wiki-brain rebuild` — force a Graphify rebuild
- `/recall` — show last 5 activities + read linked pages

### 3.4 Obsidian setup (Dev Brain vault)

The Dev Brain is a **separate** Obsidian vault at `~/Documents/Dev Brain/`. It must be opened independently from the CKIS vault.

Required setup:
1. Open `~/Documents/Dev Brain/` as an Obsidian vault.
2. Enable community plugins.
3. Install **BRAT** (Beta Reviewers Auto-update Tester).
4. Via BRAT: add `Aryan Gupta/3D-Graph` (v2.4.1) → enable.
5. In 3D Graph settings, configure color groups:
   - Community 0 ([your-project] core): electric blue `#3B82F6`
   - Community 1 ([your-project]-2 core): emerald `#10B981`
   - `wiki/` path prefix: magenta `#D946EF`
   - `timeline/` path prefix: grey `#6B7280`

The graph view then shows a live, navigable 3D view of every code node across all projects, cross-linked with wiki knowledge.

━━━

## 4. Layer 3 — CKIS Bridge

CKIS is not a substitute for `.brain/` — it's the strategic layer above it. The bridge is intentionally thin:

| Situation | Destination |
| --- | --- |
| Routine code change, refactor, test | git commit only — no brain entry |
| Decision about *this project* (architecture, dependency, deploy) | `<repo>/.brain/decisions/YYYY-MM-DD-<slug>.md` |
| Bug with a lesson worth keeping (root cause, not patch) | `<repo>/.brain/bugs/YYYY-MM-DD-<slug>.md` |
| Strategic / cross-project / personal | CKIS `_MEMORY.md` + `02-projects/<slug>/_overview.md` |
| Pattern reusable across projects | CKIS `03-knowledge/permanent-notes/` |
| System-level CKIS change | `00-system/ckis/CHANGELOG.md` + relevant CKIS file |

**Cross-post rule:** important `.brain/decisions/` entries get a one-line cross-post to CKIS `_MEMORY.md` Open Decisions, pointing back to the brain file for detail. CKIS stays as the strategic top layer; `.brain/` owns the implementation layer.

━━━

## 5. Information Flows (complete)

### Per-commit flow

```
git commit
  └── post-commit.graphify
      └── graphify update . → graph.json, GRAPH_REPORT.md, graph.html

  └── post-commit.brain (async, waits for graph to settle)
      ├── Always: sync-graph-to-vault.sh
      │   └── CKIS/02-projects/<slug>/graph-report.md  (CKIS visible)
      └── Every OBSIDIAN_GRAPH_CADENCE commits: sync-obsidian-graph.sh
          └── Dev Brain/code-graph/<slug>/*.md  (3D graph visible)
```

### Per-session flow

```
SessionStart
  └── assemble-context.sh
      ├── rotate orphaned state (crash recovery)
      ├── sync-graph-to-vault.sh (catch-up)
      └── emit _CONTEXT.md → injected into Claude's context window
          ├── CKIS pointers
          ├── last 3 session logs
          ├── open decisions + open bugs
          └── god-nodes from GRAPH_REPORT.md

During session
  ├── PostToolUse(Bash) → log-tool-event.sh → sessions/_active.md
  └── UserPromptSubmit → log-compact.sh (on /compact)
      ├── extract most recent prior compact from JSONL → sessions/compacts/<ts>.md
      └── route → Dev Brain/sessions/compacts/<project>/ (eager, idempotent)

Stop
  └── log-session.sh
      ├── extract /compact summaries from JSONL → sessions/compacts/<ts>.md
      ├── route each compact → Dev Brain/sessions/compacts/<project>/ (catch-all)
      ├── merge iterations from _active.md
      ├── compute git diff + commits + duration
      ├── write sessions/<ts>-session.md (persistent, searchable)
      └── Dev Brain session index:
          └── append line to ~/Documents/Dev Brain/sessions/index.md

SessionEnd (global, wiki-brain)
  └── wiki-brain session-end.sh
      └── check rebuild cadence → maybe graphify rebuild in Dev Brain
```

### CKIS sync flow

```
02-projects/<slug>/graph-report.md  ← auto (every commit via post-commit.brain)
02-projects/<slug>/_overview.md     ← human-curated (sync overviews skill)
00-inbox/_MEMORY.md                 ← cross-post from .brain/decisions/ (manual)
03-knowledge/permanent-notes/       ← elevated from .brain/ when reusable
```

━━━

## 6. Tool Decisions

### Graphify (`safishamsi/graphify`, PyPI: `graphifyy==0.6.7`)

Selected over `abhigyanpatwari/GitNexus` because:
- **License:** Graphify is MIT. GitNexus is PolyForm Noncommercial — hard blocker for [YOUR_PROJECT] commercial work.
- **Obsidian native:** Graphify's Python API writes a real Obsidian vault (one `.md` per node, wikilinks, community frontmatter). GitNexus has no Obsidian integration.

Known risks:
- 1-month-old project at adoption time; fast branch churn (`v4 → v5 → v6` in 4 weeks).
- Funnel for paid Penpax SaaS.
- Mitigation: pinned to `graphifyy==0.6.7`. Architecture is tool-replaceable — if Graphify dies, `graph.json` format is NetworkX node-link JSON, the Python script in `sync-obsidian-graph.sh` can be swapped for any tool that produces the same format.

Install: `uv tool install graphifyy==0.6.7`

### Wiki-Brain (`tenfoldmarc/wiki-brain-skill`)

Claude Code skill that makes Claude the sole writer of a compounding engineering knowledge base. It occupies Layer 2 (Dev Brain vault), completely separate from CKIS. The `SessionEnd` global hook triggers periodic rebuilds without requiring manual invocation.

━━━

## 7. Replication Guide — Adding `.brain/` to a New Project

Estimated time: 30–45 minutes per repo once the skeleton is stable.

### Step 1 — Copy the skeleton

```bash
REPO=/path/to/new-project
REFERENCE=<YOUR_REFERENCE_REPO_PATH>

mkdir -p "$REPO/.brain"/{decisions,bugs,sessions/compacts,graph,scripts}
cp "$REFERENCE/.brain/scripts"/*.sh "$REPO/.brain/scripts/"
cp "$REFERENCE/.brain/BRAIN.md" "$REPO/.brain/"
cp "$REFERENCE/.brain/README.md" "$REPO/.brain/"
cp "$REFERENCE/.brain/decisions/README.md" "$REPO/.brain/decisions/"
cp "$REFERENCE/.brain/bugs/README.md" "$REPO/.brain/bugs/"
touch "$REPO/.brain/sessions/.gitkeep"
touch "$REPO/.brain/graph/.gitkeep"
```

### Step 2 — Create `config.sh`

```bash
cat > "$REPO/.brain/config.sh" << 'EOF'
PROJECT_SLUG="<slug>"        # must match 02-projects/<slug>/ in CKIS
PROJECT_NAME="<Name>"
CKIS_VAULT="$HOME/Documents/Second Brain"
CKIS_MEMORY="$CKIS_VAULT/00-inbox/_MEMORY.md"
CKIS_PROJECT_OVERVIEW="$CKIS_VAULT/02-projects/$PROJECT_SLUG/_overview.md"
CKIS_ARCHITECTURE_NOTE="$CKIS_VAULT/03-knowledge/permanent-notes/per-project-second-brain.md"
BRAIN_DIR=".brain"
SESSIONS_DIR="$BRAIN_DIR/sessions"
DECISIONS_DIR="$BRAIN_DIR/decisions"
BUGS_DIR="$BRAIN_DIR/bugs"
GRAPH_DIR="$BRAIN_DIR/graph"
CONTEXT_FILE="$BRAIN_DIR/_CONTEXT.md"
SESSION_STATE="$BRAIN_DIR/.session-state"
RECENT_SESSIONS_LIMIT=3
DEV_BRAIN_VAULT="$HOME/Documents/Dev Brain"
OBSIDIAN_GRAPH_CADENCE=10
EOF
```

### Step 3 — Add `.gitignore` entries

```
.brain/_CONTEXT.md
.brain/.session-state
.brain/sessions/*
!.brain/sessions/.gitkeep
.brain/graph/*
!.brain/graph/.gitkeep
graphify-out
```

### Step 4 — Create `.claude/settings.json`

```json
{
  "permissions": {
    "allow": ["Bash(npm run build)", "Bash(npm run dev)", "Bash(npm run lint)",
              "Bash(git *)", "Bash(bash .brain/scripts/*)", "Bash(graphify *)",
              "Bash(bash .brain/scripts/sync-obsidian-graph.sh)"]
  },
  "hooks": {
    "SessionStart": [
      {"hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/assemble-context.sh'"}]}
    ],
    "PostToolUse": [
      {"matcher": "Bash", "hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/log-tool-event.sh'"}]}
    ],
    "UserPromptSubmit": [
      {"hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/log-compact.sh'"}]}
    ],
    "Stop": [
      {"hooks": [{"type": "command", "command": "bash -c 'cd \"$(git rev-parse --show-toplevel 2>/dev/null)\" && bash .brain/scripts/log-session.sh'"}]}
    ]
  }
}
```

### Step 5 — Run Graphify and install hooks

```bash
cd "$REPO"
graphify update .                    # generates .brain/graph/{graph.json, GRAPH_REPORT.md, graph.html}
graphify hook install                # installs post-commit

# Preserve Graphify hook and chain brain hook
mv .git/hooks/post-commit .git/hooks/post-commit.graphify
cp "$REFERENCE/.git/hooks/post-commit" .git/hooks/post-commit
cp "$REFERENCE/.git/hooks/post-commit.brain" .git/hooks/post-commit.brain
chmod +x .git/hooks/post-commit .git/hooks/post-commit.graphify .git/hooks/post-commit.brain

# Move graphify-out into .brain/graph and symlink back
rm -rf .brain/graph
mv graphify-out .brain/graph
ln -s .brain/graph graphify-out
```

### Step 6 — Seed Dev Brain and CKIS

```bash
bash .brain/scripts/sync-obsidian-graph.sh  # writes Dev Brain code-graph/<slug>/
bash .brain/scripts/sync-graph-to-vault.sh  # writes CKIS 02-projects/<slug>/graph-report.md
```

### Step 7 — First commit to confirm the chain

```bash
git add .brain/ .claude/ .gitignore
git commit -m "feat: adopt per-project .brain/ second brain architecture"
# post-commit chain should fire automatically
```

### Global dependencies (install once)

```bash
uv tool install graphifyy==0.6.7
# wiki-brain skill: already at ~/.claude/skills/wiki-brain/ (global)
# Dev Brain vault: already at ~/Documents/Dev Brain/ (global)
```

━━━

## 8. Open Risks

| Risk | Mitigation |
| --- | --- |
| Graphify maturity | Pinned `graphifyy==0.6.7`; architecture is tool-replaceable |
| `sync-obsidian-graph.sh` depends on `graphify.export.to_obsidian` internal API | If API breaks on version bump, the Python script is isolated and replaceable without touching the rest of the system |
| Stop hook reliability | Dev Brain `SUMMARY_LINE` auto-generated via 4-tier fallback (compact → commit → last assistant turn → diffstat). No human input required. |
| Dev Brain vault not mounted | `sync-obsidian-graph.sh` exits 0 with a no-op message if vault not found — never fails the commit |
| CKIS vault not mounted | `sync-graph-to-vault.sh` exits 0 if `DEST_DIR` doesn't exist — never fails the commit |
| PolyForm-licensed tools | GitNexus excluded for this reason; Graphify is MIT |

━━━

## 9. Deployed Instances

| Repo | Status | Nodes | Notes |
| --- | --- | --- | --- |
| [your-project] | ✅ live | 376 | Pilot 2026-05-03; grew to 376 nodes by 2026-05-17 |
| [client-site] | ✅ live | 190 | Replicated 2026-05-03 |
| [your-project]-crm | ⏳ pending | — | Next after soak period |

**v2.2 additions (2026-05-17):** Both repos now registered in `projects.json`; `log-session.sh` indexes sessions into `Dev Brain/sessions/`; `sync-obsidian-graph.sh` calls `build-wiki-page.sh` after each Obsidian export; `AGENT_README.md` + `query-all.sh` enable cross-project agent queries.

━━━

## 10. Linked Notes

- [[00-ckis-master-context]] — top-level CKIS spec
- [[02-obsidian-vault-architecture]] — vault folder taxonomy (CKIS side)
- [[04-claude-code-obsidian-agent]] — agent behavior rules (CKIS side)
- [[06-decision-execution-and-review-protocol]] — decision-log format used in `.brain/decisions/`
- [[09-cross-model-shared-context-protocol]] — Claude ↔ ChatGPT context handoff
- [[02-projects/[your-project]/_overview]] — [YOUR_PROJECT] curated overview
- [[02-projects/[client-site]/_overview]] — [CLIENT_SITE] curated overview
- [[ai-specialization-automation-engineering]] — why this matters for [OWNER]'s specialization
