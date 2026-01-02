function New-UnattendedFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Version,
        [String][Parameter(Position = 1, Mandatory)]$BuilderPath,
        [String][Parameter(Position = 2, Mandatory)]$SourcePath,
        [String][Parameter(Position = 3, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 4, Mandatory)]$BuildPath,
        [String][Parameter(Position = 5, Mandatory)]$FileNameTemplate,
        [Switch][Parameter(Position = 6, Mandatory)]$FullBuild
    )

    Write-LogInfo 'Building unattended files...'

    Set-Variable -Option Constant UnattendedPath ([String]"$BuilderPath\unattended")
    Set-Variable -Option Constant ConfigsPath ([String]"$SourcePath\3-configs")

    Set-Variable -Option Constant BaseFile ([String]"$BuildPath\autounattend.xml")

    Set-Variable -Option Constant Locales ([Collections.Generic.List[String]]@('English', 'Russian'))

    . "$UnattendedPath\New-UnattendedBase.ps1"
    . "$UnattendedPath\Set-AppRemovalList.ps1"
    . "$UnattendedPath\Set-CapabilitiesRemovalList.ps1"
    . "$UnattendedPath\Set-FeaturesRemovalList.ps1"
    . "$UnattendedPath\Set-InlineFiles.ps1"
    . "$UnattendedPath\Set-LocaleSettings.ps1"
    . "$UnattendedPath\Set-PowerSchemeConfiguration.ps1"
    . "$UnattendedPath\Set-WindowsSecurityConfiguration.ps1"

    New-UnattendedBase $TemplatesPath $BaseFile $FullBuild

    foreach ($Locale in $Locales) {
        [String]$OutputFileName = $FileNameTemplate.Replace('{LOCALE}', $Locale)

        [Collections.Generic.List[String]]$TemplateContent = Get-Content $BaseFile

        $TemplateContent = Set-LocaleSettings $Locale $TemplateContent

        $TemplateContent = Set-AppRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-CapabilitiesRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-FeaturesRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-WindowsSecurityConfiguration $SourcePath $TemplateContent

        $TemplateContent = Set-PowerSchemeConfiguration $ConfigsPath $TemplateContent

        $TemplateContent = Set-InlineFiles $Locale $ConfigsPath $TemplateContent

        $TemplateContent = $TemplateContent.Replace('{VERSION}', $Version)

        $TemplateContent | Out-File $OutputFileName -Encoding UTF8
    }

    Out-Success
}
