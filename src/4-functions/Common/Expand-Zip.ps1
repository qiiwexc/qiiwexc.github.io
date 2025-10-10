function Expand-Zip {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Temp
    )

    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress -PercentComplete 50 -Task "Extracting '$ZipPath'..."

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

    Remove-File $TemporaryExe

    Remove-Directory $ExtractionPath

    New-Item -Force -ItemType Directory $ExtractionPath | Out-Null

    try {
        if ($ZIP_SUPPORTED) {
            [IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractionPath)
        } else {
            foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($ExtractionPath).CopyHere($Item)
            }
        }
    } catch [Exception] {
        Write-LogException $_ "Failed to extract '$ZipPath'" $LogIndentLevel
        return
    }

    Remove-File $ZipPath

    if (-not $IsDirectory) {
        Move-Item -Force $TemporaryExe $TargetExe
        Remove-Directory $ExtractionPath
    }

    if (-not $Temp -and $IsDirectory) {
        Remove-Directory "$TargetPath\$ExtractionDir"
        Move-Item -Force $ExtractionPath $TargetPath
    }

    Out-Success $LogIndentLevel
    Write-LogInfo "Files extracted to '$TargetPath'" $LogIndentLevel

    return $TargetExe
}
