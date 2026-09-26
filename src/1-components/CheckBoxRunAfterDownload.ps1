function New-CheckBoxRunAfterDownload {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.Panel]$Parent,
        [Switch]$Disabled,
        [Switch]$Checked
    )

    # A centred group of its own, which the options of the same button join: the checkbox's Parent
    Set-Variable -Option Constant Panel ([Windows.Controls.StackPanel](New-Object Windows.Controls.StackPanel))
    $Panel.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
    $Panel.Margin = [Windows.Thickness]::new(0, 3, 0, 3)
    [void]$Parent.Children.Add($Panel)

    Set-Variable -Option Constant CheckBox ([Windows.Controls.CheckBox](New-CheckBox $Panel 'Start after download' -Disabled:$Disabled -Checked:$Checked))
    $CheckBox.Margin = [Windows.Thickness]::new(0, 0, 0, 2)

    return $CheckBox
}
