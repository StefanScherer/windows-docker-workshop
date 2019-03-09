Install-Module -Name PSWindowsUpdate -RequiredVersion 2.1.1.2 -Force
Get-Command -Module PSWindowsUpdate
Write-Output Listing Windows Updates
$ProgressPreference = 'SilentlyContinue'
Get-WUInstall -MicrosoftUpdate -AcceptAll
Write-Output Installing Windows Updates
Get-WUInstall -Install -MicrosoftUpdate -AcceptAll -IgnoreReboot
Write-Output Done.

$procname="TiWorker"

$finished = 0

while ($finished -lt 3) {

  Start-Sleep 30
  Write-Output "Checking for $procname ($finished)"
  $output = "$(get-process -erroraction silentlycontinue $procname)"
  if ( $output -eq "") {
    $finished = $finished + 1
  } else {
    $finished = 0
  }
}
