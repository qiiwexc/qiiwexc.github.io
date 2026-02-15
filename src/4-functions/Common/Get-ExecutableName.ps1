function Get-ExecutableName {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ZipName,
        [Parameter(Position = 1, Mandatory)][String]$ExtractionDir
    )

    switch -Wildcard ($ZipName) {
        'Office_Installer.zip' {
            [String]$Suffix = ''
            if (-not $OS_64_BIT) {
                $Suffix = ' x86'
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
            [String]$Suffix = ''
            if ($OS_64_BIT) {
                $Suffix = '64'
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
            return ($ZipName -replace '\.[^.]+$', '') + '.exe'
        }
    }
}
