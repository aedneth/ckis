---
name: workflow-extend-pattern-a
description: >
  Extend a stub workflow (< 6 files) to full Pattern A structure (12-15 files) following
  the G5.META SOP at 00-systems/workflows/workflow-creation-sop.md. Use when [OWNER] says
  "workflow-extend-pattern-a", "extend this workflow to Pattern A", "complete this workflow",
  "apply Pattern A to [workflow]", or "this workflow is a stub, fill it out". Reads the SOP,
  audits existing files, creates all missing files with correct YAML + content, verifies
  file count, and updates CKIS CHANGELOG.
argument-hint: "path to the workflow folder (e.g. 00-systems/workflows/founders-playbook/)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.0.0
  ckis-context: true
  category: workflow-automation
---

# Workflow Extend — Pattern A

> Converts a stub workflow folder into a complete Pattern A multi-file workflow following the G5.META SOP. Created after G5.A and G5.NEW showed that Pattern A conversion is [OWNER]'s most-executed recurring workflow (applied to Founders Playbook, AI Builder's Handbook, Building Effective AI Agents, Claude Skill Building — all in the same sprint).

━━━

## Scope

This skill operates on a single workflow folder under: `00-systems/workflows/{workflow-name}/`

**Do NOT touch**:
- `00-inbox/` contents
- `.obsidian/` folder
- Files in other workflows
- Any file with `status: archived` in frontmatter

━━━

## Pre-conditions

Before running, verify:
1. [ ] [OWNER] has named the target workflow folder (e.g., `00-systems/workflows/founders-playbook/`)
2. [ ] The source material (book, PDF, or document) has already been read — this skill does NOT read source content
3. [ ] `00-systems/workflows/workflow-creation-sop.md` exists and is readable

If [OWNER] has NOT yet read the source material, stop and say: "I need the source content to fill Pattern A files. Please read the PDF/book first, or paste the key frameworks you want captured."

━━━

## Phase 1: Read SOP and Audit

1. Read `00-systems/workflows/workflow-creation-sop.md` — extract Pattern A file structure and required sections.

2. Glob the target workflow folder:
   ```
   Glob "00-systems/workflows/{workflow-name}/**"
   ```

3. Build an audit manifest:
   - Files present: list each file with its current line count
   - Files missing: compare against Pattern A required structure (see below)
   - YAML issues: check each present file for `type`, `status`, `related` fields

4. Report the audit to [OWNER] before making any changes:
   ```
   Workflow: {workflow-name}
   Files present: {N} — [list]
   Files missing: {M} — [list]
   YAML issues: {K} — [list]
   ```

━━━

## Pattern A Required Structure

Every Pattern A workflow MUST have these files (adapt names to the specific domain):

| File | Required? | Purpose |
|------|-----------|---------|
| `_workflow.md` | YES | Index + navigation |
| `00-{name}-system.md` | YES | System prompt / Project Instructions for an agent |
| `01-{context}.md` | YES | [OWNER]'s current context for this domain |
| `02-{core-framework}.md` | YES | Primary framework (often the G2/G3 foundation file) |
| `03-{domain-A}.md` | YES | Domain module 1 |
| `04-{domain-B}.md` | YES | Domain module 2 |
| `05-{domain-C}.md` | YES | Domain module 3 |
| `06-{operations}.md` | Recommended | Operational rules / checklists |
| `07-{advanced}.md` | Optional | Advanced topics |
| `08-active-slot.md` | YES | Mutable working state (resets each session) |
| `09-reusable-cards.md` | YES | Reusable templates / cards for recurring tasks |
| `10-first-message-guide.md` | YES | How to start a session with this workflow |
| `11-maintenance-protocol.md` | YES | When and how to update this workflow |

Minimum viable Pattern A: `_workflow.md` + `00-` + `01-` + at least 3 domain files + `08-active-slot.md` + `11-maintenance-protocol.md` = 8 files.
Full Pattern A: 12-15 files.

━━━

## Phase 2: Create Missing Files

> Confirm with [OWNER] before creating >5 files: "I'm about to create {N} files. Proceed?"

5. For each missing file, create it using the appropriate template below. Use the domain content [OWNER] has provided (from the source material reading session).

**`_workflow.md` template**:
```yaml
---
type: system
subtype: workflow-index
workflow: {workflow-name}
created: {YYYY-MM-DD}
modified: {YYYY-MM-DD}
status: active
tags: [workflow, systems, ckis, {domain-tag}]
related:
  - "[[00-systems/workflows/_index]]"
  - "[[00-systems/ckis/00-ckis-master-context]]"
canonical: true
---

# {Workflow Title} — Workflow Index

> {One-sentence thesis: what this workflow is for and why it exists.}

━━━

## Ruta canónica

{folder tree}

━━━

## File Index

| # | File | Propósito |
|---|------|-----------|
{rows}

━━━

## Cómo se usa

{3-4 sentences on when to open this workflow and what to do first}

━━━

## Cuándo usar este workflow

- {Trigger 1}
- {Trigger 2}
- {Trigger 3}
```

**`00-{name}-system.md` template** (Project Instructions / System Prompt):
```yaml
---
type: system
subtype: workflow-module
workflow: {workflow-name}
created: {YYYY-MM-DD}
modified: {YYYY-MM-DD}
status: active
tags: [workflow, systems, ckis, {domain-tag}]
role: system-prompt
---

# {Workflow} — System Prompt

You are {role description}. [OWNER] is {[OWNER]'s context for this domain}.

## Core Principles

{3-5 principles that govern how the agent in this workflow thinks}

## [OWNER]'s Current Context

{[OWNER]'s current state relevant to this workflow — stage, active projects, blockers}

## Workflow Files

{Brief description of each file in the workflow}
```

**`08-active-slot.md` template** (always reset — mutable):
```yaml
---
type: system
subtype: workflow-module
workflow: {workflow-name}
created: {YYYY-MM-DD}
modified: {YYYY-MM-DD}
status: active
tags: [workflow, systems, ckis, {domain-tag}]
role: active-slot
---

# {Workflow} — Active Slot

> Reset this file at the start of each new task. This is the mutable working state.

## Current Task

{Description of what's being worked on now}

## Hypothesis

{[OWNER]'s current hypothesis or question}

## Open Questions

- {Question 1}
- {Question 2}

## Next Action

{Concrete next step}
```

**`11-maintenance-protocol.md` template**:
```yaml
---
type: system
subtype: workflow-module
workflow: {workflow-name}
created: {YYYY-MM-DD}
modified: {YYYY-MM-DD}
status: active
tags: [workflow, systems, ckis, {domain-tag}]
role: maintenance
---

# {Workflow} — Maintenance Protocol

## Update Triggers

| Event | Action |
|-------|--------|
| {Event 1} | {Action} |
| {Event 2} | {Action} |
| Monthly review | Audit all files; update `modified` fields |

## What NOT to Store Here

- Sensitive data (API keys, PII, .env content)
- Temporary calculations or scratch notes
- Content that belongs in `00-inbox/`

## Source Integrity

Original sources are in `00-inbox/`. This workflow contains [OWNER]'s synthesis, not raw extracts.

## Deprecation

If this workflow becomes irrelevant: move to `09-archive/workflows/`. Never delete.
```

6. For each domain file (01- through 07-), create the file with:
   - Correct YAML frontmatter (`type: system`, `subtype: workflow-module`, `workflow: {name}`, all required fields)
   - Content synthesized from [OWNER]'s source material (frameworks, tables, examples — not raw extracts)
   - `related:` links to `_workflow.md` and the most connected sibling files
   - `━━━` separators between major sections

━━━

## Phase 3: Fix YAML in Existing Files

7. For each existing file that has YAML issues:
   - Add `type: system` if missing
   - Add `subtype: workflow-module` if missing
   - Add `status: active` if missing
   - Add `workflow: {workflow-name}` if missing
   - Add `related:` with link to `_workflow.md` if missing
   - Update `modified:` to today's date
   - Preserve all existing content — never rewrite body unless it's an active-slot file

━━━

## Phase 4: Verify

8. After all files created/fixed, verify:
   - [ ] Glob the folder — count files. Minimum 8 for viable Pattern A.
   - [ ] Each file has `type:` and `status: active` in frontmatter
   - [ ] `_workflow.md` file index table lists all current files
   - [ ] `08-active-slot.md` exists and has current task populated (or is blank if no active task)
   - [ ] No files deleted
   - [ ] No `.obsidian/` modifications

9. Update `_workflow.md` file index table if new files were added.

10. Update CKIS CHANGELOG (`00-systems/ckis/CHANGELOG.md`) with a new version entry:
    ```
    ## v{version} — {YYYY-MM-DD}
    
    **{workflow-name} Pattern A extension**
    - Created {N} new files: [list]
    - Fixed YAML in {M} existing files: [list]
    - Workflow now at {total} files (Pattern A complete)
    ```

━━━

## Examples

**Example 1** — [OWNER] says "workflow-extend-pattern-a 00-systems/workflows/founders-playbook/" with Founders Playbook content already read:
- Phase 1: Audit finds `_workflow.md` + 7 domain files. Missing: `08-active-slot.md`, `09-reusable-cards.md`, `10-first-message-guide.md`, `11-maintenance-protocol.md`
- Phase 2: Creates 4 missing files
- Phase 3: Fixes `related:` in 3 existing files
- Phase 4: 12 files total. CHANGELOG updated.

**Example 2** — [OWNER] says "apply Pattern A to 00-systems/workflows/sales-workflow/" — only has 2 files:
- Phase 1: Audit finds `_workflow.md` + `01-wsb-principles.md`. Missing: `00-`, `02-`, `03-`, `04-`, `08-`, `09-`, `10-`, `11-`
- Phase 2: Confirms with [OWNER] before creating 8 files
- [OWNER] confirms → creates all 8 with domain content from WSB + Naval synthesis
- Phase 4: 10 files. CHANGELOG updated.

━━━

## Troubleshooting

**Source material not yet read**: Do not hallucinate domain content. Stop and tell [OWNER]: "I need the source content to fill the domain files. Please provide the frameworks from the source material."

**File already exists at target path**: Read it first. If it's a stub (< 10 lines), replace. If it has real content, merge — never overwrite.

**More than 15 files already**: This is Pattern A+ (advanced). Do not delete existing files. Focus on YAML fixes and ensuring required files exist.

**`_workflow.md` index table out of sync**: Always update the table to match actual files on disk. Do not leave phantom entries or missing rows.

━━━

## QA Checklist

Before completing:
- [ ] Minimum 8 files in the workflow folder
- [ ] Every file has `type:`, `status:`, `workflow:` in YAML frontmatter
- [ ] `_workflow.md` index table matches actual files
- [ ] `08-active-slot.md` exists
- [ ] `11-maintenance-protocol.md` exists
- [ ] No files deleted (added only)
- [ ] CKIS CHANGELOG updated
- [ ] `modified` dates updated on all touched files
