function Get-UsersRegistryKeys {
    try {
        Set-Variable -Option Constant Users ([String[]](Get-Item 'Registry::HKEY_USERS\*' -ErrorAction Stop).Name)
        return $Users | Where-Object { $_ -match 'S-1-5-21' -and $_ -notmatch '_Classes$' } | ForEach-Object { Split-Path $_ -Leaf }
    } catch {
        Write-LogWarning "Failed to retrieve users registry keys: $_"
        return $()
    }
}
