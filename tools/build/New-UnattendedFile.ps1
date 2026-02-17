function New-UnattendedFile {
    param(
        [Parameter(Position = 0, Mandatory)][Version]$Version,
        [Parameter(Position = 1, Mandatory)][String]$BuilderPath,
        [Parameter(Position = 2, Mandatory)][String]$SourcePath,
        [Parameter(Position = 3, Mandatory)][String]$ResourcesPath,
        [Parameter(Position = 4, Mandatory)][String]$TemplatesPath,
        [Parameter(Position = 5, Mandatory)][String]$BuildPath,
        [Parameter(Position = 6, Mandatory)][String]$VmPath,
        [Switch]$CI
    )

    New-Activity 'Building unattended files'

    Set-Variable -Option Constant TestLocale ([String]'English')

    Set-Variable -Option Constant UnattendedPath ([String]"$BuilderPath\unattended")
    Set-Variable -Option Constant ConfigsPath ([String]"$SourcePath\3-configs")

    Set-Variable -Option Constant NonLocalizedFileName ([String]'autounattend.xml')
    Set-Variable -Option Constant LocalizedFileNameTemplate ([String]'autounattend-{LOCALE}.xml')

    Set-Variable -Option Constant Locales ([String[]]@('English', 'Russian'))

    Set-Variable -Option Constant BaseFile ([String]"$BuildPath\$NonLocalizedFileName")

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

        [String]$OutputFileName = "$BuildPath\" + $LocalizedFileNameTemplate.Replace('{LOCALE}', $Locale)

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

        $UpdatedTemplateContent = Set-InlineFiles $Locale $ConfigsPath $ResourcesPath $UpdatedTemplateContent
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
        Set-Variable -Option Constant BuildFile ([String]("$BuildPath\" + $LocalizedFileNameTemplate.Replace('{LOCALE}', $TestLocale)))
        Set-Variable -Option Constant VmFile ([String]("$VmPath\unattend\$NonLocalizedFileName"))
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
        [String]$LocalizedFileName = $LocalizedFileNameTemplate.Replace('{LOCALE}', $Locale)
        [String]$BuildFileName = "$BuildPath\$LocalizedFileName"

        [String]$FileContent = Read-TextFile $BuildFileName

        foreach ($Regex in $DevRegexRemovals) {
            $FileContent = $FileContent -replace $Regex, ''
        }

        Write-TextFile $BuildFileName $FileContent -NoNewline
    }

    Write-ActivityCompleted
}
