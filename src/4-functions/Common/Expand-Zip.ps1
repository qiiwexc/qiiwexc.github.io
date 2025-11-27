function Expand-Zip {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ZipPath,
        [Switch]$Temp
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-ActivityProgress -PercentComplete 50 -Task "Extracting '$ZipPath'..."

    Set-Variable -Option Constant ZipName ([String](Split-Path -Leaf $ZipPath))
    Set-Variable -Option Constant ExtractionPath ([String]$ZipPath.TrimEnd('.zip'))
    Set-Variable -Option Constant ExtractionDir ([String](Split-Path -Leaf $ExtractionPath))

    if ($Temp) {
        Set-Variable -Option Constant TargetPath ([String]$PATH_APP_DIR)
    } else {
        Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
    }

    Initialize-AppDirectory

    switch -Wildcard ($ZipName) {
        'ActivationProgram.zip' {
            if (-not $OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]'_x86.exe')
            }
            Set-Variable -Option Constant Executable ([String]"ActivationProgram$Suffix.exe")
        }
        'Office_Installer+.zip' {
            if (-not $OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]' x86.exe')
            }
            Set-Variable -Option Constant Executable ([String]"Office Installer+$Suffix.exe")
        }
        'cpu-z_*' {
            if ($OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]'64')
            } else {
                Set-Variable -Option Constant Suffix ([String]'32')
            }
            Set-Variable -Option Constant Executable ([String]"$ExtractionDir\cpuz_x$Suffix.exe")
        }
        'SDIO_*' {
            Set-Variable -Option Constant Executable ([String]"$ExtractionDir\SDIO_auto.bat")
        }
        'ventoy*' {
            Set-Variable -Option Constant Executable ([String]"$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe")
        }
        'Victoria*' {
            Set-Variable -Option Constant Executable ([String]"$ExtractionDir\$ExtractionDir\Victoria.exe")
        }
        Default {
            Set-Variable -Option Constant Executable ([String]($ZipName.TrimEnd('.zip') + '.exe'))
        }
    }

    Set-Variable -Option Constant IsDirectory ([Bool]($ExtractionDir -and $Executable -like "$ExtractionDir\*"))
    Set-Variable -Option Constant TemporaryExe ([String]"$ExtractionPath\$Executable")
    Set-Variable -Option Constant TargetExe ([String]"$TargetPath\$Executable")

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
