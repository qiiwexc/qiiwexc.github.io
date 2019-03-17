function DownloadFile ($URL, $FileName, $Execute) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    $SavePath = if ($FileName) {$FileName} else {$DownloadURL | Split-Path -Leaf}

    Write-Log $_INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path "$SavePath") {Write-Log $_WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Write-Log $_ERR "Download failed: $($_.Exception.Message)"
        return
    }

    if ($Execute) {ExtractAndExecute $SavePath}
}

function ExtractAndExecute ($FileName) {
    Write-Log $_INF "Extracting $FileName"

    switch -wildcard ($FileName) {
        'ChewWGA.zip' {
            $TargetDirName = '.'
            $Executable = 'CW.eXe'
        }
        'Office_2013-2019.zip' {
            $TargetDirName = '.'
            $Executable = 'OInstall.exe'
        }
        'Victoria_4.47.zip' {
            $TargetDirName = '.'
            $Executable = 'Victoria 4.47.exe'
        }
        'KMSAuto_Lite.zip' {
            $TargetDirName = $FileName.trimend('.zip')
            $Executable = if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'KMSAuto x64.exe'} else {'KMSAuto.exe'}
        }
        "SDI_R*" {
            $TargetDirName = $FileName.trimend('.zip')
            $Executable = "$TargetDirName\SDI_auto.bat"
        }
        Default {$TargetDirName = $FileName.trimend('.zip')}
    }

    if ($TargetDirName -ne '.') {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory($FileName, $TargetDirName)}
    catch [Exception] {
        Write-Log $_ERR "Extraction failed: $($_.Exception.Message)"
        return
    }

    if ($TargetDirName -eq 'KMSAuto_Lite') {
        $TempDir = $TargetDirName
        $TargetDirName = '.'

        Move-Item -Path "$TempDir\$Executable" -Destination "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Write-Log $_INF "Files extracted to $TargetDirName"

    Write-Log $_INF "Removing $FileName"
    Remove-Item $FileName -ErrorAction Ignore

    Write-Log $_WRN 'Extraction finished'

    Write-Log $_INF "Executing '$Executable'"
    & ".\$Executable"
}
