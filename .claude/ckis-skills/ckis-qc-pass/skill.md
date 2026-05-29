---
name: ckis-qc-pass
description: >
  Run a standard quality-control pass on the vault: conventions check, YAML audit,
  wikilink integrity, git status, and CHANGELOG entry. Use when [OWNER] says
  "ckis-qc-pass", "run QC", "do a vault QC", "quality check the vault", "QC pass",
  or at the end of any major sprint gate. Outputs a pass/fail report per check,
  auto-fixes safe violations, and adds a CHANGELOG entry when structural changes occurred.
argument-hint: "optional: scope to a specific folder or sprint gate (e.g. G5.QC, 04-resources/)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.0.0
  ckis-context: true
  category: workflow-automation
---

# CKIS QC Pass

> Standard quality-control checklist for the vault — the systematic gate [OWNER] runs after each sprint phase to prevent accumulation of structural debt. Created after G5.QC showed that a 13-item remediation was needed because no QC skill existed to catch issues incrementally.

━━━

## Scope

Default: entire vault (all folders except `.obsidian/`).
Scoped: a specific folder or set of folders if [OWNER] provides an argument.

**Do NOT touch**:
- `.obsidian/` folder (ever)
- `_PROFILE.md`, `_MEMORY.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`
- `_CONVENTION.md` files (reference only)
- Files with `status: archived` (unless [OWNER] specifies)

━━━

## Pre-conditions

Before running, verify:
1. [ ] No other bulk vault operation is in progress
2. [ ] Git working tree is in a reasonable state (run `git status` as first action)

━━━

## The 5 QC Checks

Each check runs independently. All 5 must pass for the QC pass to be "green."

### Check 1 — Conventions Integrity

Verify that key folders have `_CONVENTION.md` files.

Required `_CONVENTION.md` locations (minimum set):
- `04-resources/social-captures/instagram-captures/`
- `04-resources/social-captures/instagram-captures/saved-posts/`
- `03-knowledge/permanent-notes/`
- `03-knowledge/maps-of-content/`
- `00-inbox/`
- `01-daily/`
- `02-projects/`
- `00-systems/ckis/`

Run:
```bash
for dir in \
  "04-resources/social-captures/instagram-captures" \
  "04-resources/social-captures/instagram-captures/saved-posts" \
  "03-knowledge/permanent-notes" \
  "03-knowledge/maps-of-content" \
  "00-inbox" \
  "01-daily" \
  "02-projects" \
  "00-systems/ckis"; do
  test -f "${VAULT}/${dir}/_CONVENTION.md" && echo "OK: $dir" || echo "MISSING: $dir"
done
```

**Pass**: All 8 locations have `_CONVENTION.md`.
**Fail**: List missing locations. Create missing convention files using the template in `04-resources/social-captures/instagram-captures/saved-posts/_CONVENTION.md` as reference.

━━━

### Check 2 — YAML Graph Audit

Run the `yaml-graph-audit` skill on the scoped folder (or full vault if no scope).

Acceptable failure threshold: **0 Category A violations** (wrong type for location). Category B/C/D may have up to 5 unfixed items if they require manual review — flag them.

**Pass**: 0 wrong-type-for-location violations. All auto-fixable issues resolved.
**Fail**: Any Category A violation present. List each with diagnosis.

If the yaml-graph-audit skill is available:
- Say: "Running yaml-graph-audit on {scope}..." and execute it inline
- Otherwise: run the YAML scan manually using Glob + Read frontmatter on each file

━━━

### Check 3 — Wikilink Integrity

Scan for broken wikilinks — links to files that no longer exist at the expected path.

Focus on the highest-risk areas:
1. MOC files in `03-knowledge/maps-of-content/` — these are the most link-dense
2. Files that were moved in recent sessions (check git log for `git mv` operations)
3. `_workflow.md` index tables

Run:
```bash
# Find all [[wikilinks]] in MOC files
grep -r '\[\[' "03-knowledge/maps-of-content/" --include="*.md" | grep -oP '(?<=\[\[)[^\]]+' | sort -u
```

For each wikilink found, verify the target file exists:
```bash
find . -name "{linked-file}.md" 2>/dev/null
```

**Pass**: All wikilinks in MOC files resolve to existing files.
**Fail**: List broken links with the source file and the target that doesn't exist.

Auto-fix: If a file was renamed (e.g., `reel-X.md` → `instagram-X.md`), update all links. If file is genuinely gone, surface to [OWNER] — do not delete the link silently.

━━━

### Check 4 — Git Status Review

Run `git status` to understand the current state of vault changes.

```bash
git -C "{vault-path}" status --short
```

Evaluate:
- **Untracked files**: Are there important files that should be committed? Flag any `.md` files in `03-knowledge/`, `04-resources/`, `00-systems/` that are untracked.
- **Modified files**: Are there unstaged changes to system files (`CHANGELOG.md`, `_workflow.md`, sprint docs)? Flag these.
- **Staged files**: Note any staged changes.
- **Large uncommitted batches**: If >20 files modified/untracked, suggest a commit.

**Pass**: No critical system files with unstaged changes. Untracked count is accounted for.
**Fail**: System files (`CKIS CHANGELOG`, sprint doc, `_MEMORY.md`) have unstaged modifications.

The QC pass does NOT commit — it only reports. [OWNER] decides when to commit.

━━━

### Check 5 — CHANGELOG Currency

Verify that `00-systems/ckis/CHANGELOG.md` has an entry for the most recent significant vault operation.

1. Read the last 40 lines of `00-systems/ckis/CHANGELOG.md`
2. Check: does the most recent entry date match within the last 48 hours?
3. Check: does the entry describe the most recent sprint gate or major operation?

**Pass**: CHANGELOG has an entry within 48 hours that describes recent work.
**Fail**: CHANGELOG is stale (last entry > 48 hours old) OR the most recent sprint gate has no entry.

If CHANGELOG is stale AND the QC pass itself found/fixed violations: add a new entry:
```markdown
## v{next-version} — {YYYY-MM-DD}

**CKIS QC Pass**
- Conventions check: {result}
- YAML audit: {N violations fixed}
- Wikilink audit: {result}
- Git status: {summary}
- CHANGELOG: updated this entry
```

━━━

## Report Format

After all 5 checks, deliver the QC pass report:

```
━━━ CKIS QC Pass — {YYYY-MM-DD} ━━━

Scope: {folder or "full vault"}

Check 1 — Conventions:  {PASS ✅ | FAIL ❌ — N missing}
Check 2 — YAML Audit:   {PASS ✅ | FAIL ❌ — N violations}
Check 3 — Wikilinks:    {PASS ✅ | FAIL ❌ — N broken}
Check 4 — Git Status:   {PASS ✅ | WARN ⚠️ — summary}
Check 5 — CHANGELOG:    {PASS ✅ | FAIL ❌ — N days stale}

Overall: {GREEN ✅ | YELLOW ⚠️ | RED ❌}

Auto-fixed this pass:
- {fix 1}
- {fix 2}

Manual action required:
- {item 1 with diagnosis}
- {item 2 with diagnosis}

Next recommended action:
- {git commit recommendation if applicable}
- {specific fix [OWNER] needs to handle}
```

━━━

## Examples

**Example 1** — [OWNER] says "ckis-qc-pass" after G5.NEW:
- Check 1: All 8 convention files present ✅
- Check 2: YAML audit finds 3 Category C violations (non-standard subtypes) — auto-fixed ✅
- Check 3: 2 broken wikilinks in MOC (files renamed) — auto-updated ✅
- Check 4: 15 untracked files in `03-knowledge/` — flagged for commit ⚠️
- Check 5: CHANGELOG last entry is 6 hours ago → PASS ✅
- Overall: YELLOW (git status needs attention)
- Report delivered. [OWNER] runs commit.

**Example 2** — [OWNER] says "ckis-qc-pass 04-resources/":
- Scoped to `04-resources/` only
- Check 1: Only checks `04-resources/social-captures/instagram-captures/` convention files
- Check 2: YAML audit scoped to `04-resources/`
- Check 3: Only MOC files linking to `04-resources/` content
- Check 4: Full git status (always full)
- Check 5: CHANGELOG always checked (always full)
- Faster, focused result

━━━

## Troubleshooting

**yaml-graph-audit skill not available**: Run manual YAML scan — Glob folder, read frontmatter of each file, check `type` against folder path rules. More time-consuming but same logic.

**Large vault (>500 files)**: Process checks in parallel where possible. Check 1, 4, 5 are fast (always). Check 2 (YAML) and Check 3 (wikilinks) can take time — report progress every 50 files.

**Wikilink resolution ambiguous**: If a wikilink like `[[some-note]]` could match multiple files, surface to [OWNER]. Do not silently pick one.

**CHANGELOG version number**: Increment the patch version (e.g., v2.3.10 → v2.3.11). If in doubt about the correct version, read the current CHANGELOG top entry and add 1 to the patch number.

━━━

## QA Checklist

The QC pass itself passes when:
- [ ] All 5 checks run and reported
- [ ] All auto-fixable violations resolved
- [ ] Manual items surfaced with clear diagnosis
- [ ] CHANGELOG updated if any structural changes occurred
- [ ] No files deleted (only edited/created)
- [ ] No `.obsidian/` modifications
- [ ] Final report delivered to [OWNER]
