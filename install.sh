#!/usr/bin/env bash
# Thin helper: link CLI and print next steps.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$ROOT/bin/app-gate"
mkdir -p "$HOME/.local/bin"
ln -sfn "$ROOT/bin/app-gate" "$HOME/.local/bin/app-gate"
echo "Linked: $HOME/.local/bin/app-gate -> $ROOT/bin/app-gate"
echo
echo "Next:"
echo "  app-gate install telegram --from $ROOT/examples/telegram.conf"
echo "  app-gate install genymotion --from $ROOT/examples/genymotion.conf"
echo "  app-gate list"
