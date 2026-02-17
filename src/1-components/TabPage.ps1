function New-TabPage {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Text
    )

    Set-Variable -Option Constant TabItem ([Windows.Controls.TabItem](New-Object Windows.Controls.TabItem))

    $TabItem.Header = $Text

    Set-Variable -Option Constant ScrollViewer ([Windows.Controls.ScrollViewer](New-Object Windows.Controls.ScrollViewer))
    $ScrollViewer.VerticalScrollBarVisibility = 'Auto'
    $ScrollViewer.HorizontalScrollBarVisibility = 'Disabled'
    $ScrollViewer.Padding = [Windows.Thickness]::new(8, 8, 8, 8)

    Set-Variable -Option Constant WrapPanel ([Windows.Controls.WrapPanel](New-Object Windows.Controls.WrapPanel))
    $WrapPanel.ItemWidth = $CARD_COLUMN_WIDTH
    $WrapPanel.Margin = [Windows.Thickness]::new(0)

    $ScrollViewer.Content = $WrapPanel
    $TabItem.Content = $ScrollViewer

    [void]$TAB_CONTROL.Items.Add($TabItem)

    $script:LayoutContext.CurrentTab = [Windows.Controls.WrapPanel]$WrapPanel

    return $TabItem
}
