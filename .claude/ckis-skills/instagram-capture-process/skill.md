---
name: instagram-capture-process
description: >
  Process a new Instagram save (reel or carousel) into a properly-named Type B note,
  inject transcription, update the saved-posts index, and update the MOC. Use when [OWNER]
  says "instagram-capture-process", "process this reel", "process this carousel",
  "add this IG capture", or "process Instagram save". Outputs a verified Type B note in
  04-resources/social-captures/instagram-captures/saved-posts/ with full transcription,
  updated index, and MOC link.
argument-hint: "reel or carousel + author handle + topic slug + raw transcription (or path to source file)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.0.0
  ckis-context: true
  category: workflow-automation
---

# Instagram Capture Process

> Turns a raw Instagram save (reel or carousel) into a correctly-classified, fully-transcribed Type B note — and keeps the index + MOC current. Created after G5.QC revealed that manual processing without a skill produced 61 misrouted, untranscribed notes.

━━━

## Scope

This skill operates on: `04-resources/social-captures/instagram-captures/saved-posts/`

**Do NOT touch**:
- `00-inbox/_PROFILE.md`, `_MEMORY.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md`
- `.obsidian/` folder
- `03-knowledge/permanent-notes/` — social captures NEVER go here (Type A only)
- Any file with `status: archived` in frontmatter

━━━

## Pre-conditions

Before running, verify:
1. [ ] [OWNER] has provided: content type (reel or carousel), author handle, topic description, and transcription text or source file path
2. [ ] `04-resources/social-captures/instagram-captures/instagram-saved-posts-index.md` exists
3. [ ] `03-knowledge/maps-of-content/MOC-Reels-Knowledge-Batch-2026-05.md` exists (or ask [OWNER] which MOC to update)

If pre-conditions are not met, stop and ask [OWNER] for the missing inputs.

━━━

## Phase 1: Classify and Name

1. Determine content type from [OWNER]'s input:
   - **Reel** (single video with audio) → prefix `instagram-`
   - **Carousel** (multi-slide static images) → prefix `instagram-`
   - Both use the same prefix; distinguish by `subtype: social-capture` and note body

2. Build the canonical filename:
   ```
   instagram-{author-slug}-{topic-slug}.md
   ```
   Rules:
   - `author-slug`: Instagram handle, lowercased, dots/underscores → hyphens
   - `topic-slug`: 2-5 word kebab-case topic summary
   - No special characters, no spaces
   - Example: `instagram-mavenhq-agent-harnesses.md`

3. Check for filename collision:
   ```
   Glob "04-resources/social-captures/instagram-captures/saved-posts/instagram-{author-slug}-*.md"
   ```
   If a file with the same author+topic exists, add `-v2` suffix and notify [OWNER].

━━━

## Phase 2: Draft the Note

4. Build the YAML frontmatter (Type B — do NOT use `type: permanent-note`):

```markdown
---
type: resource
subtype: social-capture
processing: index-only
platform: instagram
author: {author-handle}
handle: @{author-handle}
content-type: {reel | carousel}
topic: "{topic description}"
captured: {YYYY-MM-DD}
created: {YYYY-MM-DD}
modified: {YYYY-MM-DD}
status: processed
tags: [resource, social-capture, instagram, {topic-tag}]
related:
  - "[[04-resources/social-captures/instagram-captures/instagram-saved-posts-index]]"
  - "[[03-knowledge/maps-of-content/MOC-Reels-Knowledge-Batch-2026-05]]"
---
```

5. Build the note body:

```markdown
# {Author Handle} — {Topic Title}

> {One-sentence description of what this content covers and why it's relevant to [OWNER]/[YOUR_PROJECT].}

━━━

## Key Points

- {Bullet 1 — main insight or technique}
- {Bullet 2}
- {Bullet 3}
(3-5 bullets max — Type B means body is sacred, do not over-synthesize)

## [YOUR_PROJECT] Relevance

{1-2 sentences on how this applies to [YOUR_PROJECT] or [OWNER]'s current work.}

━━━

## Transcription

{Full verbatim transcription of the reel/carousel text content. For reels: full spoken text. For carousels: all slide text in order, with slide breaks marked as "---".}
```

6. Write the note to:
   `04-resources/social-captures/instagram-captures/saved-posts/{filename}.md`

━━━

## Phase 3: Update the Index

7. Read `04-resources/social-captures/instagram-captures/instagram-saved-posts-index.md` to find the last row number.

8. Append one new row to the table (do not rewrite the whole file — use Edit):

```markdown
| {N+1} | [[{filename-without-.md}]] | @{author-handle} | {content-type} | {captured-date} | {1-line description} |
```

9. Update `modified:` field in the index frontmatter to today's date.

━━━

## Phase 4: Update the MOC

10. Read `03-knowledge/maps-of-content/MOC-Reels-Knowledge-Batch-2026-05.md` (or the MOC [OWNER] specified).

11. Find the most relevant topic section for this content (e.g., "Agent Infrastructure", "Content & Personal Brand", "Sales & Positioning").

12. Append the wikilink under that section:
    ```markdown
    - [[{filename-without-.md}]] — {1-line description}
    ```

13. If no existing section fits, add a new section header before the "Related MOCs" section:
    ```markdown
    ## {New Topic Name}
    
    - [[{filename-without-.md}]] — {1-line description}
    ```

━━━

## Phase 5: Verify

14. Run final checks:
    - [ ] File exists at correct path in `saved-posts/`
    - [ ] `type: resource` (NOT `type: permanent-note`)
    - [ ] `processing: index-only` present
    - [ ] `## Transcription` section has actual content (not empty)
    - [ ] Index has the new row
    - [ ] MOC has the new wikilink
    - [ ] No `.obsidian/` modifications

15. Report to [OWNER]:
    ```
    Processed: instagram-{author-slug}-{topic-slug}.md
    Type: {reel | carousel}
    Path: 04-resources/social-captures/instagram-captures/saved-posts/
    Index: row {N+1} added
    MOC: added to "{Section Name}" section
    ```

━━━

## Examples

**Example 1** — [OWNER] says "instagram-capture-process — @mavenhq posted about token savings, here's the transcript: [transcript text]":
- Phase 1: Filename → `instagram-mavenhq-token-savings.md`
- Phase 2: Type B frontmatter + body + full transcription
- Phase 3: Index row appended
- Phase 4: Added under "Agent Infrastructure" section in MOC
- Result: 1 verified Type B note, index +1, MOC +1

**Example 2** — [OWNER] says "process this carousel — @juanaia, automatizar con Claude, slides: [slide text]":
- Phase 1: `instagram-juanaia-automatizar-claude.md`
- Phase 2: content-type: carousel, slide text as transcription with `---` breaks
- Phase 3-4: Index + MOC updated
- Result: Complete Type B carousel note

━━━

## Troubleshooting

**No transcription provided**: Ask [OWNER]: "What's the transcription text for this capture? I need the spoken words (reel) or slide text (carousel) before I can create the note." Do not create an empty `## Transcription` section.

**Author handle ambiguous**: Use the exact handle from [OWNER]'s input. If unclear, ask: "What's the exact Instagram handle?" Do not guess.

**MOC section unclear**: If [OWNER]'s content doesn't fit any existing MOC section, surface the top 2-3 candidate sections and ask which to use.

**Collision with existing file**: Append `-v2` to the slug and inform [OWNER]. Do not overwrite existing captures.

━━━

## QA Checklist

Before marking complete:
- [ ] File in `04-resources/social-captures/instagram-captures/saved-posts/` (NOT in `03-knowledge/`)
- [ ] `type: resource` in frontmatter
- [ ] `processing: index-only` in frontmatter
- [ ] `## Transcription` section has real content
- [ ] Index row added with correct link and description
- [ ] MOC wikilink added in correct section
- [ ] No files deleted
- [ ] No `.obsidian/` modifications
