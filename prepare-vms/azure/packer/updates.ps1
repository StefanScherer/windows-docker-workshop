Write-Host Install all Windows Updates
Get-Content C:\windows\system32\en-us\WUA_SearchDownloadInstall.vbs | ForEach-Object {
 $_ -replace 'confirm = msgbox.*$', 'confirm = vbNo'
} | Out-File $env:TEMP\WUA_SearchDownloadInstall.vbs
"a`na`na`na`na`na`na`na`na" | cscript $env:TEMP\WUA_SearchDownloadInstall.vbs
