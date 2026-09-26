# Makes the window tall enough for its tallest tab to show without scrolling, as far as MaxHeight allows, and keeps it
# centred where it was placed. Runs once the window is laid out at the Height it was given, before it is drawn
# (Loaded): every tab is measured against the room the selected one has, so nothing else the window holds needs
# measuring
function Set-WindowHeight {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Window]$Window,
        [Parameter(Position = 1, Mandatory)][Windows.Controls.TabControl]$TabControl,
        [Parameter(Position = 2, Mandatory)][Double]$MaxHeight
    )

    # A tab is a scroll viewer around the panel its cards are in (New-TabPage). The cards wrap in its width less its
    # padding: a scroll bar the selected tab shows now is gone once the window fits
    Set-Variable -Option Constant Selected ([Windows.Controls.ScrollViewer]$TabControl.SelectedItem.Content)
    Set-Variable -Option Constant Width ([Double]($Selected.ActualWidth - $Selected.Padding.Left - $Selected.Padding.Right))

    [Double]$Tallest = 0
    foreach ($Item in $TabControl.Items) {
        [Windows.UIElement]$Panel = $Item.Content.Content
        $Panel.Measure([Windows.Size]::new($Width, [Double]::PositiveInfinity))
        $Tallest = [Math]::Max($Tallest, $Panel.DesiredSize.Height)
    }

    Set-Variable -Option Constant CurrentHeight ([Double]$Window.Height)
    Set-Variable -Option Constant Height ([Double][Math]::Ceiling([Math]::Min($CurrentHeight + $Tallest - $Selected.ViewportHeight, $MaxHeight)))

    $Window.MinHeight = $Height
    $Window.Height = $Height
    $Window.Top += ($CurrentHeight - $Height) / 2
}
