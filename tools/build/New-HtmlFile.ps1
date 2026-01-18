function New-HtmlFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$TemplatesPath,
        [PSCustomObject[]][Parameter(Position = 1, Mandatory)]$Config
    )

    Write-LogInfo 'Building web page...'

    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\home.html")
    Set-Variable -Option Constant OutputFile ([String]'.\index.html')

    [String]$TemplateContent = Get-Content $TemplateFile -Raw -Encoding UTF8

    $Config | ForEach-Object {
        [String]$Placeholder = "{$($_.key)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, $_.value)
    }

    $TemplateContent = $TemplateContent.Replace('../d/stylesheet.css', 'https://bit.ly/stylesheet_web')

    Set-Content $OutputFile $TemplateContent -NoNewline

    Out-Success
}
