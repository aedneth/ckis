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
  local failures=0
  local scan="$HERE/../hooks/pre-commit-secret-scan.sh"

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
    bash "$HERE/ckis-push.sh" "$path" || { ckis::warn "$slug: push reported an error"; failures=$((failures+1)); }
  done < <(ckis::targets)

  # 3. Centralize every project .brain/ (any agent, any visibility), then push.
  local reg; reg="$(ckis::expand "$(ckis::manifest '.discovery.registry // empty')")"
  bash "$HERE/brains-sync.sh" || ckis::warn "brains-sync had issues"
  local agg_dir agg_remote
  agg_dir="$(ckis::expand "$(ckis::manifest '.discovery.aggregate_workdir // empty')")"
  agg_remote="$(ckis::manifest '.discovery.brain_aggregator // empty')"
  if [ -n "$agg_dir" ] && [ "$agg_dir" != "null" ] && [ -d "$agg_dir" ]; then
    # Ensure the aggregator has its OWN .git (a dir without one would resolve to
    # a parent repo such as $HOME and add the whole home tree).
    if ! ckis::is_repo_root "$agg_dir"; then
      git -C "$agg_dir" init -q
      git -C "$agg_dir" symbolic-ref HEAD refs/heads/master 2>/dev/null || true
      ckis::info "aggregator: initialized own git repo at $agg_dir"
    fi
    # The aggregator holds private brains too, so it MUST be secret-scanned on
    # commit just like every other backup target.
    if [ ! -e "$agg_dir/.git/hooks/pre-commit" ]; then
      ln -sf "$HERE/../hooks/pre-commit-secret-scan.sh" "$agg_dir/.git/hooks/pre-commit" 2>/dev/null || true
    fi
    if ! ckis::repo_has_remote "$agg_dir" && [ -n "$agg_remote" ] && _have_gh; then
      if ! gh repo view "$agg_remote" >/dev/null 2>&1; then
        gh repo create "$agg_remote" --private >>"$CKIS_LOG_FILE" 2>&1 || ckis::warn "aggregator: repo auto-create failed"
      fi
      git -C "$agg_dir" remote add origin "https://github.com/$agg_remote.git" 2>/dev/null || true
    fi
    bash "$HERE/ckis-push.sh" "$agg_dir" || { ckis::warn "aggregator push had issues"; failures=$((failures+1)); }
  fi

  # 3.5 Self-healing wiring + secret blind-spot sweep across every discovered
  #     brain repo (any agent). Ensures new projects auto-get secret-scan
  #     protection, and catches credentials embedded in any repo's .git/config
  #     (the staged-content hook structurally cannot see those).
  # .gitcfg marker namespace is re-evaluated every run (set if a token is found,
  # cleared when fixed) — kept separate from push markers, which a successful
  # push clears even though the embedded token would still be there.
  _sweep_cfg() {  # slug repo
    if bash "$scan" --git-config "$2" >/dev/null 2>&1; then
      ckis::clear_fail "$1.gitcfg"
    else
      ckis::err "$1: embedded credential in .git/config"
      ckis::mark_fail "$1.gitcfg" "embedded credential in .git/config"
      failures=$((failures+1))
    fi
  }
  while IFS=$'\t' read -r slug path remote class kind; do
    [ -d "$path" ] || continue
    _sweep_cfg "$slug" "$path"
  done < <(ckis::targets)
  while IFS=$'\t' read -r slug repo; do
    [ -d "$repo" ] || continue
    if [ ! -e "$repo/.git/hooks/pre-commit" ]; then
      ln -sf "$scan" "$repo/.git/hooks/pre-commit" 2>/dev/null \
        && ckis::info "$slug: secret-scan pre-commit auto-installed"
    fi
    _sweep_cfg "$slug" "$repo"
  done < <(ckis::brain_repos)

  # 3.6 Deep secret audit (full content scan of every repo), throttled to ~daily.
  #     The universal net for repos whose own pre-commit we don't control (CLIs
  #     with a build/supply-chain hook, etc.): a secret committed anywhere is
  #     detected within a day and surfaces as a hard failure, even without our
  #     pre-commit installed there. Cheap to amortize over a day.
  local audit_marker="$CKIS_LOG_DIR/last-audit" now last_audit=0
  now="$(date +%s)"
  [ -f "$audit_marker" ] && last_audit="$(cat "$audit_marker" 2>/dev/null || echo 0)"
  case "$last_audit" in ''|*[!0-9]*) last_audit=0 ;; esac
  if [ "$(( now - last_audit ))" -ge 86400 ]; then
    if bash "$HERE/ckis-secret-audit.sh" >>"$CKIS_LOG_FILE" 2>&1; then
      ckis::clear_fail "secret-audit"; printf '%s' "$now" >"$audit_marker"
    else
      ckis::err "deep secret audit FOUND secret material — see log"
      ckis::mark_fail "secret-audit" "deep audit found secret material"
      failures=$((failures+1))
    fi
  fi

  # 4. Physical backup if a drive is mounted (best-effort).
  if bash "$HERE/ckis-backup-physical.sh" >>"$CKIS_LOG_FILE" 2>&1; then
    ckis::info "physical backup ran"
  else
    ckis::info "physical backup skipped (no drive mounted)"
  fi

  # 4.5 Refresh the local search index (best-effort, agent-agnostic floor).
  #     OPTIONAL (manifest .search_index). The qmd BM25 index is regenerable and
  #     lives outside any repo, so it is never a backup TARGET — but it must stay
  #     fresh for edits made outside any coding agent (Obsidian desktop/mobile,
  #     direct edits). A stale index is NOT a backup failure: this NEVER touches
  #     $failures. Skipped cleanly if absent.
  local idx_cmd idx_bin
  idx_cmd="$(ckis::manifest '.search_index.refresh_cmd // empty')"
  idx_bin="$(ckis::manifest '.search_index.binary // empty')"
  if [ -n "$idx_cmd" ] && [ -n "$idx_bin" ] && command -v "$idx_bin" >/dev/null 2>&1; then
    if $idx_cmd >>"$CKIS_LOG_FILE" 2>&1; then
      ckis::info "search index refreshed ($idx_cmd)"
    else
      ckis::warn "search index refresh had issues (non-fatal): $idx_cmd"
    fi
  else
    ckis::info "search index refresh skipped (not configured or binary absent)"
  fi

  # 5. Health summary.
  ckis::info "health: $(bash "$HERE/ckis-backup-doctor.sh" --oneline)"

  # 6. HARD-FAIL signal. Exit non-zero if anything failed this run OR a prior
  #    unresolved failure marker persists, so systemd shows failure (not the old
  #    silent "success") and the SessionStart banner screams. This is the fix for
  #    the 24h-silent-outage: a blocked backup can no longer masquerade as green.
  local lingering; lingering="$(ckis::list_fails | tr '\n' ' ')"
  if [ "$failures" -gt 0 ] || [ -n "${lingering// /}" ]; then
    ckis::err "═══ backup-all done WITH FAILURES (this run: $failures · unresolved: ${lingering:-none}) ═══"
    return 1
  fi
  ckis::info "═══ backup-all done ═══"
  return 0
}

ckis::with_lock "backup-all" _run
rc=$?
[ "$rc" = "75" ] && { ckis::info "backup-all already running, skipped"; exit 0; }
exit "$rc"
