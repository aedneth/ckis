#!/usr/bin/env bash
# ckis-secret-audit.sh — whole-system secret audit.
# Scans the working tree (tracked files) AND .git/config of every backup target
# and every registered project for REAL secret material, using the strongest-mode
# scanner. Catches what a staged-content pre-commit hook structurally cannot:
# tokens already living in a repo, or embedded in a remote URL in .git/config
# (the blind spot that hid a live PAT). Per-repo .ckis-secret-allow is honored.
#
# Exit 0 = clean, 1 = secrets found. Safe to run any time; read-only.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init
SCAN="$HERE/../hooks/pre-commit-secret-scan.sh"

_audit_repo() {  # path label
  local path="$1" label="$2" rc=0
  [ -d "$path" ] || return 0
  ckis::is_repo "$path" || return 0
  # tracked working-tree files (node_modules etc. excluded by being gitignored)
  if ! git -C "$path" ls-files -z 2>/dev/null \
       | ( cd "$path" && xargs -0 -r bash "$SCAN" --files ); then rc=1; fi
  # .git/config embedded credentials (remote URLs)
  if ! bash "$SCAN" --git-config "$path"; then rc=1; fi
  [ "$rc" -eq 0 ] && ckis::info "audit ✅ $label" || ckis::err "audit 🔴 $label — secret material found"
  return "$rc"
}

overall=0
seen=" "

# 1. manifest targets
while IFS=$'\t' read -r slug path remote class kind; do
  _audit_repo "$path" "$slug" || overall=1
  seen="$seen$path "
done < <(ckis::targets)

# 2. every registered project (private repos included)
reg="$(ckis::expand "$(ckis::manifest '.discovery.registry // empty')")"
if [ -f "$reg" ]; then
  while IFS=$'\t' read -r slug repo; do
    [ -n "$repo" ] || continue
    case "$seen" in *" $repo "*) continue;; esac   # de-dupe vs targets
    _audit_repo "$repo" "$slug" || overall=1
    seen="$seen$repo "
  done < <(jq -r '.projects[] | [.slug, .repo_root] | @tsv' "$reg" 2>/dev/null)
fi

if [ "$overall" -eq 0 ]; then
  ckis::info "secret audit: CLEAN across all repos"
else
  ckis::err "secret audit: SECRET MATERIAL FOUND — see lines above"
fi
exit "$overall"
