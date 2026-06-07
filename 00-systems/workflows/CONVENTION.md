---
type: system
subtype: convention
folder: 00-systems/workflows
created: 2026-05-29
modified: 2026-06-06
status: active
tags: [convention, systems, ckis]
---

# 00-systems/workflows — Automated Workflows

**Purpose:** Reusable, documented workflows — processes you've automated or structured as repeatable prompts.

## What is a workflow?

A workflow in CKIS is a documented multi-step process that you've:
1. Run manually at least 3 times (proven it's worth automating)
2. Formalized into a repeatable sequence of steps
3. Captured here so Claude Code (or any agent) can execute it consistently

Workflows are different from skills (`.claude/ckis-skills/`):
- **Skills** = Claude Code trigger → automated vault operation (built-in, runs on demand)
- **Workflows** = documented process that may span multiple tools, manual steps, or agent calls

## What goes here

- Multi-tool processes you repeat (e.g., "Client delivery checklist", "Launch day runbook")
- Cross-system workflows (e.g., "How to migrate a Notion database to vault")
- Prompt templates you've refined over many iterations
- Decision trees for recurring choices

## What doesn't go here

- Single-skill workflows → those are in `.claude/ckis-skills/`
- Project-specific SOPs → those go in `02-projects/<project>/processes/`
- One-time processes → write in a daily note, don't formalize here

## Workflow file structure

```markdown
---
type: workflow
created: YYYY-MM-DD
tags: [workflow, your-area]
status: active
---

# [Workflow Name]

**Trigger:** [when to run this]
**Duration:** [how long it takes]
**Depends on:** [tools, accounts, prerequisites]

## Steps

1. [Step 1 — specific action]
2. [Step 2]
...

## Notes

[Edge cases, common failures, tips]
```

## Naming

- `verb-noun-workflow.md` — action-oriented
- Examples: `deploy-client-site.md`, `process-instagram-backlog.md`, `weekly-content-creation.md`
