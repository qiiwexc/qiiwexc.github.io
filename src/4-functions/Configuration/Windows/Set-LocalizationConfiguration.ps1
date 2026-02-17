function Set-LocalizationConfiguration {
    try {
        Set-ItemProperty -Path 'HKCU:\Control Panel\International' -Name 'sCurrency' -Value ([Char]0x20AC) -ErrorAction Stop
    } catch {
        Out-Failure "Failed to set currency symbol: $_"
    }

    try {
        Set-WinHomeLocation -GeoId 140 -ErrorAction Stop
    } catch {
        Out-Failure "Failed to set home location to Latvia: $_"
    }

    try {
        $LanguageList = Get-WinUserLanguageList -ErrorAction Stop
        if (-not ($LanguageList | Where-Object { $_.LanguageTag -like 'lv' })) {
            $LanguageList.Add('lv')
            Set-WinUserLanguageList $LanguageList -Force -ErrorAction Stop
        }
        Out-Success
    } catch {
        Out-Failure "Failed to add Latvian language to user language list: $_"
    }
}
