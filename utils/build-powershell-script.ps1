function New-PowerShellScript {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$SourcePath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Ps1File,
        [System.Object[]][Parameter(Position = 2, Mandatory = $True)]$Config
    )

    Write-LogInfo 'Building PowerShell script...'

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    Set-Variable -Option Constant ProjectFiles (Get-ChildItem -Recurse -File $SourcePath)
    Set-Variable -Option Constant FileCount $ProjectFiles.Length

    [String[]]$OutputStrings = @()

    [Int]$CurrentFileNum = 1
    [String]$PreviousRegion = ''
    foreach ($File in $ProjectFiles) {
        [String]$FilePath = $File.FullName
        [String]$FileName = $File.Name

        [Boolean]$IsConfigFile = -not ($FileName -match '\.ps1$')

        [String]$CurrentRegion = $FilePath.Replace('\src\', '|').Split('|')[1].Replace('\', ' > ') -replace '\..{1,}$', '' -replace '\d{1,2}(-|\s)', ''

        if ($CurrentFileNum -eq 1) {
            $OutputStrings += "#region $CurrentRegion`n"
        } else {
            $OutputStrings += "`n#endregion $PreviousRegion`n"
            $OutputStrings += "`n#region $CurrentRegion`n"
        }

        $PreviousRegion = $CurrentRegion

        [String[]]$Content = Get-Content $FilePath

        if ($IsConfigFile) {
            [String]$VariableName = "CONFIG_$(($FileName.Replace(' ', '_') -replace '\..{1,}$', '').ToUpper())"
            $Content[0] = "Set-Variable -Option Constant $VariableName '$($Content[0])"
            $OutputStrings += $Content
            $OutputStrings += "'"
        } else {
            $OutputStrings += $Content
        }

        if ($CurrentFileNum -eq $FileCount) {
            $OutputStrings += "`n#endregion $CurrentRegion"
        }

        $CurrentFileNum++
    }

    $Config | ForEach-Object { $OutputStrings = $OutputStrings.Replace("{$($_.key)}", $_.value) }

    Write-LogInfo "Writing output file $Ps1File"
    $OutputStrings | Out-File $Ps1File

    Out-Success
}
