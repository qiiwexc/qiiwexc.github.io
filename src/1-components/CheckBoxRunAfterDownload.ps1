function New-CheckBoxRunAfterDownload {
    param(
        [Switch]$Disabled,
        [Switch]$Checked
    )

    [Windows.Controls.CheckBox]$CheckBox = New-CheckBox 'Start after download' -Disabled:$Disabled -Checked:$Checked

    [void]$CURRENT_GROUP.Children.Remove($CheckBox)
    $CheckBox.Margin = [Windows.Thickness]::new(0, 0, 0, 2)

    Set-Variable -Option Constant Panel ([Windows.Controls.StackPanel](New-Object Windows.Controls.StackPanel))
    $Panel.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
    $Panel.Margin = [Windows.Thickness]::new(0, 3, 0, 3)
    [void]$Panel.Children.Add($CheckBox)
    [void]$CURRENT_GROUP.Children.Add($Panel)

    Set-Variable -Scope Script CENTERED_CHECKBOX_GROUP $Panel
    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX ([Windows.Controls.CheckBox]$CheckBox)

    return $CheckBox
}
