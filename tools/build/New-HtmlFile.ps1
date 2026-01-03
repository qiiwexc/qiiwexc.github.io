function New-HtmlFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$TemplatesPath,
        [Collections.Generic.List[Object]][Parameter(Position = 1, Mandatory)]$Config
    )

    Write-LogInfo 'Building web page...'

    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\home.html")
    Set-Variable -Option Constant OutputFile ([String]'.\index.html')

    [Collections.Generic.List[String]]$TemplateContent = Get-Content $TemplateFile

    $Config | ForEach-Object {
        [String]$Placeholder = "{$($_.key)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, $_.value)
    }

    $TemplateContent = $TemplateContent.Replace('../d/stylesheet.css', 'https://bit.ly/stylesheet_web')

    $TemplateContent | Out-File $OutputFile -Encoding UTF8

    Out-Success
}
