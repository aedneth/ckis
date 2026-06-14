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
ckis::info "linked $(ls "$HERE"/bin/*.sh | wc -l) scripts into $BIN_DIR"

# 2. systemd --user timer (daily safety net)
if [ "${CKIS_NO_SYSTEMD:-0}" != "1" ] && command -v systemctl >/dev/null 2>&1; then
  mkdir -p "$SYSTEMD_DIR"
  sed "s|@BIN@|$BIN_DIR|g" "$HERE/systemd/ckis-backup.service" >"$SYSTEMD_DIR/ckis-backup.service"
  cp "$HERE/systemd/ckis-backup.timer" "$SYSTEMD_DIR/ckis-backup.timer"
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now ckis-backup.timer 2>/dev/null \
    && ckis::info "systemd timer enabled (daily)" \
    || ckis::warn "could not enable systemd timer (headless? run: systemctl --user enable --now ckis-backup.timer)"
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
