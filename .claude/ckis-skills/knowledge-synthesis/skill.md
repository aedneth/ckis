---
name: knowledge-synthesis
description: Search the entire vault for all notes related to a topic, compile what Eduardo already knows, surface patterns, contradictions, and gaps, and create or update a MOC. Use when Eduardo says "synthesize [topic]", "síntesis de [tema]", "what do I know about [topic]", or "qué sé sobre [tema]".
---

# Knowledge Synthesis

Pull every relevant note across the vault into a single, coherent view of "what does Eduardo know about X". This is the skill that makes the second brain feel like a brain — the moment Eduardo asks "wait, what *do* I know about pricing?" and gets a real answer instead of a search result list.

## Workflow

1. **Parse the topic** from Eduardo's request. If ambiguous (`"synthesize AI"` is too broad), ask one clarifying question.
2. **Generate search terms**: the topic itself, 3-5 synonyms, related concepts, and the Spanish/English counterpart. Example for "pricing": `pricing`, `precios`, `cotización`, `value-based`, `wtp`, `willingness to pay`, `anchoring`.
3. **Search the vault** in parallel using Grep across:
   - `03-knowledge/permanent-notes/`
   - `03-knowledge/literature-notes/`
   - `03-knowledge/maps-of-content/`
   - `04-resources/`
   - `02-projects/`
   - `00-inbox/quick-capture/` (for unprocessed thoughts)
   Also Glob filenames containing the search terms.
4. **Read each match** (or the relevant section if a long file). Build an in-memory map of: source → claim/insight → tags → date.
5. **Compile the synthesis** with these sections:
   - **What Eduardo knows** — the consolidated view, written as connected prose, not a bullet list of citations
   - **Recurring patterns** — claims/ideas that show up in 2+ notes
   - **Contradictions** — places where notes disagree (genuine intellectual tension Eduardo should resolve)
   - **Gaps** — questions the existing notes raise but don't answer
   - **Source list** — every note used, with `[[wikilinks]]`
6. **Create or update the MOC** at `03-knowledge/maps-of-content/MOC-{{Topic}}.md`:
   - If it exists, update it: refresh the modified date, add any newly-found notes, refine sub-themes
   - If it doesn't exist, create it using the MOC template (see `monthly-consolidation` skill)
7. **If the synthesis surfaces a brand-new permanent insight** that none of the existing notes captured cleanly, create a permanent note in `03-knowledge/permanent-notes/`.
8. **Output the synthesis inline** to Eduardo (don't just point at the MOC file — show him the synthesis directly). End with: "Updated [[MOC-Topic]]" or "Created [[MOC-Topic]]".

## Inline synthesis format

```markdown
# Synthesis: {{Topic}}

## What you know
{{2-4 paragraphs of connected prose. Cite notes as [[wikilinks]] inline. No bullet dumps.}}

## 🔁 Recurring patterns
- **{{pattern}}** — appears in [[note1]], [[note2]], [[note3]]
- ...

## ⚡ Contradictions
- [[note A]] argues X, [[note B]] argues ¬X. Worth resolving because {{...}}

## 🕳️ Gaps
- {{question Eduardo's vault doesn't answer}}
- ...

## Sources used (N notes)
- [[note1]] · [[note2]] · [[note3]] · ...

→ Updated [[MOC-Topic]]
```

## Rules

- The "What you know" section is **prose, not bullets**. Forcing prose forces synthesis. Bullet dumps are not synthesis.
- Cite at least 3 notes or admit Eduardo has very little on the topic. Don't fabricate connections.
- Bilingual: write the synthesis in the language most of the source notes use. If split 50/50, use Spanish (Eduardo's native).
- Never delete or rewrite source notes. Synthesis is read-only on its inputs.
- "Contradictions" must be substantive — different framings of the same idea don't count.
- If fewer than 3 relevant notes exist, say so plainly: "Eduardo has 2 notes on this topic — too thin to synthesize. Suggest capturing more before running this again."

## Example invocation

```
Eduardo: synthesize value-based pricing
→ Search terms: value-based, pricing, wtp, willingness to pay, anchoring, cotización, precios
→ Grep across 03-knowledge/, 04-resources/, 02-projects/korvex/ → 11 matches
→ Read all matches → compile prose synthesis → identify 2 patterns, 1 contradiction, 3 gaps
→ Update existing MOC-Business-Strategy.md with new sub-section
→ Output synthesis inline
```
