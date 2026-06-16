#!/usr/bin/env bash
# Contract for bin/ckis-backup-all.sh — orchestrator push loop + graceful degrade.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
ALL="$ROOT/bin/ckis-backup-all.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# two targets with local bare remotes, both dirty
for t in t1 t2; do
  git init -q --bare "$SB/$t.git"
  git clone -q "$SB/$t.git" "$SB/$t" 2>/dev/null
  git -C "$SB/$t" config user.email a@a; git -C "$SB/$t" config user.name a
  echo "data-$t" >"$SB/$t/file.md"
done

# fixture manifest: targets only, no apparatus/discovery (those steps degrade)
cat >"$SB/m.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "targets":[
    {"slug":"t1","path":"$SB/t1","remote":"aedneth/t1","class":"track","kind":"vault"},
    {"slug":"t2","path":"$SB/t2","remote":"aedneth/t2","class":"track","kind":"vault"}],
  "physical":{"dest_subdir":"X","size_guard_mb":25,"mount_candidates":["/nonexistent"]} }
JSON
export CKIS_MANIFEST="$SB/m.json"

assert_ok "backup-all exits 0"                bash "$ALL"
assert_eq "t1 pushed to remote" "1" "$(git --git-dir="$SB/t1.git" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"
assert_eq "t2 pushed to remote" "1" "$(git --git-dir="$SB/t2.git" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"

# idempotent: second run, no new commits
assert_ok "second run exits 0"                bash "$ALL"
assert_eq "t1 still 1 commit" "1" "$(git --git-dir="$SB/t1.git" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"

# health line present in log
assert_contains "health summary logged" "$(cat "$CKIS_LOG_DIR/backup.log")" "BACKUP"
# deep secret audit ran (throttled, universal net) and recorded its marker
assert_file "deep secret-audit marker written" "$CKIS_LOG_DIR/last-audit"

# HARD-FAIL: a target whose pre-commit hook blocks the commit must make backup-all
# exit NON-ZERO and record a FAILED marker — never the old silent success.
git init -q --bare "$SB/b.git"
git clone -q "$SB/b.git" "$SB/blocked" 2>/dev/null
git -C "$SB/blocked" config user.email a@a; git -C "$SB/blocked" config user.name a
printf '#!/bin/sh\nexit 1\n' >"$SB/blocked/.git/hooks/pre-commit"; chmod +x "$SB/blocked/.git/hooks/pre-commit"
echo data >"$SB/blocked/x.md"
cat >"$SB/mb.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "targets":[{"slug":"blocked","path":"$SB/blocked","remote":"aedneth/blocked","class":"track","kind":"vault"}],
  "physical":{"size_guard_mb":25,"mount_candidates":["/nonexistent"]} }
JSON
export CKIS_MANIFEST="$SB/mb.json"
assert_fail "backup-all exits NON-ZERO on a blocked target" bash "$ALL"
assert_file "FAILED marker recorded for blocked target"     "$CKIS_LOG_DIR/failures/blocked"
assert_contains "health line screams FAILED"               "$(cat "$CKIS_LOG_DIR/backup.log")" "FAILED"

assert_summary
