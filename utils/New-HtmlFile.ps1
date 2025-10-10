function New-HtmlFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [Collections.Generic.List[Object]][Parameter(Position = 1, Mandatory = $True)]$Config
    )

    Write-LogInfo 'Building the web page...'

    Set-Variable -Option Constant TemplateFile "$AssetsPath\template.html"
    Set-Variable -Option Constant OutputFile '.\index.html'

    [Collections.Generic.List[String]]$TemplateContent = Get-Content $TemplateFile

    $Config | ForEach-Object { $TemplateContent = $TemplateContent.Replace("{$($_.key)}", $_.value) }

    $TemplateContent = $TemplateContent.Replace('../d/stylesheet.css', 'https://bit.ly/stylesheet_web')

    $TemplateContent | Out-File $OutputFile -Encoding UTF8

    Out-Success
}
