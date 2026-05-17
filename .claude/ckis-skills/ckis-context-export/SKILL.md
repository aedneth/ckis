---
name: ckis-context-export
description: Regenerate the ChatGPT upload package under 00-systems/ckis/chatgpt-project-upload/ from the latest CKIS files. Diffs against the previous version and writes a CHANGELOG entry. Use when Eduardo says "export context" or after any material CKIS change. Copy-only — does not modify the source CKIS files.
---

# CKIS Context Export

Refresh the ChatGPT upload package so ChatGPT Projects always reflect the current CKIS state.

## Workflow

1. **Read** `00-systems/ckis/11-chatgpt-project-instructions.md` §1 to get the canonical file list.
2. **Verify** every listed file exists in `00-systems/ckis/`. If any are missing, abort and report.
3. **Confirm or create** the destination directory: `00-systems/ckis/chatgpt-project-upload/`.
4. **Copy** each listed file from `00-systems/ckis/<file>` to `00-systems/ckis/chatgpt-project-upload/<file>` (overwriting). Use `cp`, not `mv`.
5. **Diff:** run `git diff --stat -- 00-systems/ckis/chatgpt-project-upload/` to summarize what changed.
6. **CHANGELOG entry** in `00-systems/ckis/CHANGELOG.md`:

```
## YYYY-MM-DD — ChatGPT upload package regenerated

- Files refreshed: <count> (<list of files actually changed per git diff>)
- Source CKIS files modified since last export: <list>
- Action item: re-upload the package to the ChatGPT Project.
```

7. **Output a short report:**
   - Files in package: <count>.
   - Files changed since last export: <list>.
   - Reminder: re-upload to ChatGPT Project.

## Rules

- **Copy-only.** Never modify the source CKIS files in `00-systems/ckis/`.
- **No extra files.** The upload folder must contain exactly the files listed in CKIS file 11 §1 — nothing more, nothing less. If extra files are present, list them in the report (do not auto-delete; ask Eduardo).
- **No source-file edits.** This skill never edits the source CKIS files, even if it spots a typo.
- **CHANGELOG always.** Even when no files changed since the last export, write an entry stating "no changes since YYYY-MM-DD."

## QA Checklist

- [ ] Every file listed in CKIS file 11 §1 is present in the upload folder.
- [ ] No extra files in the upload folder.
- [ ] Source CKIS files unchanged (verify with `git status -- 00-systems/ckis/` excluding the upload folder).
- [ ] CHANGELOG entry written.
- [ ] Report mentions re-upload action.

## Do Not

- Modify the source CKIS files.
- Re-render or "improve" file content during copy.
- Auto-upload to ChatGPT — that's a manual step Eduardo does in the browser.
- Delete anything in the upload folder without explicit confirmation.
