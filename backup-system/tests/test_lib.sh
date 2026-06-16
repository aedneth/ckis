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

# ── Shannon entropy (bits/char): real secret vs placeholder/prose ──
# (Use a high-entropy NON-token string so this fixture itself never trips the
#  scanner — the entropy fn is prefix-agnostic, which is exactly the point.)
hi="$(ckis::entropy 'Xk7Qm2Rp9Lw4Ez8Ty1Ui5Io3Nz6Vc0DfHbJg')"
lo="$(ckis::entropy 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')"
assert_ok "entropy: high-entropy string > 3.0" bash -c "awk 'BEGIN{exit !($hi>3.0)}'"
assert_ok "entropy: placeholder < 1.0"       bash -c "awk 'BEGIN{exit !($lo<1.0)}'"
assert_eq "entropy: empty -> 0.00"           "0.00" "$(ckis::entropy '')"

# ── hard-failure markers (drive doctor's FAILED state) ──
ckis::clear_fail "demo"
assert_fail "is_failed false initially"      ckis::is_failed "demo"
ckis::mark_fail "demo" "commit blocked by secret-scan"
assert_ok   "is_failed true after mark"      ckis::is_failed "demo"
assert_contains "fail_reason carries text"   "$(ckis::fail_reason demo)" "secret-scan"
assert_contains "list_fails includes demo"   "$(ckis::list_fails)" "demo"
ckis::clear_fail "demo"
assert_fail "is_failed false after clear"    ckis::is_failed "demo"

# ── brain discovery: registry ∪ filesystem scan (agent-agnostic) ──
BR="$SANDBOX/brains"; mkdir -p "$BR/proj-a/.brain" "$BR/proj-b/.brain"
git -C "$BR/proj-a" init -q; git -C "$BR/proj-b" init -q
cat >"$SANDBOX/reg.json" <<JSON
{ "version":1, "projects":[{"slug":"proj-a","repo_root":"$BR/proj-a"}] }
JSON
out="$(CKIS_REGISTRY="$SANDBOX/reg.json" CKIS_BRAIN_ROOTS="$BR" ckis::brain_repos)"
assert_contains "discovery finds registered repo"   "$out" "proj-a"
assert_contains "discovery finds UNregistered via scan" "$out" "proj-b"
n="$(printf '%s\n' "$out" | grep -c . )"
assert_eq "discovery de-dupes (2 unique repos)" "2" "$n"

assert_summary
