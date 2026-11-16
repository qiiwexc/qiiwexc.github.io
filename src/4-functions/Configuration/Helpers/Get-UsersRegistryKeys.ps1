function Get-UsersRegistryKeys {
    try {
        Set-Variable -Option Constant Users ([String[]](Get-Item 'Registry::HKEY_USERS\*' -ErrorAction Stop).Name)
        # Local and domain accounts (S-1-5-21-...) and Microsoft Entra ID ones (S-1-12-1-...), without the
        # <SID>_Classes hives that go with them or the service accounts
        return $Users | ForEach-Object { Split-Path $_ -Leaf } | Where-Object { $_ -match '^S-1-(5-21|12-1)-[\d-]+$' }
    } catch {
        Write-LogWarning "Failed to retrieve users registry keys: $_"
        return $()
    }
}
