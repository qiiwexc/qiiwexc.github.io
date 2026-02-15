$script:IconCache = @{}

function Set-Icon {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param(
        [Parameter(Position = 0)][IconName]$Name = [IconName]::Default
    )

    if ($null -eq $script:IconCache) {
        $script:IconCache = @{}
    }

    Set-Variable -Option Constant IconAction ([Action] {
            if (-not $script:IconCache.ContainsKey($Name)) {
                switch ($Name) {
                    ([IconName]::Working) {
                        $script:IconCache[$Name] = [Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
                            $ICON_WORKING.Handle,
                            [Windows.Int32Rect]::Empty,
                            [Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
                        )
                    }
                    Default {
                        $script:IconCache[$Name] = [Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
                            $ICON_DEFAULT.Handle,
                            [Windows.Int32Rect]::Empty,
                            [Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
                        )
                    }
                }
            }
            $FORM.Icon = $script:IconCache[$Name]
        })

    Invoke-OnDispatcher $IconAction
}
