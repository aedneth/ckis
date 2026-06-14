#!/usr/bin/env bash
# ckis-backup-physical.sh [dest-root]
# Physical (off-device) backup: mirror every target + full git bundles + the
# class=secret files (the ONLY place secrets are allowed to land — on an
# encrypted external drive).  Closes the 3-2-1 rule.
#
# dest-root: explicit path, else auto-detect first mounted candidate from the
# manifest under <mount>/<dest_subdir>.  Exits non-zero only if no dest usable.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

DEST="${1:-}"
if [ -z "$DEST" ]; then
  sub="$(ckis::manifest '.physical.dest_subdir // "CKIS-Backup"')"
  while IFS= read -r base; do
    base="$(ckis::expand "$base")"
    [ -d "$base" ] || continue
    # pick the first writable mountpoint under the candidate
    for mp in "$base"/*/ "$base"/; do
      [ -d "$mp" ] && [ -w "$mp" ] || continue
      DEST="${mp%/}/$sub"; break 2
    done
  done < <(ckis::manifest '.physical.mount_candidates[]')
fi
[ -n "$DEST" ] || { ckis::err "no physical dest found (pass dest-root or mount the drive)"; exit 3; }

mkdir -p "$DEST/data" "$DEST/bundles" "$DEST/secrets" 2>/dev/null \
  || { ckis::err "cannot write to dest: $DEST"; exit 3; }
ckis::info "physical backup -> $DEST"

# FAT/exFAT cannot store POSIX filenames (e.g. ':' is illegal) — the per-file
# mirror would be lossy. git bundles are single FAT-safe files holding full
# history + all filenames, so on FAT we rely on bundles only.
MIRROR=1
FSTYPE="$(stat -f -c %T "$DEST" 2>/dev/null || echo unknown)"
case "$FSTYPE" in
  msdos|vfat|exfat) MIRROR=0
    ckis::warn "dest filesystem is $FSTYPE — skipping per-file mirror; git bundles are the authoritative copy" ;;
esac

rc=0
mapfile -t SECRET_GLOBS < <(ckis::manifest '.classes.secret[]')

while IFS=$'\t' read -r slug path remote class kind; do
  [ -d "$path" ] || { ckis::warn "skip missing target: $slug"; continue; }

  # 1. full mirror (working tree incl. .git) — non-FAT only. FAT-tolerant flags
  #    so it also works on perms-less filesystems.
  if [ "$MIRROR" = 1 ]; then
    if rsync -rltD --delete --no-perms --no-owner --no-group --modify-window=2 \
         "$path"/ "$DEST/data/$slug"/ 2>>"$CKIS_LOG_FILE"; then
      ckis::info "$slug: mirrored"
    else
      ckis::warn "$slug: rsync mirror had errors (bundle is authoritative)"
    fi
  fi

  # 2. full-history bundle (single-file, restorable offline)
  if ckis::is_repo "$path"; then
    if git -C "$path" bundle create "$DEST/bundles/$slug.bundle" --all >>"$CKIS_LOG_FILE" 2>&1 \
       && git -C "$path" bundle verify "$DEST/bundles/$slug.bundle" >/dev/null 2>&1; then
      ckis::info "$slug: bundle ok"
    else
      ckis::err "$slug: bundle failed"; rc=1
    fi
  fi

  # 3. class=secret files (physical only)
  for g in "${SECRET_GLOBS[@]}"; do
    while IFS= read -r -d '' sf; do
      rel="${sf#$path/}"
      mkdir -p "$DEST/secrets/$slug/$(dirname "$rel")"
      cp -a "$sf" "$DEST/secrets/$slug/$rel" 2>/dev/null \
        && ckis::warn "$slug: copied secret-class file to encrypted dest only: $rel"
    done < <(find "$path" -name "$g" -type f -print0 2>/dev/null)
  done
done < <(ckis::targets)

date +%s > "$CKIS_LOG_DIR/last-physical"
[ "$rc" -eq 0 ] && ckis::info "physical backup complete" || ckis::err "physical backup completed with errors"
exit "$rc"
