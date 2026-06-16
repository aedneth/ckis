#!/usr/bin/env bash
# Contract for install.sh — symlinks + hook install, no systemd in test.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# one target git repo with no pre-commit hook
git init -q "$SB/t1"
cat >"$SB/m.json" <<JSON
{ "log_dir":"$CKIS_LOG_DIR",
  "targets":[{"slug":"t1","path":"$SB/t1","remote":"aedneth/t1","class":"track","kind":"vault"}] }
JSON
export CKIS_MANIFEST="$SB/m.json"
export CKIS_BIN_DIR="$SB/bin"
export CKIS_SYSTEMD_DIR="$SB/systemd"
export CKIS_NO_SYSTEMD=1

assert_ok   "install exits 0"                 bash "$ROOT/install.sh"
assert_file "ckis-push symlinked to bin"      "$SB/bin/ckis-push"
assert_file "ckis-backup-all symlinked"       "$SB/bin/ckis-backup-all"
assert_file "ckis-restore symlinked"          "$SB/bin/ckis-restore"
assert_file "secret-scan hook installed"      "$SB/t1/.git/hooks/pre-commit"

# the linked script actually runs
assert_ok   "linked script is runnable"       bash "$SB/bin/ckis-backup-doctor" --oneline

# idempotent
assert_ok   "second install idempotent"       bash "$ROOT/install.sh"

# timer cadence is templated from the manifest (reconcile, not a fixed daily)
assert_contains "timer template has @INTERVAL@" "$(cat "$ROOT/systemd/ckis-backup.timer")" "@INTERVAL@"
interval="$(jq -r '.schedule.reconcile_interval' "$ROOT/ckis-manifest.example.json")"
rendered="$(sed -e "s|@INTERVAL@|$interval|g" -e "s|@BOOTDELAY@|3min|g" "$ROOT/systemd/ckis-backup.timer")"
assert_contains "rendered timer uses OnUnitActiveSec" "$rendered" "OnUnitActiveSec=$interval"
assert_eq "no @INTERVAL@ placeholder remains"  "" "$(printf '%s' "$rendered" | grep -o '@INTERVAL@' || true)"

assert_summary
