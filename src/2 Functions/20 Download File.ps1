function DownloadFile ($URL, $SaveAs, $Execute) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$CurrentDirectory\$FileName"

    Write-Log $_INF "Downloading from $DownloadURL"
    Write-Log $_INF "SavePath = $SavePath"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path $SavePath) {Write-Log $_WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Write-Log $_ERR "Download failed: $($_.Exception.Message)"
        return
    }

    if ($Execute) {Execute $FileName}
}

function Extract ($FileName) {
    Write-Log $_INF "Extracting $FileName"

    switch -wildcard ($FileName) {
        'ChewWGA.zip' {
            $ExtractionPath = '.'
            $Executable = 'CW.eXe'
        }
        'Office_2013-2019.zip' {
            $ExtractionPath = '.'
            $Executable = 'OInstall.exe'
        }
        'Victoria_4.47.zip' {
            $ExtractionPath = '.'
            $Executable = 'Victoria 4.47.exe'
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

    $TargetDirName = "$CurrentDirectory\$ExtractionPath"
    if ($ExtractionPath -ne '.') {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$CurrentDirectory\$FileName", $TargetDirName)}
    catch [Exception] {
        Write-Log $_ERR "Extraction failed: $($_.Exception.Message)"
        return
    }

    if ($ExtractionPath -eq 'KMSAuto_Lite') {
        $TempDir = $TargetDirName
        $TargetDirName = $CurrentDirectory

        Move-Item -Path "$TempDir\$Executable" -Destination "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Write-Log $_INF "Files extracted to $TargetDirName"

    Write-Log $_INF "Removing $FileName"
    Remove-Item "$CurrentDirectory\$FileName" -ErrorAction Ignore

    Write-Log $_WRN 'Extraction finished'

    return $Executable
}

function Execute ($FileName) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {Extract $FileName} else {$FileName}

    Write-Log $_INF "Executing '$Executable'"
    & "$CurrentDirectory\$Executable"
}
