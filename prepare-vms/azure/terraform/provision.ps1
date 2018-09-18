Start-Transcript -Path C:\provision.log

Set-MpPreference -DisableRealtimeMonitoring $true

New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force

function Get-HostToIP($hostname) {
  $result = [system.Net.Dns]::GetHostByName($hostname)
  $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

Write-Output "provision.ps1"
Write-Output "HostName = $($HostName)"

$PublicIPAddress = Get-HostToIP($HostName)

Write-Output "PublicIPAddress = $($PublicIPAddress)"
Write-Output "USERPROFILE = $($env:USERPROFILE)"
Write-Output "pwd = $($pwd)"

Write-Output Install bginfo
[Environment]::SetEnvironmentVariable('FQDN', $HostName, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('PUBIP', $PublicIPAddress, [EnvironmentVariableTarget]::Machine)

refreshenv
$env:PATH=$env:PATH + ';C:\Program Files\Mozilla Firefox;C:\Program Files\Microsoft VS Code;C:\Program Files\Git\bin'
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

# Atom is installed to C:\Users\training\AppData\Local\atom so we have to do it in Terraform and not Packer
choco install -y atom

# Create shortcuts
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\PowerShell.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$shortcut.WorkingDirectory = "$Home"
$Shortcut.Save()

# Run some containers
# docker run microsoft/nanoserver cmd
# docker run microsoft/windowsservercore cmd

Write-Output Cleaning up
Remove-Item C:\provision.ps1

Restart-Computer
