function New-ButtonBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [ScriptBlock][Parameter(Position = 1, Mandatory)]$Function
    )

    New-Button $Text $Function

    New-Label 'Open in a browser' -Centered
}
