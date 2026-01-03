function Set-AppRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigsPath,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    [Collections.Generic.List[String]]$AppList = Get-Content -Raw -Encoding UTF8 "$ConfigsPath\Windows\Tools\Debloat app list.txt"
    $AppList.Add('Microsoft.OneDrive')

    [Collections.Generic.List[String]]$FormattedAppList = "`n"
    $AppList | ForEach-Object {
        [String]$App = $_.Split('#')[0].trim()
        $FormattedAppList.Add("  '$App';`n")
    }

    return $TemplateContent.Replace('{APP_REMOVAL_LIST}', -join $FormattedAppList)
}
