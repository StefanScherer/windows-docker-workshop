$ErrorActionPreference = 'Stop'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Downloading OpenSSH"
Invoke-WebRequest "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.7.1.0p1-Beta/OpenSSH-Win64.zip" -OutFile OpenSSH-Win64.zip -UseBasicParsing

Write-Host "Expanding OpenSSH"
Expand-Archive OpenSSH-Win64.zip C:\
Remove-Item -Force OpenSSH-Win64.zip

Write-Host "Disabling password authentication"
# Add-Content C:\OpenSSH-Win64\sshd_config "`nPasswordAuthentication no"
Add-Content C:\OpenSSH-Win64\sshd_config "`nUseDNS no"

Push-Location C:\OpenSSH-Win64

Write-Host "Installing OpenSSH"
& .\install-sshd.ps1

Write-Host "Generating host keys"
.\ssh-keygen.exe -A

Write-Host "Fixing host file permissions"
& .\FixHostFilePermissions.ps1 -Confirm:$false

Write-Host "Fixing user file permissions"
& .\FixUserFilePermissions.ps1 -Confirm:$false

Pop-Location

$newPath = 'C:\OpenSSH-Win64;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

Write-Host "Adding public key to authorized_keys"
$keyPath = "~\.ssh\authorized_keys"
New-Item -Type Directory ~\.ssh > $null
$sshKey | Out-File $keyPath -Encoding Ascii

Write-Host "Opening firewall port 22"
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

Write-Host "Setting sshd service startup type to 'Automatic'"
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic
Write-Host "Setting sshd service restart behavior"
sc.exe failure sshd reset= 86400 actions= restart/500
