function New-HtmlFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$TemplatesPath,
        [String][Parameter(Position = 1, Mandatory)]$BuildPath,
        [PSCustomObject][Parameter(Position = 2, Mandatory)]$Config
    )

    New-Activity 'Building web page'

    Set-Variable -Option Constant TemplateFile ([String]"$TemplatesPath\home.html")
    Set-Variable -Option Constant OutputFile ([String]"$BuildPath\index.html")

    [String]$TemplateContent = Read-TextFile $TemplateFile
    $TemplateContent = $TemplateContent.Replace('../d/stylesheet.css', '{URL_STYLESHEET_WEB}')

    $Config.PSObject.Properties | ForEach-Object {
        [String]$Placeholder = "{$($_.Name)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, $_.Value)
    }

    Write-TextFile $OutputFile $TemplateContent -NoNewline

    Write-ActivityCompleted
}
