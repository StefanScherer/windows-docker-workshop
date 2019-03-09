Install-Module PSWindowsUpdate -force
Import-Module PSWindowsUpdate
Get-WUInstall -AcceptAll | Out-File C:\PSWindowsUpdate.log
