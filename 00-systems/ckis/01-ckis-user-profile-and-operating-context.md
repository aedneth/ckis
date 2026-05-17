---
type: system
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [ckis, profile, operating-context]
status: active
related: ["[[00-ckis-master-context]]", "[[00-inbox/_PROFILE]]", "[[00-inbox/_INTERESTS]]"]
---

# 01 — User Profile & Operating Context

> Stable user context relevant to CKIS only. Subjective traits, sensitive personal details, and ephemeral state belong elsewhere (`_PROFILE.md`, `_MEMORY.md`). This file should rarely change.

**Instructions for setup:** Replace all `[PLACEHOLDER]` fields below with your own information.

━━━

## 1. Identity

- **Name:** [YOUR FULL NAME]
- **Location:** [YOUR CITY, COUNTRY]
- **Languages:** [YOUR LANGUAGES] — vault is [MONOLINGUAL/BILINGUAL]; [translation policy]

## 2. Roles

- **[PRIMARY ROLE]** — [Brief description. E.g.: "Founder of X startup."]
- **[SECONDARY ROLE]** — [Brief description. E.g.: "Student at Y university."]
- **[OTHER ROLE]** — [Brief description if applicable]

## 3. Long-term Direction

- [YOUR LONG-TERM GOAL 1]
- [YOUR LONG-TERM GOAL 2]
- [YOUR LONG-TERM GOAL 3]

## 4. Tools & Environments

- **OS:** [YOUR OS + USER + HOSTNAME + SHELL]
- **Hardware:** [YOUR HARDWARE — include any performance constraints]
- **Stack:** [YOUR TECH STACK]
- **AI:** Claude Code (primary), [OTHER AI TOOLS]

## 5. Communication Style Preferences for Claude

- **Response length:** [BRIEF / DETAILED / DEPENDS ON TASK]
- **Language:** [DEFAULT LANGUAGE FOR RESPONSES]
- **Code style:** [YOUR PREFERENCES]
- **Tone:** [DIRECT / CONVERSATIONAL / FORMAL]

━━━

## Notes for Adapters

This file tells Claude who you are so it can tailor every response to your context. The more specific you are here, the better Claude performs as your knowledge agent.

Keep this file updated when your role, stack, or preferences change significantly. Minor state changes (current project, weekly priorities) belong in `00-inbox/_MEMORY.md`.
