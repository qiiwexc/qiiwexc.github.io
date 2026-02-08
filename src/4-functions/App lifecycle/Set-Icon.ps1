function Set-Icon {
    param(
        [IconName][Parameter(Position = 0)]$Name
    )

    switch ($Name) {
        ([IconName]::Working) {
            $FORM.Icon = $ICON_WORKING
        }
        Default {
            $FORM.Icon = $ICON_DEFAULT
        }
    }
}
