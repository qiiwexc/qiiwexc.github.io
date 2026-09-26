function New-ButtonBrowser {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.Panel]$Parent,
        [Parameter(Position = 1, Mandatory)][String]$Text,
        [Parameter(Position = 2, Mandatory)][ScriptBlock]$Function,
        [Switch]$Spaced
    )

    Set-Variable -Option Constant Button ([Windows.Controls.Button](New-Button -Parent $Parent -Text $Text -Function $Function -Spaced:$Spaced))

    [Void](New-Label $Parent 'Open in a browser' -Centered)

    return $Button
}
