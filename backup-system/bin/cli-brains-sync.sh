#!/usr/bin/env bash
# cli-brains-sync.sh
# Aggregate the gitignored .brain/ dirs of PUBLIC code repos into a private
# workdir (later pushed to the aggregator repo). Private repos already back up
# their .brain/ via their own remote, so they are skipped.
#
# Discovery is registry-driven (a registry (projects.json)) — scales automatically
# as new projects register. Visibility comes from each repo's real git remote.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

REGISTRY="${CKIS_REGISTRY:-$(ckis::expand "$(ckis::manifest '.discovery.registry')")}"
WORKDIR="${CKIS_AGG_WORKDIR:-$(ckis::expand "$(ckis::manifest '.discovery.aggregate_workdir')")}"
[ -f "$REGISTRY" ] || { ckis::warn "registry not found: $REGISTRY"; exit 0; }
mkdir -p "$WORKDIR"

# Regenerable/redundant content is excluded from the aggregate (graph/ is
# graphify output; .brain-backup-* are redundant self-snapshots). Keeps the
# aggregator to high-value tactical memory (sessions, decisions, bugs).
EXC=()
while IFS= read -r e; do [ -n "$e" ] && EXC+=(--exclude "$e"); done \
  < <(ckis::manifest '.discovery.aggregate_exclude[]?' 2>/dev/null)

# Resolve owner/name from a repo's origin remote URL.
_owner_name() {
  local url name rest owner
  url="$(git -C "$1" remote get-url origin 2>/dev/null)" || return 1
  url="${url%.git}"
  name="${url##*/}"
  rest="${url%/*}"
  owner="${rest##*[:/]}"
  [ -n "$owner" ] && [ -n "$name" ] && printf '%s/%s' "$owner" "$name"
}

# Visibility: override hook for tests, else gh.
_visibility() {
  if [ -n "${CKIS_VIS_CMD:-}" ]; then eval "$CKIS_VIS_CMD \"$1\""; return; fi
  gh repo view "$1" --json visibility -q .visibility 2>/dev/null
}

synced=0
while IFS=$'\t' read -r slug repo; do
  [ -n "$repo" ] || continue
  brain="$repo/.brain"
  [ -d "$brain" ] || continue
  on="$(_owner_name "$repo")" || { ckis::warn "$slug: no origin remote, skipping"; continue; }
  vis="$(_visibility "$on")"
  case "$vis" in
    PUBLIC|public)
      mkdir -p "$WORKDIR/$slug"
      if rsync -a --delete "${EXC[@]}" "$brain"/ "$WORKDIR/$slug/.brain"/ 2>>"$CKIS_LOG_FILE"; then
        ckis::info "$slug: public .brain aggregated"; synced=$((synced+1))
      else
        ckis::err "$slug: rsync failed"
      fi ;;
    PRIVATE|private)
      ckis::info "$slug: private repo, .brain backed up via own remote — skip" ;;
    *)
      ckis::warn "$slug: unknown visibility ('$vis'), skipping for safety" ;;
  esac
done < <(jq -r '.projects[] | [.slug, .repo_root] | @tsv' "$REGISTRY")

ckis::info "aggregator: $synced public .brain dir(s) synced into $WORKDIR"
exit 0
