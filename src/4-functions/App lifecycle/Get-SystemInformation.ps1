function Get-SystemInformation {
    Write-LogInfo 'Current system information:'

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Set-Variable -Option Constant Motherboard ([PSObject](Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer, Product))
    Write-LogInfo "Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)" $LogIndentLevel

    Set-Variable -Option Constant BIOS ([PSObject](Get-CimInstance -ClassName CIM_BIOSElement | Select-Object -Property Manufacturer, Name, ReleaseDate))
    Write-LogInfo "BIOS: $($BIOS.Manufacturer) $($BIOS.Name) (release date: $($BIOS.ReleaseDate))" $LogIndentLevel

    Write-LogInfo "Operation system: $($OPERATING_SYSTEM.Caption)" $LogIndentLevel

    Set-Variable -Option Constant WindowsRelease ([String](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion)

    Write-LogInfo "OS release: v$WindowsRelease" $LogIndentLevel
    Write-LogInfo "Build number: $($OPERATING_SYSTEM.Version)" $LogIndentLevel
    Write-LogInfo "OS architecture: $($OPERATING_SYSTEM.OSArchitecture)" $LogIndentLevel
    Write-LogInfo "OS language: $SYSTEM_LANGUAGE" $LogIndentLevel

    switch ($OFFICE_VERSION) {
        16 {
            Set-Variable -Option Constant OfficeYear ([String]'2016 / 2019 / 2021 / 2024')
        }
        15 {
            Set-Variable -Option Constant OfficeYear ([String]'2013')
        }
        14 {
            Set-Variable -Option Constant OfficeYear ([String]'2010')
        }
        12 {
            Set-Variable -Option Constant OfficeYear ([String]'2007')
        }
    }

    if ($OfficeYear) {
        Set-Variable -Option Constant OfficeName ([String]"Microsoft Office $OfficeYear")
    } else {
        Set-Variable -Option Constant OfficeName ([String]'Unknown version or not installed')
    }

    Write-LogInfo "Office version: $OfficeName" $LogIndentLevel

    if ($OFFICE_INSTALL_TYPE) {
        Write-LogInfo "Office installation type: $OFFICE_INSTALL_TYPE" $LogIndentLevel
    }
}
