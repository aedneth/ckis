#!/usr/bin/env bash
# ckis-restore.sh [--no-system] [--no-apparatus]
# Plug-and-play rebuild on a fresh machine/OS. Reads the manifest, clones every
# missing target from its private remote, restores the L0 apparatus into
# ~/.claude, and installs the runtime (symlinks, systemd timer, hooks).
# The ONLY manual step afterwards is re-provisioning secrets (never in backup).
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$HERE/../lib/common.sh"
ckis::init

NO_SYSTEM=0; NO_APP=0
for a in "$@"; do case "$a" in --no-system) NO_SYSTEM=1;; --no-apparatus) NO_APP=1;; esac; done

REMOTE_BASE="${CKIS_REMOTE_BASE:-https://github.com/}"
CLAUDE_HOME="${CKIS_CLAUDE_HOME:-$HOME/.claude}"

ckis::info "═══ restore start ═══"

# 1. Clone every missing target.
while IFS=$'\t' read -r slug path remote class kind; do
  if [ -d "$path/.git" ]; then
    ckis::info "$slug: already present, skip"; continue
  fi
  [ -n "$remote" ] && [ "$remote" != "null" ] || { ckis::warn "$slug: no remote, cannot restore"; continue; }
  local_url="${REMOTE_BASE}${remote}.git"
  mkdir -p "$(dirname "$path")"
  if ckis::retry 3 git clone "$local_url" "$path" >>"$CKIS_LOG_FILE" 2>&1; then
    ckis::info "$slug: cloned from $local_url"
  else
    ckis::err "$slug: clone failed ($local_url)"
  fi
done < <(ckis::targets)

# 1.5 Restore the centralized brains aggregator into its workdir, so every
#     project's .brain/ is available immediately on the fresh machine. Non-fatal:
#     the next backup-all rebuilds it from the live projects anyway.
agg_remote="$(ckis::manifest '.discovery.brain_aggregator // empty')"
agg_dir="$(ckis::expand "$(ckis::manifest '.discovery.aggregate_workdir // empty')")"
if [ -n "$agg_remote" ] && [ "$agg_remote" != "null" ] && [ -n "$agg_dir" ] && [ "$agg_dir" != "null" ]; then
  if [ -d "$agg_dir/.git" ]; then
    ckis::info "aggregator: already present, skip"
  else
    mkdir -p "$(dirname "$agg_dir")"
    agg_url="${REMOTE_BASE}${agg_remote}.git"
    if ckis::retry 3 git clone "$agg_url" "$agg_dir" >>"$CKIS_LOG_FILE" 2>&1; then
      ckis::info "aggregator: cloned centralized brains from $agg_url"
    else
      ckis::warn "aggregator: clone failed ($agg_url) — next backup-all will rebuild it"
    fi
  fi
fi

# 2. Restore L0 apparatus into ~/.claude (merge; never deletes user data).
if [ "$NO_APP" -eq 0 ] && [ -d "$CKIS_INFRA_ROOT/apparatus" ]; then
  mkdir -p "$CLAUDE_HOME"
  rsync -a "$CKIS_INFRA_ROOT/apparatus"/ "$CLAUDE_HOME"/ >>"$CKIS_LOG_FILE" 2>&1 \
    && ckis::info "apparatus restored into $CLAUDE_HOME"
fi

# 3. Install runtime (symlinks, systemd, hooks).
if [ "$NO_SYSTEM" -eq 0 ] && [ -x "$CKIS_INFRA_ROOT/install.sh" ]; then
  bash "$CKIS_INFRA_ROOT/install.sh" || ckis::warn "install.sh reported issues"
fi

cat <<EOF
─────────────────────────────────────────────────────────
✅ CKIS restore complete.
Manual steps remaining (by design — secrets are never backed up):
  1. gh auth login                 (GitHub access for pushes)
  2. claude  → re-auth             (~/.claude/.credentials.json)
  3. Mount + unlock the encrypted backup drive for physical/secret restore
  4. Rebuild regenerable layers:   graphify update  (per code repo)
─────────────────────────────────────────────────────────
EOF
ckis::info "═══ restore done ═══"
exit 0
