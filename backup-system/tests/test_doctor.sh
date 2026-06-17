#!/usr/bin/env bash
# Contract for bin/ckis-backup-doctor.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
DOC="$ROOT/bin/ckis-backup-doctor.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# Build a fixture manifest with one fully-backed-up target.
git init -q --bare "$SB/remote.git"
git clone -q "$SB/remote.git" "$SB/clean" 2>/dev/null
git -C "$SB/clean" config user.email t@t; git -C "$SB/clean" config user.name t
echo a >"$SB/clean/a"; git -C "$SB/clean" add -A; git -C "$SB/clean" commit -q -m a
git -C "$SB/clean" push -q -u origin master 2>/dev/null || git -C "$SB/clean" push -q -u origin main 2>/dev/null

mkfix() { # path -> writes fixture manifest pointing at it
cat >"$SB/m.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "targets":[{"slug":"t1","path":"$1","remote":"aedneth/t1","class":"track","kind":"vault"}],
  "physical":{"size_guard_mb":25} }
JSON
}
export CKIS_MANIFEST="$SB/m.json"

# clean+pushed -> all pushed, exits 0
mkfix "$SB/clean"
out="$(bash "$DOC" --oneline)"
assert_ok       "doctor exits 0"          bash "$DOC" --oneline
assert_contains "clean target -> all pushed" "$out" "all pushed"
assert_contains "physical never marker"      "$out" "physical never"

# drift: add an unpushed commit
echo b >"$SB/clean/b"; git -C "$SB/clean" add -A; git -C "$SB/clean" commit -q -m b
out2="$(bash "$DOC" --oneline)"
assert_contains "drift shows warning"     "$out2" "⚠"
assert_contains "drift names target"      "$out2" "t1"
assert_contains "drift shows unpushed"    "$out2" "unpushed"

# physical marker age
date +%s >"$CKIS_LOG_DIR/last-physical"
out3="$(bash "$DOC" --oneline)"
assert_contains "physical 0d when marker fresh" "$out3" "physical 0d"

# missing repo
mkfix "$SB/does-not-exist"
out4="$(bash "$DOC" --oneline)"
assert_contains "missing repo flagged"    "$out4" "missing"

# HARD FAILURE state: a persistent failure marker outranks benign drift and the
# banner must scream 🔴 FAILED (the fix for the 24h silent-success outage).
mkfix "$SB/clean"
mkdir -p "$CKIS_LOG_DIR/failures"
printf '%s\tcommit blocked by secret-scan\n' "$(date -u +%FT%TZ)" >"$CKIS_LOG_DIR/failures/t1"
out5="$(bash "$DOC" --oneline)"
assert_contains "failed marker -> 🔴 FAILED"  "$out5" "FAILED"
assert_contains "FAILED names the target"      "$out5" "t1"
# brain-repo / .gitcfg markers also surface even if not a manifest target
printf '%s\tembedded credential in .git/config\n' "$(date -u +%FT%TZ)" >"$CKIS_LOG_DIR/failures/someproject.gitcfg"
out6="$(bash "$DOC" --oneline)"
assert_contains "non-target failure marker surfaces" "$out6" "someproject.gitcfg"
rm -rf "$CKIS_LOG_DIR/failures"

assert_summary
