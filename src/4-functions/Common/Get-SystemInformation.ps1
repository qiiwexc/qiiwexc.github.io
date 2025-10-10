function Get-SystemInformation {
    Write-LogInfo 'Current system information:'

    Set-Variable -Option Constant LogIndentLevel 1

    Set-Variable -Option Constant Motherboard (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer, Product)
    Set-Variable -Option Constant BIOS (Get-CimInstance -ClassName CIM_BIOSElement | Select-Object -Property Manufacturer, Name, ReleaseDate)

    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion)

    Set-Variable -Option Constant -Scope Script OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -like '*64') { $True })

    Set-Variable -Option Constant OfficeYear $(switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021 / 2024' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })

    Write-LogInfo "Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)" $LogIndentLevel
    Write-LogInfo "BIOS: $($BIOS.Manufacturer) $($BIOS.Name) (release date: $($BIOS.ReleaseDate))" $LogIndentLevel
    Write-LogInfo "Operation system: $($OPERATING_SYSTEM.Caption)" $LogIndentLevel
    Write-LogInfo "$(if ($OS_VERSION -ge 10) {'OS release / '})Build number: $(if ($OS_VERSION -ge 10) {"v$WindowsRelease / "})$($OPERATING_SYSTEM.Version)" $LogIndentLevel
    Write-LogInfo "OS architecture: $($OPERATING_SYSTEM.OSArchitecture)" $LogIndentLevel
    Write-LogInfo "OS language: $SYSTEM_LANGUAGE" $LogIndentLevel
    Write-LogInfo "Office version: $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})" $LogIndentLevel
}
