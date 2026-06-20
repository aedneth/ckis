#!/usr/bin/env bash
# Contract for bin/ckis-reflux-all.sh — the autonomous context-maintenance engine.
# The load-bearing guarantee under test: the structural guards reject any unsafe
# proposal, and the propose path NEVER touches the live heart doc. No claude -p
# is invoked (a stub model is used) so the test is fast and deterministic.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"

SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# Source the engine for its functions only (sourcing guard prevents _run).
export CKIS_MANIFEST="$ROOT/ckis-manifest.json"   # real manifest for SCAN path etc.
source "$ROOT/bin/ckis-reflux-all.sh"

# ── a synthetic "live" heart doc ─────────────────────────────────────────────
LIVE="$SB/_MEMORY.md"
cat >"$LIVE" <<'EOF'
---
type: capture
created: 2026-04-07
modified: 2026-05-22
tags: [memory]
status: active
---

# Live Business State

## Project Alpha
- Stage: launched
- Client: Acme Corp

## Blockers
- none

## Focus
- ship the reflux engine
EOF
LIVE_LINES=$(wc -l < "$LIVE")

# helper: clone live, run a mutator, return the proposal path
_mk() { local p="$SB/prop.md"; cp "$LIVE" "$p"; "$@" "$p"; printf '%s' "$p"; }

# ── Guard tests (max_lines=150, min_pct=70) ──────────────────────────────────

# 1. a faithful proposal (created same, all headings, modified bumped) → PASS
good="$SB/good.md"; cp "$LIVE" "$good"; sed -i 's/^modified:.*/modified: 2026-06-19/' "$good"
assert_ok   "good proposal passes all guards"        _guards "$LIVE" "$good" 150 70

# 2. changed `created` → REJECT
badc="$SB/badc.md"; cp "$good" "$badc"; sed -i 's/^created:.*/created: 2026-01-01/' "$badc"
assert_fail "changed created is rejected"            _guards "$LIVE" "$badc" 150 70

# 3. dropped a `##` heading → REJECT
badh="$SB/badh.md"; grep -v '^## Blockers' "$good" >"$badh"
assert_fail "dropped section heading is rejected"    _guards "$LIVE" "$badh" 150 70

# 4. shrunk below 70% of live → REJECT
bads="$SB/bads.md"; head -4 "$good" >"$bads"   # only frontmatter-ish, way under 70%
assert_fail "shrink below 70% is rejected"          _guards "$LIVE" "$bads" 150 70

# 5. over max_lines (cap=10) → REJECT  (good doc is >10 lines)
assert_fail "over max_lines is rejected"            _guards "$LIVE" "$good" 10 70

# 6. contains a real secret → REJECT
badk="$SB/badk.md"; cp "$good" "$badk"
printf '\n- token: ghp_%s\n' "aB3dE6gH9jK2mN5pQ8rS1tU4vW7xY0zA3bC6" >>"$badk"  # ckis-allow-secret (test fixture)
assert_fail "secret material is rejected"           _guards "$LIVE" "$badk" 150 70

# 7. duplicate-heading drop (multiset, not set) → REJECT
#    live with two identical headings; proposal keeps only one instance.
dlive="$SB/dlive.md"; { cat "$good"; printf '\n## Notes\n- a\n\n## Notes\n- b\n'; } >"$dlive"
ddrop="$SB/ddrop.md"; { cat "$good"; printf '\n## Notes\n- a\n'; } >"$ddrop"   # one '## Notes' dropped
assert_fail "dropping one of two identical headings is rejected" _guards "$dlive" "$ddrop" 150 70

# 8. secret scanner MISSING → FAIL-CLOSED (reject, never silently skip)
_SCAN_REAL="$SCAN"; SCAN="$SB/nonexistent-scanner.sh"
assert_fail "missing secret scanner fails closed"   _guards "$LIVE" "$good" 150 70
SCAN="$_SCAN_REAL"

# ── Propose path: quarantine + live untouched (stub model, no claude -p) ──────
# Fixture manifest: vault=$SB, model_cmd=a stub that emits a faithful proposal.
STUB="$SB/stub-model.sh"
cat >"$STUB" <<EOF
#!/usr/bin/env bash
# ignores the prompt arg; emits a faithful update of the live doc
sed 's/^modified:.*/modified: 2026-06-19/' "$LIVE"
EOF
chmod +x "$STUB"

mkdir -p "$SB/00-inbox"
cp "$LIVE" "$SB/00-inbox/_MEMORY.md"
LIVE_VAULT="$SB/00-inbox/_MEMORY.md"
git init -q "$SB" 2>/dev/null || true   # _build_digest tolerates non-repo, but be safe

cat >"$SB/m.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "reflux": {
    "vault": "$SB",
    "queue_subdir": "00-inbox/_REFLUX-QUEUE",
    "model_cmd": "$STUB",
    "min_retain_pct": 70,
    "sources": { "session_logs": "01-daily/logs", "recent_days": 21 },
    "docs": [ { "slug":"memory", "path":"00-inbox/_MEMORY.md", "max_lines":150, "cadence":"daily", "auto_apply":false } ]
  } }
JSON

before="$(md5sum "$LIVE_VAULT" | awk '{print $1}')"
digest="$SB/digest.txt"; echo "## test digest" >"$digest"
CKIS_MANIFEST="$SB/m.json" _propose_doc "memory" "00-inbox/_MEMORY.md" 150 "$digest" >/dev/null
after="$(md5sum "$LIVE_VAULT" | awk '{print $1}')"

assert_eq   "live heart doc UNTOUCHED by propose"   "$before" "$after"
qf="$(ls "$SB/00-inbox/_REFLUX-QUEUE/"memory-*.md 2>/dev/null | head -1)"
assert_file "proposal queued to quarantine"         "$qf"
assert_contains "queue file carries the PROPOSAL marker" "$(cat "$qf" 2>/dev/null)" "---PROPOSAL---"
assert_contains "queue file shows a diff"                "$(cat "$qf" 2>/dev/null)" "modified: 2026-06-19"

# ── Regression: the model call must NOT eat the doc-loop's stdin ─────────────
# `claude -p` reads stdin; the propose loop is fed by process substitution. If the
# model call doesn't redirect stdin from /dev/null it swallows the loop's stream
# and only the FIRST doc is processed. Reproduce with a stub that CONSUMES stdin.
STUB2="$SB/stub-eats-stdin.sh"
cat >"$STUB2" <<EOF
#!/usr/bin/env bash
cat >/dev/null 2>&1   # consume all stdin, like claude -p does
sed 's/^modified:.*/modified: 2026-06-19/' "$SB/00-inbox/\$REFLUX_DOC"
EOF
chmod +x "$STUB2"
cp "$LIVE" "$SB/00-inbox/_A.md"; cp "$LIVE" "$SB/00-inbox/_B.md"
# the stub needs to know which doc; simplest: emit a generic valid update of LIVE
cat >"$STUB2" <<EOF
#!/usr/bin/env bash
cat >/dev/null 2>&1   # consume all stdin, exactly like claude -p
sed 's/^modified:.*/modified: 2026-06-19/' "$LIVE"
EOF
chmod +x "$STUB2"
cat >"$SB/m2.json" <<JSON
{ "github_owner":"aedneth", "log_dir":"$CKIS_LOG_DIR",
  "reflux": {
    "vault": "$SB", "queue_subdir": "00-inbox/_REFLUX-QUEUE2", "model_cmd": "$STUB2",
    "min_retain_pct": 70, "sources": { "session_logs": "01-daily/logs", "recent_days": 21 },
    "docs": [
      { "slug":"a", "path":"00-inbox/_A.md", "max_lines":150, "cadence":"daily", "auto_apply":false },
      { "slug":"b", "path":"00-inbox/_B.md", "max_lines":150, "cadence":"daily", "auto_apply":false } ]
  } }
JSON
( export CKIS_MANIFEST="$SB/m2.json"; _run --digest "$digest" >/dev/null 2>&1 )
n_q2=$(ls "$SB/00-inbox/_REFLUX-QUEUE2/" 2>/dev/null | wc -l | tr -d ' ')
assert_eq   "stdin-eating model still processes ALL docs (not just 1)" "2" "$n_q2"

# ── Apply path: promotes the reviewed proposal to live (guards re-checked) ────
CKIS_MANIFEST="$SB/m.json" _apply "$qf" >/dev/null 2>&1
applied="$(grep -c '^modified: 2026-06-19' "$LIVE_VAULT")"
assert_eq   "apply promotes proposal to live"       "1" "$applied"

assert_summary
