Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0)]$ZipPath = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No file name specified"),
        [Switch]$Execute
    )
    if (-not $ZipPath) { Return }

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant MultiFileArchive ($ZipName -eq 'AAct.zip' -or $ZipName -eq 'KMSAuto_Lite.zip' -or `
            $URL -Match 'hwmonitor_' -or $URL -Match 'SDI_R' -or $URL -Match 'Victoria')

    Set-Variable -Option Constant ExtractionPath $(if ($MultiFileArchive) { $ZipPath.TrimEnd('.zip') })
    Set-Variable -Option Constant TemporaryPath $(if ($ExtractionPath) { $ExtractionPath } else { $TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $TEMP_DIR } else { $CURRENT_DIR })
    Set-Variable -Option Constant ExtractionDir $(if ($ExtractionPath) { Split-Path -Leaf $ExtractionPath })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'Office_2013-2021.zip' { 'OInstall.exe' }
        'AAct.zip' { "AAct$(if ($OS_64_BIT) {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { "KMSAuto$(if ($OS_64_BIT) {' x64'}).exe" }
        'Victoria*' { 'Victoria.exe' }
        'SDI_R*' { "$ExtractionDir\$(if ($OS_64_BIT) {"$($ExtractionDir.Split('_') -Join '_x64_').exe"} else {"$ExtractionDir.exe"})" }
        Default { $ZipName.TrimEnd('.zip') + '.exe' }
    }

    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -Like "$ExtractionDir\*")
    Set-Variable -Option Constant TemporaryExe "$TemporaryPath\$Executable"
    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"

    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryExe
    if ($MultiFileArchive) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $TemporaryPath
        New-Item -Force -ItemType Directory $TemporaryPath | Out-Null
    }

    Add-Log $INF "Extracting $ZipPath..."

    try {
        if ($ZIP_SUPPORTED) { [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $TemporaryPath) }
        else { ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) { $SHELL.NameSpace($TemporaryPath).CopyHere($Item) } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $ZipPath': $($_.Exception.Message)"
        Return
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    if (-not $IsDirectory) {
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe
        if ($ExtractionPath) { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath }
    }

    if ( -not $Execute -and $IsDirectory) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryPath $TargetPath
    }

    Out-Success
    Add-Log $INF "Files extracted to $TemporaryPath"

    Return $TargetExe
}
