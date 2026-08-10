# Wrapper: starts NoDPI, turns the Windows system proxy ON while it runs,
# and turns the proxy back OFF automatically when NoDPI stops (Ctrl+C or window close).
#
# Usage (from repo root, mirrors RUNNING.md):
#   .\scripts\run-nodpi.ps1
#   .\scripts\run-nodpi.ps1 --blacklist blacklists\big-blacklist.txt --host 127.0.0.1 --port 8881
#
# Any arguments you pass are forwarded as-is to src\main.py.

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$NoDpiArgs
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$python = Join-Path $repoRoot '.venv\Scripts\python.exe'
$mainPy = Join-Path $repoRoot 'src\main.py'

if ($NoDpiArgs.Count -eq 0) {
    $NoDpiArgs = @('--blacklist', (Join-Path $repoRoot 'blacklists\big-blacklist.txt'))
}

& (Join-Path $PSScriptRoot 'enable-proxy.ps1')

try {
    & $python $mainPy @NoDpiArgs
}
finally {
    & (Join-Path $PSScriptRoot 'disable-proxy.ps1')
}
