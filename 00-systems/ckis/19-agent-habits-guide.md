---
type: system
created: 2026-05-17
modified: 2026-05-17
tags: [ckis, habits, workflow, agent, terminal, claude-code]
status: active
related: ["[[00-ckis-master-context]]", "[[17-crons-architecture]]", "[[18-memory-architecture]]", "[[04-claude-code-obsidian-agent]]"]
---

# 19 — Agent Habits Guide: Working with Claude Code

> Structured daily and weekly habits for using Claude Code terminal sessions so that the CKIS memory system actually compounds over time. The difference between a tool and a system is consistency.

━━━

## Why habits matter

The CKIS memory system is fully automated at the *capture* level — hooks fire, logs are created, compactions are extracted. But the **signal quality** of what gets captured depends entirely on how Eduardo uses the terminal. A session of 47 prompts with no `/compact` and no context management produces junk logs. A session with intentional breaks, clear prompts, and a closing summary produces the raw material the memory system needs.

━━━

## 1. Session Opening Ritual (60 seconds)

When you open a new Claude Code session in the Second Brain vault:

```bash
cd ~/Documents/Second\ Brain
claude  # or: claude --model claude-opus-4-7 for orchestration tasks
```

**What the SessionStart hook injects automatically:**
- `_MEMORY.md` — current business state
- `_ACTIVE-PROJECTS.md` — project roster
- Last session log — what was worked on before

**Your job at session start:**
1. Read the injected context (it's already there in your terminal)
2. If the context is stale (last session was >1 week ago), say: *"Update _MEMORY.md with current state"*
3. State your session intent clearly in the first prompt: *"Today I'm working on X"*

━━━

## 2. During the Session

### Use /compact deliberately

`/compact` is your primary memory compression tool. Use it when:
- The session has been running for >30-45 minutes
- You're about to switch to a different topic within the same session
- The context feels "full" (Claude references things from earlier that are no longer relevant)
- Before a complex multi-step task that needs the full context window

```
/compact
```

After `/compact`, the session summary is **automatically extracted** and saved to `01-daily/logs/compacts/`. You do not need to do anything manually.

### Use /compact with a focus note (optional but powerful)

```
/compact Next: implement the Cron 5 extended prompt in crontab-ckis.txt
```

The focus note after `/compact` gets captured in the compact file, giving the next context window a clear starting point.

### Don't use /compact to escape problems

If something is going wrong, fix it — don't compact and hope the problem disappears. The compact preserves the problem context.

━━━

## 3. Session Closing Ritual (2 minutes)

Before you close a Claude Code session, do ONE of these:

**Option A (preferred)**: Let Claude write the closing summary
```
Write a session summary to today's log at 01-daily/logs/YYYY-MM-DD.md.
Include: what we built/decided, key files touched, and the next open action.
```

**Option B (fast)**: Just close — the Stop hook auto-captures the last assistant message
The new `vault-session-stop.sh` (as of 2026-05-17) automatically extracts the last assistant message as the session summary. So if your last exchange with Claude covered what was done, you get a free summary.

**Option C (for important sessions)**: Manual note
```
Note to add to session log: We decided to [X] because [Y]. Next: [Z].
Write this to 01-daily/logs/2026-05-17.md.
```

━━━

## 4. Daily Habits Checklist

| Habit | When | Time | What it does |
|---|---|---|---|
| State session intent | Start of session | 10 sec | Gives Claude context for the session |
| `/compact` | Every 30-45 min | 5 sec | Extracts compact, frees context window |
| Close session deliberately | End of session | 60 sec | Stop hook captures summary |
| Glance at `_MEMORY.md` | Once per day | 30 sec | Verify state is current |
| Review active daily note | End of day | 2 min | Catch anything not logged |

━━━

## 5. Weekly Review Habit (Sunday evening — automated + manual)

**Automated (Cron 4, Sunday 9:30pm)**:
- Cron 4 reads the week's daily logs + session logs + project overviews
- Writes `06-goals/weekly/week-YYYY-WW.md` with: Wins, Losses, Blockers, Korvex Progress, Priorities
- **No action needed** — just read the output Monday morning

**Manual additions (15 minutes)**:
1. Read the auto-generated weekly review in `06-goals/weekly/`
2. Add personal reflections or context the cron missed
3. Update `_PROFILE.md` if skills/stack changed (e.g., learned a new technology)
4. Update `_INTERESTS.md` if focus areas shifted
5. Check if any `_overview.md` has the ⚠ overview-stale flag (Cron 5 will add this)
6. Commit: `git commit -m "feat: weekly review YYYY-WW"`

━━━

## 6. When Memory Feels Wrong

**Symptom**: Claude doesn't remember something from a previous session
→ Check `~/.claude/projects/<your-vault-project>/memory/MEMORY.md`
→ If the memory isn't there, save it manually: *"Remember that..."*

**Symptom**: _MEMORY.md is stale (references past state)
→ Cron 5 should update it every 2h, but only when activated
→ Trigger manually: *"Update 00-inbox/_MEMORY.md with current project state"*

**Symptom**: Session log is just timestamps, no content
→ This is fixed in v2 (2026-05-17) — Stop hook now extracts last assistant message
→ If still empty: verify `jq` is installed (`which jq`)

**Symptom**: /compact isn't being saved
→ Check `01-daily/logs/compacts/` — compact files should appear after each `/compact`
→ Verify `vault-session-stop.sh` is executable: `ls -la .brain/scripts/`

━━━

## 7. Korvex-web Sessions (separate from vault)

When working on the korvex-web codebase:

```bash
cd "<YOUR_PROJECT_PATH>"
claude
```

The korvex-web `.brain/` system is **more automated** than the vault:
- **SessionStart**: auto-assembles `_CONTEXT.md` with last 3 sessions + open decisions
- **PostToolUse**: auto-captures every build, test, lint, and commit
- **Stop**: auto-writes session log with iterations and compactions
- **74+ compaction files** already captured

For korvex-web sessions, your only habit is: **use /compact generously**. Everything else is automatic.

━━━

## 8. The Compounding Test

CKIS is working if:
- A new session starts with accurate context (no re-explaining)
- Decisions made weeks ago are findable in `/compact` memory
- `_MEMORY.md` reflects today's reality, not last month's
- `01-daily/logs/` has meaningful content, not just timestamps
- `06-goals/weekly/` has auto-generated reviews

CKIS is NOT working if:
- You spend the first 5 minutes of every session re-explaining who you are and what you're building
- Important decisions get made and disappear after the session ends
- The weekly review folder is empty
- Logs are just "Session ended: 14:22"

━━━

## 9. Terminal Commands Reference

```bash
# Start a vault session (Second Brain)
cd ~/Documents/Second\ Brain && claude

# Start a coding session (korvex-web)
cd "<YOUR_PROJECT_PATH>" && claude

# Check today's session log
cat ~/Documents/Second\ Brain/01-daily/logs/$(date +%Y-%m-%d).md

# Check compact files from today
ls ~/Documents/Second\ Brain/01-daily/logs/compacts/ | grep $(date +%Y-%m-%d)

# Verify crons are installed
crontab -l | grep vault-git-sync

# Install crons (first time or after update)
crontab ~/.claude/scripts/crontab-ckis.txt

# Check cron logs
tail ~/logs/vault-git-sync.log
tail ~/logs/memory-consolidation.log

# Run memory consolidation manually (requires ANTHROPIC_API_KEY in ~/.claude/.env)
bash -c 'source ~/.claude/.env && cd ~/Documents/Second\ Brain && \
  claude -p "Update 00-inbox/_MEMORY.md from current project overviews." \
  --bare --dangerously-skip-permissions --allowedTools "Read,Glob,Write" --max-turns 10'

# Check auto-memory state
cat ~/.claude/projects/<your-vault-project>/memory/MEMORY.md
```

━━━

**Principle**: The system learns from you — but only if you give it something to learn from. 10 seconds of intent at the start of a session and 60 seconds of closing at the end is all it takes to make the memory compound.
