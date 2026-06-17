#!/usr/bin/env bash
# ckis-push.sh <repo-dir> [commit-msg]
# Real-time per-repo backup push: stage all, commit if dirty, push with retry.
# Idempotent, lock-guarded, never blocks (safe to call from hooks in background).
#   * not a git repo        -> warn, exit 0
#   * clean and 0 ahead     -> no-op, exit 0
#   * dirty                 -> commit (timestamp msg) then push
#   * has unpushed commits  -> push
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

DIR="${1:-}"
[ -n "$DIR" ] || { ckis::err "usage: ckis-push.sh <repo-dir>"; exit 2; }
DIR="$(ckis::expand "$DIR")"

if ! ckis::is_repo "$DIR"; then
  ckis::warn "not a git repo, skipping: $DIR"; exit 0
fi
# Safety: never operate on a parent repo (e.g. $HOME if it is a git repo).
if ! ckis::is_repo_root "$DIR"; then
  ckis::err "refusing to push: $DIR is inside a parent git repo, not its own root — skipping to avoid touching the parent"
  exit 0
fi

_push_one() {
  local dir="$1" msg="${2:-}"
  local slug; slug="$(basename "$dir")"

  if ckis::repo_dirty "$dir"; then
    git -C "$dir" add -A
    local big guard; big="$(ckis::max_staged_mb "$dir")"
    guard="$(ckis::manifest '.physical.size_guard_mb // 25')"
    if [ "${big:-0}" -ge "${guard:-25}" ]; then
      ckis::warn "$slug: staging a ${big}MB blob (>= ${guard}MB guard) — backing up anyway"
    fi
    # CRITICAL: distinguish "nothing actually staged" (benign no-op) from
    # "commit aborted by a pre-commit hook" (HARD FAILURE). The old code ran
    # `git commit || warn` then unconditionally logged success, so a secret-scan
    # block silently stalled the vault for ~24h while reporting "up to date".
    if git -C "$dir" diff --cached --quiet; then
      ckis::info "$slug: nothing staged after add (no-op)"
    else
      [ -n "$msg" ] || msg="ckis-backup: auto $(date -u +%Y-%m-%dT%H:%M:%SZ) on $(hostname -s 2>/dev/null || echo host)"
      if git -C "$dir" commit -q -m "$msg"; then
        ckis::info "$slug: committed local changes"
      else
        ckis::err "$slug: COMMIT BLOCKED by pre-commit hook (e.g. secret-scan) — backup FAILED; staged changes remain uncommitted"
        ckis::mark_fail "$slug" "commit blocked by pre-commit hook (secret-scan?)"
        return 1
      fi
    fi
  fi

  if ! ckis::repo_has_remote "$dir"; then
    ckis::warn "$slug: no remote configured — committed locally, not pushed"
    ckis::clear_fail "$slug"
    return 0
  fi

  # Push when no upstream exists yet (establish it) or there are unpushed commits.
  # If an upstream exists and we are 0 ahead, it's a genuine no-op.
  if git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    local ahead; ahead="$(ckis::repo_ahead "$dir")"
    if [ "${ahead:-0}" = "0" ]; then
      ckis::info "$slug: up to date, nothing to push"; ckis::clear_fail "$slug"; return 0
    fi
  fi
  local branch; branch="$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || echo HEAD)"
  if ckis::retry 3 git -C "$dir" push -u origin "$branch"; then
    ckis::info "$slug: pushed ($branch)"
    ckis::clear_fail "$slug"
  else
    ckis::err "$slug: push failed after retries — local commit safe, will retry next run"
    ckis::mark_fail "$slug" "push failed after retries"
    return 1
  fi
}

ckis::with_lock "push-$(basename "$DIR")" _push_one "$DIR" "${2:-}"
rc=$?
# Treat "lock held" (75) as a successful no-op for the caller.
[ "$rc" = "75" ] && exit 0
exit "$rc"
