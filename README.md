# App Gate

Schedule-gated launcher for Linux desktop apps.

You choose **when** an app is allowed to run. Outside those windows the menu
launcher refuses to start it, and a per-minute systemd user timer closes it if
it is already running. Optional PIN-protected **unlock** gives temporary access
that always ends with a forced close.

Built as a small pet project after living with Telegram / Genymotion addiction
loops on a long computer workday.

## Features

- Per-app config files (any binary or Flatpak)
- Time windows (`HH:MM-HH:MM`, comma-separated, midnight wrap supported)
- Emergency unlock with optional PIN (expires → process is killed even if a
  schedule window is still open)
- Desktop entry override + `systemd --user` timer (`OnCalendar=minutely`)
- Example profiles for Telegram (Flatpak) and Genymotion (native)

## Requirements

- Linux with `bash`, `systemd --user`
- Optional: `notify-send`, `zenity` (nicer prompts)
- Flatpak apps: `flatpak` CLI

## Quick start

```bash
git clone https://github.com/YOUR_USER/app-gate.git
cd app-gate
chmod +x bin/app-gate

# Install an example (copies config, desktop entry, timer)
./bin/app-gate install telegram --from examples/telegram.conf

# Edit windows / PIN / paths
app-gate telegram edit

# Check state
app-gate telegram status
app-gate list
```

After install, the CLI is linked to `~/.local/bin/app-gate` (ensure that
directory is on your `PATH`).

## Commands

```text
app-gate <app-id> status
app-gate <app-id> open [--] [args...]
app-gate <app-id> enforce          # used by the timer
app-gate <app-id> unlock [minutes] # default 15; requires UNLOCK_PIN if set
app-gate <app-id> lock
app-gate <app-id> edit

app-gate install <app-id> [--from PATH]
app-gate uninstall <app-id>
app-gate list
```

## Config reference

Configs live in:

```text
~/.config/app-gate/apps/<app-id>.conf
```

| Variable | Meaning |
|----------|---------|
| `APP_NAME` | Label in notifications / menu |
| `WINDOWS` | Allowed ranges, e.g. `12:30-12:45,19:00-19:30` (end exclusive) |
| `UNLOCK_PIN` | PIN for unlock; empty = no PIN |
| `LAUNCH_MODE` | `command` or `flatpak` |
| `LAUNCH_CMD` | Full command when `LAUNCH_MODE=command` |
| `FLATPAK_ID` | Flatpak app id |
| `FLATPAK_ARGS` | Extra args for `flatpak run` |
| `STOP_CMD` | Optional graceful stop before kill |
| `PROCESS_PATTERNS` | Comma-separated cmdline substrings for detect/kill |
| `DESKTOP_*` | Menu entry filename, icon, categories, WM class |

See `examples/generic.conf` for a filled template with comments.

### Window semantics

- Format: `start-end` in 24-hour `HH:MM`
- End is **exclusive**: `16:00-16:15` means until `16:14`
- Crossing midnight: `23:00-00:30`

### Unlock vs schedule

| Situation | Behavior |
|-----------|----------|
| Inside `WINDOWS` | App may run |
| Active unlock | App may run |
| Unlock expires | App is **always** closed (even mid-schedule) |
| Outside windows, no unlock | Launch blocked; timer kills leftovers |

## How it works

```text
Menu click ──► app-gate <id> open ──► allow? ──► start app
                                   └─ no ──► notify / zenity

systemd timer (every minute)
        └── app-gate <id> enforce
                ├─ unlock expired? → kill
                ├─ in schedule?    → keep
                └─ else running?   → kill
```

This is **friction**, not a security boundary. A determined user can stop the
timer, edit the config, or launch the binary directly — the goal is to break
impulse opens.

## Examples

### Telegram (Flatpak)

```bash
./bin/app-gate install telegram --from examples/telegram.conf
app-gate telegram edit   # set WINDOWS + UNLOCK_PIN
```

The install writes `~/.local/share/applications/org.telegram.desktop.desktop`
so the normal Telegram menu entry goes through the gate.

### Genymotion

```bash
# Edit paths in the example first (replace /home/YOU/...)
./bin/app-gate install genymotion --from examples/genymotion.conf
```

Uses `gmtool admin stopall` via `STOP_CMD`, then pattern kills for player/qemu.

### Any other app

```bash
cp examples/generic.conf ~/.config/app-gate/apps/spotify.conf
# fill LAUNCH_CMD / PROCESS_PATTERNS / WINDOWS
./bin/app-gate install spotify
```

## Uninstall one app

```bash
app-gate uninstall telegram
```

Removes the timer and desktop override; keeps the config file.

## Project layout

```text
bin/app-gate              # main CLI
examples/                 # ready-made configs
  generic.conf
  telegram.conf
  genymotion.conf
systemd/                  # documented unit templates
LICENSE
README.md
```

## License

MIT — see [LICENSE](LICENSE).
