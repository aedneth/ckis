#!/usr/bin/env bash
# pre-commit-secret-scan.sh — block commits that introduce secrets.
# Dependency-free regex scanner (no gitleaks needed). Install as a repo's
# .git/hooks/pre-commit (or call directly to scan staged changes).
#
# Exit 0 = clean, exit 1 = secret found (commit blocked).
# Modes:
#   (no args)      scan staged diff (git diff --cached) — hook mode
#   --files F...   scan the given files — standalone/test mode
set -uo pipefail

# High-signal secret patterns. Conservative to avoid false positives on notes.
PATTERNS='(ghp_[A-Za-z0-9]{36})|(gho_[A-Za-z0-9]{36})|(github_pat_[A-Za-z0-9_]{40,})|(sk-[A-Za-z0-9]{32,})|(AKIA[0-9A-Z]{16})|(AIza[0-9A-Za-z_-]{35})|(xox[baprs]-[A-Za-z0-9-]{10,})|(-----BEGIN ([A-Z]+ )?PRIVATE KEY-----)|(glpat-[A-Za-z0-9_-]{20})'

scan_stream() { grep -nIE "$PATTERNS"; }   # returns 0 if a match is found

found=0
report() { echo "🔴 SECRET BLOCK: potential secret in $1"; echo "   $2"; found=1; }

if [ "${1:-}" = "--files" ]; then
  shift
  for f in "$@"; do
    [ -f "$f" ] || continue
    while IFS= read -r hit; do report "$f" "$hit"; done < <(scan_stream <"$f")
  done
else
  # Hook mode: scan the staged content of added/modified files.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    while IFS= read -r hit; do report "$f" "$hit"; done \
      < <(git show ":$f" 2>/dev/null | scan_stream)
  done < <(git diff --cached --name-only --diff-filter=AM 2>/dev/null)
fi

if [ "$found" -ne 0 ]; then
  echo "   Commit aborted. Remove the secret or move it to a class=secret path (physical-disk only)." >&2
  exit 1
fi
exit 0
