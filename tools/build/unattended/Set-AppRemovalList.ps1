function Set-AppRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ConfigsPath,
        [String][Parameter(Position = 1, Mandatory)]$TemplateContent
    )

    [Collections.Generic.List[String]]$AppList = Read-TextFile -AsList "$ConfigsPath\Windows\Tools\Debloat app list.txt"
    $AppList.Add('Microsoft.OneDrive')

    [Collections.Generic.List[String]]$FormattedAppList = @("`n")
    $AppList | ForEach-Object {
        [String]$App = $_.Split('#')[0].trim()
        $FormattedAppList.Add("  '$App';`n")
    }

    return $TemplateContent.Replace('{APP_REMOVAL_LIST}', -join $FormattedAppList)
}
