---
name: convert-to-md
description: Convert non-markdown files in 00-inbox/convert-queue/ (.pdf, .docx, .txt, .rtf) to .md and move them to 00-inbox/ for processing. Use when [OWNER] says "convert files", "convierte archivos", or wants to ingest documents into the vault.
---

# Convert Files to Markdown

Scan `00-inbox/convert-queue/` for convertible files and transform them into `.md` so they can flow through the normal `process inbox` workflow. Source files are never deleted — they move to `processed/`.

## Workflow

1. **Check dependencies first.** Before doing anything else, verify the required tools are installed:
   - Run `which pandoc` — needed for `.docx` and `.rtf`
   - Run `which pdftotext` — needed for `.pdf`
   - If either is missing and files of that type exist in the queue, output the exact install command and stop:
     - pandoc missing: `sudo apt install pandoc` (Linux) / `brew install pandoc` (Mac)
     - pdftotext missing: `sudo apt install poppler-utils` (Linux) / `brew install poppler` (Mac)
   - Do not attempt partial conversion if a required tool is absent.

2. **Scan the queue.** List all files in `00-inbox/convert-queue/` (not in `processed/`):
   - Supported: `.pdf`, `.docx`, `.txt`, `.rtf`
   - Ignore: `.md` files, dotfiles, `.gitkeep`, subdirectories
   - If no supported files found, report "Queue is empty" and stop.

3. **Convert each file** using the method for its type:

   | Extension | Command |
   |---|---|
   | `.docx` | `pandoc "[file]" -o "00-inbox/[basename].md"` |
   | `.rtf` | `pandoc "[file]" -o "00-inbox/[basename].md"` |
   | `.pdf` | `pdftotext "[file]" "00-inbox/[basename].md"` |
   | `.txt` | `cp "[file]" "00-inbox/[basename].md"` |

   - **Preserve original filename** — only change the extension. `Report Q1.docx` → `00-inbox/Report Q1.md`
   - If the destination `.md` already exists in `00-inbox/`, append `-2`, `-3`, etc. to avoid collisions.
   - If a conversion command fails (non-zero exit), record it as a failure and continue with the next file.

4. **Move originals to processed.** After each successful conversion:
   ```
   mv "[file]" "00-inbox/convert-queue/processed/[filename]"
   ```
   Failed conversions stay in `convert-queue/` untouched.

5. **Output the report** (format below). Stop. Do not auto-trigger `process inbox`.

## Output report format

```markdown
# Convert-to-MD Report — YYYY-MM-DD

**Scanned:** N files
**Converted:** N
**Failed:** N

## ✅ Converted

- `Report Q1.docx` → `00-inbox/report-q1.md`
- `notes.txt` → `00-inbox/notes.md`

## ❌ Failed

- `scan.pdf` — pdftotext error: [error message]

## ⚠️ Missing tools

- `pandoc` not found — run: `sudo apt install pandoc`
```

## Rules

- **NEVER delete source files.** Move to `00-inbox/convert-queue/processed/` only.
- **Preserve original filename.** Only the extension changes.
- **If a required tool is missing**, output the exact install command and stop — do not attempt workarounds.
- **Do not auto-process** the converted files. Let Eduardo trigger `process inbox` separately.
- **Handle spaces in filenames** — always quote paths in shell commands.
