#!/usr/bin/env bash
# .git/hooks is not version-controlled, so a fresh clone has no hook.
# Run this once after cloning:  scripts/install-hooks.sh
set -euo pipefail
cd "$(dirname "$0")/.."
printf "%s\\n" "#!/usr/bin/env bash" "exec \"\$(git rev-parse --show-toplevel)/scripts/validate-plugins.sh\"" > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "pre-commit hook installed -> scripts/validate-plugins.sh"
