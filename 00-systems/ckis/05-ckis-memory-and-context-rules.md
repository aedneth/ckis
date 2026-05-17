---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, memory, context]
status: active
related: ["[[00-ckis-master-context]]", "[[09-cross-model-shared-context-protocol]]", "[[14-active-working-slot]]"]
---

# 05 — CKIS Memory & Context Rules

> What belongs in CKIS memory, what doesn't, and where it lives. CKIS distinguishes between *durable* knowledge (persisted indefinitely in the vault) and *temporary* context (active session, slot, or chat).

━━━

## 1. Layers of Memory

| Layer | Lives in | Lifetime | Read every session? |
|---|---|---|---|
| Identity | `00-inbox/_PROFILE.md`, `[[01-ckis-user-profile-and-operating-context]]` | Years | Yes (light) |
| Live business state | `00-inbox/_MEMORY.md` | Weeks (manually refreshed in weekly review) | **Yes (always)** |
| Active project state | `02-projects/<project>/_overview.md` | Months | When working on that project |
| Decisions | `06-goals/weekly/`, decision-log notes | Indefinite | When the decision is relevant |
| Knowledge | `03-knowledge/permanent-notes/`, `literature-notes/`, MOCs | Indefinite | On demand |
| Reference | `04-resources/` | Indefinite | On demand |
| Daily session | `01-daily/<date>.md`, `01-daily/logs/<date>.md` | Days | Recent ones, briefly |
| Active working slot | `[[14-active-working-slot]]` | Single session / current task | Yes during the task |
| Chat thread | Claude.ai / ChatGPT transcript | Until closed | No — must be exported to vault to count |

## 2. What Belongs in Each Layer

**`00-inbox/_MEMORY.md`** — durable but volatile. Updated manually during weekly review. ≤150 lines. Holds:

- Korvex / project stages and status.
- Active focus for the current week (max 3 items).
- Open decisions awaiting resolution.
- Blockers per project.
- Financial state (summary only).
- University deadlines and active subjects.
- "System state" — what's built, what's pending.

**`02-projects/<project>/_overview.md`** — per-project canonical state. Append-only Recent progress; in-place updates for Status, Open Decisions, Blockers, Key Files.

**`03-knowledge/permanent-notes/`** — atomic, evergreen ideas. Reusable across projects.

**Active working slot (`[[14-active-working-slot]]`)** — temporary scratch for the current task. Cleared or archived when the task closes.

**`01-daily/logs/<date>.md`** — Claude Code session summaries. What was done, decisions, blockers.

## 3. What Does NOT Belong in CKIS Memory

- Secrets, API keys, OAuth tokens, passwords, credentials.
- Real-time PII for clients (full government ID, full bank account, etc.). Use partial / handle-based references and store sensitive raw data outside the vault.
- Transaction-level financial records — those go in spreadsheet / Wave; only summaries enter `05-areas/finance-business.md`.
- Speculative claims framed as facts — mark as "proposed" or move to a permanent note explicitly tagged `#hypothesis`.
- Memory dumps from chat threads without curation. Extract the insight, write a permanent note, link the source.
- Personal thoughts that Eduardo would not want a third party reviewing — keep those in a local-only note that is gitignored, not in the synced vault.
- Irrelevant personal details (medical history, etc.) unless directly relevant to a tracked area like `health-fitness.md`.

## 4. Durable vs Temporary Information

A piece of information is **durable** if at least one is true:

- It will still be useful in 6+ months.
- It encodes a decision or rationale.
- It connects to ≥2 other vault notes.
- It documents a recurring system or pattern.

Otherwise it's **temporary** — it lives in `00-inbox/quick-capture/`, `01-daily/`, or the active working slot, and decays naturally.

## 5. Active Project State

For each project, the `_overview.md` answers:

- What is this project?
- Current status (one line).
- Recent progress (append-only changelog).
- Open decisions.
- Blockers.
- Key files (links to canonical files in the project folder).
- Last updated.

Use `sync overviews` to keep these current via git diffs — never re-write them by hand for routine updates.

## 6. Decisions

A decision becomes durable when it gets a decision-log entry. Format and protocol live in `[[06-decision-execution-and-review-protocol]]`. Until then, it's a "discussion" and lives in chat or in the daily note.

## 7. References to External Systems

Document external systems as **reference notes**, not by copying their contents in:

- `~/korvex/` (code repo)
- `~/brisas-del-golfo/` (code repo)
- Wave / spreadsheet (finance)
- Linear / Trello / similar (if used)
- Wompi SV portal, Vercel dashboard, Supabase project URLs (sanitized — no keys)

Pattern: write a tiny note in `04-resources/tools/` or `02-projects/<project>/` that says *what is there* and *when to look at it*. Do not mirror the contents.

## 8. Sensitive-Data Boundary

The vault is committed to git. Treat anything in the vault as potentially shareable. Specifically:

- Never paste a `.env` file or its contents.
- Never paste API keys, OAuth tokens, signed URLs.
- Never paste raw client identity documents.
- Never paste full payment-gateway responses with cardholder data.

If sensitive content shows up in `00-inbox/` (e.g., a screenshot with a token), redact before processing.

## 9. Memory Refresh Protocol

- **Weekly review** — Eduardo updates `_MEMORY.md` manually. Recommended Sunday during weekly review.
- **Monthly consolidation** — `monthly-consolidation` skill suggests `_MEMORY.md` edits but does not write them. Eduardo accepts/edits.
- **Per-project `_overview.md`** — refreshed automatically by `sync overviews` whenever new files appear under the project folder.
- **CKIS files** — refreshed during any CKIS architecture change. CHANGELOG entry required.

## 10. Stale Context

Heuristics that something has gone stale:

- `modified` date in `_overview.md` is older than 30 days *and* the project is listed as active in `_ACTIVE-PROJECTS.md`.
- An "Open Decision" in `_MEMORY.md` is older than 14 days.
- A blocker entry is unchanged across 2+ weekly reviews.
- An item has been in `00-inbox/` for ≥7 days.

When detected: surface during the next daily brief or weekly review. Do not auto-resolve.
