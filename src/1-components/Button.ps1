function New-Button {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.Panel]$Parent,
        [Parameter(Position = 1, Mandatory)][String]$Text,
        [Parameter(Position = 2)][ScriptBlock]$Function,
        [Switch]$Disabled,
        [Switch]$Spaced
    )

    Set-Variable -Option Constant Button ([Windows.Controls.Button](New-Object Windows.Controls.Button))

    $Button.Content = $Text
    $Button.IsEnabled = -not $Disabled
    $Button.Style = $FORM.FindResource('Win11Button')

    if ($Function) {
        $Button.Add_Click($Function)
    }

    # Set apart from whatever comes before it in the card
    if ($Spaced) {
        $Button.Margin = [Windows.Thickness]::new(0, 14, 0, 4)
    }

    [void]$Parent.Children.Add($Button)

    return $Button
}
