function DownloadFile ($Url, $SaveAs, $Execute, $Switches) {
    if ($Url.length -lt 1) {
        Write-Log $ERR 'No download URL specified'
        return
    }

    $DownloadURL = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$CURRENT_DIR\$FileName"

    Write-Log $INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) {Write-Log $WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Write-Log $ERR "Download failed: $($_.Exception.Message)"
        return
    }

    if ($Execute) {ExecuteFile $FileName $Switches}
}


function ExecuteFile ($FileName, $Switches) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {ExtractArchive $FileName} else {$FileName}

    if ($Switches) {
        Write-Log $INF "Installing '$Executable' silently..."

        try {Start-Process "$CURRENT_DIR\$Executable" $Switches -Wait}
        catch [Exception] {
            Write-Log $ERR "'$Executable' silent installation failed: $($_.Exception.Message)"
            return
        }

        Write-Log $INF "Removing $FileName..."
        Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore

        Write-Log $WRN "'$Executable' installation completed"
    }
    else {
        Write-Log $WRN "Executing '$Executable'..."

        try {Start-Process "$CURRENT_DIR\$Executable"}
        catch [Exception] {Write-Log $ERR "'$Executable' execution failed: $($_.Exception.Message)"}
    }
}


function ExtractArchive ($FileName) {
    Write-Log $INF "Extracting $FileName..."

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' {
            $ExtractionPath = '.'
            $Executable = 'CW.eXe'
        }
        'Office_2013-2019.zip' {
            $ExtractionPath = '.'
            $Executable = 'OInstall.exe'
        }
        'Victoria.zip' {
            $ExtractionPath = '.'
            $Executable = 'Victoria.exe'
        }
        'KMSAuto_Lite.zip' {
            $ExtractionPath = $FileName.trimend('.zip')
            $Executable = if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'KMSAuto x64.exe'} else {'KMSAuto.exe'}
        }
        "SDI_R*" {
            $ExtractionPath = $FileName.trimend('.zip')
            $Executable = "$ExtractionPath\SDI_auto.bat"
        }
        Default {$ExtractionPath = $FileName.trimend('.zip')}
    }

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath -ne '.') {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName)}
    catch [Exception] {
        Write-Log $ERR "Extraction failed: $($_.Exception.Message)"
        return
    }

    if ($ExtractionPath -eq 'KMSAuto_Lite') {
        $TempDir = $TargetDirName
        $TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Write-Log $WRN "Files extracted to $TargetDirName"

    Write-Log $INF "Removing $FileName..."
    Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore

    Write-Log $WRN 'Extraction completed'

    return $Executable
}
