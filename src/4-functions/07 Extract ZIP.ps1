Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Execute
    )

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')

    [Switch]$MultiFileArchive = !($ZipName -eq 'AAct.zip' -or $ZipName -eq 'Office_2013-2024.zip')

    Set-Variable -Option Constant TemporaryPath $(if ($MultiFileArchive) { $ExtractionPath } else { $PATH_TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant ExtractionDir $(if ($MultiFileArchive) { Split-Path -Leaf $ExtractionPath })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'AAct.zip' { "AAct$(if ($OS_64_BIT) {'_x64'}).exe" }
        'ActivationProgram.zip' { "ActivationProgram$(if ($OS_64_BIT) {''} else {'_x86'}).exe" }
        'Office_2013-2024.zip' { 'OInstall.exe' }
        'Office_Installer+.zip' { "Office Installer+$(if ($OS_64_BIT) {''} else {' x86'}).exe" }
        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
        'ventoy*' { "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe" }
        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
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

    Add-Log $INF "Extracting '$ZipPath'..."

    try {
        if ($ZIP_SUPPORTED) {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $TemporaryPath)
        } else {
            ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($TemporaryPath).CopyHere($Item)
            }
        }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract '$ZipPath': $($_.Exception.Message)"
        Return
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    if (!$IsDirectory) {
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe

        if ($MultiFileArchive) {
            Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
        }
    }

    if (!$Execute -and $IsDirectory) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryPath $TargetPath
    }

    Out-Success
    Add-Log $INF "Files extracted to '$TargetPath'"

    Return $TargetExe
}
