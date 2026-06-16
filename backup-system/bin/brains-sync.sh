#!/usr/bin/env bash
# brains-sync.sh
# CENTRALIZE every per-project .brain/ into one private aggregator workdir,
# regardless of which coding agent created the project (Claude Code, Codex,
# Gemini, OpenCode, ...) or the project's own visibility. The CLIs are just
# projects — there is no CLI-specific or public/private branching here.
#
# Discovery is agent-agnostic: the UNION of Dev Brain's registry and a bounded
# filesystem scan of brain_roots (ckis::brain_repos). Regenerable/redundant
# content (graph/, .brain-backup-*) is excluded so the aggregate stays high-value.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

WORKDIR="${CKIS_AGG_WORKDIR:-$(ckis::expand "$(ckis::manifest '.discovery.aggregate_workdir')")}"
case "$WORKDIR" in ''|null) ckis::warn "no aggregate_workdir configured — skipping brains-sync"; exit 0 ;; esac
mkdir -p "$WORKDIR"

EXC=()
while IFS= read -r e; do [ -n "$e" ] && EXC+=(--exclude "$e"); done \
  < <(ckis::manifest '.discovery.aggregate_exclude[]?' 2>/dev/null)

synced=0
while IFS=$'\t' read -r slug repo; do
  [ -n "$repo" ] || continue
  brain="$repo/.brain"
  [ -d "$brain" ] || continue
  mkdir -p "$WORKDIR/$slug"
  if rsync -a --delete "${EXC[@]}" "$brain"/ "$WORKDIR/$slug/.brain"/ 2>>"$CKIS_LOG_FILE"; then
    ckis::info "$slug: .brain centralized"; synced=$((synced+1))
  else
    ckis::err "$slug: rsync failed"
  fi
done < <(ckis::brain_repos)

ckis::info "aggregator: $synced .brain dir(s) centralized into $WORKDIR"
exit 0
