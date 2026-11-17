# While the default user profile is loaded its file is locked, and Windows cannot create an account's profile from it,
# so the unload is retried in case another process, such as an antivirus scanning the hive, still has a key open.
# Never throws: it runs after the import, whose own failure must not be replaced by this one
function Dismount-DefaultUserHive {
    Set-Variable -Option Constant LogIndentLevel ([Int]2)
    Set-Variable -Option Constant Attempts ([Int]5)

    [String]$Reason = ''
    for ([Int]$Attempt = 1; $Attempt -le $Attempts; $Attempt++) {
        try {
            [Int]$ExitCode = Invoke-RegCommand @('unload', 'HKU\DefaultUser')
            if ($ExitCode -eq 0) {
                Write-LogDebug 'Unloaded the default user profile' $LogIndentLevel
                return
            }
            $Reason = "reg.exe exited with code $ExitCode"
        } catch {
            $Reason = "$_"
        }

        if ($Attempt -lt $Attempts) {
            Start-Sleep -Seconds 1
        }
    }

    Write-LogWarning "Could not unload the default user profile, so a new account cannot sign in until Windows restarts: $Reason" $LogIndentLevel
}
