#!/bin/bash
# Coverage report: cross-references spec YAML entries against scenarios.
#
# Usage: ./agents/specs/coverage.sh [--summary] [--missing] [--package PKG]
#
# Reads all .yaml files in agents/specs/, extracts entries, and reports:
#   - Total entries per status (covered/missing/flight-gap/deviation)
#   - Entries with scenario references vs. without
#   - Missing entries with no scenario (the work queue)

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

SPEC_DIR="agents/specs"
FIXTURE_DIR="test/fixtures"

show_summary=false
show_missing=false
filter_pkg=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary) show_summary=true; shift;;
    --missing) show_missing=true; shift;;
    --package) filter_pkg="$2"; shift 2;;
    *) echo "Usage: $0 [--summary] [--missing] [--package PKG]"; exit 1;;
  esac
done

if ! command -v python3 &>/dev/null; then
  echo "error: python3 required for YAML parsing" >&2
  exit 1
fi

# Parse all YAML specs and produce a TSV: id \t status \t gap \t scenario_count \t scenarios
parse_specs() {
  python3 -c "
import yaml, sys, os, glob

spec_dir = sys.argv[1]
filter_pkg = sys.argv[2] if len(sys.argv) > 2 else ''

for path in sorted(glob.glob(os.path.join(spec_dir, '*.yaml'))):
    with open(path) as f:
        doc = yaml.safe_load(f)
    if not doc or 'entries' not in doc:
        continue
    pkg = doc.get('package', os.path.basename(path).replace('.yaml', ''))
    if filter_pkg and pkg != filter_pkg:
        continue
    for entry in doc['entries']:
        eid = entry.get('id', '?')
        status = entry.get('status', '?')
        gap = entry.get('gap', '') or '-'
        scenarios = entry.get('scenarios', []) or []
        sc_list = ';'.join(scenarios) if scenarios else '-'
        notes = entry.get('notes', '') or '-'
        notes_clean = notes.replace('\n', ' ').strip()
        print(f'{eid}\t{status}\t{gap}\t{len(scenarios)}\t{sc_list}\t{notes_clean}')
" "$SPEC_DIR" "$filter_pkg"
}

specs=$(parse_specs)
if [[ -z "$specs" ]]; then
  echo "No spec entries found in $SPEC_DIR/*.yaml"
  exit 0
fi

total=$(echo "$specs" | wc -l)
covered=$(echo "$specs" | grep -c $'\tcovered\t' || true)
missing=$(echo "$specs" | grep -c $'\tmissing\t' || true)
flight_gap=$(echo "$specs" | grep -c $'\tflight-gap\t' || true)
deviation=$(echo "$specs" | grep -c $'\tdeviation\t' || true)

with_scenarios=$(echo "$specs" | awk -F'\t' '$4 > 0' | wc -l)
without_scenarios=$(echo "$specs" | awk -F'\t' '$4 == 0' | wc -l)

# Verify scenario references point to real fixtures
bad_refs=0
while IFS=$'\t' read -r eid status gap sc_count sc_list notes; do
  if [[ -n "$sc_list" && "$sc_list" != "-" ]]; then
    IFS=';' read -ra refs <<< "$sc_list"
    for ref in "${refs[@]}"; do
      fixture_path="${ref%%:*}"
      if [[ ! -f "$FIXTURE_DIR/${fixture_path}.json" ]]; then
        if ! $show_summary; then
          echo "BROKEN REF: $eid → $ref (no fixture at $FIXTURE_DIR/${fixture_path}.json)"
        fi
        ((bad_refs++)) || true
      fi
    done
  fi
done <<< "$specs"

echo "═══ Coverage Report ═══"
echo ""
echo "Total entries:     $total"
echo "  covered:         $covered"
echo "  missing:         $missing"
echo "  flight-gap:      $flight_gap"
echo "  deviation:       $deviation"
echo ""
echo "Scenario coverage: $with_scenarios with refs, $without_scenarios without"
echo "Broken refs:       $bad_refs"
echo ""

pct_covered=$( (( total > 0 )) && echo "scale=1; $covered * 100 / $total" | bc || echo 0)
pct_scenario=$( (( total > 0 )) && echo "scale=1; $with_scenarios * 100 / $total" | bc || echo 0)
echo "Implementation:    ${pct_covered}% covered"
echo "Scenario coverage: ${pct_scenario}% with scenario refs"

if $show_missing; then
  echo ""
  echo "═══ Missing (work queue) ═══"
  echo ""
  echo "$specs" | awk -F'\t' '$2 == "missing" { printf "  [ ] %s\n", $1 }'
  echo ""
  echo "═══ Flight gaps ═══"
  echo ""
  echo "$specs" | awk -F'\t' '$2 == "flight-gap" { gap = ($3 == "-" ? "" : $3); printf "  [!] %s — %s\n", $1, gap }'
fi

if ! $show_summary && ! $show_missing; then
  echo ""
  echo "═══ Entries without scenario references ═══"
  echo ""
  echo "$specs" | awk -F'\t' '$4 == 0 { printf "  %-50s %s\n", $1, $2 }'
fi
