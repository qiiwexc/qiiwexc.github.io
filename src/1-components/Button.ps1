function New-Button {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant Button ([Windows.Controls.Button](New-Object Windows.Controls.Button))

    $Button.Content = $Text
    $Button.IsEnabled = -not $Disabled
    $Button.Style = $FORM.FindResource('Win11Button')

    if ($Function) {
        $Button.Add_Click($Function)
    }

    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_BUTTON) {
        $Button.Margin = [Windows.Thickness]::new(0, 14, 0, 4)
    }

    [void]$CURRENT_GROUP.Children.Add($Button)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON ([Windows.Controls.Button]$Button)
    Set-Variable -Scope Script CENTERED_CHECKBOX_GROUP $Null
}
