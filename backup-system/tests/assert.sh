#!/usr/bin/env bash
# tests/assert.sh — minimal dependency-free assertion library.
# Each test_*.sh sources this, runs assertions, ends with `assert_summary`.

_T_PASS=0; _T_FAIL=0
_t_name() { printf '  %-58s' "$1"; }

assert_eq() { # desc expected actual
  _t_name "$1"
  if [ "$2" = "$3" ]; then echo "PASS"; _T_PASS=$((_T_PASS+1));
  else echo "FAIL (expected='$2' actual='$3')"; _T_FAIL=$((_T_FAIL+1)); fi
}
assert_ok() { # desc cmd...
  local d="$1"; shift; _t_name "$d"
  if "$@" >/dev/null 2>&1; then echo "PASS"; _T_PASS=$((_T_PASS+1));
  else echo "FAIL (rc=$?)"; _T_FAIL=$((_T_FAIL+1)); fi
}
assert_fail() { # desc cmd...   (expects non-zero)
  local d="$1"; shift; _t_name "$d"
  if "$@" >/dev/null 2>&1; then echo "FAIL (expected non-zero)"; _T_FAIL=$((_T_FAIL+1));
  else echo "PASS"; _T_PASS=$((_T_PASS+1)); fi
}
assert_contains() { # desc haystack needle
  _t_name "$1"
  case "$2" in *"$3"*) echo "PASS"; _T_PASS=$((_T_PASS+1));;
                    *) echo "FAIL ('$3' not in output)"; _T_FAIL=$((_T_FAIL+1));; esac
}
assert_file() { # desc path
  _t_name "$1"
  if [ -e "$2" ]; then echo "PASS"; _T_PASS=$((_T_PASS+1));
  else echo "FAIL (missing: $2)"; _T_FAIL=$((_T_FAIL+1)); fi
}
assert_no_file() { # desc path
  _t_name "$1"
  if [ ! -e "$2" ]; then echo "PASS"; _T_PASS=$((_T_PASS+1));
  else echo "FAIL (should not exist: $2)"; _T_FAIL=$((_T_FAIL+1)); fi
}
assert_summary() {
  echo "  ── $_T_PASS passed, $_T_FAIL failed ──"
  [ "$_T_FAIL" -eq 0 ]
}
