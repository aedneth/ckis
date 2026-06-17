#!/usr/bin/env bash
# ckis-apparatus-export.sh [dest-dir]
# Curated allowlist export of the L0 machine apparatus (~/.claude) into the
# infra repo's apparatus/ dir. NEVER a raw mirror; deny[] always wins so secrets
# (.credentials.json, tokens, caches, session blobs) are physically excluded.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

SRC="${CKIS_APPARATUS_SRC:-$(ckis::expand "$(ckis::manifest '.apparatus.source')")}"
DEST="${1:-$CKIS_INFRA_ROOT/$(ckis::manifest '.apparatus.dest')}"
[ -d "$SRC" ] || { ckis::warn "apparatus source missing, skip: $SRC"; exit 0; }
mkdir -p "$DEST"

# deny list -> rsync --exclude args (applied to every copy, defense in depth)
EXC=()
while IFS= read -r d; do [ -n "$d" ] && EXC+=(--exclude "$d"); done \
  < <(ckis::manifest '.apparatus.deny[]')

copied=0
# 1. allowlisted top-level entries
while IFS= read -r item; do
  [ -n "$item" ] || continue
  if [ -e "$SRC/$item" ]; then
    rsync -a --delete "${EXC[@]}" "$SRC/$item" "$DEST/" 2>>"$CKIS_LOG_FILE" \
      && { ckis::info "apparatus: exported $item"; copied=$((copied+1)); }
  fi
done < <(ckis::manifest '.apparatus.allow[]')

# 2. auto-memory: projects/*/memory (re-included despite projects/ being denied)
mg="$(ckis::manifest '.apparatus.memory_glob // empty')"
if [ -n "$mg" ]; then
  shopt -s nullglob
  for md in "$SRC"/$mg; do
    [ -d "$md" ] || continue
    rel="${md#$SRC/}"
    mkdir -p "$DEST/$(dirname "$rel")"
    rsync -a --delete "$md/" "$DEST/$rel/" 2>>"$CKIS_LOG_FILE" \
      && { ckis::info "apparatus: exported memory $rel"; copied=$((copied+1)); }
  done
  shopt -u nullglob
fi

# 3. hard safety net: never let a credential file survive in the export
find "$DEST" -name '.credentials.json' -o -name '*.pem' -o -name 'id_rsa*' 2>/dev/null \
  | while IFS= read -r leak; do rm -f "$leak"; ckis::warn "apparatus: purged stray secret $leak"; done

ckis::info "apparatus export: $copied item(s) -> $DEST"
exit 0
