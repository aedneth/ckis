---
name: client-onboarding
description: Spin up a new [YOUR_PROJECT] client — create a person note in 07-people/clients/, a project file in 02-projects/[your-project]/clients/, prompt Eduardo for the essentials (business type, services, contact, start date, channel), and produce a client brief. Use when [OWNER] says "onboard client [name]", "nuevo cliente [nombre]", or "new client [name]".
---

# Client Onboarding

Every new [YOUR_PROJECT] client needs the same scaffolding: a relationship note (who they are), a project file (what we're delivering), a brief (the at-a-glance summary), and a clear comms channel. This skill creates all of that in one pass and asks [OWNER] only for the things that can't be inferred.

## Workflow

1. **Parse the client name** from [OWNER]'s request. Generate a kebab-case slug (e.g., "Restaurante La Brisa" → `restaurante-la-brisa`).
2. **Check for collisions**: Glob `07-people/clients/<slug>*.md` and `02-projects/[your-project]/clients/<slug>*.md`. If files exist, ask Eduardo if this is a new engagement or a continuation.
3. **Read the template** at `08-templates/client-note.md` if it exists. Use it as the structure for the new files.
4. **Ask Eduardo for the essentials** in one batch (use AskUserQuestion if multiple questions). Required fields:
   - **Business type / industry** (restaurante, retail, servicios, etc.)
   - **Services contracted** (sitio web, branding, SEO, etc.)
   - **Contact info** (name, phone, email)
   - **Project start date** (YYYY-MM-DD)
   - **Primary communication channel** (WhatsApp, correo, Slack, etc.)
   - **Estimated value / pricing** (optional but useful)
   - **Deadline / target launch date** (optional)
5. **Create the person note** at `07-people/clients/<slug>.md` (template below).
6. **Create the project file** at `02-projects/[your-project]/clients/<slug>.md` (template below).
7. **Update `02-projects/[your-project]/_overview.md`** — add the new client to the active client list (Edit, don't rewrite).
8. **Update `00-inbox/_ACTIVE-PROJECTS.md`** if [YOUR_PROJECT]'s status line should change (e.g., new client takes Eduardo from "1 active client" to "2 active clients").
9. **Generate and output a client brief** (format below) for [OWNER] to skim or share.

## Person note template (07-people/clients/<slug>.md)

```markdown
---
type: person
subtype: client
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#[your-project], #cliente]
status: active
related: [[<slug>]]
---

# {{Client Name}}

**Empresa:** {{business type}}
**Contacto principal:** {{name}}
**Teléfono:** {{phone}}
**Email:** {{email}}
**Canal preferido:** {{channel}}
**Cliente desde:** {{start date}}

## Sobre el cliente
{{1-2 sentences on who they are and what they do}}

## Historial de comunicación
- {{YYYY-MM-DD}} — primer contacto / onboarding

## Notas relacionales
- {{anything Eduardo should remember about how to work with this person}}
```

## Project file template (02-projects/[your-project]/clients/<slug>.md)

```markdown
---
type: project
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [#[your-project], #cliente-activo]
status: active
related: [[<slug>]]
client: "{{Client Name}}"
start_date: YYYY-MM-DD
target_launch: YYYY-MM-DD
value: "{{pricing}}"
---

# Proyecto: {{Client Name}}

> **Cliente:** [[<slug>]] · **Inicio:** {{start date}} · **Canal:** {{channel}}

## Servicios contratados
- {{service 1}}
- {{service 2}}

## Estado actual
{{one line — e.g., "Onboarding completado, esperando contenido del cliente"}}

## Hitos
- [ ] Onboarding completado
- [ ] Brief de marca recibido
- [ ] Diseño aprobado
- [ ] Desarrollo iniciado
- [ ] Lanzamiento

## Decisiones abiertas
- {{things waiting on the client or on Eduardo}}

## Notas de sesión
- {{YYYY-MM-DD}} — {{what happened}}
```

## Client brief output format (echo to Eduardo)

```markdown
# 🆕 Cliente onboarded: {{Client Name}}

**Industria:** {{business type}}
**Servicios:** {{services}}
**Contacto:** {{name}} · {{channel}}
**Inicio:** {{start date}}{{ · Lanzamiento: target_launch}}

## Archivos creados
- [[07-people/clients/<slug>]] — ficha relacional
- [[02-projects/[your-project]/clients/<slug>]] — proyecto activo

## Próximo paso sugerido
{{e.g., "Enviar formulario de brief de marca por <channel>"}}
```

## Rules

- Always create BOTH files: the person note and the project file. They cross-link via the `related` frontmatter field.
- Default language is Spanish — [YOUR_PROJECT] clients are local. Only switch to English if Eduardo explicitly indicates the client is English-speaking.
- Never overwrite existing client files. If a slug collides, ask.
- Optional fields (value, target_launch) can be left empty in frontmatter (`""`) — don't fabricate.
- If `08-templates/client-note.md` doesn't exist yet, proceed with the templates above and tell Eduardo at the end that the template file is missing so he can create it for next time.
- Don't auto-send anything (no email, no WhatsApp). The brief is for [OWNER], not the client.

## Example invocation

```
[OWNER]: nuevo cliente Restaurante La Brisa
→ Slug: restaurante-la-brisa
→ Glob check: no collision
→ AskUserQuestion: business type, services, contact, start date, channel
→ Eduardo answers: restaurante, sitio web + reservas, "Joaquín / +503 7777-7777", 2026-04-08, WhatsApp
→ Write 07-people/clients/restaurante-la-brisa.md
→ Write 02-projects/[your-project]/clients/restaurante-la-brisa.md
→ Edit 02-projects/[your-project]/_overview.md → add to client list
→ Echo brief
```
