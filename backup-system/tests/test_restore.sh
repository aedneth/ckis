#!/usr/bin/env bash
# Contract for bin/ckis-restore.sh — the plug-and-play "prueba reina".
# Simulates a FRESH machine in a sandbox (isolated $HOME-like dirs, fake remotes)
# and proves a full rebuild: targets cloned + centralized brains cloned +
# apparatus restored + runtime installed (symlinks), all idempotent.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
RES="$ROOT/bin/ckis-restore.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# seed a bare "remote" for a target and for the centralized brains aggregator
mkdir -p "$SB/remotes"
seed_remote() { # name file content
  git init -q --bare "$SB/remotes/$1.git"
  git clone -q "$SB/remotes/$1.git" "$SB/seed-$1" 2>/dev/null
  git -C "$SB/seed-$1" config user.email a@a; git -C "$SB/seed-$1" config user.name a
  mkdir -p "$(dirname "$SB/seed-$1/$2")"
  echo "$3" >"$SB/seed-$1/$2"; git -C "$SB/seed-$1" add -A; git -C "$SB/seed-$1" commit -q -m init
  git -C "$SB/seed-$1" push -q -u origin master 2>/dev/null || git -C "$SB/seed-$1" push -q -u origin main 2>/dev/null
}
seed_remote t1            note.md          "restored knowledge"
seed_remote brains-backup my-project/.brain/decisions.md "centralized brain"

cat >"$SB/m.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "targets":[{"slug":"t1","path":"$SB/restored/t1","remote":"t1","class":"track","kind":"vault"}],
  "discovery":{"brain_aggregator":"brains-backup","aggregate_workdir":"$SB/restored/brains"},
  "schedule":{"reconcile_interval":"15min","boot_delay":"3min"} }
JSON
export CKIS_MANIFEST="$SB/m.json"
export CKIS_REMOTE_BASE="$SB/remotes/"
export CKIS_CLAUDE_HOME="$SB/home"

# ── clean-room restore (no real systemd) ──
assert_no_file "target absent before restore"  "$SB/restored/t1/note.md"
CKIS_NO_SYSTEMD=1 CKIS_BIN_DIR="$SB/bin" CKIS_SYSTEMD_DIR="$SB/systemd" \
  bash "$RES" >/dev/null 2>&1
rc=$?
assert_eq   "restore exits 0"                  "0" "$rc"
assert_file "target cloned"                    "$SB/restored/t1/note.md"
assert_file "centralized brains cloned"        "$SB/restored/brains/my-project/.brain/decisions.md"
# apparatus restore is optional — only assert it if an apparatus/ ships with the repo
[ -f "$ROOT/apparatus/CLAUDE.md" ] && \
  assert_file "L0 apparatus restored (CLAUDE.md)" "$SB/home/CLAUDE.md"
assert_file "runtime installed (ckis-push link)" "$SB/bin/ckis-push"
assert_file "runtime installed (backup-all link)" "$SB/bin/ckis-backup-all"

# ── idempotent: a second restore leaves everything intact ──
CKIS_NO_SYSTEMD=1 CKIS_BIN_DIR="$SB/bin" CKIS_SYSTEMD_DIR="$SB/systemd" \
  bash "$RES" >/dev/null 2>&1
assert_eq   "second restore idempotent"        "0" "$?"
assert_file "target content still present"     "$SB/restored/t1/note.md"
assert_file "brains still present"             "$SB/restored/brains/my-project/.brain/decisions.md"

assert_summary
