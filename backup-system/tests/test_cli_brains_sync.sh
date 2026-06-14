#!/usr/bin/env bash
# Contract for bin/cli-brains-sync.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
SYNC="$ROOT/bin/cli-brains-sync.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"
export CKIS_MANIFEST="$ROOT/ckis-manifest.example.json"

# a fake public CLI repo with a .brain/ dir and an origin remote
mkrepo() { # path owner/name
  git init -q "$1"; git -C "$1" remote add origin "https://github.com/$2.git"
  mkdir -p "$1/.brain/sessions"; echo "session log" >"$1/.brain/sessions/s1.md"
  echo "decision" >"$1/.brain/decisions.md"
  mkdir -p "$1/.brain/graph"; echo '{"big":1}' >"$1/.brain/graph/graph.json"   # regenerable
}
mkrepo "$SB/pub" "aedneth/pub-cli"
mkrepo "$SB/priv" "aedneth/priv-app"

cat >"$SB/reg.json" <<JSON
{ "version":1, "projects":[
  {"slug":"pub-cli","repo_root":"$SB/pub"},
  {"slug":"priv-app","repo_root":"$SB/priv"}
]}
JSON
export CKIS_REGISTRY="$SB/reg.json"
export CKIS_AGG_WORKDIR="$SB/agg"

# Visibility override: pub-cli=PUBLIC, everything else PRIVATE
export CKIS_VIS_CMD='_vis(){ case "$1" in */pub-cli) echo PUBLIC;; *) echo PRIVATE;; esac; }; _vis'

assert_ok   "sync exits 0"                     bash "$SYNC"
assert_file "public .brain aggregated"         "$SB/agg/pub-cli/.brain/sessions/s1.md"
assert_file "public decisions aggregated"      "$SB/agg/pub-cli/.brain/decisions.md"
assert_no_file "private repo NOT aggregated"   "$SB/agg/priv-app"
assert_no_file "regenerable graph/ excluded"   "$SB/agg/pub-cli/.brain/graph"

# idempotent re-run
assert_ok   "second run idempotent"            bash "$SYNC"
assert_file "still present after re-run"        "$SB/agg/pub-cli/.brain/sessions/s1.md"

# repo with no .brain is skipped silently
git init -q "$SB/nobrain"; git -C "$SB/nobrain" remote add origin https://github.com/aedneth/x.git
cat >"$SB/reg.json" <<JSON
{ "version":1, "projects":[{"slug":"x","repo_root":"$SB/nobrain"}]}
JSON
assert_ok   "no-.brain repo skipped, exit 0"   bash "$SYNC"

assert_summary
