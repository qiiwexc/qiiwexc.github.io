function Set-SearchConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FileName
    )

    Write-LogInfo 'Applying Windows search index configuration...'

    [String]$ConfigLines = ''

    try {
        Set-Variable -Option Constant FileExtensionRegistries ((Get-Item 'Registry::HKEY_CLASSES_ROOT\*' -ErrorAction SilentlyContinue).Name | Where-Object { $_ -match '^HKEY_CLASSES_ROOT\\\.' })
        foreach ($Registry in $FileExtensionRegistries) {
            [Object]$PersistentHandlers = (Get-Item "Registry::$Registry\*").Name | Where-Object { $_ -match 'PersistentHandler' }

            foreach ($PersistentHandler in $PersistentHandlers) {
                [String]$DefaultHandler = (Get-ItemProperty "Registry::$PersistentHandler").'(default)'

                if ($DefaultHandler -and -not ($DefaultHandler -eq '{098F2470-BAE0-11CD-B579-08002B30BFEB}')) {
                    $ConfigLines += "`n[$Reg]`n"
                    $ConfigLines += "@=`"{098F2470-BAE0-11CD-B579-08002B30BFEB}`"`n"
                    $ConfigLines += "`"OriginalPersistentHandler`"=`"$DefaultHandler`"`n"
                }

            }
        }
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to read the registry'
    }

    if ($ConfigLines) {
        Import-RegistryConfiguration $FileName $ConfigLines
    } else {
        Out-Success
    }
}
