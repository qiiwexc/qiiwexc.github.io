function Set-Icon {
    param(
        [IconName][Parameter(Position = 0)]$Name
    )

    switch ($Name) {
        ([IconName]::Cleanup) {
            $FORM.Icon = $ICON_CLEANUP
        }
        ([IconName]::Download) {
            $FORM.Icon = $ICON_DOWNLOAD
        }
        Default {
            $FORM.Icon = $ICON_DEFAULT
        }
    }
}
