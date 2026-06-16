#!/usr/bin/env bash
# Contract for bin/ckis-secret-audit.sh — whole-system secret audit.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
AUDIT="$ROOT/bin/ckis-secret-audit.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"
rnd() { head -c 96 /dev/urandom | base64 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 36; }
mkrepo() { mkdir -p "$1"; git -C "$1" init -q; git -C "$1" config user.email t@t; git -C "$1" config user.name t; }

mkrepo "$SB/clean"; echo "general notes about keys" >"$SB/clean/a.md"
git -C "$SB/clean" add -A; git -C "$SB/clean" commit -qm x

mkrepo "$SB/dirty"; printf 'tok = ghp_%s\n' "$(rnd)" >"$SB/dirty/leak.md"
git -C "$SB/dirty" add -A; git -C "$SB/dirty" commit -qm leak

cat >"$SB/manifest.json" <<EOF
{ "github_owner":"x","log_dir":"$SB/state",
  "targets":[{"slug":"clean","path":"$SB/clean","remote":"x/clean","class":"track","kind":"vault"}],
  "discovery":{"registry":"$SB/projects.json"},
  "physical":{"size_guard_mb":25} }
EOF
cat >"$SB/projects.json" <<EOF
{ "version":1,"projects":[{"slug":"dirty","repo_root":"$SB/dirty"}] }
EOF
export CKIS_MANIFEST="$SB/manifest.json"

assert_fail "audit detects committed token in a registered repo" bash "$AUDIT"
git -C "$SB/dirty" rm -q leak.md; git -C "$SB/dirty" commit -qm scrub
assert_ok   "audit clean after working-tree scrub"               bash "$AUDIT"

# .git/config embedded credential (the .git/config blind spot)
git -C "$SB/clean" remote add origin "https://u:$(rnd)@github.com/x/clean.git"
assert_fail "audit detects .git/config embedded token"           bash "$AUDIT"
git -C "$SB/clean" remote set-url origin "https://github.com/x/clean.git"
assert_ok   "audit clean after .git/config scrub"                bash "$AUDIT"

assert_summary
