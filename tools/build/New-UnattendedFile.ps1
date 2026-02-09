function New-UnattendedFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Version,
        [String][Parameter(Position = 1, Mandatory)]$BuilderPath,
        [String][Parameter(Position = 2, Mandatory)]$SourcePath,
        [String][Parameter(Position = 3, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 4, Mandatory)]$BuildPath,
        [String][Parameter(Position = 5, Mandatory)]$VmPath,
        [Switch]$CI
    )

    New-Activity 'Building unattended files'

    Set-Variable -Option Constant TestLocale ([String]'English')

    Set-Variable -Option Constant UnattendedPath ([String]"$BuilderPath\unattended")
    Set-Variable -Option Constant ConfigsPath ([String]"$SourcePath\3-configs")

    Set-Variable -Option Constant NonLocalisedFileName ([String]'autounattend.xml')
    Set-Variable -Option Constant LocalisedFileNameTemplate ([String]'autounattend-{LOCALE}.xml')

    Set-Variable -Option Constant Locales ([String[]]@('English', 'Russian'))

    Set-Variable -Option Constant BaseFile ([String]"$BuildPath\$NonLocalisedFileName")

    Write-ActivityProgress 5

    . "$UnattendedPath\New-UnattendedBase.ps1"
    . "$UnattendedPath\Set-AppRemovalList.ps1"
    . "$UnattendedPath\Set-InlineFiles.ps1"
    . "$UnattendedPath\Set-LocaleSettings.ps1"
    . "$UnattendedPath\Set-MalwareProtectionConfiguration.ps1"
    . "$UnattendedPath\Set-PowerSchemeConfiguration.ps1"

    Write-ActivityProgress 10

    New-UnattendedBase $TemplatesPath $BaseFile

    Write-ActivityProgress 15

    Set-Variable -Option Constant TemplateContent ([String](Read-TextFile $BaseFile))

    Write-ActivityProgress 20

    [Int]$Iteration = 0
    foreach ($Locale in $Locales) {
        [Int]$Percentage = 20 + $Iteration * 15

        [String]$OutputFileName = "$BuildPath\" + $LocalisedFileNameTemplate.Replace('{LOCALE}', $Locale)

        [String]$UpdatedTemplateContent = Set-LocaleSettings $Locale $TemplateContent
        $Percentage += 2
        Write-ActivityProgress $Percentage

        $UpdatedTemplateContent = Set-AppRemovalList $ConfigsPath $UpdatedTemplateContent
        $Percentage += 2
        Write-ActivityProgress $Percentage

        $UpdatedTemplateContent = Set-MalwareProtectionConfiguration $SourcePath $UpdatedTemplateContent
        $Percentage += 2
        Write-ActivityProgress $Percentage

        $UpdatedTemplateContent = Set-PowerSchemeConfiguration $ConfigsPath $UpdatedTemplateContent
        $Percentage += 2
        Write-ActivityProgress $Percentage

        $UpdatedTemplateContent = Set-InlineFiles $Locale $ConfigsPath $UnattendedPath $UpdatedTemplateContent
        $Percentage += 2
        Write-ActivityProgress $Percentage

        $UpdatedTemplateContent = $UpdatedTemplateContent.Replace('{VERSION}', $Version)

        Write-TextFile $OutputFileName $UpdatedTemplateContent -NoNewline
        $Percentage += 2
        Write-ActivityProgress $Percentage

        $Iteration++
    }

    Write-ActivityProgress 80

    if (-not $CI) {
        Set-Variable -Option Constant BuildFile ([String]("$BuildPath\" + $LocalisedFileNameTemplate.Replace('{LOCALE}', $TestLocale)))
        Set-Variable -Option Constant VmFile ([String]("$VmPath\unattend\$NonLocalisedFileName"))
        Copy-Item $BuildFile $VmFile
    }

    Set-Variable -Option Constant DevRegexRemovals ([String[]]@(
            '\s*<File path="C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1">([\s\S]*?)<\/File>'
            "\s*{\s*&amp; 'C:\\Windows\\Setup\\VBoxGuestAdditions\.ps1';\s*};"
            '\s*<ImageInstall>([\s\S]*?)<\/ImageInstall>'
            '\s*<UserAccounts>([\s\S]*?)<\/UserAccounts>'
            '\s*<AutoLogon>([\s\S]*?)<\/AutoLogon>'
            '\s*<RunSynchronousCommand wcm:action="add">(?:[\s\S](?!<RunSynchronousCommand))*?diskpart[\s\S]*?<\/RunSynchronousCommand>'
            '(?s)\s*\{[^{}]*?AutoLogonCount[^{}]*?\}\s*;'
        )
    )

    Write-ActivityProgress 85

    foreach ($Locale in $Locales) {
        [String]$LocalisedFileName = $LocalisedFileNameTemplate.Replace('{LOCALE}', $Locale)
        [String]$BuildFileName = "$BuildPath\$LocalisedFileName"

        [String]$FileContent = Read-TextFile $BuildFileName

        foreach ($Regex in $DevRegexRemovals) {
            $FileContent = $FileContent -replace $Regex, ''
        }

        Write-TextFile $BuildFileName $FileContent -NoNewline
    }

    Write-ActivityCompleted
}
