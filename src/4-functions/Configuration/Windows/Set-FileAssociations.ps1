function Set-FileAssociations {
    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress -PercentComplete 70 -Task 'Setting file associations...'

    Set-Variable -Option Constant SophiaScriptUrl ([String]"https://raw.githubusercontent.com/farag2/Sophia-Script-for-Windows/master/src/Sophia_Script_for_Windows_$OS_VERSION/Module/Sophia.psm1")
    Set-Variable -Option Constant SophiaScriptPath ([String]"$PATH_TEMP_DIR\Sophia.ps1")

    [Collections.Generic.List[Object]]$AppAssociations = @()

    Select-Xml -Xml ([xml]$CONFIG_APP_ASSOCIATIONS) -XPath '//Association' | ForEach-Object {
        [String][ValidateSet('Registry', 'Sophia')]$Method = $(if ($_.Node._resistant -eq 'true') { 'Sophia' } else { 'Registry' })

        $AppAssociations.Add(@{
                Method      = $Method
                Application = $_.Node.ProgId
                Extension   = $_.Node.Identifier
            })
    }

    Set-Variable -Option Constant NoConnection ([String](Test-NetworkConnection))
    if (-not $NoConnection) {
        Start-BitsTransfer -Source $SophiaScriptUrl -Destination $SophiaScriptPath -Dynamic

        (Get-Content $SophiaScriptPath -Raw -Encoding UTF8 -Force) | Set-Content $SophiaScriptPath -Encoding UTF8 -Force

        . $SophiaScriptPath
    }

    Set-Variable -Option Constant FileTypeCount ([Int]$AppAssociations.Count)
    Set-Variable -Option Constant Step ([Math]::Floor(20 / $FileTypeCount))

    [Int]$Iteration = 1
    foreach ($FileAssociation in $AppAssociations) {
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
