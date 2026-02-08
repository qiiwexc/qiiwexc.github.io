Set-Variable -Option Constant COMMON_PADDING ([Int]15)

Set-Variable -Option Constant BUTTON_WIDTH ([Int]170)
Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)

Set-Variable -Option Constant CHECKBOX_HEIGHT ([Int]($BUTTON_HEIGHT - 10))


Set-Variable -Option Constant INTERVAL_BUTTON ([Int]($BUTTON_HEIGHT + $COMMON_PADDING))

Set-Variable -Option Constant INTERVAL_CHECKBOX ([Int]($CHECKBOX_HEIGHT + 5))


Set-Variable -Option Constant GROUP_WIDTH ([Int]($COMMON_PADDING + $BUTTON_WIDTH + $COMMON_PADDING))

Set-Variable -Option Constant FORM_WIDTH ([Int](($GROUP_WIDTH * 3) + ($COMMON_PADDING * 4) + $COMMON_PADDING))
Set-Variable -Option Constant FORM_HEIGHT ([Int]615)

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON ([Drawing.Point]"$COMMON_PADDING, $($COMMON_PADDING + 5)")

Set-Variable -Option Constant CHECKBOX_PADDING ([Int]20)


Set-Variable -Option Constant FONT_NAME ([String]'Microsoft Sans Serif')
Set-Variable -Option Constant BUTTON_FONT ([Drawing.Font]"$FONT_NAME, 10")


Set-Variable -Option Constant ICON_DEFAULT ([Drawing.Icon]::ExtractAssociatedIcon("$PATH_SYSTEM_32\cliconfg.exe"))
Set-Variable -Option Constant ICON_WORKING ([Drawing.Icon]::ExtractAssociatedIcon("$PATH_SYSTEM_32\Dxpserver.exe"))
