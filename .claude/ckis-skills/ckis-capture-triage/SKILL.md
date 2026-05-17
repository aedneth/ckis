---
name: ckis-capture-triage
description: Lightweight pre-process-inbox triage. Move mis-routed inbox items into the right inbox subfolder (screenshots → social-media-queue, URL dumps → url-dumps, PDFs/DOCX → convert-queue) without classifying or moving to a final folder. Use when Eduardo says "triage inbox" or wants to clean up the inbox before a full processing run. Never moves files out of 00-inbox/, never deletes anything.
---

# CKIS Capture Triage

Sort `00-inbox/` into its correct subfolders before a full `process inbox` run. This is the lighter pass — it doesn't classify, normalize frontmatter, or route to final folders.

## Workflow

1. **Read context.** Confirm by reading the first 3 lines of `00-inbox/_MEMORY.md` so the report can reference current focus areas (don't dump the whole file).
2. **Glob inbox.** `Glob 00-inbox/**/*` — exclude system files (`_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`) and the `processed/` subfolder under `convert-queue/`.
3. **For each file**, infer source by:
   - Filename pattern (`Screenshot_*.png` → social, `*.pdf`/`*.docx`/`*.rtf` → convert, URL-shaped names → url-dumps).
   - Extension.
   - First few lines if `.md` (Web Clipper output usually has a `source:` URL in frontmatter → url-dumps; raw thought paste → quick-capture).
4. **Move via `mv`** to the correct inbox subfolder:
   - Images / screenshots from social → `00-inbox/social-media-queue/`.
   - URL captures (Web Clipper output, articles) → `00-inbox/url-dumps/`.
   - PDF / DOCX / RTF / TXT non-markdown → `00-inbox/convert-queue/`.
   - YouTube transcripts or links → `00-inbox/youtube-queue/`.
   - Plain raw thoughts → `00-inbox/quick-capture/`.
   - Anything ambiguous → leave in `00-inbox/` root for processing.
5. **Output a triage report** with counts per subfolder and a per-file list of moves.

## Rules

- **Never** move a file out of `00-inbox/`. That's `process-inbox`'s job.
- **Never** delete a file. If a file looks like junk, leave it in place and flag it in the report.
- **Never** modify file contents — this skill only moves files.
- **Never** touch `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md` — they don't move.
- **Confirm** before moving more than 20 files in a single run.

## Output

Triage report in this shape:

```
Triage report — YYYY-MM-DD

Moved:
  social-media-queue/  +N
    - <filename>
  url-dumps/           +N
    - <filename>
  convert-queue/       +N
    - <filename>
  youtube-queue/       +N
  quick-capture/       +N

Left in inbox root (ambiguous):  N
  - <filename> — reason

Flagged (likely junk; review):  N
  - <filename> — reason
```

## QA Checklist

- [ ] No file moved out of `00-inbox/`.
- [ ] No file deleted.
- [ ] No frontmatter or body content modified.
- [ ] Report counts add up to total files seen.
- [ ] System files untouched.

## Do Not

- Run full `process-inbox` logic (classify, link, route to final folders).
- Convert PDFs / DOCX — that's the `convert-to-md` skill.
- Promote anything to `03-knowledge/` or any other content folder.
