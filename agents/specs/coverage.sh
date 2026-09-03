#!/bin/bash
# Coverage report: cross-references spec YAML entries against scenarios.
#
# Usage: ./agents/specs/coverage.sh [--summary] [--unmapped] [--unsourced] [--package PKG]
#
# Reads all .yaml files in agents/specs/, extracts entries, and reports:
#   - Total entries and how many have scenario references
#   - Entries without scenario refs (the work queue)
#   - Entries without source provenance
#   - Broken scenario refs (fixture file missing)

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

SPEC_DIR="agents/specs"
FIXTURE_DIR="test/fixtures"

show_summary=false
show_unmapped=false
show_unsourced=false
filter_pkg=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary) show_summary=true; shift;;
    --unmapped) show_unmapped=true; shift;;
    --unsourced) show_unsourced=true; shift;;
    --package) filter_pkg="$2"; shift 2;;
    *) echo "Usage: $0 [--summary] [--unmapped] [--unsourced] [--package PKG]"; exit 1;;
  esac
done

if ! command -v python3 &>/dev/null; then
  echo "error: python3 required for YAML parsing" >&2
  exit 1
fi

# Parse all YAML specs and produce a TSV: id \t scenario_count \t scenarios \t source_count \t notes
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
        scenarios = entry.get('scenarios', []) or []
        sc_list = ';'.join(scenarios) if scenarios else '-'
        sources = entry.get('source', []) or []
        src_count = len(sources)
        notes = entry.get('notes', '') or '-'
        notes_clean = notes.replace('\n', ' ').strip()
        print(f'{eid}\t{len(scenarios)}\t{sc_list}\t{src_count}\t{notes_clean}')
" "$SPEC_DIR" "$filter_pkg"
}

specs=$(parse_specs)
if [[ -z "$specs" ]]; then
  echo "No spec entries found in $SPEC_DIR/*.yaml"
  exit 0
fi

total=$(echo "$specs" | wc -l)
with_scenarios=$(echo "$specs" | awk -F'\t' '$2 > 0' | wc -l)
without_scenarios=$(echo "$specs" | awk -F'\t' '$2 == 0' | wc -l)
with_source=$(echo "$specs" | awk -F'\t' '$4 > 0' | wc -l)
without_source=$(echo "$specs" | awk -F'\t' '$4 == 0' | wc -l)

# Verify scenario references point to real fixtures
bad_refs=0
while IFS=$'\t' read -r eid sc_count sc_list src_count notes; do
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
echo "Total entries:       $total"
echo ""
echo "Scenario mapping:    $with_scenarios mapped, $without_scenarios unmapped"
echo "Source provenance:    $with_source sourced, $without_source unsourced"
echo "Broken refs:         $bad_refs"
echo ""

pct_scenario=$( (( total > 0 )) && echo "scale=1; $with_scenarios * 100 / $total" | bc || echo 0)
pct_source=$( (( total > 0 )) && echo "scale=1; $with_source * 100 / $total" | bc || echo 0)
echo "Scenario coverage:   ${pct_scenario}%"
echo "Source coverage:     ${pct_source}%"

if $show_unmapped; then
  echo ""
  echo "═══ Unmapped (no scenario ref) ═══"
  echo ""
  echo "$specs" | awk -F'\t' '$2 == 0 { print "  " $1 }'
fi

if $show_unsourced; then
  echo ""
  echo "═══ Unsourced (no source provenance) ═══"
  echo ""
  echo "$specs" | awk -F'\t' '$4 == 0 { print "  " $1 }'
fi

if ! $show_summary && ! $show_unmapped && ! $show_unsourced; then
  echo ""
  echo "═══ Unmapped entries ═══"
  echo ""
  echo "$specs" | awk -F'\t' '$2 == 0 { print "  " $1 }'
fi
