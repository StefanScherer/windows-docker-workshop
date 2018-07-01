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

Write-Output Cleaning up
Remove-Item C:\provision.ps1

Restart-Computer
