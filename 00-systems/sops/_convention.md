---
type: system
subtype: convention
folder: 00-systems/sops
created: 2026-06-06
modified: 2026-06-06
status: active
tags: [convention, systems, ckis, sop]
related:
  - "[[00-systems/ckis/02-obsidian-vault-architecture]]"
  - "[[00-systems/ckis/08-note-templates-and-frontmatter]]"
  - "[[00-systems/_convention]]"
canonical: true
---

# Convention — 00-systems/sops/

## Purpose

An **SOP (Standard Operating Procedure)** is an executable, repeatable, step-by-step procedure for accomplishing a specific operational task. You run an SOP; you do not just read it.

**SOP vs permanent note vs workflow:**

| Artifact | Lives in | What it is | How you use it |
|----------|----------|------------|----------------|
| **SOP** | `00-systems/sops/<domain>/` or `<project>/processes/` | Executable step-by-step procedure | You run it start-to-finish |
| **Permanent note** | `03-knowledge/` | Compounding knowledge — insight, concept, framework | You read, reference, and build on it |
| **Workflow** | `00-systems/workflows/` | Large multi-file operating system for a work domain | You activate and maintain it long-term |

This file is the convention companion to `_index.md`. The `_index.md` is the registry of every active SOP; this `_convention.md` defines what can live here and how.

━━━

## What Goes Here

- Cross-cutting SOPs that apply to CKIS, development, OS/hardware, or content — not specific to one project
- Subdomain folders: `ckis/`, `dev/`, `os-and-hardware/`, `content/`
- The root `_index.md` that registers every SOP (both tiers)

## What Does NOT Go Here

- Project-specific SOPs → stay in `02-projects/<project>/processes/`
- Conceptual frameworks → `03-knowledge/frameworks/`
- Generic knowledge guides → `03-knowledge/guides/`
- Agent skills (Claude Code) → `~/.claude/skills/` or `.claude/ckis-skills/`
- Source code or scripts → external code repository

━━━

## Two-Tier Home Rule

```
Tier 1 — Project-local:   02-projects/<project>/processes/
          For SOPs tightly coupled to one project's operations.
          Owned by that project's team/context.

Tier 2 — Cross-cutting:   00-systems/sops/<domain>/
          For SOPs that span projects, apply to CKIS itself,
          or govern [OWNER]'s personal operating system.

BOTH tiers are registered in [[00-systems/sops/_index]].
```

━━━

## File Naming Convention

- `-sop.md` suffix for all SOP files
- Descriptive kebab-case prefix for the process name
- Examples:
  - `inbox-processing-sop.md`
  - `weekly-review-sop.md`
  - `client-site-deploy-sop.md`
  - `api-key-rotation-sop.md`
  - `pop-os-fresh-install-sop.md`

━━━

## Required Frontmatter

```yaml
---
type: sop
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [sop, <domain>, ...]
status: active            # active | draft | deprecated
sop_domain: <domain>      # ckis | dev | os-hardware | [your-project] | content ...
trigger: ""               # invocation phrase if agent-invokable, else empty
related: []
---
```

━━━

## Body Template

```markdown
# SOP — <Process Name>
> One-line purpose · who runs this · when.

## 1. Purpose & Scope
## 2. When to Execute
## 3. Prerequisites
## 4. Steps
## 5. Verification / Expected Output
## 6. Troubleshooting        (optional — symptom | cause | fix table)
## 7. Notes & Exceptions / Lessons Learned   (optional)
## 8. Agent-Delegatable Summary   (optional — paste block to hand an agent)

*SOP v<x> — <author> — <date>*
```

Sections §1–5 are **required**. Sections §6–8 are optional but encouraged for complex or agent-invokable SOPs.

━━━

## Domains

| Domain | Lives in | Examples |
|--------|----------|---------|
| `ckis` | `00-systems/sops/ckis/` | Inbox processing, weekly review, CKIS maintenance |
| `dev` | `00-systems/sops/dev/` | Repo bootstrap, deployment runbooks, API key rotation |
| `os-hardware` | `00-systems/sops/os-and-hardware/` | Pop!_OS install, USB boot, hardware setup |
| `content` | `00-systems/sops/content/` | YouTube upload, social post, newsletter send |
| `project-local` | `<project>/processes/` | [YOUR_PROJECT] client onboarding, [YOUR_CLIENT] deploy |

━━━

## How to Add a New SOP

1. **Pick tier** — project-local (`<project>/processes/`) or cross-cutting (`00-systems/sops/<domain>/`).
2. **Copy template** — duplicate `[[08-templates/sop]]` into the target folder.
3. **Fill §1–5** — at minimum, complete Purpose, When to Execute, Prerequisites, Steps, and Verification.
4. **Register** — add a row to `[[00-systems/sops/_index]]` under the correct domain subheading.
5. **CHANGELOG** — if the SOP is cross-cutting or modifies CKIS, add an entry to `[[00-systems/ckis/CHANGELOG]]`.

━━━

## Related Folders

- [[00-systems/workflows/_convention]] — workflows (large multi-file operating systems)
- `<project>/processes/_convention.md` — project-local SOP convention (generalised by this file)
- [[08-templates/_convention]] — Obsidian templates (includes `sop.md` template)
