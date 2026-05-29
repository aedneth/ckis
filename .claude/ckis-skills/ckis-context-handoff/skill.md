---
name: ckis-context-handoff
description: >
  Extract ALL accumulated knowledge from the current Claude Code session and write a
  structured 9-section handoff document so a fresh session can resume with the full
  compounded context. Use when [OWNER] says "ckis-context-handoff", "create handoff",
  "context handoff", "session is too large", "need a handoff doc", or "continue in new tab".
  Reads recent compacts, git state, active sprint, and inbox memory; produces a single
  paste-ready `.md` file at `00-systems/ckis/YYYY-MM-DD-handoff-{gate}.md`. Updates
  CKIS CHANGELOG.
argument-hint: "optional: gate or topic for the handoff (e.g. g2, [your-project]-pitch, pi-sprint)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.0.0
  ckis-context: true
  category: workflow-automation
---

# CKIS Context Handoff

> Standard protocol for compressing a saturated session into a paste-ready handoff document — created after [OWNER]'s G2 research sprint reached ~50MB and a cold restart lost in-session decisions, intermediate vault states, and a paste-ready research brief. Without a handoff doc, a new session reads CLAUDE.md + recent logs but misses the compounded session work. This skill fixes that by writing every load-bearing fact to a single file the next agent can read in 30 seconds.

━━━

## Scope

This skill operates on the current session's accumulated state and produces ONE output file:
`00-systems/ckis/YYYY-MM-DD-handoff-{gate-or-topic}.md`.

**Inputs read**:
- `01-daily/logs/compacts/` — ALL compacts from the current session (can be 20+)
- `git log --oneline -10` + `git status`
- Most recent sprint doc in `02-projects/[your-project]/` (or relevant project folder)
- `00-inbox/_MEMORY.md`, `00-inbox/_ACTIVE-PROJECTS.md`

**Do NOT touch**:
- `.obsidian/` folder
- `_PROFILE.md`, `_MEMORY.md` (read-only here)
- Any source file unrelated to the handoff
- Files with `status: archived`

━━━

## Pre-conditions

Before running, verify:
1. [ ] [OWNER] has stated the gate / topic for the handoff (or you can infer it from the active sprint doc — confirm before writing)
2. [ ] `00-systems/ckis/` is writable and CHANGELOG.md exists
3. [ ] At least one compact file exists in `01-daily/logs/compacts/` for this session
4. [ ] Git working tree is in a reasonable state (run `git status` first)

If no compact files exist yet, ask [OWNER]: "No session compacts found. Should I generate the handoff from current chat state only? (Lower fidelity — some in-session detail may be lost.)"

━━━

## Phase 1: Gather Session State

1. List ALL compact files for this session:
   ```bash
   ls -lt "01-daily/logs/compacts/" | grep -v "^total"
   ```
   Large sessions fill context quickly — a multi-gate sprint can produce 20+ compacts in a single day, with each compact covering only ~1 hour of dense work. Read ALL of them in chronological order (oldest first), not just the most recent few. Each compact is a structured summary of one context window and contains the actual work — decisions, files created, task IDs completed.

   To read all compacts from the current session date:
   ```bash
   ls "01-daily/logs/compacts/" | sort | grep "$(date +%Y-%m-%d)" 
   ```
   If the session spans multiple days, read all compacts since the session started (check sprint doc `created:` date or git log for the first commit of this sprint).

   Synthesis rule: as you read through compacts chronologically, build a running cumulative picture — later compacts supersede earlier ones on the same fact. Don't read only the latest compact and call it done.

2. Run git state checks:
   ```bash
   git log --oneline -10
   git status --short
   ```
   Capture: last 10 commits with version tags, current uncommitted changes, current branch.

3. Identify the active sprint doc:
   ```bash
   ls -lt "02-projects/[your-project]/" | grep -E "(sprint|clarity|gate)" | head -5
   ```
   Read the most recent sprint file. Extract: gate name, sub-task IDs (e.g. G2.1, PI.3.4), which are ✅ done, which are pending.

4. Read business state files:
   - `00-inbox/_MEMORY.md` — current [YOUR_PROJECT] status, recent decisions
   - `00-inbox/_ACTIVE-PROJECTS.md` — active project list with status flags

5. Read CKIS CHANGELOG top entry:
   ```bash
   head -40 "00-systems/ckis/CHANGELOG.md"
   ```
   Capture the current version number (e.g. v2.3.28) to anchor Section 9.

━━━

## Phase 2: Identify Handoff Content

6. From the compact files, extract per-compact:
   - **Files created** (path + 1-sentence purpose)
   - **Files modified** (path + what changed)
   - **Decisions captured** (decision + rationale)
   - **Tasks completed** (with exact gate/sub-task ID)
   - **Tasks still pending** (with exact ID + dependency)
   - **Paste-ready deliverables** (any artifact built in chat for use elsewhere — research brief, project instructions, pitch text, first message)

7. Identify the "Most recent sprint gate context":
   - Which gate is active right now
   - Which subtasks under that gate are ✅ done (cite sprint doc lines)
   - Which subtasks remain (cite IDs)
   - What blocking decision (if any) is open

8. If [OWNER]'s request specifies `{gate-or-topic}` (argument), the **paste-ready deliverable** in Section 6 must be the relevant artifact for that topic. Examples:
   - `create handoff g2` → Section 6 contains the G2 research brief or project setup
   - `create handoff [your-project]-pitch` → Section 6 contains the pitch text / deck draft
   - If no specific deliverable exists, write `_(no paste-ready deliverable for this handoff — orientation only)_`

━━━

## Phase 3: Write the Handoff Document

9. Filename: `00-systems/ckis/YYYY-MM-DD-handoff-{gate-or-topic}.md` (use today's date, kebab-case slug).

10. Write all 9 sections with strict frontmatter:
    ```yaml
    ---
    type: system
    subtype: handoff
    created: {YYYY-MM-DD}
    modified: {YYYY-MM-DD}
    status: active
    tags: [ckis, handoff, context, {gate-tag}]
    related:
      - "[[02-projects/[your-project]/{active-sprint-file}]]"
      - "[[02-projects/[your-project]/2026-05-21-clarity-sprint]]"
      - "[[00-systems/ckis/00-ckis-master-context]]"
    ---

    # Handoff — {Gate or Topic} — {YYYY-MM-DD}

    > Paste this file path as the first message in a new Claude Code tab.
    > The new agent reads it to compound full session context into a fresh window.

    ━━━

    ## 1 · IDENTITY

    {[OWNER]'s identity: role, location, university/background, tech stack, languages.}

    ━━━

    ## 2 · KORVEX CONTEXT

    **5-layer stack** (exact names from `02-projects/[your-project]/03-service-packages-pricing.md`):
    - {Layer 1 exact name + 1-line purpose}
    - {Layer 2 ...}
    - {Layer 3 ...}
    - {Layer 4 ...}
    - {Layer 5 ...}

    **Current services + pricing** (cite source file):
    {table or list — verbatim from source doc, no approximations}

    **ICP tracks**:
    - Track A: {exact name + segment}
    - Track B: {exact name + segment}

    **Core thesis** (1 sentence): {from VISION.md or strategic-replan doc}

    ━━━

    ## 3 · CKIS CONTEXT

    **Vault root**: `$HOME/Documents/Second Brain/`

    **Folder structure** (top level):
    {0X-folder/    → purpose, one line each}

    **Active sprint**: `{sprint file path}`
    - Gate: {GATE NAME}
    - Done: {list of ✅ subtasks with IDs}
    - Pending: {list of subtasks with IDs}

    **Tool stack** (active):
    - {tool 1 — purpose}
    - {tool 2 — purpose}

    ━━━

    ## 4 · WHAT WAS DONE THIS SESSION

    **Files created**:
    | Path | Purpose |
    |------|---------|
    | {path} | {1-sentence purpose} |

    **Files modified**:
    | Path | Change |
    |------|--------|
    | {path} | {what changed} |

    **Decisions captured**:
    - {decision} — rationale: {why}

    **Tasks completed** (with sprint IDs):
    - [x] {Task ID} — {description}

    ━━━

    ## 5 · WHAT COMES NEXT

    Numbered pending tasks, in execution order:
    1. **{Task ID}** — {description}
       - File(s) to edit: `{path}`
       - Dependency: {blocking item, if any}
       - Verify: {success criterion}
    2. **{Task ID}** — {description}
       - ...

    ━━━

    ## 6 · PASTE-READY DELIVERABLE

    {If the session produced something to be pasted elsewhere — research brief,
     Claude.ai Project instructions, pitch text, first message, etc. — include it
     VERBATIM in a fenced code block. The new agent must not have to re-derive it.}

    ```
    {deliverable content here, verbatim}
    ```

    _(If no deliverable: write `_(orientation handoff — no paste-ready artifact)_`.)_

    ━━━

    ## 7 · KEY FILES TO READ

    | # | Path | What it contributes |
    |---|------|---------------------|
    | 1 | `02-projects/[your-project]/{sprint}.md` | Active gate + subtask state |
    | 2 | `00-inbox/_MEMORY.md` | Current business state |
    | 3 | `00-inbox/_ACTIVE-PROJECTS.md` | Project list with flags |
    | 4 | `00-systems/ckis/00-ckis-master-context.md` | CKIS canonical description |
    | 5 | `.claude/CLAUDE.md` + `.claude/guardrails.md` | Operational rules |
    | 6 | {gate-specific file} | {what it contributes} |

    ━━━

    ## 8 · HARD RULES

    1. **Read before edit** — never modify a file without reading it first.
    2. **No deletion without explicit confirmation** — move to `09-archive/` instead.
    3. **Preserve YAML frontmatter** — never strip; preserve `created`; update `modified`.
    4. **Preserve wikilinks, backlinks, aliases** — never break the graph.
    5. **No `.obsidian/` modifications** unless [OWNER] asks.
    6. **No secrets in vault** — never paste `.env`, API keys, OAuth tokens.
    7. **Update CHANGELOG** after any non-trivial CKIS change.
    8. **Match [OWNER]'s voice** — bilingual ES/EN, direct, structured, no buzzwords.

    ━━━

    ## 9 · VAULT VERSION

    - Current commit SHA: `{git rev-parse --short HEAD}`
    - Current CKIS version: `{from CHANGELOG top entry, e.g. v2.3.28}`
    - Next expected version: `v{next-patch}`
    - Branch: `{git branch --show-current}`
    - Handoff created: `{YYYY-MM-DD HH:MM CST}`
    ```

11. Be specific in every section. Use exact file paths (not "the sprint doc"). Use exact task IDs (not "the next task"). Use exact commit SHAs (not "the latest commit"). Use exact pricing / layer names (verify against source files in Phase 1, do not paraphrase).

12. Update CKIS CHANGELOG (`00-systems/ckis/CHANGELOG.md`) — prepend a new dated entry:
    ```markdown
    ## YYYY-MM-DD — Handoff doc created for {gate-or-topic} (v{next-version})

    **Type:** session continuity — handoff document

    **Created:** `00-systems/ckis/YYYY-MM-DD-handoff-{gate-or-topic}.md`

    **Why:** Session context approaching/exceeding limits; new tab will resume from this doc.

    **Sections populated:** 1–9 (all). Paste-ready deliverable: {brief description or "orientation only"}.
    ```

━━━

## Phase 4: Deliver

13. Deliver to [OWNER], exactly:
    ```
    ━━━ Handoff Created ━━━

    File: 00-systems/ckis/YYYY-MM-DD-handoff-{slug}.md

    Top 3 things the new agent needs to know:
    1. {most critical context — e.g. "Active gate is G2.4, blocked on Track B ICP validation"}
    2. {second — e.g. "Paste-ready research brief is in Section 6 — do NOT regenerate"}
    3. {third — e.g. "Uncommitted changes in 02-projects/[your-project]/ — commit before switching"}

    Next steps:
    1. Open a new Claude Code tab (close this one OR keep it open as reference).
    2. The new session auto-loads CLAUDE.md + runs SessionStart hook which reads
       the latest compact.
    3. Paste this path as your first message:
       00-systems/ckis/YYYY-MM-DD-handoff-{slug}.md
    4. The new agent will read all 9 sections and resume.
    ```

━━━

## Report Format

After Phase 4 the report is delivered inline (see step 13). No separate report file.

━━━

## Examples

**Example 1** — [OWNER] says "create handoff g2" mid-session after building a Claude.ai G2 research project:
- Phase 1: Lists all compacts in `01-daily/logs/compacts/` → finds 14 for this session (G2.0 through G2.5 work, spanning ~6 hours). Reads all 14 chronologically. Runs `git log -10` → commits up to v2.3.28. `git status` shows 3 modified files in `02-projects/[your-project]/`.
- Phase 2: Extracts — created `00-systems/ckis/2026-05-28-g2-claude-project-setup.md`; modified `2026-05-21-clarity-sprint.md` to mark G2.0/G2.1 ✅; pending G2.2–G2.7. Paste-ready deliverable: the full T1 XML project instructions + first message.
- Phase 3: Writes `00-systems/ckis/2026-05-29-handoff-g2.md` with all 9 sections. Section 6 contains the G2 project instructions verbatim (fenced code block). CHANGELOG updated v2.3.28 → v2.3.29.
- Phase 4: Reports filename + 3 key facts ("Active gate G2, project setup file ready to paste into Claude.ai, pending G2.2–G2.7 follow-up tasks").

**Example 2** — [OWNER] says "session is too large" with no specific topic, in a vault-maintenance session:
- Phase 1: Lists all compacts → finds 8 for this session (all routine inbox + PI processing). Reads all 8. Active sprint = `2026-05-21-clarity-sprint.md`, current gate = PI cleanup.
- Phase 2: No paste-ready deliverable — purely vault maintenance. Section 6 written as "_(orientation handoff — no paste-ready artifact)_".
- Phase 3: Writes `00-systems/ckis/2026-05-29-handoff-vault-maintenance.md` with all 9 sections. Sections 4–5 list every file moved + every pending YAML fix.
- Phase 4: Reports filename + "no paste deliverable, this is orientation only — new agent should continue PI cleanup from PI.3.5".

━━━

## Troubleshooting

**No compact files exist in `01-daily/logs/compacts/`**: The session never reached a `/compact` checkpoint. Ask [OWNER]: "No compacts found for this session — handoff will be lower fidelity (git state + sprint doc only). Proceed?"

**Only 1–3 compacts exist for a long session**: Can happen if the compact hook misfired. Use what exists and note the gap explicitly in Section 4: "Only {N} compacts available for this session — some in-session detail may be missing."

**Multiple sprint docs in `02-projects/[your-project]/`**: Pick the one with the latest `modified:` date AND `status: active`. If ambiguous, ask [OWNER].

**Paste-ready deliverable exceeds reasonable file size (>1500 lines)**: Split it. Keep the activation/first-message inline in Section 6, and reference the full artifact by path (e.g. "Full project instructions: `00-systems/ckis/2026-05-28-g2-claude-project-setup.md` lines 80–240").

**CKIS CHANGELOG version conflict**: Read the top entry — increment the patch number by 1 (e.g. v2.3.28 → v2.3.29). If you're producing a handoff in the same minute as another commit, use the next patch above whatever the most recent commit tag is.

**Git status shows uncommitted changes to system files**: Flag this in the "Next steps" of the delivery report. Do NOT auto-commit — [OWNER] decides commit timing.

**[OWNER] did not specify gate / topic**: Infer it from the active sprint doc — but confirm: "Inferred topic = `{slug}`. Use that or specify another?"

━━━

## QA Checklist

Before considering the handoff complete:
- [ ] Output file exists at `00-systems/ckis/YYYY-MM-DD-handoff-{slug}.md`
- [ ] All 9 sections populated (no placeholders left)
- [ ] Section 2 (Project/Domain Context) uses exact names, numbers, and facts from source docs — no approximations, no memory-based summaries
- [ ] Section 4 cites at least one specific file path created/modified this session
- [ ] Section 5 has at least one numbered pending task with exact ID + file path
- [ ] Section 6 contains either a verbatim fenced deliverable OR explicit "orientation only" note
- [ ] Section 9 includes current commit SHA + current version + next expected version
- [ ] CKIS CHANGELOG prepended with new version entry
- [ ] Delivery report includes filename + top-3 key facts + new-tab instructions
- [ ] No `.obsidian/` modifications
- [ ] No files deleted
