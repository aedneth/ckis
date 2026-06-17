#!/usr/bin/env bash
# lib/common.sh — shared library for the CKIS autonomous backup system.
#
# Invariants every consumer relies on:
#   * Pure dependency-free except: coreutils, git, jq, flock, rsync.
#   * Never exits the parent shell on error — functions return non-zero, callers decide.
#   * All state/logs under $CKIS_LOG_DIR (default ~/.local/state/ckis-backup).
#   * Idempotent helpers; safe to source multiple times.
#
# Source this, then call ckis::init before using manifest/log helpers.

# Guard against double-sourcing.
[ -n "${__CKIS_COMMON_SOURCED:-}" ] && return 0
__CKIS_COMMON_SOURCED=1

# ── Path resolution ──────────────────────────────────────────────────────────
# Resolve the infra repo root from this file's location (lib/ -> repo root).
__ckis_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CKIS_INFRA_ROOT="${CKIS_INFRA_ROOT:-$(cd "$__ckis_lib_dir/.." && pwd)}"

# Manifest path: env override (used by tests) or repo default.
CKIS_MANIFEST="${CKIS_MANIFEST:-$CKIS_INFRA_ROOT/ckis-manifest.json}"

# Expand a leading ~ and embedded $HOME/$USER in a path string.
ckis::expand() {
  local p="$1"
  p="${p/#\~/$HOME}"
  p="${p//\$HOME/$HOME}"
  p="${p//\$USER/$USER}"
  printf '%s' "$p"
}

# ── Logging ──────────────────────────────────────────────────────────────────
CKIS_LOG_DIR="${CKIS_LOG_DIR:-$(ckis::expand "$(jq -r '.log_dir // "~/.local/state/ckis-backup"' "$CKIS_MANIFEST" 2>/dev/null || echo "~/.local/state/ckis-backup")")}"
CKIS_LOG_FILE="${CKIS_LOG_FILE:-$CKIS_LOG_DIR/backup.log}"

ckis::init() {
  mkdir -p "$CKIS_LOG_DIR" "$CKIS_LOG_DIR/locks" 2>/dev/null || true
}

# ckis::log LEVEL MSG...   → timestamped line to logfile + stderr.
ckis::log() {
  local level="$1"; shift
  local ts; ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local line="[$ts] [$level] $*"
  mkdir -p "$CKIS_LOG_DIR" 2>/dev/null || true
  printf '%s\n' "$line" >>"$CKIS_LOG_FILE" 2>/dev/null || true
  printf '%s\n' "$line" >&2
}
ckis::info() { ckis::log INFO "$@"; }
ckis::warn() { ckis::log WARN "$@"; }
ckis::err()  { ckis::log ERROR "$@"; }

# ── Manifest accessors (jq) ──────────────────────────────────────────────────
# ckis::manifest <jq-filter>  → raw jq query over the manifest.
ckis::manifest() { jq -r "$1" "$CKIS_MANIFEST"; }

# Emit "slug<TAB>expanded-path<TAB>remote<TAB>class<TAB>kind" per target.
ckis::targets() {
  jq -r '.targets[] | [.slug, .path, .remote, .class, .kind] | @tsv' "$CKIS_MANIFEST" \
  | while IFS=$'\t' read -r slug path remote class kind; do
      printf '%s\t%s\t%s\t%s\t%s\n' "$slug" "$(ckis::expand "$path")" "$remote" "$class" "$kind"
    done
}

# ── Concurrency ──────────────────────────────────────────────────────────────
# ckis::with_lock NAME CMD...  → run CMD under an exclusive non-blocking lock.
# Returns 0 on success, 75 (EX_TEMPFAIL) if the lock is already held.
ckis::with_lock() {
  local name="$1"; shift
  ckis::init
  local lock="$CKIS_LOG_DIR/locks/$name.lock"
  exec {__ckis_fd}>"$lock"
  if ! flock -n "$__ckis_fd"; then
    ckis::warn "lock held, skipping: $name"
    exec {__ckis_fd}>&-
    return 75
  fi
  "$@"; local rc=$?
  flock -u "$__ckis_fd" 2>/dev/null || true
  exec {__ckis_fd}>&-
  return $rc
}

# ── Retry with backoff ───────────────────────────────────────────────────────
# ckis::retry N CMD...  → up to N attempts, backoff 2,4,8...s. Returns last rc.
ckis::retry() {
  local max="$1"; shift
  local n=1 delay=2 rc=0
  while :; do
    "$@" && return 0
    rc=$?
    [ "$n" -ge "$max" ] && return $rc
    ckis::warn "attempt $n/$max failed (rc=$rc), retrying in ${delay}s: $*"
    sleep "$delay"; n=$((n+1)); delay=$((delay*2))
  done
}

# ── Git helpers ──────────────────────────────────────────────────────────────
ckis::is_repo()    { git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1; }
# True only if DIR is the ROOT of its own repo (not merely inside a parent repo).
# Critical guard: $HOME may itself be a git repo, so a dir without its own .git
# would otherwise resolve to the $HOME repo and operate on the entire home tree.
ckis::is_repo_root() {
  local top; top="$(git -C "$1" rev-parse --show-toplevel 2>/dev/null)" || return 1
  [ "$(readlink -f "$top" 2>/dev/null)" = "$(readlink -f "$1" 2>/dev/null)" ]
}
ckis::repo_dirty() { [ -n "$(git -C "$1" status --porcelain 2>/dev/null)" ]; }
# unpushed-commit count vs upstream; prints 0 when no upstream/clean.
ckis::repo_ahead() { git -C "$1" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0; }
ckis::repo_has_remote() { [ -n "$(git -C "$1" remote 2>/dev/null)" ]; }

# Largest newly-added blob size (MB) staged in DIR; 0 if none. For size-guard.
ckis::max_staged_mb() {
  local dir="$1" max=0 f sz
  while IFS= read -r f; do
    [ -f "$dir/$f" ] || continue
    sz=$(stat -c%s "$dir/$f" 2>/dev/null || echo 0)
    sz=$((sz/1024/1024))
    [ "$sz" -gt "$max" ] && max=$sz
  done < <(git -C "$dir" diff --cached --name-only --diff-filter=A 2>/dev/null)
  printf '%s' "$max"
}

# ── Entropy ──────────────────────────────────────────────────────────────────
# Shannon entropy in bits/char of a string (0.00 for empty). Pure awk. Used by
# the secret scanner to tell a real high-entropy secret from a low-entropy
# placeholder ("ghp_xxxx…") or a documentation token, killing false positives.
ckis::entropy() {
  printf '%s\n' "${1:-}" | awk '
    NR==1 {
      n=length($0)
      if(n==0){printf "0.00"; exit}
      for(i=1;i<=n;i++){c=substr($0,i,1); f[c]++}
      H=0
      for(c in f){p=f[c]/n; H-=p*log(p)/log(2)}
      printf "%.2f", H
    }'
}

# ── Brain discovery (agent-agnostic) ─────────────────────────────────────────
# Emit "slug<TAB>repo_path" for every project that has a .brain/ dir — the UNION
# of the Dev Brain registry AND a bounded filesystem scan of discovery.brain_roots.
# The scan makes discovery agent-agnostic: a project created by ANY coding agent
# (Codex, Gemini, OpenCode, ...) is found even if it never ran a registration
# hook. De-duplicated by repo path; registry entries win the slug.
ckis::brain_repos() {
  local reg seen="|" slug repo root brain maxdepth roots_src
  reg="${CKIS_REGISTRY:-$(ckis::expand "$(ckis::manifest '.discovery.registry // empty')")}"

  # 1. registry (fast path)
  if [ -f "$reg" ]; then
    while IFS=$'\t' read -r slug repo; do
      [ -n "$repo" ] || continue
      repo="$(ckis::expand "$repo")"
      [ -d "$repo/.brain" ] || continue
      case "$seen" in *"|$repo|"*) continue;; esac
      seen="$seen$repo|"
      printf '%s\t%s\n' "$slug" "$repo"
    done < <(jq -r '.projects[] | [.slug, .repo_root] | @tsv' "$reg" 2>/dev/null)
  fi

  # 2. filesystem scan of brain_roots (agent-agnostic safety net)
  maxdepth="$(ckis::manifest '.discovery.brain_scan_maxdepth // 5')"
  local prune=() nm first=1
  prune+=( '(' )
  while IFS= read -r nm; do
    [ -n "$nm" ] || continue
    [ "$first" = 1 ] && first=0 || prune+=( -o )
    prune+=( -name "$nm" )
  done < <(ckis::manifest '.discovery.brain_scan_prune[]?' 2>/dev/null)
  prune+=( ')' -prune )

  # roots: env override (newline-separated; empty disables the scan) or manifest
  if [ "${CKIS_BRAIN_ROOTS+x}" = "x" ]; then
    roots_src="$CKIS_BRAIN_ROOTS"
  else
    roots_src="$(ckis::manifest '.discovery.brain_roots[]?' 2>/dev/null)"
  fi
  while IFS= read -r root; do
    [ -n "$root" ] || continue
    root="$(ckis::expand "$root")"
    [ -d "$root" ] || continue
    while IFS= read -r brain; do
      repo="$(dirname "$brain")"
      ckis::is_repo "$repo" || continue
      case "$seen" in *"|$repo|"*) continue;; esac
      seen="$seen$repo|"
      printf '%s\t%s\n' "$(basename "$repo")" "$repo"
    done < <( [ "$first" = 0 ] \
      && find "$root" -maxdepth "$maxdepth" "${prune[@]}" -o -type d -name .brain -print 2>/dev/null \
      || find "$root" -maxdepth "$maxdepth" -type d -name .brain -print 2>/dev/null )
  done <<< "$roots_src"
}

# ── Hard-failure markers ─────────────────────────────────────────────────────
# Persistent record that a target FAILED to back up (e.g. commit blocked by the
# secret scanner, or push failing). The doctor reads these to show 🔴 FAILED
# (distinct from benign drift) and backup-all exits non-zero when any is set.
# Keyed by slug (basename of the repo dir, matching the manifest target slugs).
ckis::_fail_dir() { printf '%s' "$CKIS_LOG_DIR/failures"; }
ckis::mark_fail() {  # slug reason...
  local slug="$1"; shift
  mkdir -p "$(ckis::_fail_dir)" 2>/dev/null || true
  printf '%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >"$(ckis::_fail_dir)/$slug" 2>/dev/null || true
}
ckis::clear_fail()  { rm -f "$(ckis::_fail_dir)/$1" 2>/dev/null || true; }
ckis::is_failed()   { [ -f "$(ckis::_fail_dir)/$1" ]; }
ckis::fail_reason() { cut -f2- "$(ckis::_fail_dir)/$1" 2>/dev/null || true; }
ckis::list_fails()  { ls -1 "$(ckis::_fail_dir)" 2>/dev/null || true; }
