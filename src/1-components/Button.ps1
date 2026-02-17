function New-Button {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Text,
        [Parameter(Position = 1)][ScriptBlock]$Function,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant Button ([Windows.Controls.Button](New-Object Windows.Controls.Button))

    $Button.Content = $Text
    $Button.IsEnabled = -not $Disabled
    $Button.Style = $FORM.FindResource('Win11Button')

    if ($Function) {
        $Button.Add_Click($Function)
    }

    if ($script:LayoutContext.PreviousLabelOrCheckbox -or $script:LayoutContext.PreviousButton) {
        $Button.Margin = [Windows.Thickness]::new(0, 14, 0, 4)
    }

    [void]$script:LayoutContext.CurrentGroup.Children.Add($Button)

    $script:LayoutContext.PreviousLabelOrCheckbox = $Null
    $script:LayoutContext.PreviousButton = [Windows.Controls.Button]$Button
    $script:LayoutContext.CenteredCheckboxGroup = $Null
}
