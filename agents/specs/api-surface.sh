#!/bin/bash
# API surface check: cross-references OpenFL 9.5.2 public members against spec source: fields.
#
# Usage: ./agents/specs/api-surface.sh [--uncovered] [--stale] [--package PKG]
#
# Extracts public class members from OpenFL 9.5.2 source, then:
#   --uncovered: lists public members with no spec entry pointing at them
#   --stale: lists spec source: refs that don't match any OpenFL source member
#   (default): prints both reports
#
# Requires: python3, PyYAML, and OpenFL 9.5.2 installed via haxelib.

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

SPEC_DIR="agents/specs"
OPENFL_SRC=""

# Find OpenFL source
for candidate in \
  /home/agent/.haxelib/openfl/9,5,2/src/openfl \
  "$(haxelib path openfl 2>/dev/null | head -1)openfl" \
  ; do
  if [[ -d "$candidate" ]]; then
    OPENFL_SRC="$candidate"
    break
  fi
done

if [[ -z "$OPENFL_SRC" ]]; then
  echo "error: OpenFL 9.5.2 source not found. Install via: haxelib install openfl 9.5.2" >&2
  exit 1
fi

show_uncovered=false
show_stale=false
filter_pkg=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uncovered) show_uncovered=true; shift;;
    --stale) show_stale=true; shift;;
    --package) filter_pkg="$2"; shift 2;;
    *) echo "Usage: $0 [--uncovered] [--stale] [--package PKG]"; exit 1;;
  esac
done

# If neither flag, show both
if ! $show_uncovered && ! $show_stale; then
  show_uncovered=true
  show_stale=true
fi

if ! command -v python3 &>/dev/null; then
  echo "error: python3 required" >&2
  exit 1
fi

python3 -c "
import yaml, sys, os, glob, re

openfl_src = sys.argv[1]
spec_dir = sys.argv[2]
filter_pkg = sys.argv[3] if len(sys.argv) > 3 else ''
do_uncovered = sys.argv[4] == '1'
do_stale = sys.argv[5] == '1'

# Step 1: Extract public members from OpenFL source
# Pattern: public var/function/property declarations
member_re = re.compile(
    r'^\s*(?:@:\w+\s+)*'           # optional metadata
    r'(?:override\s+)?'             # optional override
    r'public\s+'                    # public keyword
    r'(?:static\s+)?'              # optional static
    r'(?:inline\s+)?'              # optional inline
    r'(?:var|function|final)\s+'   # member kind
    r'(\w+)',                       # member name
    re.MULTILINE
)

# Also match public properties: public var name(get,set)
prop_re = re.compile(
    r'^\s*(?:@:\w+\s+)*'
    r'(?:override\s+)?'
    r'public\s+'
    r'(?:var|final)\s+'
    r'(\w+)\s*\(',
    re.MULTILINE
)

# Package directories to scan
pkg_dirs = {
    'events': 'events', 'display': 'display', 'display3d': 'display3D',
    'desktop': 'desktop', 'geom': 'geom', 'filters': 'filters',
    'ui': 'ui', 'text': 'text', 'media': 'media', 'net': 'net',
    'utils': 'utils', 'system': 'system', 'external': 'external',
    'filesystem': 'filesystem', 'printing': 'printing',
    'profiler': 'profiler', 'sensors': 'sensors', 'security': 'security',
    'globalization': 'globalization', 'permissions': 'permissions',
    'errors': 'errors',
}

public_members = {}  # 'relative/path.hx:member' -> True

for pkg_name, pkg_subdir in sorted(pkg_dirs.items()):
    if filter_pkg and pkg_name != filter_pkg:
        continue
    pkg_path = os.path.join(openfl_src, pkg_subdir)
    if not os.path.isdir(pkg_path):
        continue
    for root, dirs, files in os.walk(pkg_path):
        # Skip _internal directories
        dirs[:] = [d for d in dirs if d != '_internal']
        for fname in sorted(files):
            if not fname.endswith('.hx'):
                continue
            fpath = os.path.join(root, fname)
            rel = os.path.relpath(fpath, openfl_src)
            with open(fpath) as f:
                content = f.read()
            for m in member_re.finditer(content):
                name = m.group(1)
                if name.startswith('__') or name.startswith('_'):
                    continue
                key = f'{rel}:{name}'
                public_members[key] = True

# Step 2: Collect source refs from specs
spec_sources = {}  # 'relative/path.hx:member' -> [entry_id, ...]

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
        sources = entry.get('source', []) or []
        for src in sources:
            spec_sources.setdefault(src, []).append(eid)

# Step 3: Report
if do_uncovered:
    uncovered = [k for k in sorted(public_members) if k not in spec_sources]
    print(f'=== Uncovered public members: {len(uncovered)} of {len(public_members)} ===')
    print()
    for k in uncovered:
        print(f'  {k}')
    print()

if do_stale:
    stale = [k for k in sorted(spec_sources) if k not in public_members]
    print(f'=== Stale source refs: {len(stale)} ===')
    print()
    for k in stale:
        ids = ', '.join(spec_sources[k])
        print(f'  {k}  (referenced by: {ids})')
    print()

# Summary
covered_count = len([k for k in public_members if k in spec_sources])
print(f'Public members: {len(public_members)}')
print(f'Covered by spec: {covered_count}')
print(f'Uncovered: {len(public_members) - covered_count}')
print(f'Stale refs: {len([k for k in spec_sources if k not in public_members])}')
" "$OPENFL_SRC" "$SPEC_DIR" "$filter_pkg" \
  "$($show_uncovered && echo 1 || echo 0)" \
  "$($show_stale && echo 1 || echo 0)"
