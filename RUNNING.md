# Running NoDPI on Windows (manual start, via `uv`)

This repo is set up to run **from source**, with the virtual environment managed by [`uv`](https://github.com/astral-sh/uv) instead of the stock `venv` module. NoDPI is **not** registered for Windows startup — it only runs when you start it yourself from a terminal, and stops when you close that terminal or hit `Ctrl+C`.

For browser proxy configuration (Firefox/Chrome/Edge/etc.), see [`NODPI_SETUP.md`](NODPI_SETUP.md) — this doc only covers getting the proxy process itself running.

## One-time setup

From the repo root (`c:\Dev\NoDPI`):

```powershell
uv venv
```

This creates a `.venv` folder with its own Python interpreter. NoDPI has **no third-party dependencies** (pure standard library), so there's nothing to install — no `uv sync` / `uv pip install` step needed.

## Starting NoDPI

### Recommended: `scripts\run-nodpi.ps1` (auto-toggles the system proxy)

Running NoDPI alone does nothing unless Windows is actually configured to send traffic through it. This wrapper starts NoDPI **and** turns the Windows system proxy ON (pointed at `127.0.0.1:8881`) for the duration, then automatically turns it back OFF when NoDPI stops (`Ctrl+C` or the window closes) — so it never gets left on when you're on a network (e.g. home WiFi) that doesn't need it.

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

Press `Ctrl+C` in the terminal running it, or just close the terminal window.

**If you started it with `scripts\run-nodpi.ps1`**, the system proxy is turned off automatically as part of stopping — nothing else to do.

**If you started it manually** (the "Manual" section above), **remember to turn off your browser/system HTTP proxy setting yourself** after stopping NoDPI (`.\scripts\disable-proxy.ps1` or Settings → Network & Internet → Proxy), or your browser won't be able to load anything.
