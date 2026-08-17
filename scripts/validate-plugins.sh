#!/usr/bin/env bash
# Validate every plugin before it ships.
#
# Two failures this catches, both of which are silent:
#
#   1. Broken SKILL.md frontmatter. A stray character on the opening `---`
#      ("loo---", 2026-08-17) makes the whole YAML block unparseable, so the
#      skill loses its name and description and simply stops triggering. Nothing
#      errors; it just never fires again.
#   2. Version drift. An update reaches nobody unless `version` changes in BOTH
#      plugin.json and the marketplace.json entry, and the README table is what
#      humans read — career-companion sat at "1.2.4 / five tools / 35,000+ jobs"
#      for two releases after none of that was true.
#
# Run directly, or let .git/hooks/pre-commit run it:
#   scripts/validate-plugins.sh
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

fail=0
note() { printf '  %s\n' "$1"; }

# --- 1. claude plugin validate, when the CLI is around -----------------------
if command -v claude >/dev/null 2>&1; then
  for dir in plugins/*/; do
    name=$(basename "$dir")
    out=$(claude plugin validate --strict "$dir" 2>&1)
    if printf '%s' "$out" | grep -q 'Validation passed'; then
      note "✔ $name — manifest + skills valid"
    else
      note "✘ $name — validation failed:"
      printf '%s\n' "$out" | grep -E '❯|Found' | sed 's/^/      /'
      fail=1
    fi
  done
else
  note "· claude CLI not found — skipping manifest validation"
fi

# --- 2. structural frontmatter check (works without the CLI) -----------------
while IFS= read -r skill; do
  first=$(head -1 "$skill")
  if [ "$first" != "---" ]; then
    note "✘ ${skill}: line 1 is '${first}', expected '---' (frontmatter unparseable)"
    fail=1
  fi
  for key in name description; do
    grep -qE "^${key}:" "$skill" || { note "✘ ${skill}: missing '${key}:'"; fail=1; }
  done
done < <(find plugins -name SKILL.md -not -path '*/node_modules/*')

# --- 3. version agreement: plugin.json vs marketplace.json vs README ---------
python3 - <<'PY' || fail=1
import json, re, sys
from pathlib import Path

market = {p["name"]: p.get("version")
          for p in json.loads(Path(".claude-plugin/marketplace.json").read_text())["plugins"]}
readme = Path("README.md").read_text()
bad = False

for manifest in sorted(Path("plugins").glob("*/.claude-plugin/plugin.json")):
    m = json.loads(manifest.read_text())
    name, ver = m["name"], m["version"]
    if market.get(name) != ver:
        print(f"  ✘ {name}: plugin.json {ver} != marketplace.json {market.get(name)}")
        bad = True
    row = re.search(r"\|\s*\[" + re.escape(name) + r"\]\([^)]*\)\s*\|\s*([0-9][0-9.]*)\s*\|", readme)
    if row and row.group(1) != ver:
        print(f"  ✘ {name}: README table says {row.group(1)}, plugin.json says {ver}")
        bad = True
    if not bad:
        print(f"  ✔ {name} {ver} — plugin.json, marketplace.json and README agree")

sys.exit(1 if bad else 0)
PY

if [ "$fail" -ne 0 ]; then
  echo
  echo "Plugin validation failed — commit aborted."
  exit 1
fi
echo "All plugins valid."
