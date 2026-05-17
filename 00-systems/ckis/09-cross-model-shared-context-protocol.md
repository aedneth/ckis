---
type: system
created: 2026-05-02
modified: 2026-05-02
tags: [ckis, cross-model, claude, chatgpt]
status: active
related: ["[[00-ckis-master-context]]", "[[10-claude-project-instructions]]", "[[11-chatgpt-project-instructions]]"]
---

# 09 — Cross-Model Shared Context Protocol

> How Claude (Code + Chat) and ChatGPT cooperate without producing context drift. Obsidian is canonical. Chat threads are scratch.

━━━

## 1. Roles

| Agent                               | Role                                                                                    | Writes to vault?                                    |
| ----------------------------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Claude Code                         | Primary execution — reads, writes, refactors, processes inbox, syncs overviews, commits | **Yes (direct)**                                    |
| Claude Chat (Sonnet 4.6 / Opus 4.7) | Planning, architecture, prompt design, strategic decisions                              | No (Eduardo manually copies output back)            |
| ChatGPT                             | Secondary research, exploration, writing review, second-opinion sounding board          | No (Eduardo manually copies relevant excerpts back) |
| Eduardo                             | Operator and final decision-maker                                                       | Yes                                                 |

Obsidian is the only durable store. A thread closes; the vault stays.

## 2. What Gets Copied Between Systems

| Direction           | What flows                                         | How                                                                                                             |
| ------------------- | -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Vault → Claude Code | Live context                                       | `@file` references; session protocol reads                                                                      |
| Vault → Claude Chat | Project briefs, profile, CKIS files                | Paste relevant CKIS files at thread start; attach `_MEMORY.md` if relevant                                      |
| Vault → ChatGPT     | The CKIS upload package                            | Files under `00-system/ckis/chatgpt-project-upload/` uploaded once per ChatGPT Project; refresh on CKIS changes |
| Claude Chat → Vault | Plans, architecture decisions, prompt drafts       | Eduardo (or Claude Code) writes them into the relevant CKIS file or project note                                |
| ChatGPT → Vault     | Research notes, alternate framings, writing drafts | Saved to `00-inbox/url-dumps/` or directly to a literature note, then processed                                 |
| Cross-model         | Decision rationale                                 | Decision-log entries (see `[[06-decision-execution-and-review-protocol]]`)                                      |

## 3. What Stays in Obsidian Only

- The full vault content.
- `_MEMORY.md`, `_PROFILE.md`, `_INTERESTS.md`, `_ACTIVE-PROJECTS.md` — durable, do not paste these in their entirety into ChatGPT unless [OWNER] wants the project to know that level of detail.
- Code in `~/[your-project]/`, `~/[client-site]/`, etc. (separate from the vault).
- Anything sensitive (see `[[05-ckis-memory-and-context-rules]]` §8).

## 4. What Gets Attached Temporarily

- The active working slot (`[[14-active-working-slot]]`) — paste at the start of a focused session.
- One or two project `_overview.md` files relevant to the current task.
- Specific permanent notes that contain the vocabulary the model needs.

Temporary attachments are not "shared state" — they're conversation-only context.

## 5. Preventing Context Drift

Drift happens when chat-only conclusions never make it back to the vault, then a *different* chat re-debates them.

Mitigations:

1. **End-of-thread protocol.** Before closing a chat that produced anything durable, copy the conclusion(s) into the vault as a permanent note, decision log, or CKIS edit.
2. **Single source of truth for facts.** When two models disagree, the vault wins. If the vault is wrong, fix the vault before continuing.
3. **No quoting old chats** as authority. If a previous thread produced a useful framing, it must already be in the vault — otherwise re-derive it.
4. **CKIS upload package versioning.** The ChatGPT upload package gets refreshed whenever a CKIS file changes materially. Note the refresh in `CHANGELOG.md`.

## 6. Proposed-Change Lifecycle

When Claude Chat or ChatGPT proposes a change to CKIS architecture:

1. Capture the proposal in `00-inbox/quick-capture/<slug>.md`.
2. During processing, route it to a draft permanent note or directly to a CKIS edit if scoped clearly.
3. Mark proposed changes with `Status: proposed` in their decision-log block.
4. Eduardo decides — when adopted, edit the relevant CKIS file in `00-system/ckis/`, update `CHANGELOG.md`, regenerate the ChatGPT upload package if necessary.

## 7. Handoff Patterns

| Pattern | Use when |
|---|---|
| **Claude Chat → Claude Code** | Plan in chat, execute in vault. Paste plan into a project note, then run Claude Code with `@plan-file.md`. |
| **Claude Code → Claude Chat** | Need strategy / second-pass review on a draft. Open chat, paste the draft and the relevant `_overview.md`. |
| **Claude → ChatGPT (second opinion)** | High-stakes decision, want independent framing. Use `[[14-active-working-slot]]` as the briefing, paste into ChatGPT. |
| **ChatGPT → Claude** | Use ChatGPT for breadth (research scan), Claude for depth (synthesis + write to vault). |
| **All three → Eduardo** | Final adjudication is [OWNER]'s. The vault records the rationale. |

## 8. Conflict Resolution

When models disagree:

1. Surface the disagreement in the active working slot (`[[14-active-working-slot]]`) as two competing positions.
2. Identify the load-bearing assumption(s).
3. Test against the vault: is there an existing decision, permanent note, or `_overview.md` entry that resolves it?
4. If yes — that wins. If not — Eduardo decides; log the decision per `[[06-decision-execution-and-review-protocol]]`.

## 9. Sensitive Content Across Systems

- Never upload a `.env` file or any credentials to any chat.
- Treat ChatGPT and Claude Chat as third-party processors — anything sent is potentially logged on their end.
- For [YOUR_PROJECT] client work that involves PII or contracts: redact identifiers before pasting; or keep that work entirely in Claude Code where files don't leave the local machine.

## 10. Quick Checklist for Cross-Model Work

- [ ] Did I load the current `_MEMORY.md`?
- [ ] Did I attach the active working slot?
- [ ] Is the proposal getting a decision log if it's load-bearing?
- [ ] Will the conclusion be written back to the vault before this thread closes?
- [ ] Did I avoid pasting secrets?
