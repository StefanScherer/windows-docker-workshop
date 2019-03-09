Install-Module PSWindowsUpdate
Get-Command -Module PSWindowsUpdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
Get-WUInstall -MicrosoftUpdate -AcceptAll 
