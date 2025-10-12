function Set-SearchConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$FileName
    )

    Set-Variable -Option Constant LogIndentLevel 1

    Write-ActivityProgress -PercentComplete 35 -Task 'Applying Windows search index configuration...'

    [Collections.Generic.List[String]]$ConfigLines = @()

    try {
        Set-Variable -Option Constant FileExtensionRegistries ((Get-Item 'Registry::HKEY_CLASSES_ROOT\*' -ErrorAction Ignore).Name | Where-Object { $_ -match '^HKEY_CLASSES_ROOT\\\.' })
        Write-ActivityProgress -PercentComplete 50

        Set-Variable -Option Constant RegistriesCount ($FileExtensionRegistries.Count)
        Set-Variable -Option Constant Step ([Math]::Floor(20 / $RegistriesCount))

        [Int]$Iteration = 1
        foreach ($Registry in $FileExtensionRegistries) {
            [Int]$Percentage = 50 + $Iteration * $Step
            Write-ActivityProgress -PercentComplete $Percentage
            $Iteration++

            [Object]$PersistentHandlers = (Get-Item "Registry::$Registry\*").Name | Where-Object { $_ -match 'PersistentHandler' }

            foreach ($PersistentHandler in $PersistentHandlers) {
                [String]$DefaultHandler = (Get-ItemProperty "Registry::$PersistentHandler").'(default)'

                if ($DefaultHandler -and -not ($DefaultHandler -eq '{098F2470-BAE0-11CD-B579-08002B30BFEB}')) {
                    $ConfigLines.Add("`n[$Registry\PersistentHandler]`n")
                    $ConfigLines.Add("@=`"{098F2470-BAE0-11CD-B579-08002B30BFEB}`"`n")
                    $ConfigLines.Add("`"OriginalPersistentHandler`"=`"$DefaultHandler`"`n")
                }

            }
        }
    } catch [Exception] {
        Write-LogException $_ 'Failed to read the registry' $LogIndentLevel
    }

    if ($ConfigLines.Count) {
        Import-RegistryConfiguration $FileName $ConfigLines
    } else {
        Out-Success $LogIndentLevel
    }
}
