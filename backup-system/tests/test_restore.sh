#!/usr/bin/env bash
# Contract for bin/ckis-restore.sh — clones missing targets, safe & idempotent.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
RES="$ROOT/bin/ckis-restore.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# seed a bare "remote" with content
mkdir -p "$SB/remotes"
git init -q --bare "$SB/remotes/t1.git"
git clone -q "$SB/remotes/t1.git" "$SB/seed" 2>/dev/null
git -C "$SB/seed" config user.email a@a; git -C "$SB/seed" config user.name a
echo "restored knowledge" >"$SB/seed/note.md"; git -C "$SB/seed" add -A; git -C "$SB/seed" commit -q -m init
git -C "$SB/seed" push -q -u origin master 2>/dev/null || git -C "$SB/seed" push -q -u origin main 2>/dev/null

cat >"$SB/m.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "targets":[{"slug":"t1","path":"$SB/restored/t1","remote":"t1","class":"track","kind":"vault"}] }
JSON
export CKIS_MANIFEST="$SB/m.json"
export CKIS_REMOTE_BASE="$SB/remotes/"
export CKIS_CLAUDE_HOME="$SB/home"

assert_no_file "target absent before restore" "$SB/restored/t1/note.md"
assert_ok   "restore exits 0"                 bash "$RES" --no-system --no-apparatus
assert_file "missing target cloned"           "$SB/restored/t1/note.md"

# idempotent: re-run, target already present -> still ok, content intact
assert_ok   "second restore idempotent"       bash "$RES" --no-system --no-apparatus
assert_file "content still present"           "$SB/restored/t1/note.md"

assert_summary
