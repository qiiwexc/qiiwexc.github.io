function Set-WindowsSecurityConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$SourcePath,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    [Collections.Generic.List[String]]$Configuration = Get-Content "$SourcePath\4-functions\Configuration\Windows\Set-WindowsSecurityConfiguration.ps1"

    $Configuration.RemoveAt(0)
    $Configuration.RemoveAt($Configuration.Count - 1)

    [Collections.Generic.List[String]]$FormattedConfiguration = ''
    $Configuration | ForEach-Object { $FormattedConfiguration.Add("$($_.trim())`n") }

    return $TemplateContent.Replace('{WINDOWS_SECURITY_CONFIGURATION}', -join $FormattedConfiguration)
}
