Start-Transcript -Path C:\provision.log

function Get-HostToIP($hostname) {
  $result = [system.Net.Dns]::GetHostByName($hostname)
  $result.AddressList | ForEach-Object {$_.IPAddressToString }
}

Write-Host "provision.ps1"
Write-Host "HostName = $($HostName)"

$PublicIPAddress = Get-HostToIP($HostName)

Write-Host "PublicIPAddress = $($PublicIPAddress)"
Write-Host "USERPROFILE = $($env:USERPROFILE)"
Write-Host "pwd = $($pwd)"

Write-Host Install bginfo
[Environment]::SetEnvironmentVariable('FQDN', $HostName, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable('PUBIP', $PublicIPAddress, [EnvironmentVariableTarget]::Machine)

Write-Host Cleaning up
Remove-Item C:\provision.ps1
