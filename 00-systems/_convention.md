---
type: system
subtype: convention
folder: 00-systems
created: 2026-05-24
modified: 2026-06-06
status: active
tags: [convention, systems, ckis]
related:
  - "[[00-systems/ckis/02-obsidian-vault-architecture]]"
canonical: true
---

# Convention — 00-systems/

## Purpose
Vault infrastructure — the systems that make the Second Brain function. This is not knowledge content; it is the architecture and operational protocols of CKIS. Only [OWNER] and their agents need to read this; it is not oriented toward day-to-day consultable content.

## Internal Structure

```
00-systems/
├── ckis/          → CKIS architecture: rules, templates, protocols, memory
├── workflows/     → Reusable CKIS workflows (with _index.md)
├── tools/         → Reusable tools: prompts, scripts, configs
└── sops/          → SOPs: executable, repeatable procedures (_index.md + _convention.md)
```

## What Goes Here
- System architecture and rules files (CKIS)
- Reusable operational workflows
- Support tools (production prompts, maintenance scripts)
- Cross-cutting SOPs — executable, repeatable procedures that span multiple projects or govern CKIS itself

## What Does NOT Go Here
- Knowledge notes → `03-knowledge/`
- Active projects → `02-projects/`
- Agent skills → `~/.claude/skills/` (outside the vault) or `.claude/ckis-skills/` (vault-local)

## Modification Rule
Files in `00-systems/ckis/` are high-consequence — read the CHANGELOG before editing. For non-trivial changes, make a backup in `.claude/backups/` and log the change in `00-systems/ckis/CHANGELOG.md`.

## Related Folders
- [[00-systems/ckis/_CONVENTION]] — CKIS folder convention
- [[00-systems/tools/_convention]] — reusable tools
- [[00-systems/workflows/_index.md]] — workflows index (companion _convention at root folder)
