#!/usr/bin/env bash
# Contract for bin/ckis-push.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
PUSH="$ROOT/bin/ckis-push.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"

# bare remote + working clone
git init -q --bare "$SB/remote.git"
git clone -q "$SB/remote.git" "$SB/work" 2>/dev/null
git -C "$SB/work" config user.email t@t; git -C "$SB/work" config user.name t

# non-repo -> exit 0
assert_ok "non-repo exits 0" bash "$PUSH" "$SB/not-a-repo"

# dirty -> commit + push
echo "first" >"$SB/work/a.md"
assert_ok "push dirty repo" bash "$PUSH" "$SB/work"
got="$(git --git-dir="$SB/remote.git" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"
assert_eq "remote received 1 commit" "1" "$got"

# clean again -> no-op, no new commit
assert_ok "push clean repo (no-op)" bash "$PUSH" "$SB/work"
got2="$(git --git-dir="$SB/remote.git" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"
assert_eq "remote still 1 commit (idempotent)" "1" "$got2"

# coalescing: many files -> single commit
for i in $(seq 1 20); do echo "f$i" >"$SB/work/f$i.md"; done
assert_ok "push 20 new files" bash "$PUSH" "$SB/work"
got3="$(git --git-dir="$SB/remote.git" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"
assert_eq "20 files = 1 new commit (coalesced)" "2" "$got3"

# repo without remote: commits locally, still exit 0
git init -q "$SB/norem"; git -C "$SB/norem" config user.email t@t; git -C "$SB/norem" config user.name t
echo x >"$SB/norem/x"
assert_ok "no-remote repo commits locally, exit 0" bash "$PUSH" "$SB/norem"
assert_eq "local commit made" "1" "$(git -C "$SB/norem" log --oneline | wc -l | tr -d ' ')"

# SAFETY: pushing a subdir that belongs to a parent repo must NOT touch the parent
git init -q "$SB/parent"; git -C "$SB/parent" config user.email t@t; git -C "$SB/parent" config user.name t
mkdir -p "$SB/parent/child"; echo data >"$SB/parent/child/x.md"
assert_ok "subdir-of-repo push is a safe no-op" bash "$PUSH" "$SB/parent/child"
assert_eq "parent repo NOT committed" "0" "$(git -C "$SB/parent" log --oneline --all 2>/dev/null | wc -l | tr -d ' ')"

# HARD-FAIL: a pre-commit hook that ABORTS the commit (e.g. secret-scan block) must
# make ckis-push fail loudly and leave ZERO commits — never silently report success.
# Regression guard for the 24h silent-vault-failure bug (commit '|| warn' then log "committed").
git init -q "$SB/blocked"; git -C "$SB/blocked" config user.email t@t; git -C "$SB/blocked" config user.name t
printf '#!/bin/sh\necho "blocked by hook"; exit 1\n' >"$SB/blocked/.git/hooks/pre-commit"
chmod +x "$SB/blocked/.git/hooks/pre-commit"
echo data >"$SB/blocked/note.md"
assert_fail "commit aborted by pre-commit -> ckis-push fails hard" bash "$PUSH" "$SB/blocked"
assert_eq "blocked repo has ZERO commits" "0" "$(git -C "$SB/blocked" log --oneline 2>/dev/null | wc -l | tr -d ' ')"

# Benign: a dirty repo whose changes are all already committed-equivalent (add stages nothing
# new) is a clean no-op, exit 0 — must NOT be conflated with a hard failure.
assert_ok "blocked repo after removing the hook commits cleanly" bash -c '
  rm -f "$1/.git/hooks/pre-commit"; exec bash "$2" "$1"' _ "$SB/blocked" "$PUSH"
assert_eq "now committed (1 commit)" "1" "$(git -C "$SB/blocked" log --oneline 2>/dev/null | wc -l | tr -d ' ')"

assert_summary
