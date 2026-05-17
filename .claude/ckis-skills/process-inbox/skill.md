---
name: process-inbox
description: Read every file in 00-inbox/ and classify it as Type A (raw capture — full processing) or Type B (curated document — index only, body sacred). Type A gets restructured and rewritten. Type B gets only frontmatter + wikilinks added via Edit — the body is NEVER touched. Then move each item to its correct final folder. Use when Eduardo says "process inbox", "procesa el inbox", "vacía la bandeja", or asks for an end-of-day cleanup.
---

# Process Inbox — v2 (Type A / Type B branched)

Empty `00-inbox/` deliberately. Every file is classified before any write happens. Raw captures get structured. Curated documents get indexed. Neither branch is optional — the classification step is what separates a second brain from a corrupted file graveyard.

> The inbox processes two fundamentally different things: raw thoughts that need shaping, and complete documents that need indexing. Treating them the same corrupts the second brain. Classify first. Always.

━━━

## Workflow

**Step 0 — Auto-convert non-markdown.**
Scan `00-inbox/` recursively for `.pdf`, `.docx`, `.txt`, `.rtf`. If found, run `.claude/ckis-skills/convert-to-md/skill.md` and wait for completion. Converted files land in `00-inbox/` and are processed as Type B by default (B3 signal — authored content).

**Step 1 — List the inbox.**
`Glob 00-inbox/**/*.md`. Exclude system files: `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`. These never move.

**Step 2 — Sort by age.**
Anything with `created:` older than 7 days OR file mtime > 7 days goes into a "stale" bucket — step 6.

**Step 3 — For each file: CLASSIFY first, then execute the matching branch.**

Classification is done by reading the file (full, or head-200 + tail-50 for very large files) and running the decision tree in the next section. **Do not start writing until the type is known.**

**Step 4 — VERIFY** (both branches, before reporting).

**Step 5 — Stale items:** do NOT auto-delete. List under "⚠️ Stale".

**Step 6 — Output the processing report** (v2 format below).

━━━

## Classification decision tree

Run in order. **First match wins.** When uncertain → default to Type B.

### Hard Type B signals — any single one → Type B, stop

| Signal | Condition |
|---|---|
| B1 | frontmatter has `processing: index-only` |
| B2 | frontmatter `tags:` contains `preserve-body` OR body (first 50 lines) contains literal `#preserve-body` |
| B3 | file path matches `00-inbox/convert-queue/processed/**` |
| B4 | frontmatter `subtype:` is one of: `guide`, `reference`, `transcript`, `clipping`, `export` |
| B5 | frontmatter `type:` is `literature-note`, `resource`, or `guide` AND file has ≥80 lines |
| B6 | file has ≥200 lines (no honest raw capture reaches this length) |
| B7 | body contains ≥2 of: `**ChatGPT said:**`, `**You said:**`, `ChatGPT 4o`, `Conversation with ChatGPT` |
| B8 | frontmatter `source:` is a URL AND body contains `> [!INFO]` or `## Highlights` block |
| B9 | body contains ≥3 fenced code blocks OR ≥1 markdown table with ≥3 rows |

### Soft Type B signals — ≥2 hits → Type B

| Signal | Condition |
|---|---|
| S1 | file has ≥80 lines |
| S2 | body has ≥4 distinct H2/H3 headings |
| S3 | frontmatter already has ≥3 `related:` wikilinks |
| S4 | body has ≥3 inline `https://` URLs (citations, references) |
| S5 | filename is descriptive multi-word snake_case (e.g. `master_vibe_coding_guide.md`), NOT a timestamp/hash/Untitled |
| S6 | frontmatter has a non-empty `source:` field other than a vague tag |

### Type A fallback

Everything that doesn't match any Hard or Soft signal above. Typical profile: <80 lines, no frontmatter or skeletal frontmatter, single section or bullet dump, timestamp/Untitled/braindump filename.

**Stickiness:** when Type B is inferred from soft signals, write `processing: index-only` into the frontmatter immediately — future runs skip classification entirely (B1 fires at the top).

━━━

## Branch A — Raw capture (full processing allowed)

For files classified Type A.

**Allowed operations:** `Read`, `Write` (full rewrite), `Edit`, `Bash mv`.

**What to do:**
1. Determine: type, destination folder, 2+ tags, related wikilinks.
2. Grep `02-projects/`, `03-knowledge/`, `05-areas/` for the most distinctive nouns/topics.
3. Compose the normalized full file: frontmatter + restructured/normalized body + inline wikilinks where natural.
4. `Write` the file at the same path (or a new path if renaming).
5. Apply Mandatory linking rules (see below) to `related:`.
6. `Bash mv` to destination with clean kebab-case filename (strip Notion hashes, "Untitled", timestamps).

━━━

## Branch B — Curated document (INDEX ONLY — body is sacred)

For files classified Type B.

**Allowed operations:** `Read`, `Edit` (frontmatter and verbatim phrase wraps only), `Bash mv`.
**`Write` is FORBIDDEN on Type B files — no exceptions.**

### Frontmatter operations (Edit only, surgical)

If **no frontmatter** exists:
- Use one `Edit` targeting the file's exact first line:
  `old_string` = `<exact first line of body>`
  `new_string` = `---\n<yaml block>\n---\n\n<exact first line of body>`
- Never use `Write` to "just add frontmatter" — that replaces the entire file.

If **frontmatter exists**, edit ONLY these fields (one `Edit` per field):
- `modified:` → update to today.
- `tags:` → APPEND new kebab-case tags; never remove or reorder existing.
- `related:` → APPEND new wikilinks; never remove or reorder existing. Detect the array format (inline or block) and match it.
- `status:` → set to `active` ONLY if the field is missing entirely.
- `processing:` → set to `index-only` if Type B was inferred from soft signals.

Fields **never to touch on Type B**: `type`, `subtype`, `created`, `source`, `title`, `aliases`, any custom field.

### Inline wikilink injection (additive only, all gates must pass)

Body inline wikilinks are allowed ONLY when ALL of these hold:
1. The wikilink target name (or an exact alias) appears **verbatim** as a contiguous substring in the body.
2. The substring is NOT inside a fenced code block (count ``` occurrences before the offset — if odd, it's inside a fence).
3. The substring is NOT inside an inline code span (backticks on the same line).
4. The substring is NOT inside an existing `[[wikilink]]` or URL.
5. The phrase is ≥2 words OR a multi-syllable proper noun (not a common single word like "tool" or "the").

If any gate fails → skip. Frontmatter `related:` is sufficient. Never rephrase a sentence to insert a link.

When all gates pass: `Edit(old_string="<exact phrase>", new_string="[[<exact phrase>]]", replace_all=False)`.

### Filename rule for Type B

Default: **keep the original filename.** Eduardo and his tools chose it deliberately.
Only rename when the filename is clearly noise:
- Starts with `Untitled`
- Contains a 32-char hex hash (Notion export)
- Starts with `Pasted-` or a bare `YYYY-MM-DD-HHMMSS` with no descriptive slug

Renames: `Bash mv` only. Never use `Write` for renaming.

### Move

`Bash mv` to destination per routing table. The file contents are byte-identical to before except for frontmatter edits and allowed `[[phrase]]` wraps.

━━━

## Type B — hard rules (forbidden operations)

These are absolute. For any Type B file, the agent MUST NOT:

1. Call `Write` on the file — not even "just to add frontmatter."
2. Rewrite, paraphrase, summarize, condense, expand, or "improve" any body content.
3. Reorder sections, change heading levels, normalize bullets, fix typos, or change capitalization in the body.
4. Delete or modify code blocks, tables, URLs, citations, numbers, protocols, command examples, or any technical data.
5. Add a `## Summary`, `## TL;DR`, `## Related`, `## Notes`, or any new body section.
6. Insert a wikilink that requires rephrasing the surrounding sentence.
7. Change `type`, `subtype`, `created`, `source`, `title`, or `aliases` in frontmatter.
8. Remove or reorder existing entries in `tags:` or `related:`.
9. Move the original to a "raw" or "archive" folder while emitting a rewritten version.
10. Rename unless the filename is clearly noise (see Filename rule above).

**When in doubt about a Type B operation — do not do it.** A missing inline link costs nothing. A corrupted curated document is an unrecoverable loss.

━━━

## Preserve marker (Eduardo's manual override)

Either of these forces Type B regardless of all other signals:
- frontmatter field: `processing: index-only`
- tag `preserve-body` in the `tags:` array OR literal `#preserve-body` in the first 50 body lines

The agent never removes these markers.

━━━

## Routing table

| Subtype / content | Destination | Type default |
|---|---|---|
| Idea / insight, evergreen and atomic | `03-knowledge/permanent-notes/` | A |
| Notes from article, book, video, podcast | `03-knowledge/literature-notes/` | B if ≥80 lines |
| Long-form synthesis / reference guide | `03-knowledge/guides/` | B |
| Anything tied to Korvex / Brisas / University | `02-projects/<project>/` | varies |
| Tool, app, software reference | `04-resources/tools/` | B |
| Course material | `04-resources/courses/` | B |
| Web clips, transcripts, ChatGPT exports | `04-resources/articles/` or `03-knowledge/literature-notes/` | B |
| Health, finance, relationship, learning, wellbeing | `05-areas/<area>.md` (APPEND, never new file) | A fragments |
| Goal-related | `06-goals/` | A |
| Person (client, lead, mentor, collaborator) | `07-people/{clients,network,mentors}/` | varies |
| Task with no other home | append to today's `01-daily/` note | A |

━━━

## Frontmatter spec — Type A files (normalize to this)

```yaml
---
type: [permanent-note | literature-note | project | daily | resource | capture | area | goal | person]
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: []
source: ""
status: [active | processing | complete]
related: []
---
```

For Type B files, the spec is applied by APPENDING to existing frontmatter — never overwriting.

━━━

## Mandatory linking rules (graph-coherence — both branches)

Every file moved out of the inbox MUST end up with ≥1 `related:` link to a hub. No file leaves as a graph island.

**Graph spine:**
- 6 area files: `05-areas/*.md`
- 8 MOCs: `03-knowledge/maps-of-content/MOC-*.md`
- Monthly hub: `01-daily/YYYY-MM.md` (matching `created` month)
- Project overviews: `02-projects/<project>/_overview.md`
- Top-level: `_MEMORY`, `2026-annual`

### Minimum `related:` per destination

| Destination | Minimum `related:` required |
|---|---|
| `03-knowledge/permanent-notes/` | ≥1 MOC + ≥1 other permanent-note OR area |
| `03-knowledge/literature-notes/` | ≥1 MOC OR ≥1 permanent-note |
| `03-knowledge/patterns/` | ≥1 MOC + the permanent-notes the pattern came from |
| `03-knowledge/guides/` | `[[MOC-AI-Coding-Vibecoding]]` (default for AI/coding) OR best-fit MOC |
| `04-resources/tools/` | `[[MOC-Tools-and-Resources]]` (always) |
| `04-resources/youtube/`, `articles/`, `books/`, `courses/` | ≥1 MOC matching topic |
| `04-resources/social-captures/` | ≥1 MOC OR area matching topic |
| `02-projects/<project>/` | `[[02-projects/<project>/_overview]]` (always) |
| `06-goals/` | `[[2026-annual]]` + relevant areas |
| `07-people/` | `[[MOC-People-and-Network]]` (always) + project the person relates to |
| `01-daily/` | `[[YYYY-MM]]` (matching monthly hub) + `[[_MEMORY]]` |

### Tag-based auto-routing

| Tag(s) | Auto-add `related:` |
|---|---|
| `#tool`, `#linux`, `#pop-os`, `#bash`, `#cli` | `[[MOC-Tools-and-Resources]]` |
| `#vibe-coding`, `#claude-code`, `#ai-agents`, `#mcp`, `#prompt-engineering` | `[[MOC-AI-Coding-Vibecoding]]` |
| `#korvex` | `[[02-projects/korvex/_overview]]` + `[[MOC-Carrera-AI-Income]]` |
| `#brisas` | `[[02-projects/brisas-del-golfo/_overview]]` |
| `#university`, `#ugb` | `[[02-projects/university/_overview]]` + `[[05-areas/learning]]` |
| `#fitness`, `#salud`, `#looksmaxxing`, `#hormones` | `[[MOC-Biohacking-Optimizacion-Personal]]` + `[[05-areas/health-fitness]]` |
| `#alter-ego`, `#personal-brand`, `#viral-scripts` | `[[MOC-Identidad-Alter-Ego]]` + `[[02-projects/personal-brand/_overview]]` |
| `#freight`, `#transporte`, `#latam-transit` | `[[MOC-Startups-Transporte-LATAM]]` + `[[MOC-Business-Strategy]]` |
| `#business`, `#strategy`, `#monetization`, `#upwork` | `[[MOC-Business-Strategy]]` |
| `#finance` (personal) | `[[05-areas/finance-personal]]` |
| `#finance-business`, `#korvex-finance` | `[[05-areas/finance-business]]` |

### Verification step (run BEFORE writing the final report)

For each moved file:
1. Confirm `related:` has ≥1 entry that resolves via Glob.
2. If destination is `01-daily/`, confirm the matching `01-daily/YYYY-MM.md` exists — if not, CREATE IT from `08-templates/monthly.md` before moving.
3. If a new permanent-note was created (Type A), append its wikilink as a bullet under the best-fit MOC's `## Core notes` (append-only).
4. **Type B only:** re-Read the first 5 and last 5 lines of the moved file. Confirm the body is byte-identical to the pre-edit body (modulo allowed `[[phrase]]` wraps). If unexpected drift is detected → abort, leave file in inbox, flag in report.

If a file still cannot be linked → **move it anyway**, flag under `🤔 Needs Eduardo's input` with a suggested new MOC or hub. The system self-evolves: when 3+ flagged files share a theme, propose creating a new MOC. Connections are created over time, not enforced upfront.

━━━

## Output report format (v2)

```markdown
# Inbox Processing Report — YYYY-MM-DD

**Processed:** N files  (Type A: a  |  Type B: b)
**Moved:** N
**Stale (>7 days):** N

## ✅ Processed — Type A (restructured)

- `old-name.md` → `03-knowledge/permanent-notes/new-name.md`
  (type: permanent-note, +2 links, body restructured)

## 📦 Indexed — Type B (body preserved)

- `master_vibe_coding_guide.md` → `03-knowledge/guides/master_vibe_coding_guide.md`
  (frontmatter: +modified, +1 tag, +2 related; body: 1 phrase wrapped as [[wikilink]]; signals: B6+B9)
- `chatgpt-export-foo.md` → `03-knowledge/literature-notes/chatgpt-export-foo.md`
  (frontmatter only: +modified, +3 related; signals: B7)

## ⚠️ Stale — review for deletion

- `2026-03-20-something.md` (17 days old) — one-line summary

## 🤔 Needs Eduardo's input

- `ambiguous-file.md` — could not be linked to any hub after all rules; suggest creating MOC-X if more files on this topic arrive
```

The `signals:` annotation in the Type B section gives Eduardo a fast audit trail — he can verify why each file was treated as curated rather than rewritten.

━━━

## General rules

- Never delete files. Stale items get flagged, not removed.
- Never move `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`, `_MEMORY.md`.
- Preserve original language (Spanish/English bilingual is fine).
- If a file has zero meaningful content (empty, single word, stray test) → flag under "Needs Eduardo's input."
- Type A filename: strip Notion hash suffixes, "Untitled", bare timestamps → clean kebab-case.
- Type B filename: keep as-is unless clearly noise (see Branch B filename rule).
- If a destination filename collides, append `-2`, `-3`, etc.
- `05-areas/*.md` is always append-only — never create a new area file.
