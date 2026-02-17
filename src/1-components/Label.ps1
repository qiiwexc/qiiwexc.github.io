function New-Label {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Text,
        [Switch]$Centered
    )

    Set-Variable -Option Constant Label ([Windows.Controls.TextBlock](New-Object Windows.Controls.TextBlock))

    $Label.Text = $Text
    $Label.FontSize = $FONT_SIZE_NORMAL
    $Label.FontFamily = [Windows.Media.FontFamily]::new($FONT_NAME)
    $Label.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'FgColor')
    $Label.Opacity = 0.7

    if ($Centered) {
        $Label.HorizontalAlignment = [Windows.HorizontalAlignment]::Center
        $Label.Margin = [Windows.Thickness]::new(0, 0, 0, 4)
    } else {
        $Label.Margin = [Windows.Thickness]::new(20, 0, 0, 4)
    }

    [void]$script:LayoutContext.CurrentGroup.Children.Add($Label)

    $script:LayoutContext.PreviousLabelOrCheckbox = [Windows.Controls.TextBlock]$Label
    $script:LayoutContext.PreviousButton = $Null
    $script:LayoutContext.CenteredCheckboxGroup = $Null
}
