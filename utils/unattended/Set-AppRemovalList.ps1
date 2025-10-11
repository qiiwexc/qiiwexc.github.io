function Set-AppRemovalList {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ConfigsPath,
        [Parameter(Position = 1, Mandatory = $True)]$TemplateContent
    )

    [Collections.Generic.List[String]]$AppList = Get-Content "$ConfigsPath\Windows\Tools\Debloat app list.txt"
    $AppList.Add('Microsoft.OneDrive')

    [Collections.Generic.List[String]]$FormattedAppList = "`n"
    $AppList | ForEach-Object { $FormattedAppList.Add("  '$($_.Split('#')[0].trim())';`n") }

    return $TemplateContent.Replace('{APP_REMOVAL_LIST}', -join $FormattedAppList)
}
