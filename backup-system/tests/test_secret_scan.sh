#!/usr/bin/env bash
# Contract for hooks/pre-commit-secret-scan.sh — strongest-mode scanner.
# Proves it catches REAL secrets while NOT flagging documentation that merely
# mentions a marker (the false-positive that stalled the vault for ~24h).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
HOOK="$ROOT/hooks/pre-commit-secret-scan.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT

# high-entropy 36-char token body (assembled at runtime; never a literal in this file)
rnd() { head -c 96 /dev/urandom | base64 2>/dev/null | tr -dc 'A-Za-z0-9' | head -c "${1:-36}"; }

# ── clean passes ──
printf 'just some notes about tokens and private keys in general\n' >"$SB/clean.md"
assert_ok   "clean file passes"                bash "$HOOK" --files "$SB/clean.md"

# ── REAL token blocks (high entropy) ──
printf 'token = ghp_%s\n' "$(rnd 36)" >"$SB/realtok.md"
assert_fail "real high-entropy ghp_ token blocks" bash "$HOOK" --files "$SB/realtok.md"
printf 'aws = AKIA%s\n' "ABCDEFGHIJKLMNOP" >"$SB/aws.md"
assert_fail "AWS AKIA key blocks"              bash "$HOOK" --files "$SB/aws.md"

# ── PLACEHOLDER does NOT block (the entropy fix) ──
ph="ghp_$(printf 'x%.0s' $(seq 1 36))"
printf 'example placeholder token = %s\n' "$ph" >"$SB/placeholder.md"
assert_ok   "placeholder ghp_xxxx… passes (low entropy)" bash "$HOOK" --files "$SB/placeholder.md"

# ── PROSE mention of a PEM marker does NOT block (THE outage cause) ──
printf 'The scanner matches the literal -----BEGIN PRIVATE KEY----- marker quoted in prose.\n' >"$SB/prose.md"
assert_ok   "prose 'BEGIN PRIVATE KEY' (no body) passes" bash "$HOOK" --files "$SB/prose.md"

# ── REAL PEM block blocks (marker + base64 body on its own line) ──
{ echo "-----BEGIN PRIVATE KEY-----"; echo "$(rnd 64)"; echo "-----END PRIVATE KEY-----"; } >"$SB/realpem.md"
assert_fail "real PEM key block blocks"        bash "$HOOK" --files "$SB/realpem.md"

# ── URL-embedded credential: high entropy blocks, low entropy (doc) passes ──
printf 'remote = https://user:%s@github.com/x/y.git\n' "$(rnd 36)" >"$SB/urlcred.md"
assert_fail "URL with high-entropy token blocks" bash "$HOOK" --files "$SB/urlcred.md"
printf 'example = https://user:pass@example.com/repo.git\n' >"$SB/urldoc.md"
assert_ok   "URL with low-entropy user:pass passes" bash "$HOOK" --files "$SB/urldoc.md"

# ── class=secret FILENAME blocks regardless of content ──
echo "K=v" >"$SB/.env"
assert_fail "class=secret filename (.env) blocks" bash "$HOOK" --files "$SB/.env"
# …but documented templates (.env.example) are NOT flagged by filename
printf 'API_KEY=your_key_here\nDB_URL=postgres://user:pass@host/db\n' >"$SB/.env.example"
assert_ok   "template .env.example passes (placeholders)" bash "$HOOK" --files "$SB/.env.example"

# ── allowlist escape valve: inline marker ──
printf 'doc token ghp_%s   ckis-allow-secret\n' "$(rnd 36)" >"$SB/inline.md"
assert_ok   "inline ckis-allow-secret marker passes" bash "$HOOK" --files "$SB/inline.md"

# ── .git/config embedded-credential scan (the .git/config blind spot) ──
G="$SB/cfgrepo"; mkdir -p "$G"; git -C "$G" init -q
git -C "$G" remote add origin "https://aedneth:ghp_$(rnd 36)@github.com/aedneth/x.git"
assert_fail "embedded PAT in .git/config blocks (--git-config)" bash "$HOOK" --git-config "$G"
git -C "$G" remote set-url origin "https://github.com/aedneth/x.git"
assert_ok   "tokenless .git/config passes (--git-config)" bash "$HOOK" --git-config "$G"

# ── Hook mode inside a real repo + repo-root allowlist file ──
R="$SB/repo"; mkdir -p "$R"; git -C "$R" init -q
cp "$HOOK" "$R/.git/hooks/pre-commit"; chmod +x "$R/.git/hooks/pre-commit"
git -C "$R" config user.email t@t; git -C "$R" config user.name t
echo "hello world" >"$R/ok.md"; git -C "$R" add ok.md
assert_ok   "clean commit succeeds"            git -C "$R" commit -q -m ok
printf 'leak = ghp_%s\n' "$(rnd 36)" >"$R/leak.md"; git -C "$R" add leak.md
assert_fail "real token commit blocked"        git -C "$R" commit -q -m leak
git -C "$R" reset -q            # unstage the blocked leak.md so it isn't re-scanned
# allowlist the fixtures path -> same content now permitted
mkdir -p "$R/tests"; printf 'fixture ghp_%s\n' "$(rnd 36)" >"$R/tests/fx.md"
printf 'tests/*\n' >"$R/.ckis-secret-allow"
git -C "$R" add tests/fx.md .ckis-secret-allow
assert_ok   "allowlisted path commit succeeds" git -C "$R" commit -q -m allowed

# ── REGRESSION: a long note that documents security work (quotes a marker in
#    prose, far from any base64-looking line) must pass — the exact false positive
#    that once jammed a knowledge vault's backup for hours.
{
  echo "# Security notes"
  echo "The scanner used to false-positive on a note that merely quoted"
  echo "-----BEGIN PRIVATE KEY----- inside a sentence about how the scanner works,"
  echo "with no actual key body anywhere near the marker. That must pass now."
} >"$SB/securitynote.md"
assert_ok "doc quoting a marker (no adjacent body) passes" bash "$HOOK" --files "$SB/securitynote.md"

assert_summary
