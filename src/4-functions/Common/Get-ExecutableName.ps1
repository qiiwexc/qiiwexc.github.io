function Get-ExecutableName {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ZipName,
        [String][Parameter(Position = 1, Mandatory)]$ExtractionDir
    )

    switch -Wildcard ($ZipName) {
        'Office_Installer.zip' {
            if (-not $OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]' x86')
            }
            return "Office Installer$Suffix.exe"
        }
        'cpu-z_*' {
            if ($OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]'64')
            } else {
                Set-Variable -Option Constant Suffix ([String]'32')
            }
            return "$ExtractionDir\cpuz_x$Suffix.exe"
        }
        'SDI_*' {
            if ($OS_64_BIT) {
                Set-Variable -Option Constant Suffix ([String]'64')
            }
            return "$ExtractionDir\SDI$Suffix-drv.exe"
        }
        'ventoy*' {
            return "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe"
        }
        'Victoria*' {
            return "$ExtractionDir\$ExtractionDir\Victoria.exe"
        }
        Default {
            return ($ZipName -replace '\.zip$', '') + '.exe'
        }
    }
}
