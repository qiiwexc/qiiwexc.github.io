function New-ButtonBrowser {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Text,
        [Parameter(Position = 1, Mandatory)][ScriptBlock]$Function
    )

    New-Button $Text $Function

    New-Label 'Open in a browser' -Centered
}
