# NoDPI — Multi-OS Setup Guide

NoDPI is a pure-Python proxy that fragments TLS ClientHello packets to bypass Deep Packet Inspection (DPI). No root/admin required.

## Installation & Run

### Linux (any distro)

```bash
git clone https://github.com/GVCoder09/NoDPI.git
cd NoDPI
python3 -m venv .venv
source .venv/bin/activate
python3 src/main.py --blacklist blacklists/big-blacklist.txt --host 127.0.0.1 --port 8881
```

### Windows

1. Download the latest `nodpi.exe` from [releases](https://github.com/GVCoder09/NoDPI/releases)
2. Extract and run:
   ```cmd
   nodpi.exe --blacklist blacklists/big-blacklist.txt
   ```
3. Or from source (Python 3.8+ required):
   ```cmd
   python src/main.py --blacklist blacklists/big-blacklist.txt
   ```

### macOS

```bash
git clone https://github.com/GVCoder09/NoDPI.git
cd NoDPI
python3 -m venv .venv
source .venv/bin/activate
python3 src/main.py --blacklist blacklists/big-blacklist.txt --host 127.0.0.1 --port 8881
```

---

## Browser Proxy Configuration

NoDPI listens on `127.0.0.1:8881` — you only need to set the **HTTP/HTTPS proxy**. SOCKS fields stay **empty**.

### Firefox

Settings → Network Settings → Manual proxy configuration:
- **HTTP Proxy**: `127.0.0.1` **Port**: `8881`
- **Also use this proxy for HTTPS**: ✅ (checked)
- SOCKS Host: **leave blank**

### Chromium / Google Chrome / Edge / Brave / Vivaldi

**Option A — Launch with flag** (recommended, doesn't change system settings):

```bash
chromium --proxy-server=127.0.0.1:8881
google-chrome --proxy-server=127.0.0.1:8881
brave-browser --proxy-server=127.0.0.1:8881
vivaldi --proxy-server=127.0.0.1:8881
msedge --proxy-server=127.0.0.1:8881
```

**Option B — System proxy (Linux — GNOME/KDE)**:

GNOME: Settings → Network → Proxy → Manual → HTTP Proxy `127.0.0.1:8881`, HTTPS Proxy `127.0.0.1:8881`  
KDE: System Settings → Network → Proxy → Manual

**Option C — System proxy (Windows)**:
Settings → Network & Internet → Proxy → Use a proxy server → Address `127.0.0.1` Port `8881`

**Option D — Browser extension** (e.g. FoxyProxy, SwitchyOmega):
Create a profile: HTTP proxy `127.0.0.1:8881`, all protocols use same proxy.

### Safari (macOS)

System Settings → Network → Proxies → Web Proxy (HTTP) → `127.0.0.1:8881`  
Check "Secure Web Proxy" → same address.

---

## Blacklist Files

| File | Coverage |
|---|---|
| `blacklist.txt` (default) | YouTube only |
| `blacklists/big-blacklist.txt` | All known blocked domains |
| `blacklists/blacklist-youtube.txt` | YouTube |
| `blacklists/blacklist-discord.txt` | Discord |
| `blacklists/blacklist-instagram.txt` | Instagram |
| `blacklists/blacklist-twitter.txt` | X / Twitter |
| `blacklists/blacklist-telegram.txt` | Telegram |
| `blacklists/blacklist-meta.txt` | Facebook / Instagram / WhatsApp |
| `blacklists/blacklist-news.txt` | News sites |
| `blacklists/blacklist-roblox.txt` | Roblox |

Pass any with `--blacklist path/to/file.txt`.

### `--autoblacklist`

Auto-detect blocked domains as you browse (instead of a static list):

```bash
python3 src/main.py --autoblacklist --host 127.0.0.1 --port 8881
```

---

## Useful Flags

| Flag | What it does |
|---|---|
| `--host 0.0.0.0` | Listen on all interfaces (share with LAN) |
| `--port 8080` | Use a different port |
| `-q` | Quiet mode (no terminal output) |
| `--fragment-method sni` | Split by SNI field (default) |
| `--fragment-method random` | Random fragmentation |
| `--out-host proxy:port` | Chain through an upstream proxy |
| `--log-access access.log` | Log visited domains |
| `--log-error error.log` | Log errors |

---

## Add to Startup

After running once with the binary version (not source):

```bash
./nodpi --install    # Linux (systemd) or Windows (registry)
./nodpi --uninstall  # Remove from startup
```

For the source version, add to your `.bashrc` / `.zshrc` or create a systemd unit manually.

---

## Stopping

```bash
# Linux/macOS
pkill -f nodpi

# Windows — close the terminal or Ctrl+C
```

**Remember to disable the proxy after stopping NoDPI**, or your browser won't load anything.
