---
type: system
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [ckis, system, working-slot]
status: active
related: ["[[00-ckis-master-context]]", "[[06-decision-execution-and-review-protocol]]"]
---

# 14 — Active Working Slot

> Single-file focus system. Only one active slot at a time. When you start a task, write it here. When done, clear it and update the CHANGELOG.

━━━

## Current Slot

**Status:** EMPTY — no active task

```
Task:     [TASK NAME]
Started:  [YYYY-MM-DD HH:MM]
Context:  [1-2 sentences: what this is, what needs to happen]
Files:    [list of files being touched]
Blocked:  [blocker or "none"]
```

━━━

## Usage

1. Before starting any non-trivial task, write its name and context here.
2. During the task, Claude reads this file via the SessionStart context injection.
3. After completing, clear the Current Slot and log to CKIS CHANGELOG if it was a system change.

This file prevents context drift when a task spans multiple sessions or multiple `/compact` invocations.

━━━

## Recently Completed

*(append one line per completed slot, newest first)*

```
YYYY-MM-DD | [TASK] | [OUTCOME]
```
