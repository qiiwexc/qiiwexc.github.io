function Start-Extraction {
    Param(
        [String][Parameter(Position = 0)]$FileName = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No file name specified"),
        [Switch][Parameter(Position = 1)][alias('MF')]$MultiFileArchive
    )
    if (-not $FileName) { Return }

    Add-Log $INF "Extracting $FileName..."

    $ExtractionPath = if ($MultiFileArchive) { $FileName.TrimEnd('.zip') }

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($MultiFileArchive) {
        Remove-Item $TargetDirName -Recurse -Force -ErrorAction SilentlyContinue
        New-Item $TargetDirName -ItemType Directory -Force | Out-Null
    }

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' { $Executable = 'CW.eXe' }
        'Office_2013-2019.zip' { $Executable = 'OInstall.exe' }
        'Victoria.zip' { $Executable = 'Victoria.exe' }
        'AAct.zip' { $Executable = "AAct$(if ($OS_ARCH -eq '64-bit') {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { $Executable = "KMSAuto$(if ($OS_ARCH -eq '64-bit') {' x64'}).exe" }
        'hwmonitor_*' { $Executable = "HWMonitor_$(if ($OS_ARCH -eq '64-bit') {'x64'} else {'x32'}).exe" }
        'Recuva.zip' { $Executable = "$ExtractionPath\recuva$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" }
        'SDI_R*' { $Executable = "$ExtractionPath\$(if ($OS_ARCH -eq '64-bit') {"$($ExtractionPath.Split('_') -Join '_x64_').exe"} else {"$ExtractionPath.exe"})" }
    }

    Remove-Item "$CURRENT_DIR\$Executable" -Force -ErrorAction SilentlyContinue

    try {
        if (-not $Shell) { [System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName) }
        else { foreach ($Item in $Shell.NameSpace("$CURRENT_DIR\$FileName").Items()) { $Shell.NameSpace($TargetDirName).CopyHere($Item) } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        Return
    }

    if ($FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip' -or $FileName -Match 'hwmonitor_*') {
        $TempDir = $TargetDirName
        $TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -Force
    }

    Out-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item "$CURRENT_DIR\$FileName" -Force
    Out-Success

    Return $Executable
}
