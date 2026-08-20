# Running NoDPI on Windows (manual start, via `uv`)

This repo is set up to run **from source**, with the virtual environment managed by [`uv`](https://github.com/astral-sh/uv) instead of the stock `venv` module. NoDPI is **not** registered for Windows startup — it only runs when you start it yourself from a terminal.

> **Always stop NoDPI with `Ctrl+C`, never by closing the terminal window/tab.** When you run it via `scripts\run-nodpi.ps1`, `Ctrl+C` lets the script turn the Windows system proxy back off before exiting. Closing the window instead kills the whole process tree instantly — the cleanup code never gets to run, and Windows is left pointed at a proxy address nothing is listening on anymore, which looks like your entire internet connection is broken. If that happens, run `.\scripts\disable-proxy.ps1` to recover.

For browser proxy configuration (Firefox/Chrome/Edge/etc.), see [`NODPI_SETUP.md`](NODPI_SETUP.md) — this doc only covers getting the proxy process itself running.

## One-time setup

From the repo root (`c:\Dev\NoDPI`):

```powershell
uv venv
```

This creates a `.venv` folder with its own Python interpreter. NoDPI has **no third-party dependencies** (pure standard library), so there's nothing to install — no `uv sync` / `uv pip install` step needed.

## Starting NoDPI

### Recommended: `scripts\run-nodpi.ps1` (auto-toggles the system proxy)

Running NoDPI alone does nothing unless Windows is actually configured to send traffic through it. This wrapper starts NoDPI **and** turns the Windows system proxy ON (pointed at `127.0.0.1:8881`) for the duration, then automatically turns it back OFF when you stop NoDPI with `Ctrl+C` — so it never gets left on when you're on a network (e.g. home WiFi) that doesn't need it. This only works if you stop it with `Ctrl+C`; closing the window skips the cleanup (see warning above).

```powershell
.\scripts\run-nodpi.ps1
```

This defaults to `--blacklist blacklists\big-blacklist.txt`. To pass your own arguments (forwarded straight to `src\main.py`):
```powershell
.\scripts\run-nodpi.ps1 --blacklist blacklists\big-blacklist.txt --host 127.0.0.1 --port 8881
```

See [`scripts\enable-proxy.ps1`](scripts/enable-proxy.ps1) / [`scripts\disable-proxy.ps1`](scripts/disable-proxy.ps1) if you ever need to toggle the proxy manually (e.g. NoDPI crashed without running the `finally` cleanup).

### Manual (proxy setting not managed for you)

Run this any time from the repo root, in a terminal you're fine leaving open (the proxy runs in the foreground and stops when the terminal closes):

**PowerShell / cmd:**
```powershell
.venv\Scripts\python.exe src\main.py --blacklist blacklists\big-blacklist.txt --host 127.0.0.1 --port 8881
```

**Or via `uv run`** (equivalent, lets uv resolve the interpreter for you):
```powershell
uv run src\main.py --blacklist blacklists\big-blacklist.txt --host 127.0.0.1 --port 8881
```

`--host`/`--port` are already the defaults, so in practice you can just run:
```powershell
.venv\Scripts\python.exe src\main.py --blacklist blacklists\big-blacklist.txt
```

With this manual path, you're responsible for toggling the system proxy yourself (see below) — it won't happen automatically.

> **Git Bash note:** if you run this from Git Bash instead of PowerShell/cmd, you may hit a `UnicodeEncodeError` from the startup banner (Git Bash's console codepage can't render the box-drawing characters). Fix by setting `PYTHONUTF8=1` first, e.g. `PYTHONUTF8=1 .venv/Scripts/python.exe src/main.py --blacklist blacklists/big-blacklist.txt`. PowerShell and cmd don't need this.

## Useful flags

| Flag | What it does |
|---|---|
| `--host 0.0.0.0` | Listen on all interfaces (share with LAN) instead of just localhost |
| `--port 8080` | Use a different port than the default `8881` |
| `--blacklist <path>` | Path to a blacklist file (see `blacklists/` for presets) |
| `--no-blacklist` | Apply fragmentation to all domains, ignoring any blacklist |
| `--autoblacklist` | Auto-detect blocked domains as you browse, instead of a static list |
| `--fragment-method sni` \| `random` | ClientHello fragmentation method (`sni` is the default) |
| `--domain-matching strict` \| `loose` | How blacklist domain matching is applied |
| `--out-host proxy:port` | Chain through an upstream proxy |
| `--auth-username` / `--auth-password` | Require credentials to use the proxy |
| `--log-access access.log` | Log visited domains to a file |
| `--log-error error.log` | Log errors to a file |
| `-q` / `--quiet` | Suppress terminal output |
| `--start-in-tray` | Start minimized to the system tray (Windows only) |

`--install` / `--uninstall` also exist (they register/remove NoDPI from Windows/Linux autostart) but are **intentionally not used** in this setup — this project is meant to be started manually every time, not on boot.

## Stopping NoDPI

Press `Ctrl+C` in the terminal running it. **Do not close the terminal window/tab directly** — see the warning at the top of this doc.

**If you started it with `scripts\run-nodpi.ps1`**, `Ctrl+C` turns the system proxy off automatically as part of stopping — nothing else to do.

**If you started it manually** (the "Manual" section above), **remember to turn off your browser/system HTTP proxy setting yourself** after stopping NoDPI (`.\scripts\disable-proxy.ps1` or Settings → Network & Internet → Proxy), or your browser won't be able to load anything.

**If NoDPI ever gets killed some other way** (window closed, Task Manager, crash) and your internet looks broken afterward, run `.\scripts\disable-proxy.ps1` to restore direct traffic.

## Known issue: Windows Mobile Hotspot + a single-radio Wi-Fi card

This is unrelated to NoDPI itself, but shows up in the same workflow: if your laptop has only one Wi-Fi radio (most laptops), turning on Windows Mobile Hotspot while connected to Wi-Fi forces that one radio to act as a client and an access point at the same time. On some chipsets (Realtek 8852BE/8852BE-VT in particular) this dual-role mode is unstable and can lock up the radio entirely — the adapter drops off the network it was connected to and stops seeing any networks at all until you reboot.

If this happens to you:
- It's a Wi-Fi driver/hardware limitation, not something these scripts can fix or cause.
- Avoid running Mobile Hotspot and staying connected to Wi-Fi on the same laptop for long stretches. If you need internet on another device, prefer that device's own hotspot instead of sharing from this laptop.
- Check for a newer Wi-Fi driver (Windows Update or the laptop OEM's site) — this class of bug does get patched over time.
