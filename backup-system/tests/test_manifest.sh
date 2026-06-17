#!/usr/bin/env bash
# Generic contract for any ckis-manifest — validates structure, not specific
# values. Runs against ckis-manifest.example.json by default.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
export CKIS_MANIFEST="${CKIS_MANIFEST:-$ROOT/ckis-manifest.example.json}"
source "$ROOT/lib/common.sh"

assert_ok "manifest is valid json"          jq -e . "$CKIS_MANIFEST"
assert_ok "github_owner set"                bash -c "[ -n \"\$(jq -r .github_owner '$CKIS_MANIFEST')\" ]"

# targets: at least one, each well-formed, paths expand to absolute
assert_ok "has >= 1 target"                 bash -c "[ \$(jq '.targets|length' '$CKIS_MANIFEST') -ge 1 ]"
while IFS=$'\t' read -r slug path remote class kind; do
  [ -n "$slug" ] && [ -n "$class" ] || { echo "  target missing fields"; exit 1; }
  case "$path" in /*) ;; *) echo "  non-absolute path: $path"; exit 1;; esac
done < <(ckis::targets)
assert_eq "all targets well-formed + absolute" "0" "0"

# apparatus allow/deny disjoint + denies nested .git (if apparatus present)
if jq -e '.apparatus' "$CKIS_MANIFEST" >/dev/null 2>&1; then
  allow="$(ckis::manifest '.apparatus.allow[]?')"
  deny="$(ckis::manifest '.apparatus.deny[]?')"
  overlap="$(comm -12 <(echo "$allow"|sort -u) <(echo "$deny"|sort -u) | sed '/^$/d')"
  assert_eq "apparatus allow/deny disjoint"  "" "$overlap"
  assert_contains "deny excludes nested .git" "$deny" ".git"
fi

# classes: regenerable carries a rebuild recipe; secret class non-empty
if jq -e '.classes.regenerable' "$CKIS_MANIFEST" >/dev/null 2>&1; then
  assert_ok "regenerable has rebuild recipe" bash -c "jq -e '.classes.regenerable[0].rebuild' '$CKIS_MANIFEST'"
fi
assert_ok "secret class non-empty"          bash -c "[ \$(jq '.classes.secret|length' '$CKIS_MANIFEST') -ge 1 ]"
assert_eq "size guard is numeric"           "0" "$(jq -r '.physical.size_guard_mb' "$CKIS_MANIFEST" | grep -cE '[^0-9]')"

assert_summary
