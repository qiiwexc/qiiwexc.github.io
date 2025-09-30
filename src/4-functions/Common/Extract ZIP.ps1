function Expand-Zip {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Temp
    )

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')
    Set-Variable -Option Constant ExtractionDir (Split-Path -Leaf $ExtractionPath)
    Set-Variable -Option Constant TargetPath $(if ($Temp) { $PATH_APP_DIR } else { $PATH_WORKING_DIR })

    Initialize-AppDirectory

    [String]$Executable = switch -Wildcard ($ZipName) {
        'ActivationProgram.zip' { "ActivationProgram$(if ($OS_64_BIT) {''} else {'_x86'}).exe" }
        'Office_Installer+.zip' { "Office Installer+$(if ($OS_64_BIT) {''} else {' x86'}).exe" }
        'cpu-z_*' { "$ExtractionDir\cpuz_x$(if ($OS_64_BIT) {'64'} else {'32'}).exe" }
        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
        'ventoy*' { "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe" }
        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
        Default { $ZipName.TrimEnd('.zip') + '.exe' }
    }

    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -like "$ExtractionDir\*")
    Set-Variable -Option Constant TemporaryExe "$ExtractionPath\$Executable"
    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"

    if (Test-Path $TemporaryExe) {
        Remove-Item -Force $TemporaryExe
    }

    if (Test-Path $ExtractionPath) {
        Remove-Item -Force -Recurse $ExtractionPath
    }

    New-Item -Force -ItemType Directory $ExtractionPath | Out-Null

    Write-LogInfo "Extracting '$ZipPath'..."

    try {
        if ($ZIP_SUPPORTED) {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractionPath)
        } else {
            foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($ExtractionPath).CopyHere($Item)
            }
        }
    } catch [Exception] {
        Write-ExceptionLog $_ "Failed to extract '$ZipPath'"
        return
    }

    if (Test-Path $ZipPath) {
        Remove-Item -Force $ZipPath
    }

    if (-not $IsDirectory) {
        Move-Item -Force $TemporaryExe $TargetExe

        if (Test-Path $ExtractionPath) {
            Remove-Item -Force -Recurse $ExtractionPath
        }
    }

    if (-not $Temp -and $IsDirectory) {
        if (Test-Path "$TargetPath\$ExtractionDir") {
            Remove-Item -Force -Recurse "$TargetPath\$ExtractionDir"
        }

        Move-Item -Force $ExtractionPath $TargetPath
    }

    Out-Success
    Write-LogInfo "Files extracted to '$TargetPath'"

    return $TargetExe
}
