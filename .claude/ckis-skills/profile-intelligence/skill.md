---
name: profile-intelligence
description: Gather [OWNER]'s personal documents (academic essays, speeches, startup archives, assessments), convert them to Markdown, triage for signal, and synthesize a comprehensive Founder Profile Intelligence MOC plus any downstream profile docs (YC founder profile, bios, about pages). Use when [OWNER] says "profile intelligence", "founder intelligence", "build my founder profile", "synthesize who I am", or needs a personal/founder profile assembled from his real history.
---

# Profile Intelligence

Turn [OWNER]'s scattered personal record — academic work, competition speeches, startup archives, personality assessments, and the CKIS knowledge base — into a single coherent map of who he is as a founder and person, then power any downstream profile artifact (YC founder profile, investor bio, about page, personal-brand narrative) from that map. This is the skill that makes "tell them who I am" produce truth from evidence instead of generic founder fluff.

Codifies the workflow first executed 2026-05-25 to build `[[03-knowledge/permanent-notes/MOC-Profile-Intelligence]]` and `[[02-projects/[your-project]/yc-application/YC-S26-founder-profile]]`.

## Workflow

1. **Define the target.** Confirm what's being produced: just the intelligence MOC, or the MOC + a specific downstream doc (YC profile, bio, etc.). If a downstream doc, get its exact field list / form structure up front.
2. **Gather sources.** Collect from both the vault and external document folders:
   - Vault: `03-knowledge/permanent-notes/` (identity, philosophy, alter-ego, startup-ideas-backlog), `03-knowledge/patterns/`, `03-knowledge/maps-of-content/`, `09-archive/` (every file — past projects/applications), `00-systems/ckis/01-ckis-user-profile-and-operating-context.md`, `00-inbox/_PROFILE.md`/`_MEMORY.md`.
   - External (read-only): `~/Documents/Academic/` (essays, vocational work, IKIGAI), `~/Documents/Startups/Archieve/` (Fletex, BusNET, We Solve, Movi, Hidro+, ePOS, etc.).
3. **Convert to MD if needed.** Non-MD sources (`.docx`, `.pdf`, `.txt`, audio transcripts) get converted/read. Stage conversions in `00-inbox/tmp-*/convert-queue/` — never edit originals. Use the `convert-to-md` skill for batch conversion. PDFs: read directly with the Read tool (use `pages:` ranges for >10-page PDFs). Audio: read the existing `(transcript).txt` siblings.
4. **Triage for signal.** Not every document matters. For each source, extract: founder-DNA evidence, idea-evolution data points, thinking-framework instances, things built, communication/oratory record, values/mission/anchors, market insights. Discard administrative noise. Preserve real facts verbatim — grades, dates, placements, metrics. Never inflate or invent.
5. **Synthesize the MOC.** Build/update `03-knowledge/permanent-notes/MOC-Profile-Intelligence.md` with these sections (adapt as evidence dictates):
   - Founder DNA (repeating patterns across all sources)
   - Idea Evolution (chronological table + the connecting thread)
   - Thinking Frameworks (link each to its permanent note)
   - Building Portfolio (hardware / software / content / services)
   - Oratory & Communication
   - Personal Anchors (IKIGAI, alter ego, philosophy, disciplines)
   - Market Insights
   - The Pitch Profile (the fundable/synthesized view)
   - Vault Cross-References (every node, with `[[wikilinks]]`)
6. **Produce downstream doc(s).** If a YC founder profile / bio / about page was requested, fill every field in [OWNER]'s voice (direct, honest, concrete, no buzzwords), sourced from the MOC. Frontmatter `related:` links back to the MOC.
7. **Wire the graph.** Add bidirectional `[[wikilinks]]` between the MOC, the downstream doc, and every source permanent note referenced. Update `modified` on any existing note touched.
8. **Report inline.** Summarize the key founder-intelligence patterns discovered (3-5 sentences) and list every file created/updated with absolute paths.

## Output format

- **Primary artifact:** `03-knowledge/permanent-notes/MOC-Profile-Intelligence.md` (the 9-section map above).
- **Downstream artifacts (as requested):** profile docs in the relevant project folder (e.g. `02-projects/[your-project]/yc-application/`).
- **Inline report:** patterns discovered + file manifest with absolute paths.

## Rules

- **Read before edit.** Every file read before any modification. Never edit a note you haven't read this session.
- **Preserve originals.** Never edit source documents in `~/Documents/Academic/` or `~/Documents/Startups/`. Convert into the vault's convert-queue; treat originals as read-only.
- **No deletion.** Move to `09-archive/` if anything must be retired. Never `rm`.
- **Facts are sacred.** Add insight and connection, never change the underlying facts (grades, dates, placements, financials, who-did-what). When uncertain about a fact, flag it rather than smooth it over.
- **Preserve language.** Read Spanish sources in Spanish; do not translate vault notes. Downstream English artifacts (YC, US-facing) are written in English, but the underlying Spanish sources stay Spanish.
- **[OWNER]'s voice in profile prose.** First person, direct, confident-not-arrogant, concrete, no buzzwords. The voice reference is `[[00-systems/ckis/01-ckis-user-profile-and-operating-context]]` §Work Style.
- **Synthesis is prose, not citation dumps.** The "Founder DNA" and "Pitch Profile" sections must read as connected insight, not bullet lists of sources.
- **Wikilink liberally.** The MOC's value is its connection density — link every framework, project, and archive node.
- **Honesty over polish.** If a decision is made-but-not-executed (e.g. scholarship resignation), say exactly that. If a claim can't be sourced, don't make it.

## Gotchas

- **PDFs over 10 pages** fail a single Read — use the `pages:` parameter in ranges, or it errors out.
- **IKIGAI / vocational PDFs live deep in `~/Documents/Academic/Programa Oportunidades FGK/...`** with `~$`-prefixed lock files (LibreOffice temp files) that are NOT the real document — match the real `.pdf`/`.docx`, ignore `~$` siblings.
- **Audio sources** (e.g. Hidro+, Fletex) already have `(transcript).txt` siblings — read those, don't try to process audio.
- **The freight transcript (Fletex) is [OWNER]'s father, a truck driver, describing the problem** — attribute the *idea origin* correctly ([OWNER] saw the gap from his father's experience), don't mis-read it as [OWNER]'s own job.
- **ePOS was discarded — but the discard *reason* is the signal**, not a failure. He rejected the static/generic POS model and the thesis re-emerged in [YOUR_PROJECT]. Frame discards as maturity, not abandonment.
- **Don't treat school essays as "just homework."** The NASA/YA/IKIGAI/admission essays are deliberate identity documents (same lesson as the Jackson Steele extraction in `[[03-knowledge/patterns/chatgpt-knowledge-extraction-2026-04]]` §Gap 2). Mine them for self-model, not just facts.
- **Personality assessments (ENTJ-A, FODA) are self-reported** — present as self-assessment, not clinical fact.
- **Grades are on a 0–10 scale** (Salvadoran system: 9.8/10, 9.5/10) — don't convert to GPA or mislabel as percentages.
- **The idea-evolution thread is the highest-value output** for fundraising — always trace the convergence (We Solve → HealthFlow → ePOS → Movi → Tourdy → [YOUR_PROJECT]) rather than listing ventures in isolation. The narrative "this is a 3-year thesis, not a fresh idea" is the founder-market-fit proof.

## Example invocation

```
[OWNER]: build my founder profile for [program/investor]
→ Confirm target: intelligence MOC + the program's exact field list
→ Gather: vault permanent-notes + 09-archive + Academic essays + Startups archive
→ Convert/read non-MD sources (PDFs in page-ranges, .docx via convert-to-md, audio transcripts)
→ Triage each for founder-DNA / idea-evolution / portfolio / oratory / anchors / market
→ Build MOC-Profile-Intelligence (9 sections, heavy wikilinks)
→ Fill the program's profile fields in [OWNER]'s voice, sourced from the MOC
→ Wire bidirectional links; update modified dates
→ Report patterns discovered + file manifest (absolute paths)
```
