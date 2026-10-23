#!/bin/bash
# Lets `uv run collect.py` work in Claude Code cloud sessions. The container
# ships one Chromium build in /opt/pw-browsers, which may not be the build the
# pinned Playwright expects; expose it under the expected names.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"
INSTALLED=/opt/pw-browsers
COMPAT="$HOME/.cache/pw-browsers-compat"
PLAYWRIGHT_PIN=$(grep -oE '"playwright==[0-9.]+"' collect.py | tr -d '"')

uv run --quiet --no-project --with "$PLAYWRIGHT_PIN" python - "$INSTALLED" "$COMPAT" <<'PY'
import json, pathlib, sys
import playwright

installed, compat = map(pathlib.Path, sys.argv[1:])
compat.mkdir(parents=True, exist_ok=True)
for entry in installed.iterdir():
    link = compat / entry.name
    if not link.exists():
        link.symlink_to(entry)

browsers = json.loads((pathlib.Path(playwright.__file__).parent / "driver/package/browsers.json").read_text())
for browser in browsers["browsers"]:
    name = browser["name"].replace("-", "_")
    wanted = compat / f"{name}-{browser['revision']}"
    available = sorted(installed.glob(f"{name}-*"))
    if not wanted.exists() and available:
        wanted.symlink_to(available[-1])
PY

echo "export PLAYWRIGHT_BROWSERS_PATH=\"$COMPAT\"" >> "$CLAUDE_ENV_FILE"
