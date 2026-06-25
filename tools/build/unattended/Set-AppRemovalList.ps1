function Set-AppRemovalList {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ConfigsPath,
        [Parameter(Position = 1, Mandatory)][String]$TemplateContent
    )

    [Collections.Generic.List[String]]$AppList = Read-JsonFile "$ConfigsPath\Windows\Tools\Debloat app list base.json" | ForEach-Object { $_.AppId }
    $AppList.Add('Microsoft.OneDrive')

    [Collections.Generic.List[String]]$FormattedAppList = @("`n")
    $AppList | ForEach-Object {
        [String]$App = $_.Split('#')[0].trim()
        $FormattedAppList.Add("  '$App';`n")
    }

    return $TemplateContent.Replace('{APP_REMOVAL_LIST}', -join $FormattedAppList)
}
