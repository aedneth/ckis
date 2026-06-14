#!/usr/bin/env bash
# ckis-backup-doctor.sh [--oneline]
# Passive health reporter for the backup system. Always exits 0.
#   default    multi-line report per target
#   --oneline  single status line for the SessionStart banner
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"

ONELINE=0; [ "${1:-}" = "--oneline" ] && ONELINE=1

# Reason string for a target's drift, empty if fully backed up.
_drift() {
  local dir="$1"
  ckis::is_repo "$dir" || { printf 'missing'; return; }
  local r=()
  ckis::repo_dirty "$dir" && r+=("uncommitted")
  if git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    local a; a="$(ckis::repo_ahead "$dir")"
    [ "${a:-0}" != "0" ] && r+=("+$a unpushed")
  else
    # no upstream: if there are commits, they are unbacked
    git -C "$dir" rev-parse HEAD >/dev/null 2>&1 && r+=("no-upstream")
  fi
  ckis::repo_has_remote "$dir" || r+=("no-remote")
  local IFS=','; printf '%s' "${r[*]}"
}

# physical-backup age line
_phys() {
  local m="$CKIS_LOG_DIR/last-physical"
  if [ -f "$m" ]; then
    local t now d
    t="$(cat "$m" 2>/dev/null)"; now="$(date +%s)"
    case "$t" in ''|*[!0-9]*) t="$now" ;; esac   # guard against empty/corrupt marker
    d=$(( (now - t) / 86400 ))
    printf 'physical %sd' "$d"
  else
    printf 'physical never'
  fi
}

drift_list=()
report=""
while IFS=$'\t' read -r slug path remote class kind; do
  d="$(_drift "$path")"
  if [ -n "$d" ]; then
    drift_list+=("$slug ($d)")
    report+="  ⚠ $slug — $d\n"
  else
    report+="  ✅ $slug — backed up\n"
  fi
done < <(ckis::targets)

if [ "$ONELINE" -eq 1 ]; then
  if [ "${#drift_list[@]}" -eq 0 ]; then
    printf 'BACKUP ✅ all pushed · %s\n' "$(_phys)"
  else
    printf 'BACKUP ⚠ %s · %s\n' "$(IFS='; '; echo "${drift_list[*]}")" "$(_phys)"
  fi
else
  printf 'CKIS backup health:\n'
  printf '%b' "$report"
  printf '  %s\n' "$(_phys)"
fi
exit 0
