function New-HtmlFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$TemplatesPath,
        [Config[]][Parameter(Position = 1, Mandatory)]$Config
    )

    New-Activity 'Building web page'

    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\home.html")
    Set-Variable -Option Constant OutputFile ([String]'.\index.html')

    [String]$TemplateContent = Read-TextFile $TemplateFile

    $Config | ForEach-Object {
        [String]$Placeholder = "{$($_.key)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, $_.value)
    }

    $TemplateContent = $TemplateContent.Replace('../d/stylesheet.css', 'https://bit.ly/stylesheet_web')

    Write-TextFile $OutputFile $TemplateContent -NoNewline

    Write-ActivityCompleted
}
