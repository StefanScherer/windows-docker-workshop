Write-Output "Installing kb4482887"
curl.exe -o kb4482887.msu http://download.windowsupdate.com/c/msdownload/update/software/updt/2019/02/windows10.0-kb4482887-x64_826158e9ebfcabe08b425bf2cb160cd5bc1401da.msu
Start-Process wusa.exe -ArgumentList ("kb4482887.msu", '/quiet', '/norestart', "/log:c:\Wusa.log") -Wait
