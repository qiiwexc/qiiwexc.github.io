$script:IconCache = @{}

function Set-Icon {
    param(
        [Parameter(Position = 0)][IconName]$Name = [IconName]::Default
    )

    Invoke-OnDispatcher 'Set-FormIcon' @{ Name = $Name }
}

# Touches the window, so it runs on the UI thread only, through Invoke-OnDispatcher
function Set-FormIcon {
    param(
        [Parameter(Position = 0, Mandatory)][IconName]$Name
    )

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
}
