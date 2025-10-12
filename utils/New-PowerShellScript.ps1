function New-PowerShellScript {
    param(
        [String][Parameter(Position = 0, Mandatory)]$SourcePath,
        [String][Parameter(Position = 1, Mandatory)]$Ps1File,
        [Collections.Generic.List[Object]][Parameter(Position = 2, Mandatory)]$Config
    )

    Write-LogInfo 'Building PowerShell script...'

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    Set-Variable -Option Constant ProjectFiles (Get-ChildItem -Recurse -File $SourcePath)
    Set-Variable -Option Constant FileCount $ProjectFiles.Length

    [Collections.Generic.List[String]]$OutputStrings = @()

    [Int]$CurrentFileNum = 1
    [String]$PreviousRegion = ''
    foreach ($File in $ProjectFiles) {
        [String]$FilePath = $File.FullName
        [String]$FileName = $File.Name

        [Switch]$IsConfigFile = -not ($FileName -match '\.ps1$')

        [String]$CurrentRegion = $FilePath.Replace('\src\', '|').Split('|')[1].Replace('\', ' > ') -replace '\..{1,}$', '' -replace '\d{1,2}(-|\s)', ''

        if ($CurrentFileNum -eq 1) {
            $OutputStrings.Add("#region $CurrentRegion`n")
        } else {
            $OutputStrings.Add("`n#endregion $PreviousRegion`n")
            $OutputStrings.Add("`n#region $CurrentRegion`n")
        }

        $PreviousRegion = $CurrentRegion

        [Collections.Generic.List[String]]$Content = Get-Content $FilePath

        if ($IsConfigFile) {
            [String]$VariableName = "CONFIG_$(($FileName.Replace(' ', '_') -replace '\..{1,}$', '').ToUpper())"
            [Collections.Generic.List[String]]$EscapedContent = $Content.Replace("'", '"')
            $EscapedContent[0] = "Set-Variable -Option Constant $VariableName '$($EscapedContent[0])"
            $OutputStrings += $EscapedContent
            $OutputStrings.Add("'")
        } else {
            $OutputStrings += $Content
        }

        if ($CurrentFileNum -eq $FileCount) {
            $OutputStrings.Add("`n#endregion $CurrentRegion")
        }

        $CurrentFileNum++
    }

    $Config | ForEach-Object { $OutputStrings = $OutputStrings.Replace("{$($_.key)}", $_.value) }

    Write-LogInfo "Writing output file $Ps1File"
    $OutputStrings | Out-File $Ps1File

    Out-Success
}
