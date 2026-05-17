---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, usage, first-message]
status: active
related: ["[[10-claude-project-instructions]]", "[[11-chatgpt-project-instructions]]", "[[16-skill-cards-for-second-brain-workflows]]"]
---

# 12 — First-Message & Usage Guide

> Concrete first-messages and example requests for Claude (Project), Claude Code (in vault), and ChatGPT (Project). Use these as templates — copy, adapt, send.

━━━

## 1. Claude Code (in the vault, terminal)

Open: `cd ~/Documents/Second\ Brain && claude`

### First message — generic context load

```
Read .claude/CLAUDE.md, then read 00-inbox/_MEMORY.md, _PROFILE.md, _ACTIVE-PROJECTS.md. Confirm in 5 lines: today's top priorities (from _MEMORY.md), any stale inbox items, any open decisions. Don't take action yet.
```

### Daily brief

```
daily brief
```

### Process inbox

```
process inbox
```

### Pre-coding session brief for [YOUR_PROJECT]

```
project context [your-project]
```

### Synthesize a topic across the vault

```
synthesize ai-agents
```

### Sync project overviews

```
sync overviews
```

### Weekly review (Sunday)

```
weekly review
```

### Cross-model handoff

```
Run the ckis-cross-model-handoff skill: prepare a ChatGPT briefing for <topic> using @00-system/ckis/14-active-working-slot.md and the relevant project _overview.md.
```

## 2. Claude Project (claude.ai)

(Files from `00-system/ckis/` are attached — see `[[10-claude-project-instructions]]`.)

### First message — strategic planning thread

```
Acting as my strategic thinking partner per CKIS file 00 and 01. Today I'm working on <topic>. The relevant project is <name>. Before answering: list which CKIS files you're treating as authoritative for this thread. Then ask me one clarifying question if any load-bearing fact is missing — otherwise propose a plan.
```

### Decision review

```
I'm about to commit to <decision>. Apply the decision-log format from CKIS file 06. Output the entry as a copy-pasteable block, including alternatives, trade-offs, and reversal cost. End with the file path I should save it to.
```

### Architecture review of an existing CKIS file

```
Audit 00-system/ckis/<file>.md against the rest of the CKIS files attached. Find contradictions, redundancies, and missing rules. Propose precise edits, not rewrites.
```

### Prompt design

```
Design a Claude Code skill prompt for <task>. Follow the existing skill format I see in 16 - Skill Cards. Output the full SKILL.md content.
```

### Writing support (LinkedIn / [YOUR_PROJECT])

```
Draft a LinkedIn post about <topic>. Tone: founder + developer (per CKIS file 01). Length: 120–180 words. Include one specific example from my work ([YOUR_PROJECT], Brisas, etc.) — ask me which if you need to.
```

## 3. ChatGPT Project

(Files from `00-system/ckis/chatgpt-project-upload/` are uploaded — see `[[11-chatgpt-project-instructions]]`.)

### First message — second-opinion review

```
Per CKIS files 06 and 09, I want a second opinion on <decision/draft>. Here's my current framing: <paste>. Identify: (1) the load-bearing assumption, (2) one stronger alternative framing, (3) one trade-off I'm probably underweighting. Concise. End with one recommended next action.
```

### Research scan (breadth)

```
Per CKIS file 09 (you're the breadth agent), do a research scan on <topic>. Output: 5 sub-topics, the strongest source on each, and what would be the most useful permanent note to write. Don't write the note — that's Claude Code's job.
```

### Writing review

```
Review this draft against CKIS file 01 (tone). Cut filler, strengthen claims, preserve voice. Output the revised draft + a 3-bullet diff explaining the changes.
```

### Project planning (when Claude is offline / context is exhausted)

```
Per CKIS file 06, run a weekly review on the past week using this paste from my daily notes: <paste>. Output: what shipped, what slipped, patterns, top-3 next-week priorities. Use the format from CKIS file 08, weekly review template.
```

## 4. Cross-Model Handoff (Claude Chat → Claude Code)

In Claude Chat:

```
Output a ready-to-paste plan for Claude Code that:
1. Lists each file Claude Code should read first (with @paths).
2. Lists each file to write or update, with exact paths and a 1-line description of the change.
3. Ends with a single command I can paste into Claude Code.
```

Then paste into Claude Code (in vault):

```
<paste the plan>

Begin executing. Confirm each write before proceeding to the next. Stop and ask if any file does not exist where the plan claims it does.
```

## 5. Vault Maintenance Examples

### Add a new project

```
Run ckis-vault-maintenance: add a new project "<name>" under 02-projects/<slug>/. Scaffold _overview.md from CKIS file 08 §3. Update _ACTIVE-PROJECTS.md. Do not create empty subfolders.
```

### Archive a project

```
Run ckis-vault-maintenance: archive 02-projects/<name>/. Move the entire folder under 09-archive/<name>/. Update _ACTIVE-PROJECTS.md and _MEMORY.md. Confirm before moving.
```

### Refresh ChatGPT upload package

```
Run ckis-context-export: regenerate 00-system/ckis/chatgpt-project-upload/ from the latest CKIS files. Diff against the current package and report changes.
```

## 6. When Things Go Wrong

- **Claude Code is hallucinating a file path** → tell it to run `ls` or Glob first; never let it edit a file it hasn't read.
- **`_overview.md` got stale** → run `sync overviews`. If it still won't refresh, check that the `modified` date isn't ahead of all real changes; backdate manually if so (per `[[00-ckis-master-context]]` open question 5).
- **Inbox has unprocessable items** → flag them, don't auto-delete. Eduardo decides during the next weekly review.
- **Two models disagree** → see `[[09-cross-model-shared-context-protocol]]` §8.
- **A skill is misbehaving** → read `.claude/skills/<skill-name>/skill.md`, edit the rules, commit.

## 7. The Three Habits

| Habit | When | Skill |
|---|---|---|
| Capture | All day | `braindump`, Web Clipper, Share-to-Obsidian |
| Process | End of each day | `process inbox` |
| Review | Sunday + last Sunday of month | `weekly review` + `knowledge consolidation` |

If one habit slips, fix that habit before adding new ones.
