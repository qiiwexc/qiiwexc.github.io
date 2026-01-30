function Expand-Zip {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ZipPath,
        [Switch]$Temp
    )

    Write-ActivityProgress 50 "Extracting '$ZipPath'..."

    $Extension = [IO.Path]::GetExtension($ZipPath).ToLower()
    if ($Extension -notin @('.zip', '.7z')) {
        throw "Unsupported archive format: $Extension. Supported formats: .zip, .7z"
    }

    if (-not (Test-Path $ZipPath)) {
        throw "Archive not found: $ZipPath"
    }

    Set-Variable -Option Constant ZipName ([String](Split-Path -Leaf $ZipPath -ErrorAction Stop))
    Set-Variable -Option Constant ExtractionPath ([String]($ZipPath -replace '\.(zip|7z)$', ''))
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

    Initialize-AppDirectory

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
