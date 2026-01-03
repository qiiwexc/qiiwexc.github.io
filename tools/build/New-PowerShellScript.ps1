function New-PowerShellScript {
    param(
        [String][Parameter(Position = 0, Mandatory)]$SourcePath,
        [String][Parameter(Position = 1, Mandatory)]$Ps1File,
        [Collections.Generic.List[Object]][Parameter(Position = 2, Mandatory)]$Config
    )

    Write-LogInfo 'Building PowerShell script...'

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    Set-Variable -Option Constant ProjectFiles ([Collections.Generic.List[Object]](Get-ChildItem $SourcePath -Recurse -File | Where-Object { $_.Name -notmatch '.\.Tests\.ps1$' }))
    Set-Variable -Option Constant FileCount ([Int]$ProjectFiles.Count)

    [Collections.Generic.List[String]]$OutputLines = @()

    [Int]$CurrentFileNum = 1
    [String]$PreviousRegion = ''
    foreach ($File in $ProjectFiles) {
        [String]$FilePath = $File.FullName
        [String]$FileName = $File.Name

        [Switch]$IsConfigFile = -not ($FileName -match '\.ps1$')

        [String]$CurrentRegion = $FilePath.Replace('\src\', '|').Split('|')[1].Replace('\', ' > ') -replace '\..{1,}$', '' -replace '\d{1,2}(-|\s)', ''

        if ($CurrentFileNum -eq 1) {
            $OutputLines.Add("#region $CurrentRegion`n")
        } else {
            $OutputLines.Add("`n#endregion $PreviousRegion`n")
            $OutputLines.Add("`n#region $CurrentRegion`n")
        }

        $PreviousRegion = $CurrentRegion

        [String]$Content = (Get-Content $FilePath -Raw -Encoding UTF8).TrimEnd()

        if ($IsConfigFile) {
            [String]$NormalizedFileName = $FileName.Replace(' ', '_') -replace '\..{1,}$', ''
            [String]$VariableName = "CONFIG_$($NormalizedFileName.ToUpper())"
            [Collections.Generic.List[String]]$EscapedContent = $Content.Replace("'", '"')
            $EscapedContent[0] = "Set-Variable -Option Constant $VariableName '$($EscapedContent[0])"
            $OutputLines += $EscapedContent
            $OutputLines.Add("'")
        } else {
            $OutputLines += $Content
        }

        if ($CurrentFileNum -eq $FileCount) {
            $OutputLines.Add("`n#endregion $CurrentRegion")
        }

        $CurrentFileNum++
    }

    $Config | ForEach-Object {
        [String]$Placeholder = "{$($_.key)}"
        $OutputLines = $OutputLines.Replace($Placeholder, $_.value)
    }

    Write-LogInfo "Writing output file $Ps1File"
    Set-Content $Ps1File $OutputLines

    Out-Success
}
