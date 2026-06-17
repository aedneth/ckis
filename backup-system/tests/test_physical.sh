#!/usr/bin/env bash
# Contract for bin/ckis-backup-physical.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
PHYS="$ROOT/bin/ckis-backup-physical.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# target repo with a tracked file and a secret-class file
git init -q "$SB/t1"; git -C "$SB/t1" config user.email t@t; git -C "$SB/t1" config user.name t
echo "knowledge" >"$SB/t1/note.md"
printf 'TOKEN=xyz\n' >"$SB/t1/.env"        # class=secret (*.env)
git -C "$SB/t1" add note.md; git -C "$SB/t1" commit -q -m note

cat >"$SB/m.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "targets":[{"slug":"t1","path":"$SB/t1","remote":"aedneth/t1","class":"track","kind":"vault"}],
  "classes":{"secret":["*.env"]},
  "physical":{"dest_subdir":"CKIS-Backup","size_guard_mb":25,"mount_candidates":["/nonexistent"]} }
JSON
export CKIS_MANIFEST="$SB/m.json"

DEST="$SB/drive"
assert_ok       "physical run exits 0"        bash "$PHYS" "$DEST"
assert_file     "data mirror copied"          "$DEST/data/t1/note.md"
assert_file     "bundle created"              "$DEST/bundles/t1.bundle"
assert_ok       "bundle verifies"             git bundle verify "$DEST/bundles/t1.bundle"
assert_file     "secret-class file -> secrets/ only" "$DEST/secrets/t1/.env"
assert_file     "last-physical marker written" "$CKIS_LOG_DIR/last-physical"

# bundle is restorable into a fresh clone
assert_ok       "bundle clones back"          git clone -q "$DEST/bundles/t1.bundle" "$SB/restored"
assert_file     "restored content present"    "$SB/restored/note.md"

# SECURITY: an embedded credential in .git/config must NEVER reach the drive.
# The mirror excludes .git; the bundle holds objects+refs, not .git/config.
tok="ghp_$(head -c 96 /dev/urandom | base64 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c 36)"
git -C "$SB/t1" remote add origin "https://u:$tok@github.com/x/t1.git"
rm -rf "$DEST"
assert_ok       "physical re-run exits 0"        bash "$PHYS" "$DEST"
assert_no_file  ".git not present in mirror"     "$DEST/data/t1/.git"
assert_eq       "no credential anywhere on drive" "" "$(grep -rIl "$tok" "$DEST" 2>/dev/null)"
assert_ok       "bundle still restores after .git exclude" git clone -q "$DEST/bundles/t1.bundle" "$SB/restored2"

# no dest + no mount -> non-zero
assert_fail     "no dest, no mount -> error"  bash "$PHYS"

assert_summary
