---
name: claude-project-architect
description: >
  Generate a single copy-paste-ready `.md` file containing everything needed to spin up
  a new Claude.ai Project: project name, description, knowledge files to upload (with
  rationale), full T1 XML project instructions, and a self-contained first message.
  Use when [OWNER] says "claude-project-architect", "create a Claude.ai project",
  "set up a project in Claude", "architect a Claude project for [topic]", or
  "build project setup for [topic]". Always reads ALL source documents BEFORE writing
  instructions so facts (layer names, pricing, competitor names) are vault-verified,
  not hallucinated. Output: `00-systems/ckis/YYYY-MM-DD-{topic}-claude-project-setup.md`.
argument-hint: "topic / gate / domain (e.g. g2-market-research, [your-project]-sales-coach, pi-profile-analyst)"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.0.0
  ckis-context: true
  category: workflow-automation
---

# Claude.ai Project Architect

> Encodes the "read source docs first, write instructions second" protocol. Created after [OWNER]'s first G2 research project failed because instructions had approximate 5-layer-stack names, wrong pricing tiers, and no named competitors — the agent was working from memory, not from `03-service-packages-pricing.md`. This skill forces a Phase 1 read of every domain source before any prompt text is generated, then writes a vault-verified T1 XML system prompt + self-contained first message into one paste-ready file.

━━━

## Scope

This skill produces ONE output file:
`00-systems/ckis/YYYY-MM-DD-{topic}-claude-project-setup.md`

The file contains: project name, project description, knowledge-files-to-upload table, full T1 XML project instructions, self-contained first message, and "what comes back" follow-up tasks.

**Inputs read** (mandatory, Phase 1):
- All source documents in the relevant domain folder (`02-projects/[your-project]/`, `02-projects/[your-client]/`, or relevant MOC cluster — typically 15–25 files)
- `00-systems/workflows/prompt-engineering-system/03-anthropic-claude-conventions.md` (§8: Claude Projects guidance)
- `00-systems/workflows/prompt-engineering-system/13-prompt-template-library.md` (T1 template)
- Relevant MOC file if it exists for the domain

**Do NOT touch**:
- `.obsidian/` folder
- Any source file (read-only here)
- `_PROFILE.md`, `_MEMORY.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md` (reference only)

━━━

## Pre-conditions

Before running, verify:
1. [ ] [OWNER] has stated the project topic / gate (or you can infer + confirm)
2. [ ] The relevant domain folder exists and has source documents (check with Glob)
3. [ ] `00-systems/workflows/prompt-engineering-system/` exists with the T1 template and Claude conventions doc
4. [ ] Output target `00-systems/ckis/` is writable and CKIS CHANGELOG.md exists

If the domain has < 5 source documents, ask [OWNER]: "Only {N} source files in `{folder}`. Project instructions will be thin. Proceed or add more sources first?"

━━━

## Phase 1: Read Domain Source Documents

> **This phase is mandatory before any writing.** No project instructions may be drafted until all source files are read.

1. Ask [OWNER] (or parse from argument): "What is this project for? What domain / gate / task?"
   - Example answers: "G2 market research for [YOUR_PROJECT]", "PI profile analyst", "[YOUR_CLIENT] sales coach"

2. Determine the source folder(s) based on the project topic — the vault folder map:
   - Business / startup project → `02-projects/{project-name}/`
   - Book / framework study → `00-systems/workflows/{workflow-name}/`
   - Knowledge synthesis → `03-knowledge/permanent-notes/` + relevant MOC in `03-knowledge/maps-of-content/`
   - Resource analysis → `04-resources/{type}/`
   - Life area → `05-areas/{area}/`
   - Goals → `06-goals/`
   - Multiple domains → glob all relevant folders, not just one

   Glob each identified folder:
   ```bash
   Glob "{identified-folder}/**/*.md"
   ```
   Read every file found. There is no "wrong" folder to read — more source context produces better instructions.

3. Read ALL discovered source files. For each, capture:
   - Title + 1-line purpose
   - Exact named entities and terminology as the source uses them (product names, framework names, concept names, people, tools)
   - Exact numbers (prices, dates, percentages, KPIs, counts)
   - Key frameworks, mental models, templates, or structures the agent will need to reference
   - Any explicit constraints, rules, or conventions that must be respected

4. Read the prompt engineering system docs:
   ```bash
   Read "00-systems/workflows/prompt-engineering-system/03-anthropic-claude-conventions.md"
   Read "00-systems/workflows/prompt-engineering-system/13-prompt-template-library.md"
   ```
   From §8 of conventions: extract Claude Projects-specific guidance (instruction field size limit, knowledge file behavior, system prompt anchoring).
   From the template library: locate the T1 template structure and copy its block order exactly.

5. Read the domain MOC if one exists (e.g. `03-knowledge/maps-of-content/MOC-Profile-Intelligence.md`) — this shows you the knowledge graph for the domain and reveals files you might have missed.

━━━

## Phase 2: Identify Minimum Viable Knowledge Files

6. Build a candidate list of files the Claude.ai Project should have uploaded. For each candidate, ask:
   - "Does this add information NOTHING ELSE in the upload set covers?"
   - If YES → include
   - If it's downstream of another included file (e.g. a synthesis of a file already uploaded) → skip
   - If it adds noise without changing research output (CKIS architecture files, internal vault routing rules) → exclude

7. Target file count: **8–15 files** for a research project.
   - < 8 → probably missing context
   - > 15 → probably adding redundancy that hurts the model's attention

8. For each included file, write a 1-sentence rationale ("What it contributes"). Be specific:
   - Good: "Defines the exact 5-layer [YOUR_PROJECT] stack with current 2026 pricing tiers."
   - Bad: "[YOUR_PROJECT] context."

9. Write a "Do NOT upload" exclusion list (3–6 entries) with reasons:
   - "CKIS architecture files (`00-systems/ckis/0X-*.md`) — internal vault wiring, adds noise without changing research output."
   - "Daily logs (`01-daily/logs/`) — session traces, not source-of-truth facts."
   - "Inbox memory files (`_MEMORY.md`, `_PROFILE.md`) — handled in project instructions, not as knowledge files."

━━━

## Phase 3: Write the T1 XML Project Instructions

10. Open the T1 template from `00-systems/workflows/prompt-engineering-system/13-prompt-template-library.md` and follow its block order EXACTLY:

    ```xml
    <identity>
      You are {role description, 2–3 sentences}. You operate as a domain expert
      working with [OWNER] — founder of [YOUR_PROJECT], based in [YOUR_LOCATION].
      Stack: [YOUR_TECH_STACK].
    </identity>

    <context>
      {ALL static facts the agent needs, drawn from Phase 1 source docs — NOT memory.
       This is the cache-friendly block. ~2,000–3,000 chars. The content here is
       completely domain-dependent — adapt from these patterns:}

      For a BUSINESS / MARKET RESEARCH project:
        Company/product names, exact service/pricing tiers from the pricing doc,
        ICP hypotheses with exact segments, competitive landscape with named players,
        go-to-market strategy summary, key decisions already made and why.

      For a BOOK / FRAMEWORK / WORKFLOW study project:
        Core thesis of the framework in 1–3 sentences, key named concepts and their
        exact definitions as the author uses them, the most important mental models
        or decision rules, [OWNER]'s current context relative to this framework
        (what he's trying to apply it to), what he has already processed.

      For a CKIS / TOOL / SYSTEM project:
        Vault folder structure relevant to the task, the CKIS skill or workflow
        being built or used, [OWNER]'s current sprint gate and open tasks,
        the system constraints that must be respected (YAML rules, file naming,
        wikilink conventions).

      For any project type:
        [OWNER]'s identity (founder of [YOUR_PROJECT], [YOUR_LOCATION], [YOUR_UNIVERSITY],
        bilingual [YOUR_LANGUAGES], stack [YOUR_TECH_STACK]).
        Any deadlines, active experiments, or blocking decisions.

      Fill this block from source docs only. Never paraphrase from memory.
    </context>

    <task>
      {Define exactly what the agent does with each input. Adapt to the project type.}

      For a RESEARCH project:
        For each question [OWNER] asks, deliver: (1) evidence with citations,
        (2) implication for the decision at hand, (3) devil's advocate counter-position,
        (4) proposed vault update (path + change, or "no update needed").

      For a LEARNING / COACHING project:
        For each concept or scenario [OWNER] poses, deliver: (1) the framework's
        answer with page/section reference, (2) how it applies to [OWNER]'s
        current situation, (3) a concrete next action.

      For a BUILDING / CREATION project:
        For each task [OWNER] assigns, deliver: (1) the output artifact,
        (2) the rationale (which source doc / framework informed the choice),
        (3) any constraints respected, (4) proposed vault update if applicable.

      Replace these examples with the specific task definition for this project.
    </task>

    <workflow>
      1. {Step 1 — e.g. "Activate Research mode (live internet) at session start." or
         "Read all uploaded knowledge files before answering Q1."}
      2. {Step 2 — e.g. "Apply [framework name] protocol to every recommendation."}
      3. {Step 3 — e.g. "Cite the source file + section for every claim."}
      4. {Step 4 — e.g. "Distinguish knowledge-file answers from live-research answers."}
      5. {Step 5 — e.g. "End every answer with the 4-line vault-update block."}

      Define 3–6 steps specific to this project's workflow.
    </workflow>

    <constraints>
      NEVER:
      - Use approximate terminology — always use exact names, titles, and labels
        from the context block and knowledge files.
      - Invent facts, statistics, or quotes not present in the knowledge files
        or live research.
      - Use [OWNER]'s banned buzzwords: synergy, leverage, game-changer, disruptive,
        AI-powered, pivot, ideate, unpack.
      - {Add domain-specific NEVER rules from Phase 1 source docs — e.g.,
         "Call [YOUR_PROJECT] a web agency", "re-introduce dropped ICP segments",
         "confuse framework concepts X and Y".}

      ALWAYS:
      - Cite source for every numeric or factual claim.
      - Use exact terminology from the context block and knowledge files.
      - Respect [OWNER]'s bilingual context (Spanish capture → Spanish answer
        unless asked otherwise).
      - {Add domain-specific ALWAYS rules — e.g., "distinguish Track A and Track B",
         "end every answer with a vault-update proposal".}
    </constraints>

    <output_format>
      Format: Markdown.
      Length: 400–1200 words per answer (longer for multi-part questions).
      Structure per answer:
      ## {Question restated}
      **Evidence:** {2–6 bullets with citations}
      **Implication for [YOUR_PROJECT]:** {2–4 bullets}
      **Devil's advocate:** {1–3 bullets}
      **Vault update:** {path → change, or "no update needed"}
      ---
      Footer (always last line): `_Sources: {N} uploaded files + {M} live links_`
    </output_format>
    ```

11. Use exact facts from source docs — exact layer names, exact pricing tiers, exact competitor names. **Verify each against the Phase 1 source files** before writing the final instructions.

12. Total instructions length: target **4,000–6,000 characters** (Claude Projects instruction field has a practical limit around 8K chars; staying under 6K leaves headroom).

━━━

## Phase 4: Write the First Message

13. The first message must be **SELF-CONTAINED**. If someone pastes it into a blank Claude.ai chat with no prior context, the agent must still have everything it needs to start work.

14. Structure:
    ```
    Line 1: Activate Research mode (live internet) for this entire session.
             Apply {workflow name} devil's-advocate protocol to every recommendation.

    Short paragraph (3–5 sentences): What sprint gate this is, what the uploaded
    knowledge files cover, what the goal of this session is.

    =========
    TRACK A — {Track name}
    =========

    1. {Specific research question — names the hypothesis being tested,
       the evidence type needed, the format of answer required}
    2. {Specific research question — ...}
    3. {Specific research question — ...}

    =========
    TRACK B — {Track name}
    =========

    4. {Specific research question — ...}
    5. {Specific research question — ...}

    =========
    DELIVER per track:
    =========
    1. Market size (TAM/SAM/SOM with source links)
    2. ICP profile (firmographics + buyer + pain + budget)
    3. Competitive map (direct + adjacent with pricing)
    4. Go-to-market priority (1–3 ranked tactics)
    5. Risks / unknowns (3–5 items)
    ```

15. Questions must be **specific, not generic**. Each question must specify:
    - The hypothesis being tested
    - The evidence type needed (job postings, vendor pricing pages, case studies, regulatory filings)
    - The required format of the answer (table, ranked list, narrative)

    Bad: "Tell me about the SMB POS market."
    Good: "Test the hypothesis that SMB POS automation in LATAM is a Track-B fit for [YOUR_PROJECT] by finding (a) 5+ vendors offering POS+CRM bundles under $200/mo, (b) buyer-pain evidence from r/smallbusiness or Capterra reviews, (c) regulatory friction in El Salvador that would favor or block our entry. Return as a 3-column table per vendor + a 200-word recommendation."

━━━

## Phase 5: Write the Output File + WHAT COMES BACK

16. Filename: `00-systems/ckis/YYYY-MM-DD-{topic-slug}-claude-project-setup.md`

17. File structure (write all sections to this single file — nothing stays in chat):
    ```yaml
    ---
    type: system
    subtype: research-setup
    created: {YYYY-MM-DD}
    modified: {YYYY-MM-DD}
    status: active
    tags: [ckis, claude-project, research-setup, {gate-tag}]
    related:
      - "[[02-projects/[your-project]/2026-05-21-clarity-sprint]]"
      - "[[00-systems/ckis/YYYY-MM-DD-handoff-{topic}]]"
      - "[[00-systems/workflows/prompt-engineering-system/_workflow]]"
    ---

    # Claude.ai Project Setup — {Topic}

    > Paste-ready setup for a Claude.ai Project. Created from vault-verified sources
    > on {YYYY-MM-DD} for sprint gate {GATE-ID}.

    ━━━

    ## PROJECT NAME

    ```
    {Project name — short, descriptive, includes topic + [OWNER]'s name or [YOUR_PROJECT] tag}
    ```

    ━━━

    ## PROJECT DESCRIPTION

    ```
    {1–2 sentences describing the project's purpose and the agent's role.}
    ```

    ━━━

    ## PROJECT KNOWLEDGE — Files to Upload

    Upload these {N} files in this order:

    | # | Path | What it contributes |
    |---|------|---------------------|
    | 1 | `{path}` | {1-sentence rationale} |
    | 2 | `{path}` | {1-sentence rationale} |
    | ... | ... | ... |

    **Do NOT upload**:
    - `{path or pattern}` — {reason}
    - `{path or pattern}` — {reason}

    ━━━

    ## PROJECT INSTRUCTIONS

    Paste into Claude.ai → Project Settings → Custom Instructions:

    ```xml
    {Full T1 XML block from Phase 3, verbatim}
    ```

    ━━━

    ## FIRST MESSAGE

    Paste as the first chat message:

    ```
    {Full self-contained first message from Phase 4, verbatim}
    ```

    ━━━

    ## WHAT COMES BACK

    After the research returns, execute these Claude Code tasks in order:
    1. **{TaskID}** — {description} → vault file: `{path}`
    2. **{TaskID}** — {description} → vault file: `{path}`
    3. ...

    These are the downstream gates (e.g. G2.2–G2.7) that consume the research output.
    ```

18. Update CKIS CHANGELOG with new version entry:
    ```markdown
    ## YYYY-MM-DD — Claude.ai Project setup for {topic} (v{next-version})

    **Type:** research infrastructure — Claude.ai Project blueprint

    **Created:** `00-systems/ckis/YYYY-MM-DD-{topic-slug}-claude-project-setup.md`

    **Knowledge files:** {N} files mapped from {source-folder}.
    **Instructions length:** ~{chars} chars (T1 XML format).
    **Next:** [OWNER] creates the Claude.ai Project, uploads files, pastes instructions + first message.
    **Downstream gates:** {list of follow-up task IDs}.
    ```

━━━

## Phase 6: Quality Gate

19. Read back the generated instructions and first message. Verify each item below — if any fails, fix and re-verify:
    - [ ] Every named entity in `<context>` (product names, framework names, concept labels, pricing, KPIs) traces to a specific source file read in Phase 1 — no memory-based approximations
    - [ ] Every number in `<context>` (prices, dates, percentages, counts) matches the source file exactly — no rounding, no "approximately"
    - [ ] `<constraints>` NEVER list includes at least one domain-specific rule drawn from the source docs (not just the generic buzzword ban)
    - [ ] No buzzwords present: synergy, leverage, game-changer, disruptive, AI-powered, pivot, ideate, unpack
    - [ ] Instructions length is between 4,000 and 6,000 chars (count it; not under, not over)
    - [ ] First message is self-contained — no references to "the previous conversation" or "as we discussed"
    - [ ] Output file exists at `00-systems/ckis/YYYY-MM-DD-{topic-slug}-claude-project-setup.md`
    - [ ] CKIS CHANGELOG prepended with new version entry
    - [ ] WHAT COMES BACK section lists at least 2 downstream Claude Code tasks

20. Deliver to [OWNER]:
    ```
    ━━━ Claude.ai Project Setup Ready ━━━

    File: 00-systems/ckis/YYYY-MM-DD-{topic-slug}-claude-project-setup.md

    Summary:
    - Project name: {name}
    - Knowledge files: {N} (paths in table)
    - Instructions: ~{chars} chars, T1 XML format
    - First message: self-contained, {workflow} devil's advocate enabled
    - Downstream tasks: {N} listed in WHAT COMES BACK section

    Next steps:
    1. Open claude.ai → New Project → paste name + description
    2. Settings → Custom Instructions → paste the XML block
    3. Knowledge → upload the {N} files in the order listed
    4. Start chat → paste the first message
    5. When research returns → resume in Claude Code with the WHAT COMES BACK list
    ```

━━━

## Report Format

After Phase 6 the report is delivered inline (step 20). No separate report file.

━━━

## Examples

**Example 1** — [OWNER] says "architect a Claude project for g2 market research":
- Phase 1: Globs `02-projects/[your-project]/**/*.md` → 22 files. Reads all. Reads `MOC-[YOUR_PROJECT].md`. Reads prompt-engineering-system T1 template + Claude conventions §8.
- Phase 2: Selects 11 files for upload — VISION.md, 03-service-packages-pricing.md, ICP-hypotheses.md, Bloque-4-Competitive-Landscape.md, two-track-strategy.md, 2026-05-21-clarity-sprint.md, and 5 supporting docs. Excludes daily logs, CKIS internals, _MEMORY.md.
- Phase 3: Writes T1 XML — context block cites the 5 exact layers + pricing tiers from `03-service-packages-pricing.md`; constraints block bans buzzwords; output_format requires the 4-part answer structure. ~5,200 chars total.
- Phase 4: First message activates Research mode, organizes Track A (US high-ticket) and Track B (LATAM SMB POS) with 7 specific numbered questions each citing hypothesis + evidence type + format.
- Phase 5: Writes `00-systems/ckis/2026-05-29-g2-market-research-claude-project-setup.md` with all sections. WHAT COMES BACK lists G2.2 → G2.7 with file paths. CHANGELOG bumped v2.3.29 → v2.3.30.
- Phase 6: All 9 QA checks pass. Delivers report.

**Example 2** — [OWNER] says "create a Claude.ai project for [your-project] sales coach":
- Phase 1: Globs `02-projects/[your-project]/` + `00-systems/workflows/sales-workflow/` → 18 files. Reads all + T1 template.
- Phase 2: Selects 9 files — sales-workflow/01-wsb-principles.md, 02-naval-mental-models.md, 03-service-packages-pricing.md, ICP-hypotheses.md, decision-log-2026-05.md, founders-playbook/02-market-research-framework.md, founders-playbook/04-business-model-and-pricing.md, two-track-strategy.md, MOC-Sales.md. Excludes G5.D reels and labor-market-ai-impacts (downstream / general).
- Phase 3: T1 instructions cast the agent as "[YOUR_PROJECT] Sales Coach" — context block has exact pricing + WSB axioms + Naval leverage forms. Task block requires "objection → script → close → vault update" 4-part output.
- Phase 4: First message: "Activate Research mode. Role-play 3 calls today: (1) SMB owner $1.5K/mo, (2) US construction firm $15K/mo, (3) LATAM ANIA pilot prospect..." with explicit scoring rubric per call.
- Phase 5: Writes `00-systems/ckis/2026-05-29-[your-project]-sales-coach-claude-project-setup.md`. WHAT COMES BACK: G3.2 update sales scripts, G3.3 add objection log to vault, G3.4 weekly review of role-play sessions.
- Phase 6: Catches one buzzword ("leverage") in first draft, replaces with "use" — re-passes. Delivers.

━━━

## Troubleshooting

**Source documents incomplete or contradictory**: Surface to [OWNER] before writing instructions. Example: "Pricing tier in `03-service-packages-pricing.md` shows $5K/mo for Layer 3, but `decision-log-2026-05.md` mentions $7K. Which is current?" Do not silently pick.

**T1 template not found in `prompt-engineering-system/`**: Fall back to the inline T1 structure shown in Phase 3 step 10. Flag to [OWNER]: "T1 template file missing — used inline fallback structure. Consider regenerating prompt-engineering-system workflow."

**Instructions exceed 6,000 chars**: Cut from `<context>` first (remove redundant subpoints), then `<workflow>` (collapse steps), never from `<constraints>` (those prevent hallucination).

**No domain folder exists**: If the topic doesn't match an existing project folder, ask [OWNER]: "Topic `{topic}` doesn't match `02-projects/{[your-project]|brisas-del-golfo}` or any MOC. Create a new project folder first, OR specify the source folder to read."

**Duplicate Claude.ai project name**: If [OWNER] already has a Claude.ai project with the same name, suggest a date-suffixed variant: "[YOUR_PROJECT] G2 Research — 2026-05-29".

**Knowledge file list under 8**: Re-glob broader (include `03-knowledge/permanent-notes/` for relevant domain notes, `04-resources/` for reference material). If still under 8, ask [OWNER]: "Only {N} candidate files. Proceed with thin context, or read additional sources first?"

━━━

## QA Checklist

Before considering the project setup complete:
- [ ] Output file exists at `00-systems/ckis/YYYY-MM-DD-{topic-slug}-claude-project-setup.md`
- [ ] PROJECT NAME, PROJECT DESCRIPTION, KNOWLEDGE table, INSTRUCTIONS, FIRST MESSAGE, WHAT COMES BACK all populated
- [ ] Knowledge file count is 8–15
- [ ] Each knowledge file has a 1-sentence "what it contributes" rationale
- [ ] "Do NOT upload" exclusion list has 3–6 entries with reasons
- [ ] T1 XML instructions follow exact block order: identity → context → task → workflow → constraints → output_format
- [ ] Instructions length is 4,000–6,000 chars (counted, not estimated)
- [ ] Every named entity and number in `<context>` is verified against a specific source file read in Phase 1 (no memory-based facts)
- [ ] No buzzwords anywhere in the file
- [ ] First message is self-contained (passes the "blank chat" test)
- [ ] CKIS CHANGELOG prepended with new version entry
- [ ] Delivery report includes filename + 5-step paste instructions
- [ ] No `.obsidian/` modifications
- [ ] No source files modified (read-only this skill)
