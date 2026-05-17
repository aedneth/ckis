# 07-people — Relationship Intelligence

**Purpose:** Notes on people who matter — clients, mentors, and network. One file per person.

## Subfolders

| Folder | Who goes here |
|---|---|
| `clients/` | Active and past clients (business relationships) |
| `mentors/` | People you learn from — advisors, coaches, role models |
| `network/` | Peers, collaborators, contacts worth nurturing |

## What doesn't go here

- Client project files → `02-projects/<project>/clients/`
- Public figures you follow but don't know → their content goes in `04-resources/`

## Person note structure

```markdown
---
type: person
subtype: [client | mentor | network]
created: YYYY-MM-DD
modified: YYYY-MM-DD
tags: [person, client]
status: active
---

# [Full Name]

**Role / company:** [their role and where]
**How we connected:** [context]
**Last contact:** YYYY-MM-DD

## What they care about
[What's important to them professionally and personally]

## Our relationship
[History, how we've worked together, dynamics]

## Notes
- YYYY-MM-DD — [meeting note, observation, follow-up]

## Links
- [[02-projects/...]] (if they're a client)
- [LinkedIn / contact info]
```

## The `client-onboarding` skill

When a new client starts, run `onboard client [name]` — it creates both the person note here AND the project file in `02-projects/<project>/clients/` automatically.

## Naming

- `first-last.md` (lowercase kebab)
- Example: `ada-lovelace.md`
