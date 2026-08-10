# Turns OFF the Windows system proxy.
# Run this when you're done with NoDPI (e.g. back on home WiFi) so other
# apps/browsers go back to connecting directly instead of through 127.0.0.1:8881.

Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0

Add-Type -Namespace Win32 -Name WinInet -MemberDefinition @'
[DllImport("wininet.dll", SetLastError = true)]
public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int dwBufferLength);
'@
[Win32.WinInet]::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null  # INTERNET_OPTION_SETTINGS_CHANGED
[Win32.WinInet]::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null  # INTERNET_OPTION_REFRESH

Write-Host "System proxy OFF - traffic goes direct again." -ForegroundColor Yellow
