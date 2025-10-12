function Set-FileAssociation {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Application,
        [String][Parameter(Position = 1, Mandatory)]$RegistryPath,
        [Switch][Parameter(Position = 2)]$SetDefault
    )

    New-RegistryKeyIfMissing $RegistryPath

    if ($SetDefault) {
        Set-Variable -Option Constant DefaultAssociation (Get-ItemProperty -Path $RegistryPath).'(Default)'
        if ($DefaultAssociation -ne $Application) {
            Set-ItemProperty -Path $RegistryPath -Name '(Default)' -Value $Application
        }
    }

    Set-Variable -Option Constant OpenWithProgidsPath "$RegistryPath\OpenWithProgids"
    New-RegistryKeyIfMissing $OpenWithProgidsPath

    Set-Variable -Option Constant OpenWithProgids (Get-ItemProperty -Path $OpenWithProgidsPath)
    if ($OpenWithProgids) {
        Set-Variable -Option Constant OpenWithProgidsNames ($OpenWithProgids | Get-Member -MemberType NoteProperty).Name
        Set-Variable -Option Constant Progids ($OpenWithProgidsNames | Where-Object { $_ -ne 'PSDrive' -and $_ -ne 'PSProvider' -and $_ -ne 'PSPath' -and $_ -ne 'PSParentPath' -and $_ -ne 'PSChildName' })

        foreach ($Progid in $Progids) {
            if ($Progid -ne $Application) {
                Remove-ItemProperty -Path $OpenWithProgidsPath -Name $Progid
            }
        }

        if (-not ($Progids -contains $Application)) {
            New-ItemProperty -Path $OpenWithProgidsPath -Name $Application -Value ''
        }
    } else {
        New-ItemProperty -Path $OpenWithProgidsPath -Name $Application -Value ''
    }
}
