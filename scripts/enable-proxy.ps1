# Turns on the Windows system proxy, pointing it at NoDPI (127.0.0.1:8881).
# Run this AFTER starting NoDPI (see RUNNING.md), e.g. when you're on college WiFi.
# Affects all apps that use the Windows/WinINet system proxy, not just browsers.

Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value '127.0.0.1:8881'
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyOverride -Value 'localhost;127.0.0.1;<local>'

Add-Type -Namespace Win32 -Name WinInet -MemberDefinition @'
[DllImport("wininet.dll", SetLastError = true)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@
[Win32.WinInet]::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null  # INTERNET_OPTION_SETTINGS_CHANGED
[Win32.WinInet]::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null  # INTERNET_OPTION_REFRESH

Write-Host "System proxy ON -> 127.0.0.1:8881 (make sure NoDPI is running!)" -ForegroundColor Green
