$ErrorActionPreference = 'Stop'

$docker_provider = "DockerMsftProvider"
$docker_version = "18.03.1-ee-1"

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


Write-Output 'Install Chocolatey'
iex (wget 'https://chocolatey.org/install.ps1' -UseBasicParsing)

Write-Output 'Install editors'
choco install -y visualstudiocode
choco install -y atom

Write-Output 'Install Git'
choco install -y git

Write-Output 'Install browsers'
choco install -y googlechrome
choco install -y firefox

Write-Output 'Install Docker Compose'
choco install -y docker-compose

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

Write-Output 'Docker version'
docker version

$images = 
'microsoft/windowsservercore:ltsc2016',
'microsoft/nanoserver:sac2016',
'microsoft/windowsservercore',
'microsoft/nanoserver',
'microsoft/iis',
'golang',
'golang:nanoserver',
'microsoft/dotnet-framework:4.7.2-sdk',
'microsoft/dotnet-framework:4.7.2-runtime',
'microsoft/dotnet:2.0-sdk-nanoserver-sac2016',
'microsoft/dotnet:2.0-runtime-nanoserver-sac2016',
'microsoft/aspnetcore:2.0-nanoserver-sac2016',
'microsoft/iis:nanoserver-sac2016',
'microsoft/aspnet:4.7.2-windowsservercore-ltsc2016',
'microsoft/mssql-server-windows-express:2016-sp1',
'nats:1.1.0-nanoserver'

Write-Output 'Pulling images'
foreach ($tag in $images) {
    Write-Output "  Pulling image $tag"
    & docker image pull $tag
}

Write-Output 'Disable autologon'
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -PropertyType DWORD -Value "0" -Force

Write-Output 'Install all Windows Updates'
Get-Content C:\windows\system32\en-us\WUA_SearchDownloadInstall.vbs | ForEach-Object {
  $_ -replace 'confirm = msgbox.*$', 'confirm = vbNo'
} | Out-File $env:TEMP\WUA_SearchDownloadInstall.vbs
"a`na`na`na" | cscript $env:TEMP\WUA_SearchDownloadInstall.vbs
