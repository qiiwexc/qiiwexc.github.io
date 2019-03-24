function Start-Extraction ($FileName) {
    Add-Log $INF "Extracting $FileName..."

    $ExtractionPath = if ($FileName -eq 'KMSAuto_Lite.zip' -or $FileName -match 'SDI_R*') {$FileName.trimend('.zip')}

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' {$Executable = 'CW.eXe'}
        'Office_2013-2019.zip' {$Executable = 'OInstall.exe'}
        'Victoria.zip' {$Executable = 'Victoria.exe'}
        'KMSAuto_Lite.zip' {$Executable = if ($OS_ARCH -eq '64-bit') {'KMSAuto x64.exe'} else {'KMSAuto.exe'}}
        'SDI_R*' {$Executable = "$ExtractionPath\$(if ($OS_ARCH -eq '64-bit') {"$($ExtractionPath.Split('_') -Join '_x64_').exe"} else {"$ExtractionPath.exe"})"}
    }

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath) {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName)}
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        return
    }

    if ($FileName -eq 'KMSAuto_Lite.zip') {
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
