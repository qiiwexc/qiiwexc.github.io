function Set-FileAssociations {
    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress -PercentComplete 70 -Task 'Setting file associations...'

    Set-Variable -Option Constant SophiaScriptUrl "https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/src/Sophia_Script_for_Windows_$OS_VERSION/Module/Sophia.psm1"
    Set-Variable -Option Constant SophiaScriptPath "$PATH_TEMP_DIR\Sophia.ps1"

    Set-Variable -Option Constant NoConnection (Test-NetworkConnection)
    if (-not $NoConnection) {
        Start-BitsTransfer -Source $SophiaScriptUrl -Destination $SophiaScriptPath -Dynamic

        (Get-Content -Path $SophiaScriptPath -Force) | Set-Content -Path $SophiaScriptPath -Encoding UTF8 -Force

        . $SophiaScriptPath
    }

    Set-Variable -Option Constant FileTypeCount ($CONFIG_FILE_ASSOCIATIONS.Count)
    Set-Variable -Option Constant Step ([Math]::Floor(20 / $FileTypeCount))

    [Int]$Iteration = 1
    foreach ($FileAssociation in $CONFIG_FILE_ASSOCIATIONS) {
        [Int]$Percentage = 70 + $Iteration * $Step
        Write-ActivityProgress -PercentComplete $Percentage
        $Iteration++

        [String]$Extension = $FileAssociation.Extension
        [String]$Application = $FileAssociation.Application

        Set-FileAssociation $Application "Registry::HKEY_CLASSES_ROOT\$Extension"
        Set-FileAssociation $Application "HKCU:\Software\Classes\$Extension" -SetDefault
        Set-FileAssociation $Application "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$Extension"

        [String]$OriginalAssociation = $(& cmd.exe /c assoc $Extension 2`>`&1).Replace("$Extension=", '')
        if ($OriginalAssociation -ne $Application) {
            & cmd.exe /c assoc $Extension=$Application
        }

        if (-not $NoConnection -and $FileAssociation.Method -eq 'Sophia') {
            Set-Association -ProgramPath $Application -Extension $Extension
        }
    }

    Remove-File $SophiaScriptPath

    Out-Success $LogIndentLevel
}
