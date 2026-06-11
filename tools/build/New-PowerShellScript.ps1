function New-PowerShellScript {
    param(
        [Parameter(Position = 0, Mandatory)][String]$SourcePath,
        [Parameter(Position = 1, Mandatory)][String]$Ps1File,
        [Parameter(Position = 2, Mandatory)][PSCustomObject]$Config
    )

    New-Activity 'Building PowerShell script'

    Set-Variable -Option Constant ProjectFiles ([IO.FileInfo[]](Get-ChildItem $SourcePath -Recurse -File | Where-Object { $_.Name -notmatch '.\.Tests\.ps1$' }))
    Set-Variable -Option Constant FileCount ([Int]$ProjectFiles.Count)

    [Collections.Generic.List[String]]$OutputLines = @()

    [Int]$CurrentFileNum = 1
    [String]$PreviousRegion = ''
    foreach ($File in $ProjectFiles) {
        [String]$FilePath = $File.FullName
        [String]$FileName = $File.Name

        [Switch]$IsConfigFile = -not ($FileName -match '\.ps1$')

        # Normalize separators so the split works with both Windows and Unix paths
        [String]$NormalizedPath = $FilePath.Replace('\', '/')
        if ($NormalizedPath -notmatch '/src/') {
            throw "Source file is not under a 'src' directory: $FilePath"
        }

        # Numeric ordering prefixes are stripped only at the start of each path segment
        [String]$CurrentRegion = $NormalizedPath.Replace('/src/', '|').Split('|')[1].Replace('/', ' > ') -replace '\..{1,}$', '' -replace '(?<=^|> )\d{1,2}(-|\s)', ''

        if ($CurrentFileNum -eq 1) {
            $OutputLines.Add("#region $CurrentRegion`n")
        } else {
            $OutputLines.Add("`n#endregion $PreviousRegion`n")
            $OutputLines.Add("`n#region $CurrentRegion`n")
        }

        $PreviousRegion = $CurrentRegion

        [String]$Content = (Read-TextFile $FilePath).TrimEnd()

        if (-not $IsConfigFile) {
            [Management.Automation.PSParseError[]]$SyntaxErrors = @()
            [Void][Management.Automation.PSParser]::Tokenize($Content, [Ref]$SyntaxErrors)
            if ($SyntaxErrors.Count -gt 0) {
                throw "Syntax error in '$FileName': $($SyntaxErrors[0].Message) (line $($SyntaxErrors[0].Token.StartLine))"
            }
        }

        if ($IsConfigFile) {
            [String]$NormalizedFileName = $FileName.Replace(' ', '_') -replace '\..{1,}$', ''
            [String]$VariableName = "CONFIG_$($NormalizedFileName.ToUpper())"
            [String[]]$EscapedContent = $Content.Replace("'", "''")
            $EscapedContent[0] = "Set-Variable -Option Constant $VariableName ([String]('$($EscapedContent[0])"
            $OutputLines.Add($EscapedContent)
            $OutputLines.Add("'))")
        } else {
            $OutputLines.Add($Content)
        }

        if ($CurrentFileNum -eq $FileCount) {
            $OutputLines.Add("`n#endregion $CurrentRegion")
        }

        $CurrentFileNum++
    }

    $Config.PSObject.Properties | ForEach-Object {
        [String]$Placeholder = "{$($_.Name)}"
        $OutputLines = $OutputLines.Replace($Placeholder, $_.Value)
    }

    [String]$BundledScript = $OutputLines -join "`n"

    # Fail the build instead of shipping a script with unresolved '{KEY}' placeholders
    [String[]]$ResidualPlaceholders = @([regex]::Matches($BundledScript, '\{[A-Z][A-Z0-9_]*\}') | ForEach-Object { $_.Value } | Select-Object -Unique)
    if ($ResidualPlaceholders.Count -gt 0) {
        throw "Unresolved placeholders in bundled script: $($ResidualPlaceholders -join ', ')"
    }

    # Per-file checks cannot catch cross-file problems (for example a broken config
    # embedding) — verify the assembled script parses before writing it
    try {
        [Void][ScriptBlock]::Create($BundledScript)
    } catch {
        throw "Bundled script has syntax errors: $_"
    }

    Write-LogInfo "Writing output file $Ps1File"
    Write-TextFile $Ps1File $OutputLines

    Write-ActivityCompleted
}
