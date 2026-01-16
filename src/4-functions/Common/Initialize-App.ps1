function Initialize-App {
    $FORM.Activate()

    Write-FormLog ([LogLevel]::INFO) ([String]"[$((Get-Date).ToString())] Initializing...") -NoNewLine

    if ($OS_VERSION -lt 8) {
        Write-LogWarning "Windows $OS_VERSION detected, some features are not supported."
    }

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED ([Bool]$True)
    } catch {
        Write-LogWarning "Failed to load 'System.IO.Compression.FileSystem' module: $_"
    }

    Get-SystemInformation

    Initialize-AppDirectory

    Update-App
}
