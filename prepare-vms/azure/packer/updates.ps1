param($global:RestartRequired=0,
        $global:MoreUpdates=0,
        $global:MaxCycles=5,
        $MaxUpdatesPerCycle=500,
        $BeginWithRestart=0)

function Install-WindowsUpdates() {
    $script:Cycles++
    Write-Output "Evaluating Available Updates with limit of $($MaxUpdatesPerCycle):"
    $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    $script:i = 0;
    $CurrentUpdates = $SearchResult.Updates
    while($script:i -lt $CurrentUpdates.Count -and $script:CycleUpdateCount -lt $MaxUpdatesPerCycle) {
        $Update = $CurrentUpdates.Item($script:i)
        if ($null -ne $Update) {
            [bool]$addThisUpdate = $false
            if ($Update.InstallationBehavior.CanRequestUserInput) {
                Write-Output "> Skipping: $($Update.Title) because it requires user input"
            } else {
                if (!($Update.EulaAccepted)) {
                    Write-Output "> Note: $($Update.Title) has a license agreement that must be accepted. Accepting the license."
                    $Update.AcceptEula()
                    [bool]$addThisUpdate = $true
                    $script:CycleUpdateCount++
                } else {
                    [bool]$addThisUpdate = $true
                    $script:CycleUpdateCount++
                }
            }

            if ([bool]$addThisUpdate) {
                Write-Output "Adding: $($Update.Title)"
                $UpdatesToDownload.Add($Update) |Out-Null
            }
        }
        $script:i++
    }

    if ($UpdatesToDownload.Count -eq 0) {
        Write-Output "No Updates To Download..."
    } else {
        Write-Output 'Downloading Updates...'
        $ok = 0;
        while (! $ok) {
            try {
                $Downloader = $UpdateSession.CreateUpdateDownloader()
                $Downloader.Updates = $UpdatesToDownload
                $Downloader.Download()
                $ok = 1;
            } catch {
                Write-Output $_.Exception | Format-List -force
                Write-Output "Error downloading updates. Retrying in 30s."
                $script:attempts = $script:attempts + 1
                Start-Sleep -s 30
            }
        }
    }

    $UpdatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    [bool]$rebootMayBeRequired = $false
    Write-Output 'The following updates are downloaded and ready to be installed:'
    foreach ($Update in $SearchResult.Updates) {
        if (($Update.IsDownloaded)) {
            Write-Output "> $($Update.Title)"
            $UpdatesToInstall.Add($Update) |Out-Null

            if ($Update.InstallationBehavior.RebootBehavior -gt 0){
                [bool]$rebootMayBeRequired = $true
            }
        }
    }

    if ($UpdatesToInstall.Count -eq 0) {
        Write-Output 'No updates available to install...'
        $global:MoreUpdates=0
        $global:RestartRequired=0
        break
    }

    if ($rebootMayBeRequired) {
        Write-Output 'These updates may require a reboot'
        $global:RestartRequired=1
    }

    Write-Output 'Installing updates...'

    $Installer = $script:UpdateSession.CreateUpdateInstaller()
    $Installer.Updates = $UpdatesToInstall
    $InstallationResult = $Installer.Install()

    Write-Output "Installation Result: $($InstallationResult.ResultCode)"
    Write-Output "Reboot Required: $($InstallationResult.RebootRequired)"
    Write-Output 'Listing of updates installed and individual installation results:'
    if ($InstallationResult.RebootRequired) {
        $global:RestartRequired=1
    } else {
        $global:RestartRequired=0
    }

    for($i=0; $i -lt $UpdatesToInstall.Count; $i++) {
        New-Object -TypeName PSObject -Property @{
            Title = $UpdatesToInstall.Item($i).Title
            Result = $InstallationResult.GetUpdateResult($i).ResultCode
        }
        Write-Output "Item: $($UpdatesToInstall.Item($i).Title)"
        Write-Output "Result: $($InstallationResult.GetUpdateResult($i).ResultCode)"
    }
}

function Check-WindowsUpdates() {
    Write-Output "Checking For Windows Updates"
    $Username = $env:USERDOMAIN + "\" + $env:USERNAME
    Write-Output "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()

    $script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
    $script:successful = $FALSE
    $script:attempts = 0
    $script:maxAttempts = 12
    while(-not $script:successful -and $script:attempts -lt $script:maxAttempts) {
        try {
            $script:SearchResult = $script:UpdateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            $script:successful = $TRUE
        } catch {
            Write-Output $_.Exception | Format-List -force
            Write-Output "Search call to UpdateSearcher was unsuccessful. Retrying in 10s."
            $script:attempts = $script:attempts + 1
            Start-Sleep -s 10
        }
    }

    if ($SearchResult.Updates.Count -ne 0) {
        $Message = "There are " + $SearchResult.Updates.Count + " more updates."
        Write-Output $Message
        try {
            for($i=0; $i -lt $script:SearchResult.Updates.Count; $i++) {
              Write-Output $script:SearchResult.Updates.Item($i).Title
              Write-Output $script:SearchResult.Updates.Item($i).Description
              Write-Output $script:SearchResult.Updates.Item($i).RebootRequired
              Write-Output $script:SearchResult.Updates.Item($i).EulaAccepted
          }
            $global:MoreUpdates=1
        } catch {
            Write-Output $_.Exception | Format-List -force
            Write-Output "Showing SearchResult was unsuccessful. Rebooting."
            $global:RestartRequired=1
            $global:MoreUpdates=0
            Write-Output "Show never happen to see this text!"
        }
    } else {
        Write-Output 'There are no applicable updates'
        $global:RestartRequired=0
        $global:MoreUpdates=0
    }
}

$script:ScriptName = $MyInvocation.MyCommand.ToString()
$script:ScriptPath = $MyInvocation.MyCommand.Path
$script:UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
$script:UpdateSession.ClientApplicationID = 'Packer Windows Update Installer'
$script:UpdateSearcher = $script:UpdateSession.CreateUpdateSearcher()
$script:SearchResult = New-Object -ComObject 'Microsoft.Update.UpdateColl'
$script:Cycles = 0
$script:CycleUpdateCount = 0

Check-WindowsUpdates
if ($global:MoreUpdates -eq 1) {
    Install-WindowsUpdates
}
