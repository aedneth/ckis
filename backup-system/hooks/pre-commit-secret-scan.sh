#!/usr/bin/env bash
# pre-commit-secret-scan.sh — strongest-mode, dependency-free secret scanner.
#
# Blocks commits/files that introduce REAL secret material, while NOT flagging
# documentation that merely *mentions* a marker — the false-positive that
# silently stalled the CKIS vault backup for ~24h (a compact note that quoted
# "-----BEGIN PRIVATE KEY-----" jammed every commit). Self-contained (no lib
# dependency) so it works as a hook in any repo, on any machine.
#
# Detection (high-signal, low false-positive):
#   * token patterns (ghp_/gho_/github_pat/sk-/AKIA/AIza/xox/glpat) gated by
#     Shannon entropy >= threshold  → a real token, not "ghp_xxxx" / prose
#   * PEM private keys: BEGIN marker AND an actual base64 key-body line present
#     (a bare marker quoted in prose has no body → not flagged)
#   * URL-embedded credentials (https://user:SECRET@host), entropy-gated — the
#     blind spot that hid a live PAT in a repo's .git/config remote URL
#   * class=secret FILENAMES (.env, *.pem, *.key, .credentials.json, id_rsa*)
#
# Escape valve (docs/tests that legitimately quote patterns):
#   * repo-root allowlist file (.ckis-secret-allow): one path-glob per line
#   * inline marker anywhere on the offending line: "ckis-allow-secret"
#
# Exit 0 = clean, 1 = real secret found (commit blocked).
# Modes:
#   (no args)          hook mode: staged diff content + staged filenames
#   --files F...        scan specific files (standalone/test)
#   --git-config REPO   scan REPO/.git/config for embedded credentials
set -uo pipefail

ENTROPY_MIN="${CKIS_SECRET_ENTROPY:-3.0}"
ALLOW_FILE_NAME="${CKIS_SECRET_ALLOWFILE:-.ckis-secret-allow}"

TOKEN_RE='(ghp_[A-Za-z0-9]{36})|(gho_[A-Za-z0-9]{36})|(github_pat_[A-Za-z0-9_]{40,})|(sk-[A-Za-z0-9]{32,})|(AKIA[0-9A-Z]{16})|(AIza[0-9A-Za-z_-]{35})|(xox[baprs]-[A-Za-z0-9-]{10,})|(glpat-[A-Za-z0-9_-]{20})'
URLCRED_RE='://[^/:@[:space:]]+:[^/@[:space:]]+@'
PEM_BEGIN_RE='-----BEGIN ([A-Z0-9 ]+ )?PRIVATE KEY-----'
PEM_BODY_RE='^[A-Za-z0-9+/]{40,}={0,2}$'
SECRET_FILE_RE='(^|/)(\.env(\..+)?|.+\.pem|.+\.key|\.credentials\.json|id_rsa.*|id_ed25519.*)$'

found=0
_report() { echo "🔴 SECRET BLOCK: $1"; echo "   $2"; found=1; }

# Shannon entropy (bits/char) of a string; 0 for empty. Pure awk.
_entropy() {
  printf '%s\n' "${1:-}" | awk 'NR==1{n=length($0); if(n==0){print "0";exit}
    for(i=1;i<=n;i++){c=substr($0,i,1);f[c]++}
    H=0; for(c in f){p=f[c]/n; H-=p*log(p)/log(2)}; printf "%.2f",H}'
}
_ge() { awk -v a="$1" -v b="$2" 'BEGIN{exit !(a>=b)}'; }   # float a>=b

# inline allowlist marker on a single line
_allowed_line() { case "$1" in *ckis-allow-secret*) return 0;; *) return 1;; esac; }

# repo-root path-glob allowlist
ALLOW_GLOBS=()
_load_allowlist() {  # root
  ALLOW_GLOBS=()
  local af="$1/$ALLOW_FILE_NAME" line
  [ -f "$af" ] || return 0
  while IFS= read -r line; do
    line="${line%%#*}"; line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] && ALLOW_GLOBS+=("$line")
  done <"$af"
}
_path_allowed() {  # relpath
  local p="$1" g
  for g in "${ALLOW_GLOBS[@]:-}"; do
    [ -n "$g" ] || continue
    # shellcheck disable=SC2053
    [[ "$p" == $g ]] && return 0
  done
  return 1
}

# class=secret filename — but NOT documented templates (.env.example etc.),
# which are committed on purpose and hold only placeholders. Content scanning
# still applies to them, so a real key pasted into a template is still caught.
_filename_secret() {
  case "$(basename "$1")" in
    *.example|*.sample|*.template|*.dist|*.tmpl) return 1 ;;
  esac
  printf '%s' "$1" | grep -qE "$SECRET_FILE_RE"
}

# Content scan of a single file. label is what we print (repo-relative path).
_scan_file() {
  local f="$1" label="$2"
  [ -f "$f" ] || return 0

  # Pre-filter to candidate lines with grep (fast C), then entropy-check in bash.
  local cand cl lineno text tok e x secret
  cand="$(grep -nIE "$TOKEN_RE|$URLCRED_RE" "$f" 2>/dev/null || true)"
  if [ -n "$cand" ]; then
    while IFS= read -r cl; do
      lineno="${cl%%:*}"; text="${cl#*:}"
      _allowed_line "$text" && continue
      # entropy-gated tokens
      while IFS= read -r tok; do
        [ -n "$tok" ] || continue
        e="$(_entropy "$tok")"
        _ge "$e" "$ENTROPY_MIN" && _report "$label:$lineno" "high-entropy token ${tok:0:6}… (H=$e)"
      done < <(printf '%s\n' "$text" | grep -oE "$TOKEN_RE" 2>/dev/null || true)
      # entropy-gated URL-embedded credential
      while IFS= read -r tok; do
        [ -n "$tok" ] || continue
        x="${tok%@}"; secret="${x##*:}"
        e="$(_entropy "$secret")"
        _ge "$e" "$ENTROPY_MIN" && _report "$label:$lineno" "credential embedded in URL (H=$e)"
      done < <(printf '%s\n' "$text" | grep -oE "$URLCRED_RE" 2>/dev/null || true)
    done <<<"$cand"
  fi

  # PEM private key: a BEGIN marker IMMEDIATELY followed (within 5 lines) by an
  # actual base64 body line. Proximity matters — a long note may quote the marker
  # in prose AND, far away, contain an unrelated base64-looking line; that must
  # NOT be flagged. The inline marker on the BEGIN line suppresses (docs/tests).
  local pemline
  pemline="$(awk -v pat="$PEM_BEGIN_RE" -v body="$PEM_BODY_RE" '
    $0 ~ pat { if ($0 ~ /ckis-allow-secret/) { begin=0 } else { begin=NR }; next }
    begin && NR<=begin+5 && $0 ~ body { print begin; exit }
  ' "$f" 2>/dev/null || true)"
  [ -n "$pemline" ] && _report "$label:$pemline" "PEM private key block (marker + base64 body within 5 lines)"
}

case "${1:-}" in
  --files)
    shift
    root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
    _load_allowlist "$root"
    for f in "$@"; do
      [ -f "$f" ] || continue
      rel="$f"; case "$f" in "$root"/*) rel="${f#"$root"/}";; esac
      _path_allowed "$rel" && continue
      _filename_secret "$f" && _report "$f" "class=secret filename"
      _scan_file "$f" "$f"
    done
    ;;
  --git-config)
    repo="${2:-.}"
    cfg="$repo/.git/config"; [ -f "$cfg" ] || cfg="$(git -C "$repo" rev-parse --git-dir 2>/dev/null)/config"
    [ -f "$cfg" ] && _scan_file "$cfg" "$repo/.git/config"
    ;;
  *)
    # Hook mode: scan staged ADDED/MODIFIED content + staged filenames.
    root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
    _load_allowlist "$root"
    tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      _path_allowed "$f" && continue
      _filename_secret "$f" && _report "$f" "class=secret filename staged"
      if git show ":$f" >"$tmp" 2>/dev/null; then
        _scan_file "$tmp" "$f"
      fi
    done < <(git diff --cached --name-only --diff-filter=AM 2>/dev/null)
    ;;
esac

if [ "$found" -ne 0 ]; then
  echo "   Commit aborted. Remove the secret, or — if this is documentation/tests" >&2
  echo "   that legitimately quotes a pattern — allowlist the path in $ALLOW_FILE_NAME" >&2
  echo "   or add the inline marker 'ckis-allow-secret' on the line." >&2
  exit 1
fi
exit 0
