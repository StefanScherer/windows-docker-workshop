Install-Module -Name PSWindowsUpdate -RequiredVersion 2.1.1.2 -Force
Get-Command -Module PSWindowsUpdate
Write-Output Running Windows Updates
Get-WUInstall -MicrosoftUpdate -AcceptAll 
Get-WUInstall -Install -AcceptAll
