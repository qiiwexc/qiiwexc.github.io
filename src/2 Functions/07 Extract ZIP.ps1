Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0)]$FileName = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No file name specified"),
        [Switch][Parameter(Position = 1)][Alias('MF')]$MultiFileArchive
    )
    if (-not $FileName) { Return }

    Add-Log $INF "Extracting $FileName..."

    Set-Variable -Option Constant ExtractionPath $(if ($MultiFileArchive) { $FileName.TrimEnd('.zip') })

    [String]$TargetDirName = $ExtractionPath
    if ($MultiFileArchive) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $TargetDirName
        New-Item -ItemType Directory -Force $TargetDirName | Out-Null
    }

    # FIXME: relative vs absolute path
    [String]$Executable = Switch -Wildcard ($FileName) {
        'ChewWGA.zip' { 'CW.eXe' }
        'DriverStoreExplorer*' { 'Rapr.exe' }
        'Office_2013-2019.zip' { 'OInstall.exe' }
        'AAct.zip' { "AAct$(if ($OS_ARCH -eq '64-bit') {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { "KMSAuto$(if ($OS_ARCH -eq '64-bit') {' x64'}).exe" }
        'hwmonitor_*' { "HWMonitor_$(if ($OS_ARCH -eq '64-bit') {'x64'} else {'x32'}).exe" }
        'Recuva.zip' { "$ExtractionPath\recuva$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" }
        'SDI_R*' { "$ExtractionPath\$(if ($OS_ARCH -eq '64-bit') {"$($ExtractionPath.Split('_') -Join '_x64_').exe"} else {"$ExtractionPath.exe"})" }
        Default { $FileName.TrimEnd('.zip') + '.exe' }
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $Executable

    try {
        if (-not $Shell) { [System.IO.Compression.ZipFile]::ExtractToDirectory($FileName, $TargetDirName) }
        else { ForEach ($Item In $Shell.NameSpace($FileName).Items()) { $Shell.NameSpace($TargetDirName).CopyHere($Item) } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        Return
    }

    if ($FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip' -or $FileName -Match 'hwmonitor_*') {
        Set-Variable -Option Constant TempDir $TargetDirName
        [String]$TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item -Recurse -Force $TempDir
    }

    Out-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item -Force $FileName
    Out-Success

    Return $Executable
}
