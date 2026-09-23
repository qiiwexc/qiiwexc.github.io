function Assert-UnattendedFile {
    param(
        [Parameter(Position = 0, Mandatory)][String]$FileName,
        [Parameter(Position = 1, Mandatory)][String]$Content
    )

    # Sections kept in the template for the development VM only: they wipe disk 0,
    # create a local account and log it on automatically. A published file must never contain them
    Set-Variable -Option Constant DevOnlyMarkers ([String[]]@('diskpart', '<ImageInstall>', '<UserAccounts>', '<AutoLogon>', 'AutoLogonCount', 'VBoxGuestAdditions.ps1'))

    foreach ($Marker in $DevOnlyMarkers) {
        if ($Content.IndexOf($Marker, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Development-only content '$Marker' left in $FileName"
        }
    }

    Set-Variable -Option Constant Placeholders ([String[]]@([Regex]::Matches($Content, '\{[A-Z][A-Z0-9_]*\}') | ForEach-Object { $_.Value } | Select-Object -Unique))
    if ($Placeholders.Count -gt 0) {
        throw "Unresolved placeholders in ${FileName}: $($Placeholders -join ', ')"
    }

    try {
        [Void]([Xml]$Content)
    } catch {
        throw "$FileName is not well-formed XML: $($_.Exception.Message)"
    }
}
