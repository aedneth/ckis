#!/usr/bin/env bash
# Contract for bin/ckis-apparatus-export.sh — the secret-safety is critical.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/assert.sh"
EXP="$ROOT/bin/ckis-apparatus-export.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export CKIS_LOG_DIR="$SB/state"; mkdir -p "$CKIS_LOG_DIR"

# fake ~/.claude
SRC="$SB/dotclaude"; mkdir -p "$SRC"/{skills/foo,agents,cache,session-env/x,projects/proj-a/memory,projects/proj-a/logs}
echo "global instr"     >"$SRC/CLAUDE.md"
echo "{}"               >"$SRC/settings.json"
echo "skill"            >"$SRC/skills/foo/SKILL.md"
echo "TOKEN-LEAK"       >"$SRC/.credentials.json"      # MUST NOT be exported
echo "junk"             >"$SRC/cache/blob"             # denied
echo "envblob"          >"$SRC/session-env/x/e"        # denied
echo "remember this"    >"$SRC/projects/proj-a/memory/MEMORY.md"  # memory -> keep
echo "transcript"       >"$SRC/projects/proj-a/logs/t.jsonl"      # projects (non-memory) -> drop

cat >"$SB/m.json" <<JSON
{ "log_dir":"$CKIS_LOG_DIR",
  "apparatus":{ "source":"$SRC", "dest":"apparatus",
    "allow":["CLAUDE.md","settings.json","skills","agents"],
    "memory_glob":"projects/*/memory",
    "deny":[".credentials.json","cache","session-env","projects","history.jsonl"] } }
JSON
export CKIS_MANIFEST="$SB/m.json"

DEST="$SB/out"
assert_ok      "export exits 0"                bash "$EXP" "$DEST"
assert_file    "CLAUDE.md exported"            "$DEST/CLAUDE.md"
assert_file    "settings.json exported"        "$DEST/settings.json"
assert_file    "skills tree exported"          "$DEST/skills/foo/SKILL.md"
assert_file    "auto-memory exported"          "$DEST/projects/proj-a/memory/MEMORY.md"
# the critical safety assertions:
assert_no_file "credentials NEVER exported"    "$DEST/.credentials.json"
assert_no_file "cache (denied) not exported"   "$DEST/cache"
assert_no_file "session-env (denied) excluded" "$DEST/session-env"
assert_no_file "non-memory project logs dropped" "$DEST/projects/proj-a/logs"

# defense-in-depth: a credentials file nested under an allowed tree is purged
mkdir -p "$SRC/skills/bad"; echo "leak" >"$SRC/skills/bad/.credentials.json"
bash "$EXP" "$DEST" >/dev/null 2>&1
assert_no_file "nested credential purged"      "$DEST/skills/bad/.credentials.json"

assert_summary
