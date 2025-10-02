function Initialize-App {
    $FORM.Activate()

    Write-LogInfo 'Initializing...'

    if ($OS_VERSION -lt 8) {
        Write-LogWarning "Windows $OS_VERSION detected, some features are not supported."
    }

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
    } catch [Exception] {
        Set-Variable -Option Constant -Scope Script SHELL (New-Object -com Shell.Application)
        Write-LogWarning "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
    }

    Get-SystemInformation

    Initialize-AppDirectory

    Update-App
}
