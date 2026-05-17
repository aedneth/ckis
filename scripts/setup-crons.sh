#!/usr/bin/env bash
# setup-crons.sh — Interactive cron setup for CKIS
# Run once after cloning the template.
# See 00-systems/ckis/17-crons-architecture.md for full documentation.

set -euo pipefail

VAULT="$(cd "$(dirname "$0")/.." && pwd)"
CRONS_CONF="$VAULT/scripts/crontab-ckis.txt"
ENV_FILE="$HOME/.claude/.env"

echo "=== CKIS Cron Setup ==="
echo ""

# 1. Check for API key
if [ ! -f "$ENV_FILE" ]; then
  echo "Step 1: Create ~/.claude/.env with your Anthropic API key"
  echo "        This is required for Crons 4 and 5 (claude -p headless sessions)."
  echo ""
  read -rp "Enter your Anthropic API key (sk-ant-...): " apikey
  mkdir -p "$(dirname "$ENV_FILE")"
  echo "ANTHROPIC_API_KEY=$apikey" > "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  echo "Saved to $ENV_FILE (chmod 600)"
else
  echo "Step 1: $ENV_FILE already exists — skipping."
fi

echo ""
echo "Step 2: Installing crontab..."

if [ ! -f "$CRONS_CONF" ]; then
  echo "Error: $CRONS_CONF not found. Run this from the vault root."
  exit 1
fi

crontab "$CRONS_CONF"
echo "Crontab installed. Verify with: crontab -l"
echo ""
echo "Crons active:"
crontab -l | grep -v '^#' | grep -v '^$'
echo ""
echo "Done. Logs will appear in ~/logs/"
