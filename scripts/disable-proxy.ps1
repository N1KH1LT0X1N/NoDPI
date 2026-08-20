# Turns OFF the Windows system proxy.
# Run this when you're done with NoDPI (e.g. back on home WiFi) so other
# apps/browsers go back to connecting directly instead of through 127.0.0.1:8881.
#
# Clears ProxyServer too, not just ProxyEnable: leaving a stale address behind
# means the Settings app still shows a proxy configured, and anything that
# flips ProxyEnable back on later (a VPN client, a stray Settings click, a
# policy refresh) silently routes all traffic at a dead 127.0.0.1:8881.

$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
Set-ItemProperty -Path $key -Name ProxyEnable -Value 0
Remove-ItemProperty -Path $key -Name ProxyServer -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $key -Name ProxyOverride -ErrorAction SilentlyContinue

Add-Type -Namespace Win32 -Name WinInet -MemberDefinition @'
[DllImport("wininet.dll", SetLastError = true)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@
[Win32.WinInet]::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null  # INTERNET_OPTION_SETTINGS_CHANGED
[Win32.WinInet]::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null  # INTERNET_OPTION_REFRESH

Write-Host "System proxy OFF - traffic goes direct again." -ForegroundColor Yellow
