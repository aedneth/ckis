#!/usr/bin/env bash
# ckis-backup-all.sh — Ring 2: the daily safety-net orchestrator.
# Registry+manifest driven, self-healing, degrades gracefully when a piece is
# absent. Catches drift from interrupted sessions, edits outside Claude, hook
# failures and brand-new projects. Idempotent; global lock.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

_have_gh() { command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; }

_run() {
  ckis::info "═══ backup-all start ═══"

  # 1. Export L0 apparatus into the infra repo (so the next push captures it).
  local app_src; app_src="$(ckis::manifest '.apparatus.source // empty')"
  if [ -n "$app_src" ] && [ -d "$(ckis::expand "$app_src")" ]; then
    bash "$HERE/ckis-apparatus-export.sh" || ckis::warn "apparatus export had issues"
  fi

  # 2. Every target: self-heal missing remote, then push drift.
  while IFS=$'\t' read -r slug path remote class kind; do
    [ -d "$path" ] || { ckis::warn "target missing on disk: $slug ($path)"; continue; }
    ckis::is_repo "$path" || { ckis::warn "target not a git repo: $slug"; continue; }
    if ! ckis::repo_has_remote "$path" && [ -n "$remote" ] && [ "$remote" != "null" ]; then
      if _have_gh; then
        ckis::info "$slug: no remote — auto-creating private $remote"
        gh repo create "$remote" --private --source="$path" --remote=origin >>"$CKIS_LOG_FILE" 2>&1 \
          || ckis::err "$slug: auto-create failed"
      else
        ckis::warn "$slug: no remote and gh unavailable — committing locally only"
      fi
    fi
    bash "$HERE/ckis-push.sh" "$path" || ckis::warn "$slug: push reported an error"
  done < <(ckis::targets)

  # 3. Aggregate public .brain/ dirs, then push the aggregator repo.
  local reg; reg="$(ckis::expand "$(ckis::manifest '.discovery.registry // empty')")"
  if [ -n "$reg" ] && [ -f "$reg" ]; then
    bash "$HERE/cli-brains-sync.sh" || ckis::warn "aggregator sync had issues"
    local agg_dir agg_remote
    agg_dir="$(ckis::expand "$(ckis::manifest '.discovery.aggregate_workdir // empty')")"
    agg_remote="$(ckis::manifest '.discovery.public_brain_aggregator // empty')"
    if [ -n "$agg_dir" ] && [ -d "$agg_dir" ]; then
      # Ensure the aggregator has its OWN .git (a dir without one would resolve
      # to a parent repo such as $HOME and add the whole home tree).
      if ! ckis::is_repo_root "$agg_dir"; then
        git -C "$agg_dir" init -q
        git -C "$agg_dir" symbolic-ref HEAD refs/heads/master 2>/dev/null || true
        ckis::info "aggregator: initialized own git repo at $agg_dir"
      fi
      if ! ckis::repo_has_remote "$agg_dir" && [ -n "$agg_remote" ] && _have_gh; then
        git -C "$agg_dir" remote add origin "https://github.com/$agg_remote.git" 2>/dev/null || true
      fi
      bash "$HERE/ckis-push.sh" "$agg_dir" || ckis::warn "aggregator push had issues"
    fi
  fi

  # 4. Physical backup if a drive is mounted (best-effort).
  if bash "$HERE/ckis-backup-physical.sh" >>"$CKIS_LOG_FILE" 2>&1; then
    ckis::info "physical backup ran"
  else
    ckis::info "physical backup skipped (no drive mounted)"
  fi

  # 5. Health summary.
  ckis::info "health: $(bash "$HERE/ckis-backup-doctor.sh" --oneline)"
  ckis::info "═══ backup-all done ═══"
}

ckis::with_lock "backup-all" _run
rc=$?
[ "$rc" = "75" ] && { ckis::info "backup-all already running, skipped"; exit 0; }
exit "$rc"
