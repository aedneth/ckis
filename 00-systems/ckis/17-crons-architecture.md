---
type: system
created: 2026-05-17
modified: 2026-05-17
tags: [ckis, crons, automation, system]
status: active
related: ["[[00-ckis-master-context]]", "[[04-claude-code-obsidian-agent]]"]
---

# 17 — Crons Architecture

> Automated background processes that keep the CKIS vault self-maintaining. Five crons cover git sync, CRM hygiene, content discovery, weekly review, and memory consolidation. Four are active; one (content discovery) is pending API credit allocation.

━━━

## 1. Overview

| # | Name | Schedule | Status | Script |
|---|---|---|---|---|
| 1 | Vault Git Sync | every 15 min | active | `~/.claude/scripts/vault-git-sync.sh` |
| 2 | CRM Auto-sort | every 15 min | active | `~/.claude/scripts/crm-sort.sh` |
| 3 | Content Discovery | 6:00 AM daily | pending | documented below, commented out in crontab |
| 4 | Weekly Review | Sunday 21:30 | active | inline prompt in crontab |
| 5 | Memory Consolidation | every 2 hours | active | inline prompt in crontab |

Source file for crontab entries: `~/.claude/scripts/crontab-ckis.txt`

━━━

## 2. Cron 1 — Vault Git Sync

**Schedule:** `*/15 * * * *`
**Script:** `~/.claude/scripts/vault-git-sync.sh`
**Log:** `~/logs/vault-git-sync.log`

Runs `git add -A` inside the vault, checks whether anything was staged, commits with the message `auto-sync YYYY-MM-DD HH:MM`, then pushes to `origin master`. If nothing was staged, exits silently. If no remote is configured, the commit is saved locally and a warning is logged.

The vault branch is `master`, not `main`.

**Dependencies:** `git` on PATH, vault at `<YOUR_VAULT_PATH>`.

━━━

## 3. Cron 2 — CRM Auto-sort

**Schedule:** `*/15 * * * *`
**Script:** `~/.claude/scripts/crm-sort.sh`
**Log:** `~/logs/crm-sort.log`

Scans `07-people/clients/*.md` (top-level only — not subdirs). Reads the `Status:` field from the first 20 lines of each file. Moves the file into the matching subfolder:

| Status value | Target subfolder |
|---|---|
| `New` | `07-people/clients/New/` |
| `Contacted` | `07-people/clients/Contacted/` |
| `Active` | `07-people/clients/Active/` |
| `Closed` | `07-people/clients/Closed/` |

Subdirectories are created automatically if they do not exist. Files with a missing or unrecognized `Status:` value are left in place and logged as `UNCLASSIFIED`.

**Convention for client notes:** The `Status:` field must appear within the first 20 lines of the file, either as a plain `Status: Active` line or as a YAML frontmatter field. The match is case-insensitive.

━━━

## 4. Cron 3 — Content Discovery (PENDING)

**Schedule (when active):** `0 6 * * *` — daily at 6:00 AM
**Status:** Commented out in `crontab-ckis.txt`. Activate when ANTHROPIC_API_KEY is allocated and API credits are confirmed.
**Log (when active):** `~/logs/content-discovery.log`

Uses `claude -p` to read the last 3 daily notes and active project overviews, then identifies 3 high-signal topics Eduardo should explore and appends them to `00-inbox/_MEMORY.md` under a dated heading.

**To activate:**
1. Confirm `ANTHROPIC_API_KEY` is in `~/.claude/.env` (see §7 below).
2. Run `cron-env-check.sh` and verify the `claude` CLI check passes.
3. In `crontab-ckis.txt`, uncomment the Cron 3 block.
4. Run `crontab ~/.claude/scripts/crontab-ckis.txt` to reinstall.

━━━

## 5. Cron 4 — Weekly Review

**Schedule:** `30 21 * * 0` — Sunday at 21:30
**Log:** `~/logs/weekly-review.log`
**Output:** `06-goals/weekly/week-YYYY-WW.md`

Sources `~/.claude/.env` to load the API key, then calls `claude -p` with a structured prompt. The prompt instructs the agent to:

1. Read daily notes from `01-daily/` for the past 7 days.
2. Read session logs from `01-daily/logs/` for the past 7 days.
3. Read `00-inbox/_MEMORY.md` for current business state.
4. Read `02-projects/[your-project]/_overview.md` and `02-projects/[client-site]/_overview.md`.
5. Write a weekly review note to `06-goals/weekly/week-YYYY-WW.md` with sections: Summary, Wins, Blockers, [YOUR_PROJECT] Progress, University Progress, Next Week Priorities, Patterns Noticed.

The output file includes YAML frontmatter with `type: weekly-review` and `tags: [weekly-review, goals]`. No existing files are modified.

**Dependencies:** `claude` CLI on PATH, `ANTHROPIC_API_KEY` in `~/.claude/.env`, `06-goals/weekly/` directory.

━━━

## 6. Cron 5 — Memory Consolidation

**Schedule:** `0 */2 * * *` — every 2 hours
**Log:** `~/logs/memory-consolidation.log`
**Output:** overwrites `00-inbox/_MEMORY.md`

Sources `~/.claude/.env`, then calls `claude -p`. The prompt instructs the agent to:

1. Read `02-projects/[your-project]/_overview.md`.
2. Read `02-projects/[client-site]/_overview.md`.
3. Read the 3 most recent session logs in `01-daily/logs/`.
4. Read the current `00-inbox/_MEMORY.md`.
5. Rewrite `_MEMORY.md` in place, keeping the bullet-index Memory Index format, updating project state, staying within the 150-line hard limit, and never adding secrets or API keys.

This is the highest-impact cron: it ensures Claude Code always opens a session with accurate, current business context without Eduardo manually maintaining `_MEMORY.md`.

**Dependencies:** same as Cron 4. Hard limit enforced by prompt instruction — if the file exceeds 150 lines, review manually.

━━━

## 7. Environment File Pattern

Crons 4 and 5 require the Anthropic API key. The key is sourced at runtime from `~/.claude/.env` — never stored in the crontab itself and never committed to the vault.

Create the file once:

```bash
echo 'ANTHROPIC_API_KEY=sk-ant-...' > ~/.claude/.env
chmod 600 ~/.claude/.env
```

The crontab entries use `source ~/.claude/.env &&` before invoking `claude -p`. This is the safest pattern for secrets in cron: the key is scoped to that single command and does not appear in `ps` output or the cron log.

━━━

## 8. Installation

**First-time install:**

```bash
# 1. Verify the environment (run manually first)
bash ~/.claude/scripts/cron-env-check.sh

# 2. Open the crontab editor
crontab -e

# 3. Paste the contents of crontab-ckis.txt
# (or pipe directly):
crontab ~/.claude/scripts/crontab-ckis.txt

# 4. Confirm installation
crontab -l
```

**Updating an existing crontab:** edit `crontab-ckis.txt`, then run `crontab ~/.claude/scripts/crontab-ckis.txt` again to replace. The file is the source of truth — do not edit the crontab directly.

**Removing all CKIS crons:** `crontab -r` removes all crons. Be careful if you have non-CKIS cron entries.

━━━

## 9. Monitoring

| Log file | What it contains |
|---|---|
| `~/logs/vault-git-sync.log` | commit timestamps, "No changes" skips, push status |
| `~/logs/crm-sort.log` | moved/skipped/unclassified counts per run |
| `~/logs/weekly-review.log` | claude -p output for weekly review |
| `~/logs/memory-consolidation.log` | claude -p output for each memory rewrite |
| `~/logs/cron-env-check.log` | PASS/FAIL results from the health check script |
| `~/logs/content-discovery.log` | (pending) content discovery output |

Quick tail to verify a cron is running:

```bash
tail -20 ~/logs/vault-git-sync.log
tail -20 ~/logs/memory-consolidation.log
```

━━━

## 10. Pending Section

### Cron 3 — Content Discovery (not yet active)

Blocked on: ANTHROPIC_API_KEY with sufficient API credits for daily automated runs.

When content discovery is activated, the `_MEMORY.md` will gain a `## Content Discovery YYYY-MM-DD` section appended by the agent. If the 150-line limit is at risk, the Memory Consolidation cron (Cron 5) will trim old content discovery entries on the next pass.

Estimated token cost per run: low (reads ~3 daily notes + 2 overviews, writes ~150 tokens output). Safe to activate on any paid Anthropic plan.

━━━

## 11. Related Files

- `[[00-ckis-master-context]]` — canonical CKIS overview
- `[[04-claude-code-obsidian-agent]]` — agent rules and confirmation boundaries
- `[[05-ckis-memory-and-context-rules]]` — `_MEMORY.md` format and 150-line rule
- `[[13-maintenance-and-update-protocol]]` — when and how to update CKIS
- `~/.claude/scripts/crontab-ckis.txt` — installable crontab source
- `~/.claude/scripts/vault-git-sync.sh` — Cron 1 script
- `~/.claude/scripts/crm-sort.sh` — Cron 2 script
- `~/.claude/scripts/cron-env-check.sh` — pre-flight health check
