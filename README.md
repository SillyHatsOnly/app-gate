# App Gate

Schedule-gated launchers for Linux desktop apps — friction against impulse
opens (Telegram, emulators, etc.).

This repo contains:

| Tool | Role |
|------|------|
| **`tg-gate`** | Opinionated Telegram gate: weekday/weekend modes, delayed unlock, daily budget, cooldown |
| **`app-gate`** | Generic multi-app gate: simple `WINDOWS` + optional unlock per app |

Built as a pet project after a long workday + Telegram/Instagram loop.

> This is **friction**, not security. You can always stop the timer or run
> binaries by hand. The goal is to break the reflex, not to win against yourself
> with rootkits.

## Requirements

- Linux (`bash`, `systemd --user`)
- `~/.local/bin` on your `PATH`
- Optional: `notify-send`, `zenity`
- For Telegram: Flatpak (`org.telegram.desktop`)

---

## Install on a new machine

### 1. Clone and link CLIs

```bash
git clone https://github.com/SillyHatsOnly/app-gate.git
cd app-gate
./install.sh
```

This symlinks:

- `~/.local/bin/app-gate`
- `~/.local/bin/tg-gate`

If `~/.local/bin` is missing from `PATH`, add to `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then open a new terminal.

### 2. Telegram (recommended path: `tg-gate`)

```bash
# Install Telegram if needed
flatpak install -y flathub org.telegram.desktop

# Desktop entry + minutely enforce timer + default config
tg-gate install

# Lock config against impulse edits
chmod 444 ~/.config/tg-gate/config
sudo chattr +i ~/.config/tg-gate/config   # optional but recommended

tg-gate status
```

Menu “Telegram” now runs `tg-gate open`. The user timer `tg-gate.timer` kills
the app outside allowed modes / after unlock expiry.

### 3. Optional: Genymotion / other apps (`app-gate`)

```bash
# Edit paths in the example first (replace /home/YOU/...)
nano examples/genymotion.conf
./bin/app-gate install genymotion --from examples/genymotion.conf
app-gate genymotion status
```

### 4. Uninstall

```bash
tg-gate uninstall          # timer + desktop; keeps config
app-gate uninstall genymotion
```

---

## `tg-gate` — schedule map

Modes: **ban** (no access) · **open** (free) · **strict** / **weekend** (unlock only).

### Monday / Wednesday / Friday

| Time | Mode |
|------|------|
| 00:00–09:00 | ban |
| 09:00–10:00 | open |
| 10:00–19:00 | strict |
| 19:00–20:30 | open |
| 20:30–24:00 | ban |

### Tuesday / Thursday

| Time | Mode |
|------|------|
| 00:00–03:00 | ban |
| 03:00–05:00 | open (early tourism) |
| 05:00–09:00 | ban |
| 09:00–19:00 | strict |
| 19:00–20:30 | open |
| 20:30–24:00 | ban |

### Saturday / Sunday

All day: **weekend** mode.

### Limits

| | Weekday `strict` | Weekend |
|--|------------------|---------|
| Max unlock slice | **5 min** | **20 min** |
| Daily budget | **30 min** | **120 min** |
| Unlock delay | **10 min** after phrase | same |
| Cooldown after unlock | **3 hours** | same |

Schedule logic is **hardcoded** in `bin/tg-gate` (not in the config file), so
editing windows via a quick `nano` impulse does not reopen the old bypass.

### Unlock flow

```text
tg-gate unlock 5
    → shows the confirm phrase + warns about the wait
    → you type: i need telegram
    → 10 minute wait starts

tg-gate unlock-confirm
    → unlock becomes active for N minutes
    → prints remaining daily budget (total − used)
    → after expiry: kill + 3h cooldown
```

No PIN. After every successful unlock you see:

```text
Daily limit: Xm, used: Ym, left: Zm
```

(Russian UI strings in the live CLI; same numbers.)

### Useful commands

```bash
tg-gate status
tg-gate unlock 5
tg-gate unlock-confirm
tg-gate lock
tg-gate install | uninstall
```

Audit log: `~/.local/state/tg-gate/audit.log`

---

## `app-gate` — generic multi-app gate

Simple model: comma-separated `WINDOWS` plus optional unlock.

```bash
./install.sh
app-gate install myapp --from examples/generic.conf
app-gate myapp status
app-gate list
```

### Commands

```text
app-gate <app-id> status|open|enforce|unlock|lock|edit
app-gate install <app-id> [--from PATH]
app-gate uninstall <app-id>
app-gate list
```

### Config (`~/.config/app-gate/apps/<id>.conf`)

| Variable | Meaning |
|----------|---------|
| `APP_NAME` | Label |
| `WINDOWS` | e.g. `12:30-12:45,19:00-19:30` (end exclusive) |
| `LAUNCH_MODE` | `command` or `flatpak` |
| `LAUNCH_CMD` / `FLATPAK_ID` | How to start |
| `STOP_CMD` | Graceful stop before kill |
| `PROCESS_PATTERNS` | Cmdline substrings for detect/kill |
| `DESKTOP_*` | Menu entry fields |
| `UNLOCK_PIN` | Optional (empty = none) |

See `examples/generic.conf`.

---

## How enforce works

```text
Menu ──► *-gate open ──► allowed? ──► start
                          └─ no ──► notify / block

systemd --user timer (every minute)
        └── *-gate enforce
                ├─ unlock expired? → kill (+ cooldown for tg-gate)
                ├─ open period?    → keep
                └─ else running?   → kill
```

---

## Project layout

```text
bin/app-gate                 # generic multi-app CLI
bin/tg-gate                  # Telegram schedule + strict unlock
examples/
  generic.conf
  telegram.conf              # simple app-gate profile
  tg-gate.config             # sample ~/.config/tg-gate/config
  genymotion.conf
systemd/                     # documented unit templates for app-gate@
install.sh                   # link CLIs + print fresh-system steps
README.md
LICENSE
```

## License

MIT — see [LICENSE](LICENSE).
