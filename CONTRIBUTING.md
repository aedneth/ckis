# Contributing to CKIS

Thank you for contributing to CKIS — a developer knowledge operating system.

## What we welcome

- **New skill templates** — new workflows for knowledge capture, synthesis, or processing
- **Hook examples** — `.brain/` hooks for different shells, languages, or CI environments
- **Workflow adaptations** — CKIS adapted for team use, different project types, or specific domains
- **Bug fixes** — incorrect documentation, broken scripts, wrong frontmatter specs
- **Integrations** — connecting CKIS to external tools (Notion export, Readwise, etc.)

## What we don't accept

- Personal vault content (notes, logs, business details)
- Dependencies that add licensing restrictions
- Breaking changes to the frontmatter spec without discussion

## How to contribute

1. Fork this repo and create a feature branch
2. Follow the naming conventions in [SCHEMA.md](SCHEMA.md)
3. Test your skill or script locally with Claude Code
4. Submit a PR using the pull request template

## Skill template format

Every skill in `.claude/ckis-skills/<name>/skill.md` should:
- Open with a clear one-line description of what it does
- Specify trigger phrase(s)
- List steps Claude should follow
- Include example output format

## Style

- Markdown: use `━━━` as section separators (CKIS convention)
- Frontmatter: required on every note (see SCHEMA.md)
- Language: English for system files; note content can be in any language
- No emojis unless the skill explicitly produces them

## Issues

Use GitHub Issues with the provided templates. For questions, open a Discussion.
