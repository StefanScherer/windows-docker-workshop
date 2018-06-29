$ErrorActionPreference = 'Stop'

Write-Host Windows Updates to manual
Cscript $env:WinDir\System32\SCregEdit.wsf /AU 1
Net stop wuauserv
Net start wuauserv

Write-Host Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Host Do not open Server Manager at logon
New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force

Write-Host Install bginfo
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (!(Test-Path 'c:\Program Files\sysinternals')) {
  New-Item -Path 'c:\Program Files\sysinternals' -type directory -Force -ErrorAction SilentlyContinue
}
if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
  (New-Object Net.WebClient).DownloadFile('http://live.sysinternals.com/bginfo.exe', 'c:\Program Files\sysinternals\bginfo.exe')
}
if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.bgi')) {
  (New-Object Net.WebClient).DownloadFile('https://github.com/StefanScherer/adfs2/raw/master/scripts/bginfo-workshop.bgi', 'c:\Program Files\sysinternals\bginfo.bgi')
}
$vbsScript = @'
WScript.Sleep 2000
Dim objShell
Set objShell = WScript.CreateObject( "WScript.Shell" )
objShell.Run("""c:\Program Files\sysinternals\bginfo.exe"" /accepteula ""c:\Program Files\sysinternals\bginfo.bgi"" /silent /timer:0")
'@
$vbsScript | Out-File 'c:\Program Files\sysinternals\bginfo.vbs'
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name bginfo -Value 'wscript "c:\Program Files\sysinternals\bginfo.vbs"'
wscript "c:\Program Files\sysinternals\bginfo.vbs"


Write-Host Install Chocolatey
iex (wget 'https://chocolatey.org/install.ps1' -UseBasicParsing)

Write-Host Install editors
choco install -y visualstudiocode

Write-Host Install Git
choco install -y git

Write-Host Install browsers
choco install -y googlechrome

Write-Host Install Docker Compose
choco install -y docker-compose

Write-Host Pulling latest images
docker pull microsoft/windowsservercore
docker pull microsoft/nanoserver

Write-Host Pulling some application images
docker pull microsoft/iis
docker pull golang
docker pull golang:nanoserver

Write-Host Update Docker
Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose -Update -RequiredVersion 18.03.1-ee-1 -Force

Write-Host Disable autologon
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -PropertyType DWORD -Value "0" -Force

Write-Host Install all Windows Updates
Get-Content C:\windows\system32\en-us\WUA_SearchDownloadInstall.vbs | ForEach-Object {
  $_ -replace 'confirm = msgbox.*$', 'confirm = vbNo'
} | Out-File $env:TEMP\WUA_SearchDownloadInstall.vbs
"a`na`na`na" | cscript $env:TEMP\WUA_SearchDownloadInstall.vbs
