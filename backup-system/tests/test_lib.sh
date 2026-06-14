#!/usr/bin/env bash
# Behavior contract for lib/common.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"

# Isolate state in a sandbox.
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT
export CKIS_LOG_DIR="$SANDBOX/state"
export CKIS_MANIFEST="$ROOT/ckis-manifest.example.json"
source "$ROOT/lib/common.sh"
ckis::init

# ── path expansion ──
assert_eq "expand ~ -> \$HOME"        "$HOME/x"      "$(ckis::expand '~/x')"
assert_eq "expand \$HOME literal"     "$HOME/y"      "$(ckis::expand '$HOME/y')"
assert_eq "expand plain path"         "/a/b"        "$(ckis::expand '/a/b')"

# ── logging ──
ckis::info "hello-test"
assert_file "log file created"        "$CKIS_LOG_FILE"
assert_contains "log contains msg"    "$(cat "$CKIS_LOG_FILE")" "hello-test"

# ── locking ──
ckis::with_lock free_lock true
assert_eq "free lock runs cmd -> 0"   "0" "$?"

mkdir -p "$CKIS_LOG_DIR/locks"
exec 9>"$CKIS_LOG_DIR/locks/busy.lock"; flock -n 9
ckis::with_lock busy true; rc=$?
flock -u 9; exec 9>&-
assert_eq "held lock -> 75 (skip)"    "75" "$rc"

# ── retry ──
ckis::retry 1 true;  assert_eq "retry ok first try"     "0" "$?"
ckis::retry 1 false; rc=$?; assert_eq "retry exhausts -> non-zero" "1" "$rc"

CNT="$SANDBOX/cnt"; echo 0 >"$CNT"
flaky() { local n; n=$(cat "$CNT"); n=$((n+1)); echo "$n" >"$CNT"; [ "$n" -ge 2 ]; }
ckis::retry 3 flaky; assert_eq "retry succeeds on 2nd attempt" "0" "$?"

# ── git helpers ──
R="$SANDBOX/repo"; mkdir -p "$R"; git -C "$R" init -q
assert_ok   "is_repo true"            ckis::is_repo "$R"
assert_fail "is_repo false on plain"  ckis::is_repo "$SANDBOX"
echo hi >"$R/f";
ckis::repo_dirty "$R"; assert_eq "repo_dirty detects untracked" "0" "$?"

# is_repo_root: the root is a root; a subdir inside it is NOT
mkdir -p "$R/sub/deep"
assert_ok   "is_repo_root true at root"      ckis::is_repo_root "$R"
assert_fail "is_repo_root false in subdir"   ckis::is_repo_root "$R/sub/deep"
assert_ok   "is_repo true in subdir"         ckis::is_repo "$R/sub/deep"

assert_summary
