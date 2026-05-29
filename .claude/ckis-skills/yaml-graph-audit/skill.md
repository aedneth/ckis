---
name: yaml-graph-audit
description: >
  Scan a target folder for YAML frontmatter violations: wrong type values, non-standard
  subtypes, missing required fields (related, status, modified), and type mismatches between
  note content and classification. Use when [OWNER] says "yaml-graph-audit", "audit YAML",
  "fix frontmatter", "fix the graph", "check YAML in [folder]", or after any bulk processing
  operation (inbox processing, batch import, G5.QC-style remediation). Outputs a violations
  report, fixes all auto-fixable issues, and flags manual-review items.
argument-hint: "folder path to audit (e.g. 03-knowledge/permanent-notes/ or 04-resources/)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.1.0
  ckis-context: true
  category: workflow-automation
---

# YAML Graph Audit

> Finds and fixes YAML frontmatter violations across a folder — the recurring quality-control step that caught 61 misclassified notes in G5.QC. Run after any bulk operation to ensure the Obsidian graph stays clean and wikilinks resolve correctly.

━━━

## Scope

This skill operates on the folder [OWNER] specifies (default: entire vault except `.obsidian/`).

**Do NOT touch**:
- `.obsidian/` folder
- `_PROFILE.md`, `_MEMORY.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md` (system files)
- Files with `status: archived` unless [OWNER] explicitly says to include them
- `_CONVENTION.md` files (they are reference docs, not notes)

━━━

## Pre-conditions

Before running, verify:
1. [ ] [OWNER] has specified a target folder, OR the default (full vault) is acceptable
2. [ ] No other bulk vault operation is in progress (only one write-intensive operation at a time)

━━━

## YAML Standards Reference

These are the canonical CKIS values. Any deviation is a violation.

### `type` — allowed values

| type value | Where it belongs |
|-----------|-----------------|
| `permanent-note` | `03-knowledge/permanent-notes/` (synthesized, ≥2 sources) |
| `resource` | `04-resources/` — external content, social captures, reference docs |
| `system` | `00-systems/` — CKIS architecture, workflows, tools |
| `daily` | `01-daily/` — daily notes and session logs |
| `project` | `02-projects/` — active project files |
| `archive-note` | `09-archive/` — retrospective documentation created *about* a past venture or project (distinct from project files that were merely moved to archive, which keep `type: project`) |
| `literature-note` | `03-knowledge/` — single-source reading notes (not yet synthesized) |
| `area` | `05-areas/` — life area notes |
| `goal` | `06-goals/` — goal tracking |
| `person` | `07-people/` — relationship notes |
| `template` | `08-templates/` — note templates |
| `compact-summary` | `01-daily/logs/compacts/` — session compacts |

### `subtype` — common standard values

| subtype | Used with |
|---------|----------|
| `social-capture` | `type: resource` in `04-resources/social-captures/` |
| `workflow-module` | `type: system` in `00-systems/workflows/` |
| `workflow-index` | `type: system` — `_workflow.md` files |
| `ckis-core` | `type: system` in `00-systems/ckis/` |
| `guide` | `type: resource` or `type: system` |
| `permanent` | `type: permanent-note` |
| `moc` | `type: permanent-note` in `03-knowledge/maps-of-content/` |
| `literature` | `type: literature-note` |

### Required fields (all notes)

- `type` — always required
- `created` — always required, format `YYYY-MM-DD`
- `modified` — always required, format `YYYY-MM-DD`
- `status` — required: `active`, `draft`, `processed`, `archived`
- `tags` — required: array, kebab-case

### Required fields (Type B / social captures)

- `processing: index-only` — REQUIRED for all social captures
- `platform` — instagram, linkedin, x, threads
- `author` — handle or name

━━━

## Phase 1: Discovery Scan

1. Glob target folder for all `.md` files:
   ```
   Glob "{target-folder}/**/*.md"
   ```
   Exclude: `_CONVENTION.md`, `_PROFILE.md`, `_MEMORY.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`

2. For each file, read the YAML frontmatter only (first 30 lines):
   - Extract: `type`, `subtype`, `status`, `tags`, `created`, `modified`, `processing` (if present)
   - Note the file's actual folder path

3. Build the violations manifest:

   **Category A — Wrong type for location** (e.g., `type: permanent-note` in `04-resources/`):
   - These are routing errors — the note is in the wrong folder OR has the wrong type

   **Category B — Missing required fields**:
   - Missing `type`, `created`, `modified`, or `status`

   **Category C — Non-standard values**:
   - `type: permanent-notes` (plural) vs `type: permanent-note` (singular)
   - `subtype: social-capture-processed` instead of `subtype: social-capture`
   - `tags` as string instead of array

   **Category D — Social capture missing `processing: index-only`**:
   - Any `type: resource`, `subtype: social-capture` file missing this field

4. Report the manifest before making any changes:
   ```
   Audit target: {folder}
   Files scanned: {N}
   
   Category A — Wrong type for location: {count}
   Category B — Missing required fields: {count}
   Category C — Non-standard values: {count}
   Category D — Social capture missing processing field: {count}
   
   Total violations: {total}
   ```

   If total = 0: "No violations found. YAML graph is clean." Stop.

━━━

## Phase 2: Auto-Fix (safe corrections)

> Only auto-fix violations where the correct value is unambiguous. Flag everything else for manual review.

> ⚠️ Confirm with [OWNER] before touching >10 files.

5. **Category B — Add missing required fields** (safe to auto-fix):
   - `status`: if missing, add `status: draft`
   - `modified`: if missing, add today's date
   - `created`: if missing, use file creation mtime (via Bash: `stat -c %y {file}`)
   - Do NOT auto-add `type` — type requires human judgment

6. **Category C — Fix non-standard values** (safe to auto-fix):
   - `type: permanent-notes` → `type: permanent-note`
   - `subtype: social-capture-processed` → `subtype: social-capture`
   - `tags: "tag1, tag2"` (string) → `tags: [tag1, tag2]` (array)
   - Fix via Edit — surgical replacement, preserve all surrounding content

7. **Category D — Add `processing: index-only`** to social captures (safe to auto-fix):
   - Only add if `type: resource` AND `subtype: social-capture` AND `processing:` is missing
   - Insert after the `subtype:` line

8. For each auto-fixed file: update `modified:` to today's date.

9. Log each fix: `{filename} — {what was fixed}`

━━━

## Phase 3: Flag Manual-Review Items

10. For **Category A** (wrong type for location):
    - Do NOT auto-fix — moving a file or changing its type is a semantic decision
    - Surface to [OWNER] with the diagnosis:
      ```
      MANUAL REVIEW: {filename}
      Location: {current path}
      Current type: {type}
      Issue: {why this is a mismatch}
      Options:
        A) Move file to {correct path} (keep type)
        B) Change type to {correct type} (keep location)
      ```

11. For any file where the correct value is genuinely ambiguous:
    - List it under "Manual Review Required" with the question [OWNER] needs to answer

━━━

## Phase 4: Verify and Report

12. Re-run the scan on auto-fixed files to confirm violations are resolved.

13. Deliver the final report:
    ```
    YAML Graph Audit — Complete
    Target: {folder}
    Files scanned: {N}
    
    Auto-fixed: {count}
    - [list of fixes]
    
    Manual review required: {count}
    - [list with diagnosis]
    
    Remaining violations: {count}
    Clean files: {N - violations}
    ```

14. If structural changes were made (any Category A items resolved), update CKIS CHANGELOG.

━━━

## Examples

**Example 1** — [OWNER] says "yaml-graph-audit 04-resources/social-captures/":
- Phase 1: 75 files scanned. Finds 12 with `subtype: social-capture-processed`, 8 missing `processing: index-only`
- Phase 2: Auto-fixes 20 violations across 20 files
- Phase 3: No Category A issues (all in correct folder)
- Phase 4: Report + 0 manual items

**Example 2** — [OWNER] says "yaml-graph-audit 03-knowledge/permanent-notes/" after a batch import:
- Phase 1: 90 files scanned. Finds 5 with `type: resource` (wrong — they're in permanent-notes)
- Phase 2: Auto-fixes Category B+C+D only
- Phase 3: Surfaces 5 Category A items for [OWNER]'s decision
- Phase 4: Report with 5 manual items

━━━

## Troubleshooting

**File has no YAML frontmatter at all**: Flag as Category B. Do NOT auto-add full frontmatter — surface to [OWNER]: "This file has no frontmatter. What type and status should it have?"

**Large folder (>100 files)**: Process in batches of 25. Report after each batch. Continue unless [OWNER] says to stop.

**Conflicting signals** (e.g., file in `04-resources/` but tagged `permanent-note`): Treat as Category A. Surface both possible interpretations to [OWNER].

━━━

## QA Checklist

Before completing:
- [ ] All auto-fixable violations resolved
- [ ] No files deleted (only edited)
- [ ] `modified` dates updated on all touched files
- [ ] Manual review items listed with clear diagnosis
- [ ] Final report delivered
- [ ] CHANGELOG updated if structural changes were made
- [ ] No `.obsidian/` modifications
