Install-Module -Name PSWindowsUpdate -RequiredVersion 2.1.1.2 -Force
Get-Command -Module PSWindowsUpdate
Write-Output Listing Windows Updates
$ProgressPreference = 'SilentlyContinue'
Get-WUInstall -MicrosoftUpdate -AcceptAll
Write-Output Installing Windows Updates
Get-WUInstall -Install -AcceptAll -IgnoreReboot
Write-Output Done.
