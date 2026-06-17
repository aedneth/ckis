#!/usr/bin/env bash
# Contract for bin/brains-sync.sh — CENTRALIZED, agent-agnostic brain aggregation.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
SYNC="$ROOT/bin/brains-sync.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"
export CKIS_MANIFEST="$ROOT/ckis-manifest.example.json"

mkrepo() { # path owner/name
  git init -q "$1"; git -C "$1" remote add origin "https://github.com/$2.git"
  mkdir -p "$1/.brain/sessions"; echo "session log" >"$1/.brain/sessions/s1.md"
  echo "decision" >"$1/.brain/decisions.md"
  mkdir -p "$1/.brain/graph"; echo '{"big":1}' >"$1/.brain/graph/graph.json"   # regenerable
  mkdir -p "$1/.brain/.brain-backup-x"; echo "redundant" >"$1/.brain/.brain-backup-x/y"
}
mkrepo "$SB/pub"  "aedneth/pub-cli"
mkrepo "$SB/priv" "aedneth/priv-app"

cat >"$SB/reg.json" <<JSON
{ "version":1, "projects":[
  {"slug":"pub-cli","repo_root":"$SB/pub"},
  {"slug":"priv-app","repo_root":"$SB/priv"}
]}
JSON
export CKIS_REGISTRY="$SB/reg.json"
export CKIS_AGG_WORKDIR="$SB/agg"
export CKIS_BRAIN_ROOTS=""   # registry-only for the first assertions

# CENTRALIZATION: both public AND private brains are aggregated (no skipping)
assert_ok   "sync exits 0"                       bash "$SYNC"
assert_file "public .brain centralized"          "$SB/agg/pub-cli/.brain/sessions/s1.md"
assert_file "PRIVATE .brain ALSO centralized"    "$SB/agg/priv-app/.brain/decisions.md"
assert_no_file "regenerable graph/ excluded"     "$SB/agg/pub-cli/.brain/graph"
assert_no_file "redundant self-snapshot excluded" "$SB/agg/pub-cli/.brain/.brain-backup-x"

# idempotent re-run
assert_ok   "second run idempotent"              bash "$SYNC"
assert_file "still present after re-run"          "$SB/agg/priv-app/.brain/decisions.md"

# AGENT-AGNOSTIC: a repo NOT in the registry is discovered via brain_roots scan
mkrepo "$SB/scanned/orphan" "someone/orphan"     # not in reg.json
export CKIS_BRAIN_ROOTS="$SB/scanned"
assert_ok   "sync with filesystem scan exits 0"  bash "$SYNC"
assert_file "unregistered repo found by scan"    "$SB/agg/orphan/.brain/decisions.md"

# repo with no .brain is skipped silently
git init -q "$SB/nobrain"
cat >"$SB/reg.json" <<JSON
{ "version":1, "projects":[{"slug":"x","repo_root":"$SB/nobrain"}]}
JSON
export CKIS_BRAIN_ROOTS=""
assert_ok   "no-.brain repo skipped, exit 0"     bash "$SYNC"

assert_summary
