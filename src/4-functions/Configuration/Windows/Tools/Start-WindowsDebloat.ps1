function Start-WindowsDebloat {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$UsePreset,
        [Switch][Parameter(Position = 1, Mandatory)]$Personalisation,
        [Switch][Parameter(Position = 2, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting Windows 10/11 debloat utility...'

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        return
    }

    Set-Variable -Option Constant TargetPath ([String]"$PATH_TEMP_DIR\Win11Debloat")

    New-Item -Force -ItemType Directory $TargetPath | Out-Null

    if ($Personalisation) {
        Set-Variable -Option Constant AppsList ([Collections.Generic.List[String]]($CONFIG_DEBLOAT_APP_LIST + 'Microsoft.OneDrive'))
    } else {
        Set-Variable -Option Constant AppsList ([Collections.Generic.List[String]]$CONFIG_DEBLOAT_APP_LIST)
    }

    $AppsList | Set-Content "$TargetPath\CustomAppsList" -NoNewline

    if ($Personalisation) {
        Set-Variable -Option Constant Configuration ([Collections.Generic.List[String]]($CONFIG_DEBLOAT_PRESET_PERSONALISATION))
    } else {
        Set-Variable -Option Constant Configuration ([Collections.Generic.List[String]]$CONFIG_DEBLOAT_PRESET_BASE)
    }

    $Configuration | Set-Content "$TargetPath\LastUsedSettings.json" -NoNewline

    if ($UsePreset) {
        Set-Variable -Option Constant UsePresetParam ([String]'-RunSavedSettings')
    }

    if ($Silent) {
        Set-Variable -Option Constant SilentParam ([String]'-Silent')
    }

    if ($OS_VERSION -gt 10) {
        Set-Variable -Option Constant SysprepParam ([String]'-Sysprep')
    }

    Set-Variable -Option Constant Params ([String]"-NoRestartExplorer $SysprepParam $UsePresetParam $SilentParam")

    Invoke-CustomCommand -HideWindow "& ([ScriptBlock]::Create((irm 'https://debloat.raphi.re/'))) $Params"

    Out-Success
}
