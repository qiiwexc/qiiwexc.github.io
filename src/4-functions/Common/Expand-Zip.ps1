function Expand-Zip {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ZipPath,
        [Switch]$Temp
    )

    Write-ActivityProgress 65 "Extracting '$ZipPath'..."

    if (-not (Test-Path $ZipPath)) {
        throw "Archive not found: $ZipPath"
    }

    Set-Variable -Option Constant ZipName ([String](Split-Path -Leaf $ZipPath -ErrorAction Stop))
    Set-Variable -Option Constant ExtractionPath ([String]($ZipPath -replace '\.[^.]+$', ''))
    Set-Variable -Option Constant ExtractionDir ([String](Split-Path -Leaf $ExtractionPath -ErrorAction Stop))

    if ($Temp) {
        Set-Variable -Option Constant TargetPath ([String]$PATH_APP_DIR)
    } else {
        Set-Variable -Option Constant TargetPath ([String]$PATH_WORKING_DIR)
    }

    Set-Variable -Option Constant Executable ([String](Get-ExecutableName $ZipName $ExtractionDir))

    Set-Variable -Option Constant IsDirectory ([Bool]($ExtractionDir -and $Executable -like "$ExtractionDir\*"))
    Set-Variable -Option Constant TemporaryExe ([String]"$ExtractionPath\$Executable")
    Set-Variable -Option Constant TargetExe ([String]"$TargetPath\$Executable")

    if (Test-Path $TargetExe) {
        Write-LogWarning 'Previous extraction found, returning it'
        return $TargetExe
    }

    Write-ActivityProgress 70

    Initialize-AppDirectory

    Remove-File $TemporaryExe

    Remove-Directory $ExtractionPath

    New-Directory $ExtractionPath

    Write-ActivityProgress 75

    if (Test-Path $PATH_7ZIP_EXE) {
        Invoke-7Zip $ExtractionPath $ZipPath
    } else {
        if ($ZipPath.Split('.')[-1].ToLower() -eq 'zip') {
            Expand-Archive $ZipPath $ExtractionPath -Force -ErrorAction Stop
        } elseif ($OS_VERSION -ge 11) {
            Set-Variable -Option Constant SHELL (New-Object -ComObject Shell.Application)

            foreach ($Item in $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($ExtractionPath).CopyHere($Item, 4)
            }
        } else {
            throw "7-Zip not found at '$PATH_7ZIP_EXE'"
        }
    }

    Write-ActivityProgress 80

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
