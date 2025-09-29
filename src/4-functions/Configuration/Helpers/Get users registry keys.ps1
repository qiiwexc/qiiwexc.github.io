function Get-UsersRegistryKeys {
    return ((Get-Item 'Registry::HKEY_USERS\*').Name | Where-Object { $_ -match '^S-1-5-21' -and $_ -notmatch '_Classes$' })
}
