function DownloadFile ($URL, $SaveAs, $Execute, $Switches) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$_CURRENT_DIR\$FileName"

    Write-Log $_INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path $SavePath) {Write-Log $_WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Write-Log $_ERR "Download failed: $($_.Exception.Message)"
        return
    }

    if ($Execute) {ExecuteFile $FileName $Switches}
}


function ExtractArchive ($FileName) {
    Write-Log $_INF "Extracting $FileName"

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

    $TargetDirName = "$_CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath -ne '.') {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$_CURRENT_DIR\$FileName", $TargetDirName)}
    catch [Exception] {
        Write-Log $_ERR "Extraction failed: $($_.Exception.Message)"
        return
    }

    if ($ExtractionPath -eq 'KMSAuto_Lite') {
        $TempDir = $TargetDirName
        $TargetDirName = $_CURRENT_DIR

        Move-Item -Path "$TempDir\$Executable" -Destination "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Write-Log $_WRN "Files extracted to $TargetDirName"

    Write-Log $_INF "Removing $FileName"
    Remove-Item "$_CURRENT_DIR\$FileName" -ErrorAction Ignore

    Write-Log $_WRN 'Extraction completed'

    return $Executable
}


function ExecuteFile ($FileName, $Switches) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {ExtractArchive $FileName} else {$FileName}

    if ($Switches) {
        Write-Log $_INF "Installing '$Executable' silently"

        try {Start-Process -Wait -FilePath "$_CURRENT_DIR\$Executable" -ArgumentList $Switches}
        catch [Exception] {
            Write-Log $_ERR "'$Executable' silent installation failed: $($_.Exception.Message)"
            return
        }

        Write-Log $_INF "Removing $FileName"
        Remove-Item "$_CURRENT_DIR\$FileName" -ErrorAction Ignore

        Write-Log $_WRN "'$Executable' installation completed"
    }
    else {
        Write-Log $_WRN "Executing '$Executable'"

        try {Start-Process -FilePath "$_CURRENT_DIR\$Executable"}
        catch [Exception] {
            Write-Log $_ERR "'$Executable' execution failed: $($_.Exception.Message)"
            return
        }
    }
}
