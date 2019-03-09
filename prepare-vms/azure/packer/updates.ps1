Install-Module PSWindowsUpdate -Force
Get-Command -Module PSWindowsUpdate
Write-Output Running Windows Updates
Get-WUInstall -MicrosoftUpdate -AcceptAll 
