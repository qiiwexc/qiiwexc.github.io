function Set-Icon {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param(
        [IconName][Parameter(Position = 0)]$Name
    )

    Set-Variable -Option Constant IconAction ([Action] {
            switch ($Name) {
                ([IconName]::Working) {
                    $FORM.Icon = [Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
                        $ICON_WORKING.Handle,
                        [Windows.Int32Rect]::Empty,
                        [Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
                    )
                }
                Default {
                    $FORM.Icon = [Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
                        $ICON_DEFAULT.Handle,
                        [Windows.Int32Rect]::Empty,
                        [Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
                    )
                }
            }
        })

    if ($FORM.Dispatcher.CheckAccess()) {
        $IconAction.Invoke()
    } else {
        [void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, $IconAction)
    }
}
