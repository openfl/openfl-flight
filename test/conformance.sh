#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SAMPLES_DIR="$REPO_ROOT/test/openfl-samples"
TARGETS="${1:-neko cpp html5}"

PASS=0
FAIL=0
XFAIL=0
SKIP=0
RESULTS=()

# Known failures external to openfl-flight (not regressions)
KNOWN_FAILURES=(
  "demos/NyanCat"                    # needs swf haxelib
  "features/display/CustomRendering" # accesses OpenFL internal __textureID
  "features/ui/JoystickInput"        # lime.ui.Joystick.onTrackballMove missing in lime 8.3.2
)

is_known_failure() {
  local name=$1
  for kf in "${KNOWN_FAILURES[@]}"; do
    if [ "$name" = "$kf" ]; then return 0; fi
  done
  return 1
}

report() {
  local label=$1 status=$2
  if [ "$status" = "pass" ]; then
    PASS=$((PASS + 1))
    RESULTS+=("PASS  $label")
  elif [ "$status" = "skip" ]; then
    SKIP=$((SKIP + 1))
    RESULTS+=("SKIP  $label")
  elif [ "$status" = "xfail" ]; then
    XFAIL=$((XFAIL + 1))
    RESULTS+=("XFAIL $label")
  else
    FAIL=$((FAIL + 1))
    RESULTS+=("FAIL  $label")
  fi
}

if [ ! -d "$SAMPLES_DIR" ]; then
  echo "Cloning openfl-samples..."
  git clone --depth 1 https://github.com/openfl/openfl-samples.git "$SAMPLES_DIR"
fi

# Collect sample directories (skip libraries/ which need extra haxelibs)
SAMPLE_DIRS=()
while IFS= read -r project; do
  dir=$(dirname "$project")
  case "$dir" in
    */libraries/*) continue ;;
  esac
  SAMPLE_DIRS+=("$dir")
done < <(find "$SAMPLES_DIR" -name "project.xml" -not -path "*/Export/*" | sort)

echo "openfl-flight conformance suite"
echo "================================"
echo "samples: ${#SAMPLE_DIRS[@]}"
echo "targets: $TARGETS"
echo ""

for target in $TARGETS; do
  echo ""
  echo "======== target: $target ========"

  for dir in "${SAMPLE_DIRS[@]}"; do
    name="${dir#$SAMPLES_DIR/}"
    label="[$target] $name"

    # Check for extra haxelib deps we might not have
    if grep -q 'haxelib name="actuate"' "$dir/project.xml" 2>/dev/null ||
       grep -q 'haxelib name="box2d"' "$dir/project.xml" 2>/dev/null ||
       grep -q 'haxelib name="layout"' "$dir/project.xml" 2>/dev/null; then
      report "$label" "skip"
      continue
    fi

    printf "  %-50s " "$name"

    output=$(cd "$dir" && haxelib run lime build "$target" \
      --haxelib-openfl="$REPO_ROOT" 2>&1) || true
    exit_code=${PIPESTATUS[0]:-$?}

    # Check for compilation errors in the output
    if echo "$output" | grep -qE '^Error:|^[^ ]+\.hx:[0-9]+: characters [0-9]'; then
      if is_known_failure "$name"; then
        report "$label" "xfail"
        echo "XFAIL (known)"
      else
        report "$label" "fail"
        echo "FAIL"
        echo "$output" | grep -E '^Error:|^[^ ]+\.hx:[0-9]+: characters [0-9]' | head -3 | sed 's/^/    /'
      fi
    else
      report "$label" "pass"
      echo "PASS"
    fi
  done
done

echo ""
echo "================================"
echo "CONFORMANCE SUMMARY"
echo "================================"
for r in "${RESULTS[@]}"; do
  echo "  $r"
done
echo ""
echo "  pass: $PASS  fail: $FAIL  xfail: $XFAIL  skip: $SKIP"
echo ""

if [ $FAIL -gt 0 ]; then
  exit 1
fi
