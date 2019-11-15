$ErrorActionPreference = 'Stop'

$docker_provider = "DockerMsftProvider"
$docker_version = "19.03.5"

Write-Output 'Set Windows Updates to manual'
Cscript $env:WinDir\System32\SCregEdit.wsf /AU 1
Net stop wuauserv
Net start wuauserv

Write-Output 'Disable Windows Defender'
Set-MpPreference -DisableRealtimeMonitoring $true

Write-Output 'Do not open Server Manager at logon'
New-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force

Write-Output 'Install bginfo'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (!(Test-Path 'c:\Program Files\sysinternals')) {
  New-Item -Path 'c:\Program Files\sysinternals' -type directory -Force -ErrorAction SilentlyContinue
}
if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
  (New-Object Net.WebClient).DownloadFile('http://live.sysinternals.com/bginfo.exe', 'c:\Program Files\sysinternals\bginfo.exe')
}
if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.bgi')) {
  (New-Object Net.WebClient).DownloadFile('https://github.com/StefanScherer/windows-docker-workshop/raw/master/prepare-vms/azure/packer/bginfo.bgi', 'c:\Program Files\sysinternals\bginfo.bgi')
}
if (!(Test-Path 'c:\Program Files\sysinternals\background.jpg')) {
  (New-Object Net.WebClient).DownloadFile('https://github.com/StefanScherer/windows-docker-workshop/raw/master/prepare-vms/azure/packer/background.jpg', 'c:\Program Files\sysinternals\background.jpg')
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

Write-Output 'Install Chocolatey'
Invoke-WebRequest 'https://chocolatey.org/install.ps1' -UseBasicParsing | Invoke-Expression

Write-Output 'Install editors'
choco install -y vscode

Write-Output 'Install Git'
choco install -y git

Write-Output 'Install browsers'
choco install -y googlechrome
choco install -y firefox

Write-Output 'Install Docker Compose'
choco install -y docker-compose
choco install -y kubernetes-cli

choco install -y poshgit
choco install -y visualstudiocode

if (Test-Path $env:ProgramFiles\docker) {
  Write-Output Update Docker
  Install-Package -Name docker -ProviderName $docker_provider -Verbose -Update -RequiredVersion $docker_version -Force
} else {
  Write-Output "Install-PackageProvider ..."
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Write-Output "Install-Module $docker_provider ..."
  Install-Module -Name $docker_provider -Force
  Write-Output "Install-Package version $docker_version ..."
  Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
  $ErrorActionStop = 'SilentlyContinue'
  Install-Package -Name docker -ProviderName $docker_provider -RequiredVersion $docker_version -Force
  Set-PSRepository -InstallationPolicy Untrusted -Name PSGallery
  $env:Path = $env:Path + ";$($env:ProgramFiles)\docker"
}

Write-Output 'Staring Docker service'
Start-Service docker

Write-Output 'Docker version'
docker version

$images =
'mcr.microsoft.com/windows/servercore:ltsc2019',
'mcr.microsoft.com/windows/nanoserver:1809',
'mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019',
'mcr.microsoft.com/dotnet/framework/sdk:4.7.2-20190312-windowsservercore-ltsc2019',
'mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019',
'mcr.microsoft.com/dotnet/framework/aspnet',
'mcr.microsoft.com/dotnet/core/runtime:3.0',
'mcr.microsoft.com/dotnet/core/sdk:3.0.100',
'mcr.microsoft.com/dotnet/core/aspnet:3.0',
'dak4dotnet/sql-server:2017',
'nats:2.1.0',
'dockersamples/aspnet-monitoring-exporter:4.7.2-windowsservercore-ltsc2019',
'dockersamples/aspnet-monitoring-grafana:5.2.1-windowsservercore-ltsc2019',
'dockersamples/aspnet-monitoring-prometheus:2.3.1-windowsservercore-ltsc2019',
'sixeyed/elasticsearch:5.6.11-windowsservercore-ltsc2019',
'sixeyed/kibana:5.6.11-windowsservercore-ltsc2019',
'traefik:1.7.18-windowsservercore-1809'

Write-Output 'Pulling images'
foreach ($tag in $images) {
    Write-Output "  Pulling image $tag"
    & docker image pull $tag
}

Write-Output '* Configuring environment'
refreshenv
$env:PATH=$env:PATH + ';C:\Program Files\Mozilla Firefox;C:\Program Files\Git\bin'
[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)
$env:workshop='C:\scm\dak4.net'
[Environment]::SetEnvironmentVariable('workshop', $env:workshop, [EnvironmentVariableTarget]::Machine)

New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWORD -Value "1" -Force
New-ItemProperty -Path HKLM:\Software\Microsoft\ServerManager\Oobe -Name DoNotOpenInitialConfigurationTasksAtLogon -PropertyType DWORD -Value "1" -Force

Write-Output '* Cloning the workshop repo'
mkdir C:\scm -ErrorAction Ignore
cd C:\scm
git clone https://github.com/sixeyed/dak4.net.git
'master' | Out-File C:\branch.txt

Write-Output 'Disable autologon'
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -PropertyType DWORD -Value "0" -Force
