function Start-Download ($Url, $SaveAs) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'Download failed: No download URL specified'
        return
    }

    $DownloadURL = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$CURRENT_DIR\$FileName"

    Add-Log $INF "Downloading from $DownloadURL"

    $IsNotConnected = Get-Connection
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        return
    }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) {Set-Success}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        return
    }

    return $FileName
}


function Start-File ($FileName, $Switches, $IsSilentInstall) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {Start-Extraction $FileName} else {$FileName}

    if ($Switches -and $IsSilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try {Start-Process "$CURRENT_DIR\$Executable" $Switches -Wait}
        catch [Exception] {
            Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"
            return
        }

        Set-Success

        Add-Log $INF "Removing $FileName..."
        Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
        Set-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {if ($Switches) {Start-Process "$CURRENT_DIR\$Executable" $Switches} else {Start-Process "$CURRENT_DIR\$Executable"}}
        catch [Exception] {
            Add-Log $ERR "Failed to execute' $Executable': $($_.Exception.Message)"
            return
        }

        Set-Success
    }
}


function Start-Extraction ($FileName) {
    Add-Log $INF "Extracting $FileName..."

    $ExtractionPath = if ($FileName -eq 'KMSAuto_Lite.zip' -or $FileName -match 'SDI_R*') {$FileName.trimend('.zip')}

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' {$Executable = 'CW.eXe'}
        'Office_2013-2019.zip' {$Executable = 'OInstall.exe'}
        'Victoria.zip' {$Executable = 'Victoria.exe'}
        'KMSAuto_Lite.zip' {$Executable = if ($OS_ARCH -eq '64-bit') {'KMSAuto x64.exe'} else {'KMSAuto.exe'}}
        'SDI_R*' {$Executable = "$ExtractionPath\SDI_auto.bat"}
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

    Set-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
    Set-Success

    return $Executable
}
