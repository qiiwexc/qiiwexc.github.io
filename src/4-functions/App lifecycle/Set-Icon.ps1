$script:IconCache = @{}

function Set-Icon {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param(
        [Parameter(Position = 0)][IconName]$Name = [IconName]::Default
    )

    # Async operations run in a separate runspace that only receives copied function
    # bodies, not this file's top-level '$script:IconCache = @{}' statement, so the
    # variable can be genuinely unset there — use Get-Variable instead of a direct
    # '$script:IconCache' reference, which would throw under Set-StrictMode -Version Latest
    Set-Variable -Option Constant ExistingIconCache ([PSObject](Get-Variable -Scope Script -Name IconCache -ErrorAction SilentlyContinue))
    if ($null -eq $ExistingIconCache -or $null -eq $ExistingIconCache.Value) {
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
