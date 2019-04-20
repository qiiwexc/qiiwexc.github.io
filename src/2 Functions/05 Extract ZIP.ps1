function Start-Extraction ($FileName) {
    Add-Log $INF "Extracting $FileName..."

    $IsMultiFileArchive = $FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip' -or $FileName -match 'hwmonitor_*' -or $FileName -match 'SDI_R*'
    $ExtractionPath = if ($IsMultiFileArchive) { $FileName.TrimEnd('.zip') }

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($IsMultiFileArchive) { Remove-Item $TargetDirName -Recurse -ErrorAction Ignore }

    try { [System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName) }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        return
    }

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' { $Executable = 'CW.eXe' }
        'Office_2013-2019.zip' { $Executable = 'OInstall.exe' }
        'Victoria.zip' { $Executable = 'Victoria.exe' }
        'AAct.zip' { $Executable = "AAct$(if ($OS_ARCH -eq '64-bit') {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { $Executable = "KMSAuto$(if ($OS_ARCH -eq '64-bit') {' x64'}).exe" }
        'hwmonitor_*' { $Executable = "HWMonitor_$(if ($OS_ARCH -eq '64-bit') {'x64'} else {'x32'}).exe" }
        'SDI_R*' { $Executable = "$ExtractionPath\$(if ($OS_ARCH -eq '64-bit') {"$($ExtractionPath.Split('_') -Join '_x64_').exe"} else {"$ExtractionPath.exe"})" }
    }

    if ($FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip' -or $FileName -match 'hwmonitor_*') {
        $TempDir = $TargetDirName
        $TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Out-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
    Out-Success

    return $Executable
}
