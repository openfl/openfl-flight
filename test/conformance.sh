#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

PASS=0
FAIL=0
SKIP=0
RESULTS=()

report() {
  local target=$1 phase=$2 status=$3
  local label="[$target] $phase"
  if [ "$status" = "pass" ]; then
    PASS=$((PASS + 1))
    RESULTS+=("PASS  $label")
  elif [ "$status" = "skip" ]; then
    SKIP=$((SKIP + 1))
    RESULTS+=("SKIP  $label")
  else
    FAIL=$((FAIL + 1))
    RESULTS+=("FAIL  $label")
  fi
}

run_target() {
  local target=$1 hxml=$2 run_cmd=$3

  echo ""
  echo "=== $target: compile ==="
  if haxe "$hxml" 2>&1; then
    report "$target" "compile" "pass"
  else
    report "$target" "compile" "fail"
    return
  fi

  if [ -n "$run_cmd" ]; then
    echo ""
    echo "=== $target: run ==="
    local output
    local exit_code=0
    output=$($run_cmd 2>&1) || exit_code=$?

    echo "$output"

    if [ $exit_code -ne 0 ]; then
      report "$target" "run" "fail"
      echo "  exit code: $exit_code"
    else
      local failures
      failures=$(echo "$output" | grep -c '^FAIL ' || true)
      if [ "$failures" -gt 0 ]; then
        report "$target" "run" "fail"
        echo "  $failures scenario(s) failed"
      else
        report "$target" "run" "pass"
      fi
    fi
  fi
}

mkdir -p build/test

echo "openfl-flight conformance suite"
echo "================================"

# interp: baseline (fast)
echo ""
echo "=== interp: compile + run ==="
interp_exit=0
interp_output=$(haxe test/harness/compare.hxml 2>&1) || interp_exit=$?
echo "$interp_output"
if [ $interp_exit -ne 0 ]; then
  report "interp" "compile+run" "fail"
else
  interp_failures=$(echo "$interp_output" | grep -c '^FAIL ' || true)
  if [ "$interp_failures" -gt 0 ]; then
    report "interp" "compile+run" "fail"
  else
    report "interp" "compile+run" "pass"
  fi
fi

# neko: compile + run
if command -v neko >/dev/null 2>&1; then
  run_target "neko" "test/harness/compare-neko.hxml" "neko build/test/harness-neko.n"
else
  report "neko" "compile+run" "skip"
  echo "neko not found, skipping"
fi

# cpp: compile + run (slow, but catches static type issues)
if command -v g++ >/dev/null 2>&1; then
  run_target "cpp" "test/harness/compare-cpp.hxml" "build/test/harness-cpp/Main"
else
  report "cpp" "compile+run" "skip"
  echo "g++ not found, skipping cpp target"
fi

# js: compile-only (no sys access for fixture comparison)
echo ""
echo "=== js: compile (type-check only) ==="
if haxe test/harness/compare-js.hxml 2>&1; then
  report "js" "compile" "pass"
else
  report "js" "compile" "fail"
fi

# summary
echo ""
echo "================================"
echo "CONFORMANCE SUMMARY"
echo "================================"
for r in "${RESULTS[@]}"; do
  echo "  $r"
done
echo ""
echo "  pass: $PASS  fail: $FAIL  skip: $SKIP"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
