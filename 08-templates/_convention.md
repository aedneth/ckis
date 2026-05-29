---
type: system
subtype: convention
folder: 08-templates
created: 2026-05-24
modified: 2026-05-24
status: active
tags: [convention, systems, ckis]
related:
  - "[[00-systems/ckis/02-obsidian-vault-architecture]]"
  - "[[00-systems/ckis/08-note-templates-and-frontmatter]]"
canonical: true
---

# Convention — 08-templates/

## Purpose
Obsidian templates — base files with predefined structure for creating new note types. These are not real notes; they are molds. The canonical source for all templates is [[00-systems/ckis/08-note-templates-and-frontmatter]]; the files here are ready-to-use implementations in Obsidian.

## What Goes Here
- Obsidian templates for recurring note types
- Only `.md` files that are empty or contain placeholders (`{{date}}`, `{{title}}`)
- One template per note type (don't duplicate templates with minor variations)

## What Does NOT Go Here
- Real notes with content → their corresponding folder
- Code or script templates → `00-systems/tools/`
- The frontmatter specification (that's `00-systems/ckis/08-note-templates-and-frontmatter.md`)

## File Naming Convention
- Kebab-case, name of the note type
- Examples: `daily.md`, `client-note.md`, `monthly.md`, `permanent-note.md`

## Active Templates
| File | For creating |
|---------|-----------|
| `daily.md` | Daily notes in `01-daily/` |
| `client-note.md` | Client notes in `07-people/clients/` |
| `monthly.md` | Monthly reports in `06-goals/monthly/` |

## Rule
If a new template is created here, also add its spec to [[00-systems/ckis/08-note-templates-and-frontmatter]].

## Related Folders
- [[00-systems/ckis/08-note-templates-and-frontmatter]] — canonical specification for all templates
