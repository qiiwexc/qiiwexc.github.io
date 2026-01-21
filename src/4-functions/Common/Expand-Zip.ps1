function Expand-Zip {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ZipPath,
        [Switch]$Temp
    )

    Write-ActivityProgress 50 "Extracting '$ZipPath'..."

    Set-Variable -Option Constant ZipName ([String](Split-Path -Leaf $ZipPath -ErrorAction Stop))
    Set-Variable -Option Constant ExtractionPath ([String]$ZipPath.TrimEnd('.7z').TrimEnd('.zip'))
    Set-Variable -Option Constant ExtractionDir ([String](Split-Path -Leaf $ExtractionPath -ErrorAction Stop))

    if ($Temp) {
        Set-Variable -Option Constant TargetPath ([String]$PATH_APP_DIR)
    } else {
        Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
    }

    Initialize-AppDirectory

    switch -Wildcard ($ZipName) {
        'Office_Installer.zip' {
            if (-not $OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]' x86.exe')
            }
            Set-Variable -Option Constant Executable ([String]"Office Installer$Suffix.exe")
        }
        'cpu-z_*' {
            if ($OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]'64')
            } else {
                Set-Variable -Option Constant Suffix ([String]'32')
            }
            Set-Variable -Option Constant Executable ([String]"$ExtractionDir\cpuz_x$Suffix.exe")
        }
        'SDI_*' {
            if ($OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]'64')
            }
            Set-Variable -Option Constant Executable ([String]"$ExtractionDir\SDI$Suffix-drv.exe")
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

    $Null = New-Item -Force -ItemType Directory $ExtractionPath -ErrorAction Stop

    try {
        if ($ZIP_SUPPORTED -and $ZipPath.Split('.')[-1].ToLower() -eq 'zip') {
            [IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractionPath)
        } else {
            if (-not $SHELL) {
                Set-Variable -Option Constant -Scope Script SHELL (New-Object -com Shell.Application)
            }

            foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($ExtractionPath).CopyHere($Item)
            }
        }
    } catch {
        Out-Failure "Failed to extract '$ZipPath': $_"
        return
    }

    Remove-File $ZipPath

    if (-not $IsDirectory) {
        Move-Item -Force $TemporaryExe $TargetExe -ErrorAction Stop
        Remove-Directory $ExtractionPath
    }

    if (-not $Temp -and $IsDirectory) {
        Remove-Directory "$TargetPath\$ExtractionDir"
        Move-Item -Force $ExtractionPath $TargetPath -ErrorAction Stop
    }

    Out-Success
    Write-LogInfo "Files extracted to '$TargetPath'"

    return $TargetExe
}
