#!/usr/bin/env bash
# tests/run.sh — run all test_*.sh in this dir, plus syntax-check every shipped
# script. The green gate for each stage.  Usage: bash tests/run.sh
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
fail=0

echo "════════ syntax check (bash -n) ════════"
while IFS= read -r f; do
  if bash -n "$f" 2>/tmp/ckis_syn.$$; then printf '  ok    %s\n' "${f#$ROOT/}"
  else printf '  SYNTAX %s\n' "${f#$ROOT/}"; cat /tmp/ckis_syn.$$; fail=1; fi
done < <(find "$ROOT/bin" "$ROOT/lib" "$ROOT/hooks" -name '*.sh' 2>/dev/null | sort)
rm -f /tmp/ckis_syn.$$

# Optional shellcheck if present (non-fatal warnings, fatal errors).
if command -v shellcheck >/dev/null 2>&1; then
  echo "════════ shellcheck ════════"
  find "$ROOT/bin" "$ROOT/lib" "$ROOT/hooks" -name '*.sh' 2>/dev/null \
    | xargs shellcheck -S error 2>&1 | sed 's/^/  /' || fail=1
fi

echo "════════ unit / behavior tests ════════"
for t in "$HERE"/test_*.sh; do
  [ -e "$t" ] || continue
  echo "▶ $(basename "$t")"
  if bash "$t"; then :; else fail=1; fi
done

echo "════════════════════════════════════════"
if [ "$fail" -eq 0 ]; then echo "GATE: ✅ GREEN"; else echo "GATE: ❌ RED"; fi
exit $fail
