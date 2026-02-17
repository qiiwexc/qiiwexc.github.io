function New-CheckBoxRunAfterDownload {
    param(
        [Switch]$Disabled,
        [Switch]$Checked
    )

    [Windows.Controls.CheckBox]$CheckBox = New-CheckBox 'Start after download' -Disabled:$Disabled -Checked:$Checked

    [void]$script:LayoutContext.CurrentGroup.Children.Remove($CheckBox)
    $CheckBox.Margin = [Windows.Thickness]::new(0, 0, 0, 2)

    Set-Variable -Option Constant Panel ([Windows.Controls.StackPanel](New-Object Windows.Controls.StackPanel))
    $Panel.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
    $Panel.Margin = [Windows.Thickness]::new(0, 3, 0, 3)
    [void]$Panel.Children.Add($CheckBox)
    [void]$script:LayoutContext.CurrentGroup.Children.Add($Panel)

    $script:LayoutContext.CenteredCheckboxGroup = $Panel
    $script:LayoutContext.PreviousLabelOrCheckbox = [Windows.Controls.CheckBox]$CheckBox

    return $CheckBox
}
