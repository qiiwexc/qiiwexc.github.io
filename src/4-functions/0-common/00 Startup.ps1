function Initialize-Script {
    $FORM.Activate()

    Write-LogInfo 'Initializing...'

    Set-Variable -Option Constant IE_Registry_Key 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main'

    New-Item $IE_Registry_Key -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $IE_Registry_Key -Name 'DisableFirstRunCustomize' -Value 1 -ErrorAction SilentlyContinue

    if ($OS_VERSION -lt 8) {
        Write-LogWarning "Windows $OS_VERSION detected, some features are not supported."
    }

    try {
        [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
    } catch [Exception] {
        Write-LogWarning "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)"
    }

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
    } catch [Exception] {
        Set-Variable -Option Constant -Scope Script SHELL (New-Object -com Shell.Application)
        Write-LogWarning "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
    }

    Write-LogInfo 'Current system information:'

    Set-Variable -Option Constant Motherboard (Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer, Product)
    Set-Variable -Option Constant BIOS (Get-CimInstance -ClassName CIM_BIOSElement | Select-Object -Property Manufacturer, Name, ReleaseDate)

    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion)

    Set-Variable -Option Constant -Scope Script OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -like '*64') { $True })

    Set-Variable -Option Constant OfficeYear $(switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021 / 2024' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })

    Write-LogInfo "    Motherboard: $($Motherboard.Manufacturer) $($Motherboard.Product)"
    Write-LogInfo "    BIOS: $($BIOS.Manufacturer) $($BIOS.Name) (release date: $($BIOS.ReleaseDate))"
    Write-LogInfo "    Operation system: $($OPERATING_SYSTEM.Caption)"
    Write-LogInfo "    $(if ($OS_VERSION -ge 10) {'OS release / '})Build number: $(if ($OS_VERSION -ge 10) {"v$WindowsRelease / "})$($OPERATING_SYSTEM.Version)"
    Write-LogInfo "    OS architecture: $($OPERATING_SYSTEM.OSArchitecture)"
    Write-LogInfo "    OS language: $SYSTEM_LANGUAGE"
    Write-LogInfo "    Office version: $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"

    Get-CurrentVersion
}
