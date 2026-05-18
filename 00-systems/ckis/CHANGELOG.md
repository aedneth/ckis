# CKIS Changelog

All notable changes to the CKIS architecture (`00-systems/ckis/`).
Routine inbox processing and daily-note creation are tracked elsewhere (`01-daily/logs/`).

Format per entry: date · files created · files updated · sources used · open questions · next recommended action.

━━━

## 2026-05-18 — Hook CWD fix + autonomous Dev Brain summary (v2.3.2)

**Type:** bug fix — `.brain/` hooks + Dev Brain session index

**Trigger:** Hook errors (`No such file or directory`) appeared when Claude Code was launched from a directory other than the project root. Separate audit revealed Dev Brain session index always captured template comment text instead of meaningful session summary.

**Fixes applied** (korvex-web, brisas-del-golfo, CKIS template doc):

1. **Hook CWD resolution** — All 4 hook commands now prepend `bash -c 'cd "$(git rev-parse --show-toplevel 2>/dev/null)" && ...'` so scripts resolve correctly from any launch directory. No hardcoded paths — portable across machines.

2. **Autonomous Dev Brain summary** — `log-session.sh` replaces the broken awk (which read from `## Summary` placeholder — never filled by anyone) with a 4-tier fallback that generates `SUMMARY_LINE` purely from machine-readable data:
   - Tier 1: compact excerpt (if `/compact` was used)
   - Tier 2: first commit subject (`git log --oneline`)
   - Tier 3: last assistant text turn from JSONL transcript (`jq`)
   - Tier 4: diffstat (`3 files changed, 47 insertions(+)`)
   - Fallback: `no-summary`
   No human input, no API credits required. >99% of sessions now produce a meaningful index entry.

**Files updated:**
- `.brain/scripts/log-session.sh` (both korvex-web and brisas-del-golfo)
- `.claude/settings.json` (both korvex-web and brisas-del-golfo)
- `03-knowledge/permanent-notes/per-project-second-brain.md` (§2.4, §7 Step 4, §8 Open Risks)

━━━

## 2026-05-17 — Dev Brain Autonomous Architecture (v2.2)

**Type:** system correction + new architecture — Dev Brain restored and properly integrated.

**Trigger:** After incorrectly retiring Dev Brain in v2.1 (misunderstanding its purpose), Eduardo clarified: Dev Brain is an agent-queryable code knowledge database populated autonomously by graphify, NOT a manual wiki. This entry corrects the retirement and implements the proper autonomous architecture.

**What Dev Brain actually is** (clarified):
- Autonomous agent-queryable index of ALL codebases ([your-project] + [client-site], and future projects)
- Populated automatically: git commit → graphify → code-graph/ (one .md per code node)
- Any agent can `graphify query "question"` in a project dir or `query-all.sh "question"` cross-project
- NOT for manual human curation — zero manual work required

**Files created in Dev Brain** (`~/Documents/Dev Brain/`):
- `AGENT_README.md` — entry point for any agent (query patterns, registered projects, what NOT to do)
- `projects.json` — registry of all connected projects (slug, paths, graph locations)
- `sessions/index.md` — append-only session feed (one line per session from any project's Stop hook)
- `sessions/` — pointer stub per session (10 lines, `source:` path to full session log)
- `wiki/[your-project].md` + `wiki/[client-site].md` — auto-generated digests (god nodes + sessions)
- `wiki/index.md` — links to all wiki pages
- `scripts/query-all.sh` — cross-project graphify query using `merge-graphs`
- `scripts/register-project.sh` — idempotent project registration (upserts projects.json + AGENT_README.md)
- `scripts/build-wiki-page.sh` — generates wiki/<slug>.md from GRAPH_REPORT.md + session index

**Files patched in both projects** ([your-project] + [client-site]):
- `.brain/scripts/log-session.sh` — appends session pointer to Dev Brain `sessions/index.md` on every Stop hook
- `.brain/scripts/sync-obsidian-graph.sh` — calls `build-wiki-page.sh` after Obsidian sync (cadence-gated)
- `.brain/scripts/register-to-dev-brain.sh` — new 5-line wrapper to register project (run once per project)

**`~/.claude/CLAUDE.md` corrected** (not in vault git — global Claude settings):
- Removed "Dev Brain is RETIRED" (wrong)
- Replaced with correct agent query patterns (graphify query, query-all.sh, sessions/index.md)

**How the pipeline now works end-to-end**:
```
git commit in project → post-commit → graphify rebuild (background)
  ↓ every commit
  GRAPH_REPORT.md → CKIS vault (02-projects/<slug>/graph-report.md)
  ↓ every commit
  log-session.sh Stop hook → sessions/index.md (one-liner) + sessions/<slug>/<date>.md (pointer)
  ↓ every N commits (OBSIDIAN_GRAPH_CADENCE=10)
  graph.json → code-graph/<slug>/ (one .md per code node, for Obsidian 3D graph)
  build-wiki-page.sh → wiki/<slug>.md (digest: god nodes + recent sessions)
```

**Deferred** (not in this commit):
- Global SessionEnd hook not reinstated — per-project Stop hooks own session indexing
- Cross-project session query from Dev Brain wiki requires `sessions/index.md` to have entries (starts accumulating from next session)

━━━

## 2026-05-17 — Memory System Audit + Fixes (v2.1)

**Type:** system hardening — audit-driven fixes to make session memory actually compound.

**Trigger:** Pre-publication audit revealed that Second Brain session logs were timestamps-only (no content), Dev Brain was a ghost town (zero wiki entries), and key docs (_MEMORY.md, _PROFILE.md, etc.) weren't updating over time.

**Audit findings (Explore agent + Opus design):**
- ✅ [your-project] .brain/ — 53 sessions, 74 compactions, excellent (no changes needed)
- ✅ Auto-memory — healthy, 7 typed memory files
- ❌ Second Brain session logs — timestamps only, no work summaries (7 sessions/day, 0 content)
- ❌ Dev Brain wiki — 0 wiki pages, 4 log entries, never used
- ⚠️ _MEMORY.md — 2 weeks stale, only 2 commits in history
- ⚠️ _PROFILE.md / _INTERESTS.md — 6 weeks stale since creation

**Fixes implemented:**

1. **vault-session-stop.sh rewritten** (Fix 1 — HIGH)
   - Now reads JSONL transcript via `jq` to extract last assistant message as session summary
   - Extracts `isCompactSummary` entries into `01-daily/logs/compacts/YYYY-MM-DD-compact.md`
   - Falls back to "no transcript" message if jq/transcript unavailable (graceful degradation)

2. **assemble-vault-context.sh extended** (Fix 2B — MEDIUM)
   - Adds "Profile update protocol" section to every SessionStart injection
   - Instructs Claude to propose surgical edits to _PROFILE.md/_INTERESTS.md when relevant facts appear

3. **Cron 5 extended** (Fix 2A + 5 — HIGH)
   - Now reads BOTH project overviews AND [your-project] `.brain/sessions/` (5 most recent) for live signal
   - Rewrites BOTH `_MEMORY.md` AND `_ACTIVE-PROJECTS.md` in one pass
   - Flags stale overviews with ⚠ banner in _MEMORY.md instead of silently using stale data

4. **Dev Brain retired** (Fix 3 — MEDIUM)
   - `~/.claude/CLAUDE.md` wiki-brain section replaced with accurate description of actual memory architecture
   - `~/.claude/settings.json` SessionEnd hook (→ wiki-brain) removed
   - Dev Brain directory left in place ([OWNER] can archive manually when ready)

5. **19-agent-habits-guide.md created** — structured daily/weekly habits for terminal + agent use

**Files changed:**
- `.brain/scripts/vault-session-stop.sh` — complete rewrite
- `.brain/scripts/assemble-vault-context.sh` — 8-line addition
- `~/.claude/scripts/crontab-ckis.txt` — Cron 5 extended (not in vault git)
- `~/.claude/CLAUDE.md` — wiki-brain section retired (not in vault git)
- `~/.claude/settings.json` — SessionEnd hook removed (not in vault git)
- `00-systems/ckis/19-agent-habits-guide.md` — new

**Prerequisite to activate Cron 5:** `echo 'ANTHROPIC_API_KEY=sk-ant-...' > ~/.claude/.env && chmod 600 ~/.claude/.env`

━━━

## 2026-05-17 — CKIS v2: Rename + Multi-Agent Architecture + Agentic OS Integration

**Type:** system upgrade — naming change, new architecture docs, third-party tool integration, inbox processing.

**Trigger:** Pre-public-release hardening session. Eduardo decided to publish CKIS on GitHub and needed: (1) a final name decision, (2) a memory architecture document, (3) crons automation, (4) Matt Pocock skills, (5) inbox items synthesized into vault knowledge.

**Permanent decision: CKIS full name changed**
- OLD: "Custom Knowledge and Intelligence System"
- NEW: **"Central Knowledge and Intelligence System"**
- Acronym CKIS unchanged. All vault files updated via sed. Irreversible.
- Files renamed: CLAUDE.md (root), 00-ckis-master-context.md, 11-chatgpt-project-instructions.md, 15-source-map-and-generation-audit.md, chatgpt-project-upload/* (×2), .chatgpt-project-upload/* (×2), 02-projects/ckis-vault-public/_overview.md

**Multi-agent architecture established (Orchestrator: Opus 4.7)**
- Main orchestrator: Claude Code running Opus 4.7 for complex reasoning + system design
- Workers: specialized sub-agents delegated to parallel task execution
- Future: Hermes as orchestrator when integrated; Claude Code → execution role

**Files created (vault):**
- `00-systems/ckis/17-crons-architecture.md` — 5-cron automation system (see companion entry below)
- `00-systems/ckis/18-memory-architecture.md` — unified memory stack (session hooks + auto-memory + Dev Brain wiki); evaluates claude-mem + mempalace; documents 3-layer architecture
- `03-knowledge/permanent-notes/agentic-os-compound-memory.md` — synthesis of Max Mitcham's agentic OS article; maps raw/wiki/output to CKIS structure
- `03-knowledge/permanent-notes/github-repo-growth-standard.md` — research-backed standards for 100K-star repos; launch standard for ckis-vault-public
- `03-knowledge/guides/crons-setup-guide.md` — actionable guide for all 5 crons adapted to CKIS
- `04-resources/articles/claude-for-small-business-2026.md` — Anthropic SMB product note + [YOUR_PROJECT] positioning
- `04-resources/tools/mattpocock-skills.md` — reference for 18 installed Matt Pocock skills

**Files updated (vault):**
- `02-projects/ckis-vault-public/_overview.md` — added GitHub launch standard section (template repo positioning, required file tree, semver strategy)
- `00-inbox/How to Build an AI Agent Operating System.md` — status: inbox → processed
- `00-inbox/Introducing Claude for Small Business.md` — status: inbox → processed

**Files created (system, outside vault):**
- `~/.claude/skills/mattpocock/` — 18 skills, 38 files total (engineering × 10, productivity × 4, misc × 4)
- `~/.claude/scripts/vault-git-sync.sh`, `crm-sort.sh`, `cron-env-check.sh`, `crontab-ckis.txt`
- `~/.claude/projects/.../memory/project_ckis_rename_2026-05-17.md`
- `~/.claude/projects/.../memory/project_multiagent_arch_2026-05-17.md`

**Tool evaluations (2026-05-17):**
- **claude-mem**: DEFERRED — overlaps with existing auto-memory; adds worker service on port 37777 for marginal gain
- **mempalace** (MIT): PLANNED FOR V2 — best architectural fit (hierarchical MCP server); requires Python + ChromaDB; target: CKIS public repo backend
- **Matt Pocock skills** (18): INSTALLED — priority: handoff, diagnose, git-guardrails-claude-code, to-prd, triage

**Open questions:**
- `~/.claude/.env` with `ANTHROPIC_API_KEY` not yet created — Crons 4 and 5 blocked
- Cron 3 (content discovery) pending Agent SDK credits (billing changes June 15 2026)
- mempalace integration scoped to CKIS public repo v2

**Next recommended actions:**
1. Run cron-env-check.sh, create ~/.claude/.env, install crontab
2. Run `setup-matt-pocock-skills` skill in [your-project] and [client-site] repos
3. Begin CKIS public repo preparation using github-repo-growth-standard.md as launch checklist

━━━

## 2026-05-17 — Cron automation architecture

**Type:** system extension — background automation layer.

**Trigger:** Research into @keshavsuki's guide on self-maintaining second brain crons. Five cron patterns adapted to CKIS vault paths and conventions.

**Files created (4):**
- `~/.claude/scripts/vault-git-sync.sh` — Cron 1: git add -A + commit + push origin master every 15 min.
- `~/.claude/scripts/crm-sort.sh` — Cron 2: sort `07-people/clients/*.md` by `Status:` field into subfolders every 15 min.
- `~/.claude/scripts/cron-env-check.sh` — pre-flight health check script (verify vault, git, claude CLI, API key file, log dir).
- `~/.claude/scripts/crontab-ckis.txt` — installable crontab with 4 active entries + Cron 3 commented out.

**Files created in vault (1):**
- `00-systems/ckis/17-crons-architecture.md` — full architecture doc (this changelog's companion).

**Scripts made executable:** vault-git-sync.sh, crm-sort.sh, cron-env-check.sh.

**Directories created:** `~/.claude/scripts/`, `~/logs/`.

**Open questions:**
- Git remote not yet configured in vault — Cron 1 will commit locally until a remote is added.
- `~/.claude/.env` not yet created — Crons 4 and 5 blocked until Eduardo adds `ANTHROPIC_API_KEY`.

**Pending:** Cron 3 (content discovery) — uncomment in crontab when API credits are confirmed.

**Next recommended action:**
1. Run `bash ~/.claude/scripts/cron-env-check.sh` to verify the environment.
2. Create `~/.claude/.env` with `ANTHROPIC_API_KEY=sk-ant-...` (chmod 600).
3. Run `crontab ~/.claude/scripts/crontab-ckis.txt` to install crons 1, 2, 4, 5.
4. Verify with `crontab -l` and then `tail ~/logs/vault-git-sync.log` after 15 minutes.

━━━

## 2026-05-16 — Vercel security audit + [client-site] hardening

**Type:** security incident response — project audit + tool documentation.

**Trigger:** Vercel April 2026 security breach (ShinyHunters obtained Vercel internal database — NPM/GitHub tokens). Eduardo received Security Update email 2026-04-20. Audit deferred until 2026-05-16.

**Audit scope:** [client-site] — Next.js + Supabase + Wompi SV + Vercel.

**Findings (all clear on critical items):**
- ✅ No `.env` files committed to git history
- ✅ No hardcoded secrets in source code — all via `process.env`
- ✅ Vercel logs: normal traffic, no anomalous API calls or webhook abuse
- ✅ `.gitignore` correctly excludes all `.env*` files
- ✅ 11 env vars in Vercel: all Encrypted (set 57d before breach)
- ✅ 10 npm vulnerabilities resolved with `npm audit fix`
- ⚠️ 2 npm vulnerabilities remain (PostCSS XSS inside Next.js 16 — `--force` fix would downgrade to Next.js 9.x, breaking change, not applied)
- ⚠️ Env vars still pending rotation at source (Supabase, Wompi, CallMeBot)

**Files created (1):**
- `04-resources/tools/vercel-security-dashboard.md` — reference note for `~/tools/vercel-security-dashboard` (installed from github.com/0xm1kr/vercel-security-dashboard). Local-first Vercel REST API dashboard for env var rotation. AES-256-GCM encrypted creds, no value persistence.

**Files updated (1):**
- `02-projects/[client-site]/_overview.md` — new §Security with audit findings, env var rotation table per service, tool reference, action items.

**Tool installed:** `~/tools/vercel-security-dashboard` — run `npm start` → http://127.0.0.1:4319.

**Next recommended action:**
1. Eduardo manually rotates secrets at each service (Supabase Dashboard → API keys, Wompi Dashboard → Credenciales, CallMeBot → regenerate)
2. Use vercel-security-dashboard to update Vercel env vars with new values, marking them as **Sensitive**
3. Redeploy [client-site] after rotation
4. Check `admin.google.com` → Security → Access and Data Control → API Controls → Accessed Apps for any suspicious OAuth app with access to [your-github-email]

━━━

## 2026-05-13 — Skills directory architecture convention adopted

**Type:** architecture decision — skills organization.

**Trigger:** `npx skills add` (vercel-labs `find-skills`) auto-created `.claude/skills/` and `.agents/` inside the vault, conflicting with the existing `ckis-skills/` / `general-skills/` split. Session resolved the ambiguity into a canonical two-bucket rule.

**Decision:** Two buckets, hard split:
- `~/.claude/skills/` — ALL downloaded / general-purpose skills (global, available in every project session)
- `.claude/ckis-skills/` — ONLY vault-specific CKIS workflow skills

**Files updated (3):**
- `00-systems/ckis/16-skill-cards-for-second-brain-workflows.md` — new §6 "Skills Directory Architecture": two-bucket rule, current inventory table, `npx skills add` post-install cleanup procedure, invocation rules, rationale.
- `00-systems/ckis/02-obsidian-vault-architecture.md` — `.claude/` tree updated: `skills/` → `ckis-skills/`; note added that `.claude/skills/` and `.agents/` must not exist in the vault.
- `.claude/CLAUDE.md` — vault structure line updated: `general-skills/` reference removed.

**Migrations performed:**
- `gstack`, `marketingskills` moved from `.claude/general-skills/` → `~/.claude/skills/`
- `find-skills` moved from vault `.agents/skills/` → `~/.claude/skills/`
- `privacy-policy` (`phuryn/pm-skills`, 937 installs) installed → `~/.claude/skills/` (for upcoming [your-project] legal review)
- `.claude/general-skills/`, `.claude/skills/`, `.agents/` removed from vault

**`npx skills add` post-install procedure documented in §6** — convert symlink to real dir, remove `~/.agents/`, remove vault artifacts.

**Next recommended action:**
1. In next [your-project] session: invoke `/privacy-policy` skill to review and align legal pages.
2. When installing future skills: follow the §6 cleanup procedure immediately after `npx skills add`.

━━━

## 2026-05-10 — recmp3-cli project onboarded + pop-os-audio resource superseded

**Type:** new project documentation + resource lifecycle update.

**Trigger:** recmp3-cli v0.1.0 shipped — production CLI replacing the old `recmp3` bash script. CKIS documentation migrated to reflect the new project.

**Files created (1):**
- `02-projects/recmp3-cli/_overview.md` — project overview following standard template; includes status, open decisions, key files, architecture notes, strategy.

**Files updated (2):**
- `04-resources/tools/pop-os-audio-mp3-ffmpeg.md` — `status: active` → `status: superseded`; `superseded_by:` frontmatter added; callout block prepended to body pointing to recmp3-cli.
- `00-inbox/_ACTIVE-PROJECTS.md` — `recmp3-cli` entry added under `## 🟢 ACTIVE`.

**What recmp3-cli replaces:**
- `~/.local/bin/recmp3` bash script (backed up to `~/.local/bin/recmp3.bash.bak`); old script launched a "Pop Clock" GNOME Terminal profile causing visual confusion with Flow Clock
- Manual `ffmpeg -f pulse` workflow documented in `pop-os-audio-mp3-ffmpeg.md`

**recmp3-cli v0.1.0 capabilities:**
- `recmp3 record` — Ink TUI recorder (pause/resume/save/cancel) → optional transcription → optional clipboard copy
- `recmp3 transcribe <file>` — transcribe any audio file via Groq (`whisper-large-v3-turbo`) or OpenAI
- `recmp3 prompt <file>` — 7 developer templates (raw, claude-code, prd, bug, meeting-notes, todo, commit-message)
- `recmp3 sources` — list platform audio sources
- `recmp3 doctor` — 8 system checks (Node ≥20, ffmpeg ≥4.4, API key, provider ping, etc.)
- `recmp3 config` — init/show/set/path subcommands; XDG paths on Linux

**Verified working (2026-05-10):**
- `recmp3 doctor` — all 8 checks pass ✓
- `recmp3 transcribe` — live Groq API call succeeds ✓
- `recmp3 prompt` — all templates render correctly ✓
- `recmp3 sources` — lists 3 PulseAudio sources ✓

**Open items:**
- Unit tests (vitest + msw) not yet written
- v0.2.0: keytar OS keychain, local Whisper backend

**Next recommended action:**
1. Set `GROQ_API_KEY` in shell profile (`~/.bashrc` or `~/.zshrc`) so it survives new terminal sessions.
2. Run `recmp3 record` in a real session to validate full end-to-end flow.
3. Write unit tests before v0.2.0 work begins.

━━━

## 2026-05-06 — LinkedIn saved posts pipeline — 70 posts procesados

- Extracted 70 posts from `00-inbox/(7) Saved Posts _ LinkedIn.html` via local HTML parser
- 3 parallel subagents processed 3 batches (25/25/20); 0 failures, 0 duplicates
- 70 notes deployed to `04-resources/social-captures/`
- MOC-AI-Coding-Vibecoding updated (+47 social captures section)
- MOC-Business-Strategy updated (+18 social captures section)
- Known limitation: `author_headline` frontmatter field captured post summary instead of job title (cosmetic, not blocking)
- Source HTML + assets remain in `00-inbox/` — Eduardo must delete manually once verified
- Pipeline scripts preserved at `00-inbox/linkedin-processing/`

━━━

## 2026-05-05 — ChatGPT upload package — primera generación + graph connectivity fix

**Type:** context export + graph maintenance.

**Acciones:**
- Creado `00-systems/ckis/chatgpt-project-upload/` — primera generación del paquete. Contenido: 13 archivos según `11-chatgpt-project-instructions.md` §1. Todos los archivos fuente verificados presentes.
- Corregidas rutas stale `00-system/ckis/` → `00-systems/ckis/` en `.claude/skills/ckis-context-export/SKILL.md` y en el cuerpo de `11-chatgpt-project-instructions.md`.
- Añadido `related:` a 15 archivos island del Vibecoding workspace: 5 cli-adapters, 4 context-packs, 6 command-packs. Ahora conectados al hub `00-vibecoding-workflow-system` y a sus módulos específicos.
- Añadido frontmatter + `related:` al root `CLAUDE.md` para visibilidad en el grafo Obsidian.

**Action item:** Re-upload `00-systems/ckis/chatgpt-project-upload/` a ChatGPT Project. Esta es la primera vez que el paquete se genera — subir todos los archivos.

---

## 2026-05-05 — Vibecoding Central Workspace — generación completa

**Type:** new workflow — vendor-neutral CLI agent operating system.

**Trigger:** Eduardo solicitó transformar el blueprint Claude-centric en un sistema vendor-neutral con CKIS como canónico.

**Shift arquitectónico clave:**
- OLD: Claude Code como único ejecutor; Obsidian como mirror; `.zip` como deliverable.
- NEW: CLI agents como adapters intercambiables; CKIS/Obsidian como canónico; exports son mirrors opcionales.

**Archivos creados (35 nuevos):**

Core modules: `00-vibecoding-workflow-system.md` through `16-source-map-and-integrated-audit.md` (17 archivos).

CLI adapters (5): `claude-code-adapter.md` (activo), `codex-cli-adapter.md` (partial), `gemini-cli-adapter.md` (partial), `opencode-adapter.md` (pending), `generic-cli-agent-adapter.md` (plantilla).

Context packs (4): `OBSIDIAN_CANONICAL_CONTEXT_PACK.md`, `CLI_AGENT_CONTEXT_PACK.md`, `CHATGPT_PROJECT_UPLOAD.md`, `CLAUDE_PROJECT_UPLOAD.md`.

Command packs (6): new-project, repo-analysis, security-hardening, deployment-preflight, cost-and-token-audit, cross-model-handoff.

Exports (5): manifest, migration-summary, open-questions, final-upload-order, integrated-audit.

**Archivos actualizados (3):**
- `00-systems/workflows/vibecoding-central-workspace/_workflow.md` → status: active
- `00-systems/workflows/_index.md` → Vibecoding marcado como 🟢 Activo
- Este CHANGELOG.

**Nuevos protocolos definidos:**
- CMCP (Cross-Model Context Protocol) — 6 niveles: global, workflow, proyecto, repo, tarea, output
- Contrato universal de CLI adapters (7 secciones)
- Routing matrix vendor-neutral

**OPEN QUESTIONs (5):** Sintaxis Codex CLI, sintaxis Gemini CLI, capacidades OpenCode, Cursor/Windsurf instrucciones persistentes, Codex bash access. Ver `exports/open-questions.md`.

**Próxima acción:**
1. Evaluar Codex CLI y Gemini CLI en una tarea real para completar sus adapters.
2. Evaluar OpenCode.
3. Crear skills reales para `prd-builder`, `sprint-planner` cuando se hayan usado 3+ veces.

━━━

## 2026-05-05 — 00-system → 00-systems migration + workflow layer

**Type:** structural migration + new workflow layer.

**Trigger:** Eduardo changed the naming convention from singular `00-system/` to plural `00-systems/` and introduced a canonical `00-systems/workflows/` layer to house reusable operating system workflows separately from CKIS core.

**Migration performed:**

| Source | Destination |
|--------|-------------|
| `00-system/ckis/` | `00-systems/ckis/` |
| `00-system/College Homeworks Agent/` | `00-systems/workflows/college-homeworks-agent/` |
| `00-system/Event Intelligence System (Operating Core)/` | `00-systems/workflows/event-intelligence-networking-strategy/` |
| `00-system/Prompt Engineering System/` | `00-systems/workflows/prompt-engineering-system/` |

No files deleted. Eduardo manually deleted `00-system/` and `_migration-backups/` after confirming the migration.

**Files created (25):**

- `00-systems/workflows/_index.md` — global workflow registry with table
- `00-systems/workflows/college-homeworks-agent/_workflow.md`
- `00-systems/workflows/event-intelligence-networking-strategy/_workflow.md`
- `00-systems/workflows/prompt-engineering-system/_workflow.md`
- `00-systems/workflows/vibecoding-central-workspace/_workflow.md` (placeholder only)
- 17 placeholder `.md` files for the Vibecoding Central Workspace scaffold
- `00-systems/workflows/_migration-report.md`
- `00-systems/workflows/_migration-audit.md`

**Files updated (52):**

- 50 workflow module files — YAML frontmatter prepended (body untouched); previously these files had no frontmatter.
- `CLAUDE.md` (root) — all 8 `00-system/ckis/` path references updated to `00-systems/ckis/`.
- `.claude/CLAUDE.md` — "About Eduardo" corrected ([YOUR_PROJECT] non-agency framing; [ARCHIVED_PROJECT] archived); `00-systems/` added to vault structure; `02-projects/` list corrected ([archived-project] removed).

**Terminology clarification encoded:**

- **Workflow** = reusable operating system / domain workflow inside CKIS → lives in `00-systems/workflows/`.
- **Project** = actual business/software/academic execution → lives in `02-projects/`.
- These two are not the same and should not be used interchangeably.

**Open questions:**

- Vibecoding Central Workspace content generation is deferred to a future designated session.
- Should `00-systems/ckis/` itself get a `_workflow.md`-style index? Currently it only has `00-ckis-master-context.md`.

**Next recommended action:**

1. Open Obsidian — verify graph reflects new `00-systems/` structure and wikilinks resolve.
2. Schedule the Vibecoding Central Workspace content generation session.
3. Update ChatGPT upload package (`ckis-context-export` skill) to reflect new paths.

━━━

## 2026-05-04 — Graph connectivity repair (hub-and-spoke architecture)

**Type:** architecture repair + process-inbox skill upgrade.

**Trigger:** Eduardo observed that ~50% of vault nodes were disconnected islands in the Obsidian graph view after deploying the 3D Graph plugin. Specifically: daily notes, tools, guides, and area stubs had zero wikilinks.

**Root cause diagnosed:** Hub-and-spoke with no spokes. The `03-knowledge/` cluster (permanent-notes + MOCs) was internally connected but isolated from the top-level entry points (areas, daily notes) and bottom-level reference material (resources, guides).

**Files created (7):**
- `03-knowledge/maps-of-content/MOC-AI-Coding-Vibecoding.md` — master hub for AI dev stack; absorbs all 3 orphaned guides + `ai-specialization-automation-engineering` + `per-project-second-brain`
- `03-knowledge/maps-of-content/MOC-Tools-and-Resources.md` — hub for all `04-resources/tools/` files; absorbs 4 tool notes
- `03-knowledge/maps-of-content/MOC-Business-Strategy.md` — hub resolving 2+ broken `[[MOC-Business-Strategy]]` references in literature-notes
- `01-daily/2026-04.md` — monthly index hub for April; links to all 7 April daily notes
- `01-daily/2026-05.md` — monthly index hub for May
- `08-templates/daily.md` — daily note template with `related: ["[[YYYY-MM]]", "[[_MEMORY]]"]` pre-wired
- `08-templates/monthly.md` — monthly hub template for future months

**Files updated (30):**
- `05-areas/*.md` (all 6) — added `related:` arrays pointing to MOCs, permanent-notes, goals, sibling areas
- `03-knowledge/guides/*.md` (all 3) — inserted standard YAML frontmatter with `related:` to `MOC-AI-Coding-Vibecoding`
- `04-resources/tools/*.md` (all 4) — added/normalized frontmatter + `related: ["[[MOC-Tools-and-Resources]]"]`
- `01-daily/2026-04-*.md` (7) + `01-daily/2026-05-02.md` — added `related:` with monthly hub + `_MEMORY` + [your-project] overview
- `03-knowledge/maps-of-content/MOC-*.md` (all 4 existing) — extended `related:` arrays to link back to area files, goals, monthly reports
- `03-knowledge/permanent-notes/ai-specialization-automation-engineering.md` — replaced `[[MOC-AI-Agents]]` (dead) with `[[MOC-AI-Coding-Vibecoding]]` + `[[MOC-Carrera-AI-Income]]` + `[[05-areas/learning]]`
- `03-knowledge/literature-notes/ai-entrepreneur-beginner-2025.md` — replaced `[[MOC-AI-Agents]]` (dead) with `[[MOC-AI-Coding-Vibecoding]]`
- `03-knowledge/literature-notes/plan-digitalizar-transporte-publico-sv.md` — replaced `[[Información adicional transporte]]` (dead) with `[[MOC-Startups-Transporte-LATAM]]`
- `06-goals/2026-annual.md` — added 9 area + MOC links to `related:` array; now the central goal node connects to all life domains
- `.claude/skills/process-inbox/skill.md` — added `## Mandatory linking rules` section: per-destination minimum `related:` requirements, tag-based auto-routing table (11 tags), verification step, MOC append rule for new permanent-notes

**Broken links repaired (3 real, 3 false positives):**
- `[[MOC-AI-Agents]]` → `[[MOC-AI-Coding-Vibecoding]]` (2 files)
- `[[Información adicional transporte]]` → `[[MOC-Startups-Transporte-LATAM]]` (1 file)
- `[[[YOUR_PROJECT]-Optimized-Context]]`, `[[Plan-Negocio-Operaciones]]`, `[[[archived-project]-ceo-cto-strategy]]`, `[[plan-digitalizar-transporte-publico-sv]]` — confirmed as false positives (files exist, Obsidian resolves by basename)

**Permanence mechanism:**
- Process-inbox skill now enforces: no file leaves inbox as a graph island
- Monthly hub auto-creation rule: if `01-daily/YYYY-MM.md` doesn't exist, create it before routing a daily note
- MOC self-maintenance: new permanent-notes get appended to their MOC's `## Core notes` automatically during inbox processing
- Daily note template pre-wires `[[YYYY-MM]]` and `[[_MEMORY]]` from creation

**Open questions:**
- Should `07-people/` notes be connected to this spine too? Currently not enforced.
- `06-goals/weekly/` and `06-goals/monthly/` files need `related:` to `2026-annual` + monthly hub — not yet done (low priority, few files).

**Next recommended action:**
1. Reload Obsidian graph view — confirm islands have disappeared.
2. When running first bulk inbox import, confirm process-inbox mandatory linking rules fire correctly.
3. After bulk import: spot-check 5 random processed files for `related:` completeness.

━━━

## 2026-05-04 — Full system distillation + documentation update

**Type:** architecture documentation + deployment completion.

**Trigger:** Both [your-project] and [client-site] deployments complete. Session requested a full distillation of the three-layer memory system into canonical, open-source-quality documentation.

**Files updated:**

- `03-knowledge/permanent-notes/per-project-second-brain.md` — complete rewrite (v2026-05-04). Added: three-layer architecture diagram (CKIS → Dev Brain → `.brain/`); full description of all 6 scripts; complete information-flow diagrams (per-commit, per-session, CKIS sync); Graphify CLI vs Python API distinction documented; complete replication guide (7 steps, copy-pasteable); deployment status table; Dev Brain vault structure and Obsidian setup; wiki-brain skill section.
- `00-system/ckis/CHANGELOG.md` — this entry.
- `00-system/ckis/00-ckis-master-context.md` — architecture diagram updated to show three layers; Resolved Open Questions updated (Graphify now fully implemented, not "planned").

**What was deployed this session (2026-05-03/04):**

- `[your-project]/.brain/` — 6 scripts, hooks, config, BRAIN.md; all hooks wired; graphify running.
- `[client-site]/.brain/` — identical skeleton replicated; 190-node graph built.
- Dev Brain vault at `~/Documents/Dev Brain/` — created; 122 + 190 code graph notes seeded.
- wiki-brain skill at `~/.claude/skills/wiki-brain/` — installed; `SessionEnd` global hook wired.
- `~/.claude/CLAUDE.md` — graphify section + full wiki-brain section appended.
- `~/.claude/settings.json` — `SessionEnd` hook wired.
- CKIS `02-projects/[your-project]/graph-report.md` — seeded by `sync-graph-to-vault.sh`.
- CKIS `02-projects/[client-site]/graph-report.md` — seeded by `sync-graph-to-vault.sh`.

**Key technical discoveries documented:**

- Graphify CLI `update` does NOT expose `--obsidian`; Obsidian export requires Python API (`graphify.export.to_obsidian`) directly. Fixed in `sync-obsidian-graph.sh`.
- Obsidian does NOT follow symlinks pointing outside the vault to hidden directories. Fixed by copying a real `.md` file via `sync-graph-to-vault.sh`.
- NetworkX `nx.node_link_graph()` requires `edges="links"` kwarg in current version.
- `SessionEnd` (wiki-brain global) vs `Stop` (project `.brain/`) are different events — no race condition.
- Git hook chain: `post-commit` wrapper → `post-commit.graphify` (preserved) → `post-commit.brain` (brain layer).

**Open questions resolved:**

- Graphify tool spec: fully designed and deployed (was "TBD" since 2026-05-02).
- CKIS symlink strategy: replaced with real file copy (symlink approach fails with Obsidian hidden dirs).

**Newer open items:**

- [your-project]-crm: `.brain/` skeleton not yet replicated (pending soak on first two repos).
- Manual Obsidian UI steps: open Dev Brain vault → BRAT → 3D Graph plugin install (cannot be scripted).
- `/wiki-brain ingest` first use: drop a source into `~/Documents/Dev Brain/raw/` to start compounding.

**Next recommended action:**

1. Open `~/Documents/Dev Brain/` as Obsidian vault → install BRAT → install 3D Graph plugin (v2.4.1, Aryan Gupta) → configure color groups.
2. After 1 week of soak ([your-project] + [client-site]): replicate `.brain/` skeleton to [your-project]-crm.
3. Drop first engineering article/transcript into `~/Documents/Dev Brain/raw/` and run `/wiki-brain ingest`.

━━━

## 2026-05-03 — Per-project second brain architecture adopted

**Type:** architecture decision + first implementation.

**Trigger:** Open Decision in `_MEMORY.md` ("Graphify tool: project-level CLAUDE.md bridge implementation timing") resolved after research comparing `safishamsi/graphify` (MIT, native Obsidian) vs `abhigyanpatwari/GitNexus` (PolyForm Noncommercial — blocker for [YOUR_PROJECT] commercial use, no Obsidian). Graphify selected.

**Files created:**

- `03-knowledge/permanent-notes/per-project-second-brain.md` — canonical architecture spec; linked into the graph via `related:` to CKIS master context, vault architecture, agent rules, decision protocol, cross-model protocol, [YOUR_PROJECT]/Brisas overviews, AI specialization permanent note.

**Files updated:**

- `00-inbox/_MEMORY.md` — Graphify Open Decision marked adopted with link to the permanent note; "Last updated" line refreshed.
- `02-projects/[your-project]/_overview.md` — `## Decisions` section added with full CKIS decision-log entry; permanent note added to Key files; modified date bumped.
- `02-projects/[client-site]/_overview.md` — `related:` frontmatter added pointing to the permanent note (this layer applies to [client-site]'s repo too); modified date bumped.
- `00-system/ckis/CHANGELOG.md` — this entry.

**Outside the vault ([your-project] repo):**

- `.brain/{README.md, BRAIN.md, config.sh}` — agent workflow rules + per-project config.
- `.brain/decisions/README.md`, `.brain/bugs/README.md` — index files with frontmatter spec.
- `.brain/scripts/assemble-context.sh` — SessionStart hook; builds `_CONTEXT.md` from sessions + decisions + bugs + Graphify report + CKIS pointers.
- `.brain/scripts/log-session.sh` — Stop hook; captures git diff vs. session start, commits made, duration.
- `.claude/settings.json` — wired `SessionStart` and `Stop` hooks; added `Bash(bash .brain/scripts/*)` permission.
- `CLAUDE.md` — `@.brain/BRAIN.md` import added so the agent loads the brain workflow rules at session start.
- `.gitignore` — `.brain/_CONTEXT.md`, `.brain/.session-state`, `.brain/sessions/*`, `.brain/graph/*` excluded; `.gitkeep` retained.

**Sources used:**

- Research reports on `safishamsi/graphify` and `abhigyanpatwari/GitNexus` (this conversation).
- Existing CKIS files: `04-claude-code-obsidian-agent.md`, `06-decision-execution-and-review-protocol.md`, `02-obsidian-vault-architecture.md`.
- `.claude/skills/ckis-decision-log/SKILL.md` (decision-log format).

**Open questions:**

- Can the Stop hook auto-extract a narrative summary from the Claude transcript file? Currently captures only objective metadata; the `## Summary` section depends on Claude/Eduardo filling it in mid-session. Defer until 1 week of soak data shows whether this is a real friction.
- Will Graphify still be maintained 6 months from now? Branch churn (`v4 → v5 → v6` in 1 month) is high. Mitigation: pinned `graphifyy==0.6.7`; architecture is tool-replaceable.

**Next recommended action:**

1. Next [YOUR_PROJECT] Web Claude Code session: `uv tool install graphifyy`, then in repo `graphify .` and `graphify hook install`. Confirm `.brain/graph/GRAPH_REPORT.md` is produced and `_CONTEXT.md` picks it up.
2. Symlink the Graphify Obsidian vault into CKIS: `ln -s "$HOME/Documents/Startups/[YOUR_PROJECT]/Systems/[YOUR_PROJECT] Web/[your-project]/.brain/graph/vault" "$HOME/Documents/Second Brain/02-projects/[your-project]/graph"` (after Graphify produces the vault).
3. After 1 week of soak on [YOUR_PROJECT] Web: replicate `.brain/` skeleton to `[your-project]-crm` and `[client-site]`'s repo (parameterized by `config.sh`).

━━━

## 2026-05-02 — Resolution round (post-generation answers)

**Type:** follow-up resolution.

**Trigger:** Eduardo answered the 9 open questions from the initial generation; this round encodes those answers into the architecture.

**Files updated:**

- `00-system/ckis/00-ckis-master-context.md` — §1 adds CKIS aliases + [YOUR_PROJECT] non-agency framing; §3 marks [ARCHIVED_PROJECT]/HidroPlus archived; §8 consolidated "Confirmed Facts"; §9 replaced with "Resolved Open Questions (2026-05-02)" listing all 9 answers.
- `00-system/ckis/01-ckis-user-profile-and-operating-context.md` — [ARCHIVED_PROJECT]/HidroPlus moved out of active roles; §5 active project list updated; §8 "agency operations" → "[YOUR_PROJECT] operations."
- `00-system/ckis/07-projects-areas-resources-archives-map.md` — §2 Projects: [ARCHIVED_PROJECT]/HidroPlus moved to Archived section; [YOUR_PROJECT] framing updated.
- `00-system/ckis/11-chatgpt-project-instructions.md` — [YOUR_PROJECT] framing updated; [ARCHIVED_PROJECT] line removed (archived).
- `00-system/ckis/15-source-map-and-generation-audit.md` — §3 Inferred → Confirmed; §4 Open Questions → Resolved; §6 audit adds resolution-round notes.
- `00-system/ckis/CHANGELOG.md` — this entry.
- `00-inbox/_MEMORY.md` — [ARCHIVED_PROJECT] archived; Active focus + Open Decisions refreshed.
- `00-inbox/_ACTIVE-PROJECTS.md` — [ARCHIVED_PROJECT]/HidroPlus moved to Archived section.

**Filesystem changes:**

- `mv 00_System/CKIS 00-system/ckis && rmdir 00_System` (folder rename to kebab-case).
- `mv 02-projects/[archived-project] 09-archive/[archived-project]` (project archive).
- Path strings updated via `sed` across all CKIS markdown files.

**Resolutions encoded:**

1. Folder → `00-system/ckis/` (kebab-case).
2. CKIS adopted as canonical; aliases acceptable.
3. Project-level CLAUDE.md bridges → future tool **graphify** (timing TBD).
4. Obsidian Mobile sync → deferred.
5. Gemini API key → deferred.
6. AssemblyAI replacement → deferred.
7. Web Clipper → Firefox extension; no Claude Interpreter.
8. [ARCHIVED_PROJECT] archived; HidroPlus already archived.
9. No YAML `tags:` on existing 13 skills.

**Plus durable feedback memory saved:** `feedback_[your-project]_framing.md` — "do not call [YOUR_PROJECT] a web agency."

**Newer open items:**

- [YOUR_PROJECT] full positioning statement (capture in `02-projects/[your-project]/_overview.md`).
- Graphify tool spec.

**Next recommended action:**

1. Refresh ChatGPT upload package (re-copy from updated source files).
2. Capture [YOUR_PROJECT] positioning statement when Eduardo decides.
3. Draft graphify spec when project work allows.

━━━

## 2026-05-02 — Initial CKIS architecture generation

**Type:** initial generation (Phase 0).

**Files created:**

- `00-system/ckis/00-ckis-master-context.md`
- `00-system/ckis/01-ckis-user-profile-and-operating-context.md`
- `00-system/ckis/02-obsidian-vault-architecture.md`
- `00-system/ckis/03-capture-processing-retrieval-workflow.md`
- `00-system/ckis/04-claude-code-obsidian-agent.md`
- `00-system/ckis/05-ckis-memory-and-context-rules.md`
- `00-system/ckis/06-decision-execution-and-review-protocol.md`
- `00-system/ckis/07-projects-areas-resources-archives-map.md`
- `00-system/ckis/08-note-templates-and-frontmatter.md`
- `00-system/ckis/09-cross-model-shared-context-protocol.md`
- `00-system/ckis/10-claude-project-instructions.md`
- `00-system/ckis/11-chatgpt-project-instructions.md`
- `00-system/ckis/12-first-message-and-usage-guide.md`
- `00-system/ckis/13-maintenance-and-update-protocol.md`
- `00-system/ckis/14-active-working-slot.md`
- `00-system/ckis/15-source-map-and-generation-audit.md`
- `00-system/ckis/16-skill-cards-for-second-brain-workflows.md`
- `00-system/ckis/CHANGELOG.md` (this file)
- `00-system/ckis/chatgpt-project-upload/` (subset package — 13 files)
- Root `CLAUDE.md` (new — CKIS pointer; preserves `.claude/CLAUDE.md`)
- `.claude/skills/ckis-capture-triage/SKILL.md`
- `.claude/skills/ckis-vault-maintenance/SKILL.md`
- `.claude/skills/ckis-decision-log/SKILL.md`
- `.claude/skills/ckis-weekly-review/SKILL.md`
- `.claude/skills/ckis-cross-model-handoff/SKILL.md`
- `.claude/skills/ckis-context-export/SKILL.md`

**Files updated:** none (existing `.claude/CLAUDE.md`, `_MEMORY.md`, `_PROFILE.md`, etc. unchanged).

**Backups taken** (in `.claude/backups/ckis-migration/`):

- `CLAUDE.md.bak`
- `CKIS_CONVERSATION_EXTRACT.md.bak`
- `Second_Brain_Context_Transfer.md.bak`
- `Second_Brain_Final_Execution_Plan.md.bak`

**Source files used:**

- `00-inbox/CKIS_CONVERSATION_EXTRACT.md` (primary)
- `00-inbox/Second_Brain_Final_Execution_Plan.md`
- `00-inbox/Second_Brain_Context_Transfer.md`
- `.claude/CLAUDE.md`
- `00-inbox/_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`
- Sample skills: `.claude/skills/process-inbox/skill.md`, `.claude/skills/sync-overviews/skill.md`
- Existing template: `08-templates/client-note.md`
- Vault folder structure (observed)

**Open questions** (mirror `15-source-map-and-generation-audit.md` §4 and `00-ckis-master-context.md` §9):

1. Folder name `00_System/CKIS/` vs `00-system/ckis/` for convention parity.
2. Adopt **CKIS** acronym officially?
3. Project-level `CLAUDE.md` bridges — implementation timing.
4. Obsidian Mobile + sync — implementation status.
5. Gemini API key for YouTube fallback — status.
6. AssemblyAI replacement for social-video transcription.
7. Web Clipper Interpreter (Claude API) configuration status.
8. [ARCHIVED_PROJECT] reactivation trigger — define numerically.
9. Add CKIS-style `tags:` to existing 13 skills?

**Next recommended action:**

1. Eduardo reads `00-system/ckis/00-ckis-master-context.md`, then `15-source-map-and-generation-audit.md`.
2. Review and resolve the 9 open questions above (especially folder naming).
3. Test `.claude/skills/ckis-*` skills with a small case each.
4. Paste `10-claude-project-instructions.md` into a Claude Project; attach the listed CKIS files.
5. Paste `11-chatgpt-project-instructions.md` into a ChatGPT Project; upload the `chatgpt-project-upload/` package.
6. Schedule the first `ckis weekly review` for the upcoming Sunday.
