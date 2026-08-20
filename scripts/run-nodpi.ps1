# Wrapper: starts NoDPI, turns the Windows system proxy ON while it runs,
# and turns the proxy back OFF automatically when you stop NoDPI with Ctrl+C.
#
# IMPORTANT: stop this with Ctrl+C. Closing the window/tab or killing it via
# Task Manager skips the cleanup and leaves the system proxy pointed at a
# dead address - looks like your internet is broken. Run disable-proxy.ps1
# to recover if that happens.
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

$proxyHost = '127.0.0.1'
$proxyPort = '8881'
for ($i = 0; $i -lt $NoDpiArgs.Count - 1; $i++) {
    if ($NoDpiArgs[$i] -eq '--host') { $proxyHost = $NoDpiArgs[$i + 1] }
    if ($NoDpiArgs[$i] -eq '--port') { $proxyPort = $NoDpiArgs[$i + 1] }
}
$proxyAddress = "${proxyHost}:${proxyPort}"

Write-Host "Stop NoDPI with Ctrl+C - do NOT close this window, or the system proxy will be left on." -ForegroundColor Yellow

try {
    & (Join-Path $PSScriptRoot 'enable-proxy.ps1') -ProxyAddress $proxyAddress
    & $python $mainPy @NoDpiArgs
}
finally {
    & (Join-Path $PSScriptRoot 'disable-proxy.ps1')
}
