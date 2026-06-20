#!/usr/bin/env bash
# ckis-reflux-all.sh — autonomous context-maintenance (reflux) engine.
#
# Keeps the vault's canonical "heart docs" (_MEMORY/_ACTIVE-PROJECTS/_INTERESTS/
# _PROFILE) fresh from accumulated session activity, so a vault can grow for
# months without its canonical state files quietly going stale. Configured by the
# `reflux` block in ckis-manifest.json; remove that block to disable.
#
# SAFETY MODEL — propose-before-apply:
#   * Default run PROPOSES only. It writes a proposed rewrite + unified diff into
#     the quarantine queue (manifest .reflux.queue_subdir) and NEVER overwrites a
#     live heart doc.
#   * A proposal is accepted into the queue ONLY if it passes ALL structural
#     guards: frontmatter `created` immutable · no `#` section heading dropped ·
#     line count >= min_retain_pct of current · <= max_lines · secret-scan clean.
#     A proposal failing any guard is rejected and logged, never queued.
#   * Applying to the live file is a separate, deliberate act: `--apply <queue>`
#     (a human promotes a reviewed proposal) OR a doc's manifest auto_apply=true
#     (kept false until trust is established).
#
# Usage:
#   ckis-reflux-all                 propose for every due doc (recurring/self-digest)
#   ckis-reflux-all --doc memory    propose for one doc
#   ckis-reflux-all --digest FILE   use a provided digest (Stage-3 backfill via workers)
#   ckis-reflux-all --apply QUEUEF  re-check guards on QUEUEF's proposal, apply to live
#
# Idempotent; global lock. Never exits the parent shell. Best-effort model call.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

SCAN="$HERE/../hooks/pre-commit-secret-scan.sh"
TODAY="$(date +%Y-%m-%d)"

# ── helpers ──────────────────────────────────────────────────────────────────

_vault() { ckis::expand "$(ckis::manifest '.reflux.vault // empty')"; }

# frontmatter `created:` value (empty if none) — used by the immutability guard.
_created_of() { awk -F': *' '/^created:/{print $2; exit}' "$1" 2>/dev/null | tr -d ' \r'; }

# All heading lines (#..######) of a file, normalized — used by the no-drop guard.
_headings_of() { grep -E '^#{1,6} ' "$1" 2>/dev/null | sed 's/[[:space:]]*$//'; }

# Strip a leading/trailing ```markdown / ``` fence the model may add despite
# instructions, so the proposal is the raw file content.
_defence() {
  awk 'NR==1 && /^```/{next} {buf[NR]=$0} END{
    last=NR; if(buf[last] ~ /^```[[:space:]]*$/) last--
    for(i=1;i<=last;i++) if(i in buf) print buf[i]
  }' "$1"
}

# Build a bounded "recent activity" digest from session logs + Dev Brain index +
# vault git log. Used when no --digest is supplied (the recurring path). Capped.
_build_digest() {
  local vault="$1" days logs db
  days="$(ckis::manifest '.reflux.sources.recent_days // 21')"
  logs="$vault/$(ckis::manifest '.reflux.sources.session_logs // "01-daily/logs"')"
  db="$(ckis::expand "$(ckis::manifest '.reflux.sources.dev_brain_sessions // empty')")"

  echo "## Vault commits (last ${days}d, non-auto)"
  git -C "$vault" log --since="${days} days ago" --format='- %ad %s' --date=short 2>/dev/null \
    | grep -v 'ckis-backup: auto' | head -40

  echo ""
  echo "## Recent session-log summaries"
  if [ -d "$logs" ]; then
    # newest few daily logs, their tail (where the session summary lives)
    find "$logs" -maxdepth 1 -name '*.md' -mtime "-${days}" 2>/dev/null \
      | sort | tail -8 | while read -r f; do
        echo "### $(basename "$f")"
        tail -25 "$f" 2>/dev/null
      done
  fi

  echo ""
  echo "## Dev Brain sessions (recent)"
  [ -f "$db" ] && tail -25 "$db" 2>/dev/null
}

# Structural guards. Args: live proposal max_lines min_pct
# Returns 0 if ALL pass; otherwise prints the failing guard(s) and returns 1.
_guards() {
  local live="$1" prop="$2" max="$3" pct="$4" fail=0
  local lc pc need

  # 1. frontmatter created immutable
  if [ "$(_created_of "$live")" != "$(_created_of "$prop")" ]; then
    ckis::warn "guard FAIL created-immutable: '$(_created_of "$live")' -> '$(_created_of "$prop")'"; fail=1
  fi

  # 2. no section heading dropped — multiset comparison (NOT sort -u), so dropping
  #    one of two identical headings is still caught. `diff` reports a '<' line for
  #    any live-heading instance not matched by a proposal instance.
  local dropped
  dropped="$(diff <(_headings_of "$live" | sort) <(_headings_of "$prop" | sort) 2>/dev/null | grep -E '^< ' || true)"
  if [ -n "$dropped" ]; then
    ckis::warn "guard FAIL heading-dropped: $(printf '%s' "$dropped" | tr '\n' '|')"; fail=1
  fi

  # 3. line count not below min_retain_pct of live
  lc="$(wc -l < "$live")"; pc="$(wc -l < "$prop")"
  need=$(( lc * pct / 100 ))
  if [ "$pc" -lt "$need" ]; then
    ckis::warn "guard FAIL shrink: proposal ${pc} lines < ${pct}% of ${lc} (=${need})"; fail=1
  fi

  # 4. <= max_lines (if a cap is set)
  if [ -n "$max" ] && [ "$max" != "null" ] && [ "$pc" -gt "$max" ]; then
    ckis::warn "guard FAIL max-lines: proposal ${pc} > cap ${max}"; fail=1
  fi

  # 5. secret-scan clean — FAIL-CLOSED: if the scanner is missing, reject rather
  #    than silently skip a security guard (a moved/renamed hook must not disable
  #    secret detection on the propose OR apply path).
  if [ -f "$SCAN" ]; then
    if ! bash "$SCAN" --files "$prop" >/dev/null 2>&1; then
      ckis::warn "guard FAIL secret-scan: proposal contains secret material"; fail=1
    fi
  else
    ckis::warn "guard FAIL secret-scan: scanner missing at $SCAN (fail-closed)"; fail=1
  fi

  return $fail
}

# Produce a proposal for one doc via the model. Args: live max_lines digestfile out
# Returns 0 and writes the de-fenced proposal to $out on success.
_propose() {
  local live="$1" max="$2" digest="$3" out="$4"
  local model raw prompt
  model="$(ckis::manifest '.reflux.model_cmd // "claude -p"')"

  prompt="You are updating a canonical state file in a personal knowledge vault.
Output ONLY the complete updated markdown file content — no preamble, no code fences, no commentary.

HARD RULES:
- Preserve the YAML frontmatter exactly, EXCEPT set 'modified:' to ${TODAY}. NEVER change 'created:'.
- Keep EVERY existing section heading (every line starting with #). You may revise content under a heading but must not remove the heading itself.
- Stay at or under ${max:-150} lines total. Be concise; prefer updating existing bullets over adding new sections.
- Update state to reflect the RECENT ACTIVITY below. Do NOT invent facts it doesn't support. When unsure, keep the existing line.
- Never include secrets, API keys, or tokens.

=== CURRENT FILE ===
$(cat "$live")

=== RECENT ACTIVITY (newest first) ===
$(cat "$digest")

=== END. Output the full updated file now (frontmatter first, no fences): ==="

  # Model call is best-effort; capture to a temp, then de-fence into $out.
  # stdin MUST come from /dev/null: `claude -p` reads stdin, and this function
  # runs inside a `while read` loop fed by process substitution — without this
  # redirect the model swallows the loop's input stream and only the first doc
  # gets processed.
  local tmp; tmp="$(mktemp)"
  if ! $model "$prompt" </dev/null >"$tmp" 2>>"$CKIS_LOG_FILE"; then
    rm -f "$tmp"; return 1
  fi
  [ -s "$tmp" ] || { rm -f "$tmp"; return 1; }
  _defence "$tmp" >"$out"
  rm -f "$tmp"
  [ -s "$out" ]
}

# ── modes ────────────────────────────────────────────────────────────────────

# Apply a reviewed queued proposal to its live target (re-running guards first).
_apply() {
  local qfile="$1"
  [ -f "$qfile" ] || { ckis::err "apply: queue file not found: $qfile"; return 1; }
  local slug; slug="$(awk -F': *' '/^reflux-slug:/{print $2; exit}' "$qfile" | tr -d ' \r')"
  local vault; vault="$(_vault)"
  local rel max; rel="$(ckis::manifest ".reflux.docs[] | select(.slug==\"$slug\") | .path")"
  max="$(ckis::manifest ".reflux.docs[] | select(.slug==\"$slug\") | .max_lines")"
  [ -n "$rel" ] || { ckis::err "apply: unknown slug '$slug' in $qfile"; return 1; }
  local live="$vault/$rel" pct; pct="$(ckis::manifest '.reflux.min_retain_pct // 70')"

  # The queue file stores the proposal body after a '---PROPOSAL---' marker.
  local body; body="$(mktemp)"
  awk 'f{print} /^---PROPOSAL---$/{f=1}' "$qfile" >"$body"

  if ! _guards "$live" "$body" "$max" "$pct"; then
    ckis::err "apply ABORTED: proposal failed guards (live untouched): $qfile"
    rm -f "$body"; return 1
  fi
  cp "$body" "$live"
  rm -f "$body"
  ckis::info "applied reflux proposal → $rel ($slug)"
}

# Propose for one doc. Args: slug rel max digestfile
_propose_doc() {
  local slug="$1" rel="$2" max="$3" digest="$4"
  local vault; vault="$(_vault)"
  local live="$vault/$rel"
  local pct; pct="$(ckis::manifest '.reflux.min_retain_pct // 70')"
  local qdir; qdir="$vault/$(ckis::manifest '.reflux.queue_subdir // "00-inbox/_REFLUX-QUEUE"')"
  [ -f "$live" ] || { ckis::warn "reflux: live doc missing, skip: $rel"; return 0; }
  mkdir -p "$qdir"

  local prop; prop="$(mktemp)"
  if ! _propose "$live" "$max" "$digest" "$prop"; then
    ckis::warn "reflux: model produced no proposal for $slug (skip)"; rm -f "$prop"; return 1
  fi

  if ! _guards "$live" "$prop" "$max" "$pct"; then
    ckis::err "reflux: proposal REJECTED by guards, not queued: $slug"
    ckis::mark_fail "reflux-$slug" "proposal failed structural guards"
    rm -f "$prop"; return 1
  fi
  ckis::clear_fail "reflux-$slug"

  local ts qfile; ts="$(date +%Y%m%d-%H%M%S)"; qfile="$qdir/${slug}-${ts}.md"
  {
    echo "---"
    echo "type: reflux-proposal"
    echo "reflux-slug: $slug"
    echo "target: $rel"
    echo "generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "status: pending-review"
    echo "---"
    echo ""
    echo "# Reflux proposal — \`$rel\`"
    echo ""
    echo "> PROPOSE-ONLY. The live file is unchanged. Review the diff below; to apply:"
    echo "> \`ckis-reflux-all --apply \"$qfile\"\`  (re-checks guards, then overwrites the live file)."
    echo ""
    echo "## Diff (live → proposed)"
    echo '```diff'
    diff -u "$live" "$prop" | sed '1,2d' || true
    echo '```'
    echo ""
    echo "---PROPOSAL---"
    cat "$prop"
  } >"$qfile"
  rm -f "$prop"
  ckis::info "reflux proposal queued (live untouched): $qfile"
  printf '%s\n' "$qfile"
}

# Is a doc "due" for a proposal? (used by --due-only, the autonomous timer mode.)
# Returns 0 = due, 1 = skip. Skips when a pending proposal already exists (don't
# pile up) OR the live doc was refreshed within its cadence window (still fresh).
_due() {
  local slug="$1" rel="$2" cadence="$3"
  local vault qdir; vault="$(_vault)"
  qdir="$vault/$(ckis::manifest '.reflux.queue_subdir // "00-inbox/_REFLUX-QUEUE"')"
  # a pending proposal already awaits review → skip
  ls "$qdir/${slug}-"*.md >/dev/null 2>&1 && return 1
  # live modified within cadence window → still fresh, skip
  local days=1; [ "$cadence" = "weekly" ] && days=7
  local m mod_e now
  m="$(awk -F': *' '/^modified:/{print $2; exit}' "$vault/$rel" 2>/dev/null | tr -d ' \r')"
  [ -n "$m" ] || return 0
  mod_e="$(date -d "$m" +%s 2>/dev/null)" || return 0
  now="$(date +%s)"
  [ "$(( (now - mod_e) / 86400 ))" -lt "$days" ] && return 1
  return 0
}

_run() {
  local only_doc="" digest_override="" apply_file="" due_only=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --doc)      only_doc="$2"; shift 2;;
      --digest)   digest_override="$2"; shift 2;;
      --apply)    apply_file="$2"; shift 2;;
      --due-only) due_only=1; shift;;
      *) ckis::warn "unknown arg: $1"; shift;;
    esac
  done

  if [ -n "$apply_file" ]; then _apply "$apply_file"; return $?; fi

  ckis::info "═══ reflux start (propose-only) ═══"
  local vault; vault="$(_vault)"
  [ -d "$vault" ] || { ckis::err "reflux: vault not found: $vault"; return 1; }

  # Build (or reuse) the digest once for this run.
  local digest cleanup_digest=0
  if [ -n "$digest_override" ]; then
    digest="$digest_override"
    [ -f "$digest" ] || { ckis::err "reflux: --digest file not found: $digest"; return 1; }
  else
    digest="$(mktemp)"; cleanup_digest=1
    _build_digest "$vault" >"$digest"
  fi

  local proposed=0 rejected=0 skipped=0
  while IFS=$'\t' read -r slug rel max auto cadence; do
    [ -n "$only_doc" ] && [ "$slug" != "$only_doc" ] && continue
    if [ "$due_only" = 1 ] && ! _due "$slug" "$rel" "$cadence"; then
      skipped=$((skipped+1)); continue
    fi
    if _propose_doc "$slug" "$rel" "$max" "$digest" >/dev/null; then
      proposed=$((proposed+1))
    else
      rejected=$((rejected+1))
    fi
  done < <(ckis::manifest '.reflux.docs[] | [.slug, .path, (.max_lines|tostring), (.auto_apply|tostring), .cadence] | @tsv')

  [ "$cleanup_digest" = 1 ] && rm -f "$digest"
  ckis::info "═══ reflux done — proposed:$proposed rejected:$rejected skipped:$skipped (all live docs untouched) ═══"

  # A rejected proposal is a quality signal, not a backup failure: surface via a
  # marker (doctor can show it) but do NOT exit non-zero on its own here.
  return 0
}

# Only run when executed directly; sourcing (e.g. tests) gets the functions only.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  ckis::with_lock "reflux-all" _run "$@"
  rc=$?
  [ "$rc" = "75" ] && { ckis::info "reflux-all already running, skipped"; exit 0; }
  exit "$rc"
fi
