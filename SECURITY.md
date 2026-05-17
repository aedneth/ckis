# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| main branch | ✅ Yes |

## Reporting a Vulnerability

CKIS is a knowledge management template system. Security concerns are most likely to arise from:

1. **Scripts that run with shell access** — `.brain/scripts/`, `.claude/scripts/`, crontab entries
2. **Hooks that fire automatically** — Claude Code hooks in `settings.json`
3. **Cron jobs using `claude -p`** — headless Claude sessions

**To report a security issue:**

1. Do NOT open a public GitHub issue for security vulnerabilities.
2. Contact the maintainer via GitHub Discussions (private) or email via the GitHub profile.
3. Include: description of the vulnerability, steps to reproduce, potential impact.

You will receive a response within 72 hours.

## Security practices in this template

- **No secrets in the vault** — The vault must never contain `.env` files, API keys, OAuth tokens, or credentials. The `.gitignore` is pre-configured to block common secret files.
- **Cron scripts use `source ~/.claude/.env`** — API keys for headless Claude are stored in a chmod 600 file outside the vault.
- **MCP tokens** — If using `.mcp.json`, it is listed in `.gitignore` and must never be committed.
- **No eval from untrusted sources** — No scripts in this template execute code from URLs.

## Responsible use of hooks

Hooks in `settings.json` run shell commands automatically. Before enabling any hook:
- Review the script it calls
- Ensure the script path is not world-writable
- Test in a non-production vault first
