#!/usr/bin/env bash
# install.sh — wire the backup runtime into the machine. Idempotent.
#   * symlink bin/*.sh        -> ~/bin (CKIS_BIN_DIR)
#   * install + enable        systemd --user timer (unless CKIS_NO_SYSTEMD=1)
#   * install secret-scan     pre-commit hook into every manifest target repo
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/lib/common.sh"
ckis::init

BIN_DIR="${CKIS_BIN_DIR:-$HOME/bin}"
SYSTEMD_DIR="${CKIS_SYSTEMD_DIR:-$HOME/.config/systemd/user}"

# 1. symlink executables onto PATH
mkdir -p "$BIN_DIR"
for s in "$HERE"/bin/*.sh; do
  ln -sf "$s" "$BIN_DIR/$(basename "$s" .sh)"
done
# Prune our own dangling symlinks (scripts renamed/removed, e.g. cli-brains-sync
# -> brains-sync) so a rename never leaves a dead command behind. Scoped to links
# that point into THIS repo's bin/, so unrelated user symlinks are never touched.
for l in "$BIN_DIR"/*; do
  [ -L "$l" ] || continue
  tgt="$(readlink "$l")"
  case "$tgt" in "$HERE"/bin/*) [ -e "$l" ] || { rm -f "$l"; ckis::info "pruned dangling link $(basename "$l")"; } ;; esac
done
ckis::info "linked $(ls "$HERE"/bin/*.sh | wc -l) scripts into $BIN_DIR"

# 2. systemd --user timer (reconciling safety net; cadence from the manifest)
if [ "${CKIS_NO_SYSTEMD:-0}" != "1" ] && command -v systemctl >/dev/null 2>&1; then
  mkdir -p "$SYSTEMD_DIR"
  INTERVAL="$(ckis::manifest '.schedule.reconcile_interval // "15min"')"
  BOOTDELAY="$(ckis::manifest '.schedule.boot_delay // "3min"')"
  sed "s|@BIN@|$BIN_DIR|g" "$HERE/systemd/ckis-backup.service" >"$SYSTEMD_DIR/ckis-backup.service"
  sed -e "s|@INTERVAL@|$INTERVAL|g" -e "s|@BOOTDELAY@|$BOOTDELAY|g" \
    "$HERE/systemd/ckis-backup.timer" >"$SYSTEMD_DIR/ckis-backup.timer"
  systemctl --user daemon-reload 2>/dev/null || true
  if systemctl --user enable --now ckis-backup.timer 2>/dev/null; then
    systemctl --user restart ckis-backup.timer 2>/dev/null || true   # apply new cadence
    ckis::info "systemd timer enabled (reconcile every $INTERVAL)"
  else
    ckis::warn "could not enable systemd timer (headless? run: systemctl --user enable --now ckis-backup.timer)"
  fi

  # 2b. reflux timer (OPTIONAL autonomous context maintenance; only if configured)
  if [ -f "$HERE/systemd/ckis-reflux.timer" ] && [ "$(ckis::manifest '.reflux // empty')" != "" ]; then
    R_INTERVAL="$(ckis::manifest '.schedule.reflux_interval // "1d"')"
    R_BOOTDELAY="$(ckis::manifest '.schedule.reflux_boot_delay // "10min"')"
    sed "s|@BIN@|$BIN_DIR|g" "$HERE/systemd/ckis-reflux.service" >"$SYSTEMD_DIR/ckis-reflux.service"
    sed -e "s|@INTERVAL@|$R_INTERVAL|g" -e "s|@BOOTDELAY@|$R_BOOTDELAY|g" \
      "$HERE/systemd/ckis-reflux.timer" >"$SYSTEMD_DIR/ckis-reflux.timer"
    systemctl --user daemon-reload 2>/dev/null || true
    if systemctl --user enable --now ckis-reflux.timer 2>/dev/null; then
      systemctl --user restart ckis-reflux.timer 2>/dev/null || true
      ckis::info "reflux timer enabled (propose-only, every $R_INTERVAL)"
    else
      ckis::warn "could not enable reflux timer (headless? run: systemctl --user enable --now ckis-reflux.timer)"
    fi
  fi
fi

# 3. secret-scan pre-commit into each target repo (don't clobber existing hooks)
while IFS=$'\t' read -r slug path remote class kind; do
  [ -d "$path/.git" ] || continue
  hook="$path/.git/hooks/pre-commit"
  if [ ! -e "$hook" ]; then
    ln -sf "$HERE/hooks/pre-commit-secret-scan.sh" "$hook"
    ckis::info "$slug: secret-scan pre-commit installed"
  elif ! grep -q 'pre-commit-secret-scan' "$hook" 2>/dev/null; then
    ckis::warn "$slug: existing pre-commit hook left intact (add secret-scan manually if desired)"
  fi
done < <(ckis::targets)

ckis::info "install complete"
