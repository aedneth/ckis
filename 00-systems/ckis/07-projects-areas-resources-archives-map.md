---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, taxonomy, projects, areas]
status: active
related: ["[[00-ckis-master-context]]", "[[02-obsidian-vault-architecture]]"]
---

# 07 — Projects · Areas · Resources · Archives Map

> Real taxonomy as it lives in this vault. CKIS is **inspired by PARA** (Projects / Areas / Resources / Archives) but uses Eduardo's numbered-folder convention with finer-grained content folders. Do not force pure PARA on top of this — preserve the existing structure.

━━━

## 1. Taxonomy Type

Hybrid: PARA-inspired but extended. The vault adds explicit folders for **inbox**, **daily notes**, **knowledge** (permanent + literature notes + MOCs), **goals**, and **people** — each of which would be smashed flat in a strict PARA setup.

Folder mapping to PARA:

| Vault folder | PARA equivalent | Notes |
|---|---|---|
| `00-inbox/` | (capture buffer) | Strict PARA has no inbox; this vault treats it as a first-class zone |
| `01-daily/` | (operations) | Time-indexed working memory |
| `02-projects/` | Projects | Korvex, Brisas, University, Personal Brand |
| `03-knowledge/` | (Resources, but evergreen) | Permanent + literature + MOCs + frameworks + guides + patterns |
| `04-resources/` | Resources | Raw reference (articles, books, courses, social, tools, youtube) |
| `05-areas/` | Areas | Health, finance personal, finance business, relationships, learning, wellbeing |
| `06-goals/` | (separate goal system) | Annual, monthly, weekly |
| `07-people/` | (CRM-ish) | Clients, mentors, network |
| `08-templates/` | (system) | Note templates |
| `09-archive/` | Archives | Completed or inactive |
| `00-system/ckis/` | (system meta) | Architecture and operating rules |

## 2. Projects (`02-projects/`)

Active:

- **Korvex** — `02-projects/korvex/` — primary professional focus. Software / digitalization startup (not a "web agency"). Stack: Next.js 16, TypeScript, Tailwind, shadcn/ui, Supabase, Vercel, Cloudflare, Wompi SV.
- **Brisas del Golfo** — `02-projects/brisas-del-golfo/` — delivered hotel/restaurant client site. URL: brisasdelgolfo.site. Postmortem documented.
- **University** — `02-projects/university/` — UGB Ingeniería en Sistemas, Ciclo 1-2026. Goal Q2: pass all subjects (≥7/10), automate study pipelines.
- **Personal Brand** — `02-projects/personal-brand/` — LinkedIn-only, reactivated Q2 2026.

Archived (`09-archive/`):

- **Tourdy** — `09-archive/tourdy/` — coastal tourism marketplace. Archived 2026-05-02 to give Korvex full focus. Reactivation trigger: manual ("when Eduardo says so").
- **HidroPlus** — IoT hydration project (ESP8266, Blynk). Bachillerato-era project; archived (not a current priority).
- **Movi RideXpress** — dual-service startup. Archived (location TBD; check `09-archive/`).

Each project folder must contain `_overview.md`. Subfolders typical of project work: `clients/`, `processes/`, `notes/`, source-of-truth context files (e.g., `korvex-context.md`, `company-strategy-context.md`).

## 3. Areas (`05-areas/`)

Six area files (file = the area's living summary; append, don't fragment):

- `health-fitness.md` (covers Notion's Alimentación + Ejercicio)
- `finance-personal.md`
- `finance-business.md` (monthly/quarterly summaries only — no transactions)
- `relationships.md` (Familia + Pareja + close circle)
- `learning.md` (Aprendizaje + Programación)
- `wellbeing.md` (Bienestar — sleep, mindset, balance)

Areas accumulate; they don't "complete." A new entry typically appends a dated section.

## 4. Resources (`04-resources/`)

Subfolders for source kind:

- `articles/`, `books/`, `courses/`, `social-captures/`, `tools/`, `youtube/`.

Distinction from `03-knowledge/literature-notes/`:

- `04-resources/<sub>/` — raw or lightly processed reference material.
- `03-knowledge/literature-notes/` — distilled notes about a single source, with insights and links.

A single source can have both: a raw entry under `04-resources/youtube/` and a literature note under `03-knowledge/literature-notes/` linking to it.

## 5. Knowledge (`03-knowledge/`)

Five subfolders:

- `permanent-notes/` — atomic, evergreen, one idea per file.
- `literature-notes/` — source-based notes.
- `maps-of-content/` — `MOC-Topic-Name.md`, hub pages.
- `frameworks/` — reusable mental models.
- `guides/` — operational references (Master Vibe Coding Guide, Claude Code Operations).
- `patterns/` — AI-detected recurring patterns and synthesis reports.

This is the most valuable folder over time — the vault's compounding asset.

## 6. Goals (`06-goals/`)

- `2026-annual.md` — annual vision + quarterly targets.
- `monthly/` — monthly reviews / intelligence reports.
- `weekly/` — weekly reviews (`YYYY-MM-DD-weekly-review.md`).

One unified goal system. Do not introduce a parallel goal tracker.

## 7. People (`07-people/`)

- `clients/` — one note per real (not prospective) Korvex client.
- `mentors/` — relationships providing strategic input.
- `network/` — useful contacts not in the above buckets.

Use `08-templates/client-note.md` to scaffold new client notes.

## 8. Templates (`08-templates/`)

Existing: `client-note.md`. Other templates referenced in source plan but not yet present: `daily-note.md`, `project-overview.md`, `literature-note.md`, `permanent-note.md`, `goal-quarterly.md`, `weekly-review.md`. See `[[08-note-templates-and-frontmatter]]`.

## 9. Archive (`09-archive/`)

- Completed projects' full folders, moved (not deleted).
- Inactive notes that no longer fit any active context.
- Originals from `convert-queue/` after conversion (under `00-inbox/convert-queue/processed/`, parallel concept).

Rule: prefer archiving over deletion. Always.

## 10. CKIS System Folder (`00-system/ckis/`)

This folder. Holds:

- Master context, profile, vault architecture, workflow specs.
- Cross-model protocols.
- Claude Project / ChatGPT Project instructions.
- Skill cards (catalog).
- Source map and audit log.
- CHANGELOG.

## 11. Cross-Folder Patterns

- A YouTube video produces: an entry under `04-resources/youtube/`, plus a literature note under `03-knowledge/literature-notes/`, plus 0+ permanent notes under `03-knowledge/permanent-notes/`, plus possible MOC update.
- A new client produces: a note under `07-people/clients/` (from `client-note.md` template) and a project subfolder under `02-projects/korvex/clients/` if the engagement is large enough.
- A captured book produces: an entry under `04-resources/books/` and 1+ permanent notes for novel ideas.

## 12. Anti-patterns to Avoid

- Splitting an "area" into many tiny files (`05-areas/health-fitness-january.md`, `05-areas/health-fitness-february.md`). Append to the single area file instead.
- Creating a `02-projects/<project>/` folder with only `_overview.md` and no real content for weeks. If there's no work, the project may not actually be active — move to `09-archive/`.
- Cross-storing the same note in two folders. Use links, not copies.
