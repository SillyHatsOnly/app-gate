#!/usr/bin/env bash
# Fresh-system installer for app-gate + tg-gate.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"

chmod +x "$ROOT/bin/app-gate" "$ROOT/bin/tg-gate" "$ROOT/install.sh"
mkdir -p "$BIN"

ln -sfn "$ROOT/bin/app-gate" "$BIN/app-gate"
ln -sfn "$ROOT/bin/tg-gate" "$BIN/tg-gate"

echo "Linked:"
echo "  $BIN/app-gate -> $ROOT/bin/app-gate"
echo "  $BIN/tg-gate  -> $ROOT/bin/tg-gate"
echo

if ! echo ":$PATH:" | grep -q ":$BIN:"; then
  echo "WARNING: $BIN is not on PATH."
  echo "Add this to ~/.bashrc (then open a new terminal):"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo
fi

cat <<EOF
Next steps (Telegram / tg-gate):

  1) Install Telegram Flatpak if needed:
       flatpak install flathub org.telegram.desktop

  2) Enable user systemd linger (so the timer runs after login):
       # usually already OK on desktop sessions
       systemctl --user status | head

  3) Install gate (desktop override + minutely timer + config):
       tg-gate install

  4) Lock the config against impulse edits:
       chmod 444 ~/.config/tg-gate/config
       sudo chattr +i ~/.config/tg-gate/config   # optional, stronger

  5) Check:
       tg-gate status

Optional (any other app via generic app-gate):

  app-gate install genymotion --from $ROOT/examples/genymotion.conf
  # edit paths in ~/.config/app-gate/apps/genymotion.conf first

Docs: $ROOT/README.md
EOF
