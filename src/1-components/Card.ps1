function New-Card {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Text
    )

    Set-Variable -Option Constant CardBorder ([Windows.Controls.Border](New-Object Windows.Controls.Border))
    $CardBorder.SetResourceReference([Windows.Controls.Border]::BorderBrushProperty, 'BorderColor')
    $CardBorder.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'CardBgColor')
    $CardBorder.BorderThickness = [Windows.Thickness]::new(1)
    $CardBorder.CornerRadius = [Windows.CornerRadius]::new(4)
    $CardBorder.Padding = [Windows.Thickness]::new(16, 12, 16, 8)
    $CardBorder.Margin = [Windows.Thickness]::new(4, 4, 4, 4)

    Set-Variable -Option Constant CardPanel ([Windows.Controls.StackPanel](New-Object Windows.Controls.StackPanel))

    Set-Variable -Option Constant HeaderText ([Windows.Controls.TextBlock](New-Object Windows.Controls.TextBlock))
    $HeaderText.Text = $Text
    $HeaderText.FontWeight = 'Bold'
    $HeaderText.FontSize = $FONT_SIZE_HEADER
    $HeaderText.FontFamily = [Windows.Media.FontFamily]::new($FONT_NAME)
    $HeaderText.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'FgColor')
    $HeaderText.Margin = [Windows.Thickness]::new(0, 0, 0, 10)

    [void]$CardPanel.Children.Add($HeaderText)

    $CardBorder.Child = $CardPanel

    [void]$script:LayoutContext.CurrentTab.Children.Add($CardBorder)

    $script:LayoutContext.PreviousButton = $Null
    $script:LayoutContext.PreviousLabelOrCheckbox = $Null
    $script:LayoutContext.CenteredCheckboxGroup = $Null

    $script:LayoutContext.CurrentGroup = $CardPanel
}
