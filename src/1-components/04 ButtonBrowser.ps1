function New-ButtonBrowser {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function
    )

    New-Button $Text $Function

    New-Label 'Open in a browser'
}
