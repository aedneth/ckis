---
name: braindump
description: Capture raw, unstructured thoughts from Eduardo into the inbox with light classification and frontmatter. Use when Eduardo says "braindump", "brain dump", "quick capture", "vacía la cabeza", or otherwise signals he wants to dump ideas without organizing them. Does NOT file the note into a final folder — that is the job of process-inbox.
---

# Braindump

Capture raw thoughts fast. The braindump skill is the lowest-friction entry point into the vault: take what Eduardo says, write it down, classify it just enough to be retrievable later, and stop. Never try to perfect, organize, or move the note out of `00-inbox/quick-capture/`.

> The cost of capturing badly is near zero. The cost of *not* capturing because the system felt heavy is everything. Optimize for speed.

## Workflow

1. **Receive the dump.** Take whatever Eduardo says verbatim. Do not summarize away nuance, do not translate — keep the original language (Spanish or English).
2. **Ask at most ONE clarifying question** only if the content is ambiguous to the point of being unfileable. Otherwise, just capture.
3. **Classify** the dump into one of these types:
   - `idea` — a new concept, business angle, hypothesis
   - `task` — something to do
   - `insight` — a realization, lesson, or pattern noticed
   - `resource` — a link, name, tool, book, or reference to look up
   - `person` — info about someone (client, lead, collaborator)
4. **Generate filename**: `YYYY-MM-DD-HHMM-<short-kebab-slug>.md` using today's date. Slug should be 3-6 words capturing the gist.
5. **Write the file** to `00-inbox/quick-capture/` with the frontmatter and body below. Use the Write tool.
6. **Confirm** to Eduardo with: filename, type, and one-line summary. Then stop. Do NOT move it, do NOT link it, do NOT process it.

## Frontmatter spec

```yaml
---
type: capture
subtype: [idea | task | insight | resource | person]
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#kebab-case tags inferred from content]
source: braindump
status: inbox
related: []
---
```

## Body structure

```markdown
# {{one-line title in original language}}

{{the raw dump, lightly cleaned for typos but otherwise verbatim}}

## Context
{{1-2 lines: what was Eduardo doing / thinking about when this surfaced, if known}}
```

## Rules

- Never file outside `00-inbox/quick-capture/`. Filing is `process-inbox`'s job.
- Never delete or condense Eduardo's words. Capture-fidelity > tidiness.
- Bilingual: write in whatever language Eduardo used. Don't translate.
- Tags should be specific (`#korvex`, `#supabase-rls`) not generic (`#idea`, `#note`).
- If the dump contains 3+ distinct ideas, create 3+ separate files — one idea per note.
- Never block on missing info. Capture what you have.

## Example invocations

```
Eduardo: braindump — clients keep asking for SEO audits as upsell, maybe productize as a $200 fixed-scope deliverable
→ Create 00-inbox/quick-capture/2026-04-06-1430-korvex-seo-audit-productized.md
  type: capture, subtype: idea, tags: [#korvex, #productized-services, #seo]
```

```
Eduardo: brain dump, tres cosas: leer Range, Brisas necesita formulario de reservas, y Joaquín pidió cotización
→ Crear 3 archivos separados:
  - 2026-04-06-1431-leer-range-david-epstein.md (subtype: resource)
  - 2026-04-06-1431-brisas-formulario-reservas.md (subtype: task)
  - 2026-04-06-1431-joaquin-cotizacion-pendiente.md (subtype: task)
```
