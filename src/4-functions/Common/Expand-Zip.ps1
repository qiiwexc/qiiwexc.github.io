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
                Set-Variable -Option Constant Suffix ([String]' x86')
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

    New-Directory $ExtractionPath

    if ($ZipPath.Split('.')[-1].ToLower() -eq 'zip') {
        Expand-Archive $ZipPath $ExtractionPath -Force -ErrorAction Stop
    } else {
        if (-not $SHELL) {
            Set-Variable -Option Constant -Scope Script SHELL (New-Object -ComObject Shell.Application)
        }

        foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
            $SHELL.NameSpace($ExtractionPath).CopyHere($Item, 4)
        }
    }

    Remove-File $ZipPath

    if (-not $IsDirectory) {
        Move-Item -Force $TemporaryExe $TargetExe -ErrorAction Stop
        Remove-Directory $ExtractionPath
    } elseif (-not $Temp) {
        Remove-Directory "$TargetPath\$ExtractionDir"
        Move-Item -Force $ExtractionPath $TargetPath -ErrorAction Stop
    }

    Out-Success
    Write-LogInfo "Files extracted to '$TargetPath'"

    return $TargetExe
}
