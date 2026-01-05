function New-UnattendedFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Version,
        [String][Parameter(Position = 1, Mandatory)]$BuilderPath,
        [String][Parameter(Position = 2, Mandatory)]$SourcePath,
        [String][Parameter(Position = 3, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 4, Mandatory)]$BuildPath,
        [String][Parameter(Position = 5, Mandatory)]$DistPath,
        [String][Parameter(Position = 6, Mandatory)]$VmPath
    )

    Write-LogInfo 'Building unattended files...'

    Set-Variable -Option Constant TestLocale ([String]'English')

    Set-Variable -Option Constant UnattendedPath ([String]"$BuilderPath\unattended")
    Set-Variable -Option Constant ConfigsPath ([String]"$SourcePath\3-configs")

    Set-Variable -Option Constant NonLocalisedFileName ([String]'autounattend.xml')
    Set-Variable -Option Constant LocalisedFileNameTemplate ([String]'autounattend-{LOCALE}.xml')

    Set-Variable -Option Constant Locales ([Collections.Generic.List[String]]@('English', 'Russian'))

    Set-Variable -Option Constant BaseFile ([String]"$BuildPath\$NonLocalisedFileName")

    . "$UnattendedPath\New-UnattendedBase.ps1"
    . "$UnattendedPath\Set-AppRemovalList.ps1"
    . "$UnattendedPath\Set-CapabilitiesRemovalList.ps1"
    . "$UnattendedPath\Set-FeaturesRemovalList.ps1"
    . "$UnattendedPath\Set-InlineFiles.ps1"
    . "$UnattendedPath\Set-LocaleSettings.ps1"
    . "$UnattendedPath\Set-PowerSchemeConfiguration.ps1"
    . "$UnattendedPath\Set-WindowsSecurityConfiguration.ps1"

    New-UnattendedBase $TemplatesPath $BaseFile

    foreach ($Locale in $Locales) {
        [String]$OutputFileName = "$BuildPath\" + $LocalisedFileNameTemplate.Replace('{LOCALE}', $Locale)

        [String]$TemplateContent = Get-Content $BaseFile -Raw -Encoding UTF8

        $TemplateContent = Set-LocaleSettings $Locale $TemplateContent

        $TemplateContent = Set-AppRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-CapabilitiesRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-FeaturesRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-WindowsSecurityConfiguration $SourcePath $TemplateContent

        $TemplateContent = Set-PowerSchemeConfiguration $ConfigsPath $TemplateContent

        $TemplateContent = Set-InlineFiles $Locale $ConfigsPath $TemplateContent

        $TemplateContent = $TemplateContent.Replace('{VERSION}', $Version)

        Set-Content $OutputFileName $TemplateContent -NoNewline
    }

    Set-Variable -Option Constant BuiltFile ([String]("$BuildPath\" + $LocalisedFileNameTemplate.Replace('{LOCALE}', $TestLocale)))
    Set-Variable -Option Constant VmFile ([String]("$VmPath\unattend\$NonLocalisedFileName"))
    Copy-Item $BuiltFile $VmFile

    Set-Variable -Option Constant DevRegexReplacementMap ([Collections.Generic.List[Hashtable]]@(
            @{Regex = '\s*<File path="C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1">([\s\S]*?)<\/File>'; NewValue = '' },
            @{Regex = "\s*{\s*&amp; 'C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1';\s*};"; NewValue = '' },
            @{Regex = '\s*<ImageInstall>([\s\S]*?)<\/ImageInstall>'; NewValue = '' },
            @{Regex = '\s*<UserAccounts>([\s\S]*?)<\/UserAccounts>'; NewValue = '' },
            @{Regex = '\s*<AutoLogon>([\s\S]*?)<\/AutoLogon>'; NewValue = '' },
            @{Regex = '\s*<RunSynchronousCommand wcm:action="add">(?:[\s\S](?!<RunSynchronousCommand))*?diskpart[\s\S]*?<\/RunSynchronousCommand>'; NewValue = '' },
            @{Regex = '(?s)\s*\{[^{}]*?AutoLogonCount[^{}]*?\}\s*;'; NewValue = '' }
        )
    )

    foreach ($Locale in $Locales) {
        [String]$InputFileName = "$BuildPath\" + $LocalisedFileNameTemplate.Replace('{LOCALE}', $Locale)
        [String]$OutputFileName = "$DistPath\" + $LocalisedFileNameTemplate.Replace('{LOCALE}', $Locale)

        [String]$FileContent = Get-Content $InputFileName -Raw -Encoding UTF8

        foreach ($Item in $DevRegexReplacementMap) {
            $FileContent = $FileContent -replace $Item.Regex, $Item.NewValue
        }

        Set-Content $OutputFileName $FileContent -NoNewline
    }

    Out-Success
}
