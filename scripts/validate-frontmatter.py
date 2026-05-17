#!/usr/bin/env python3
"""Validate YAML frontmatter in all Markdown files in the vault."""

import sys
import re
from pathlib import Path
import yaml

SKIP_DIRS = {'.git', '.obsidian', 'node_modules'}
REQUIRED_FIELDS = {'type', 'created', 'modified'}
EXEMPT_FILES = {'README.md', 'CHANGELOG.md', 'CONTRIBUTING.md', 'SECURITY.md',
                'CODE_OF_CONDUCT.md', 'SCHEMA.md', 'CLAUDE.md'}

errors = []
checked = 0
skipped = 0

root = Path('.')
for md_file in sorted(root.rglob('*.md')):
    # Skip hidden dirs and exempt files
    if any(part in SKIP_DIRS or part.startswith('.') for part in md_file.parts[:-1]):
        skipped += 1
        continue
    if md_file.name in EXEMPT_FILES:
        skipped += 1
        continue

    content = md_file.read_text(encoding='utf-8', errors='replace')

    # Check if file has frontmatter
    if not content.startswith('---'):
        # Only warn, don't error on files without frontmatter (e.g. .gitkeep)
        if content.strip():
            errors.append(f"{md_file}: missing YAML frontmatter")
        continue

    # Extract frontmatter
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        errors.append(f"{md_file}: malformed frontmatter (no closing ---)")
        continue

    try:
        fm = yaml.safe_load(match.group(1))
    except yaml.YAMLError as e:
        errors.append(f"{md_file}: invalid YAML — {e}")
        continue

    if not isinstance(fm, dict):
        errors.append(f"{md_file}: frontmatter is not a mapping")
        continue

    # Check required fields (only in 00-systems/ckis/ and 03-knowledge/)
    if any(part in ('00-systems', '03-knowledge') for part in md_file.parts):
        missing = REQUIRED_FIELDS - set(fm.keys())
        if missing:
            errors.append(f"{md_file}: missing frontmatter fields: {missing}")

    checked += 1

print(f"Checked {checked} files, skipped {skipped}.")
if errors:
    print(f"\n{len(errors)} error(s) found:")
    for e in errors:
        print(f"  {e}")
    sys.exit(1)
else:
    print("All frontmatter valid.")
