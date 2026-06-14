#!/usr/bin/env bash
# Contract for hooks/pre-commit-secret-scan.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
HOOK="$ROOT/hooks/pre-commit-secret-scan.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT

# --files mode: clean file passes, token file blocks.
printf 'just some notes about tokens and keys\n' >"$SB/clean.md"
printf 'token = ghp_%s\n' "0123456789012345678901234567890123456789" >"$SB/bad.md"
assert_ok   "clean file passes"      bash "$HOOK" --files "$SB/clean.md"
assert_fail "github token blocks"    bash "$HOOK" --files "$SB/bad.md"

printf -- '%s PRIVATE KEY-----\nabc\n' '-----BEGIN' >"$SB/pem.md"
assert_fail "private key blocks"     bash "$HOOK" --files "$SB/pem.md"

# Hook mode inside a real repo.
R="$SB/repo"; mkdir -p "$R"; git -C "$R" init -q
cp "$HOOK" "$R/.git/hooks/pre-commit"; chmod +x "$R/.git/hooks/pre-commit"
git -C "$R" config user.email t@t; git -C "$R" config user.name t
echo "hello world" >"$R/ok.md"; git -C "$R" add ok.md
assert_ok   "clean commit succeeds"  git -C "$R" commit -q -m ok
printf 'AKIA%s\n' "ABCDEFGHIJKLMNOP" >"$R/leak.md"; git -C "$R" add leak.md
assert_fail "aws key commit blocked" git -C "$R" commit -q -m leak

assert_summary
