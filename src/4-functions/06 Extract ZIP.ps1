Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Execute
    )

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')
    Set-Variable -Option Constant ExtractionDir (Split-Path -Leaf $ExtractionPath)
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'ActivationProgram.zip' { "ActivationProgram$(if ($OS_64_BIT) {''} else {'_x86'}).exe" }
        'Office_Installer+.zip' { "Office Installer+$(if ($OS_64_BIT) {''} else {' x86'}).exe" }
        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
        'ventoy*' { "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe" }
        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
        Default { $ZipName.TrimEnd('.zip') + '.exe' }
    }

    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -Like "$ExtractionDir\*")
    Set-Variable -Option Constant TemporaryExe "$ExtractionPath\$Executable"
    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"

    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryExe
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
    New-Item -Force -ItemType Directory $ExtractionPath | Out-Null

    Add-Log $INF "Extracting '$ZipPath'..."

    try {
        if ($ZIP_SUPPORTED) {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractionPath)
        } else {
            ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($ExtractionPath).CopyHere($Item)
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
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
    }

    if (!$Execute -and $IsDirectory) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
        Move-Item -Force -ErrorAction SilentlyContinue $ExtractionPath $TargetPath
    }

    Out-Success
    Add-Log $INF "Files extracted to '$TargetPath'"

    Return $TargetExe
}
