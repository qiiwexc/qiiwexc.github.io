function New-UnattendedFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$UnattendedPath,
        [String][Parameter(Position = 1, Mandatory)]$SourcePath,
        [String][Parameter(Position = 2, Mandatory)]$AssetsPath,
        [String][Parameter(Position = 3, Mandatory)]$FileNameTemplate
    )

    . "$UnattendedPath\Set-AppRemovalList.ps1"
    . "$UnattendedPath\Set-CapabilitiesRemovalList.ps1"
    . "$UnattendedPath\Set-FeaturesRemovalList.ps1"
    . "$UnattendedPath\Set-InlineFiles.ps1"
    . "$UnattendedPath\Set-LocaleSettings.ps1"
    . "$UnattendedPath\Set-PowerSchemeConfiguration.ps1"
    . "$UnattendedPath\Set-WindowsSecurityConfiguration.ps1"

    Write-LogInfo 'Building unattended files...'

    Set-Variable -Option Constant ConfigsPath "$SourcePath\3-configs"
    Set-Variable -Option Constant TemplateFile "$AssetsPath\autounattend-template.xml"

    Set-Variable -Option Constant Locales @('English', 'Russian')

    foreach ($Locale in $Locales) {
        [String]$OutputFileName = $FileNameTemplate.Replace('{LOCALE}', $Locale)

        [Collections.Generic.List[String]]$TemplateContent = Get-Content $TemplateFile

        $TemplateContent = Set-LocaleSettings $Locale $TemplateContent

        $TemplateContent = Set-AppRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-CapabilitiesRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-FeaturesRemovalList $ConfigsPath $TemplateContent

        $TemplateContent = Set-WindowsSecurityConfiguration $SourcePath $TemplateContent

        $TemplateContent = Set-PowerSchemeConfiguration $ConfigsPath $TemplateContent

        $TemplateContent = Set-InlineFiles $Locale $ConfigsPath $TemplateContent

        $TemplateContent | Out-File $OutputFileName -Encoding UTF8
    }

    Out-Success
}
