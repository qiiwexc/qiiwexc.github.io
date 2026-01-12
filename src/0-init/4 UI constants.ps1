Set-Variable -Option Constant BUTTON_WIDTH ([Int]170)
Set-Variable -Option Constant BUTTON_HEIGHT ([Int]30)

Set-Variable -Option Constant CHECKBOX_HEIGHT ([Int]($BUTTON_HEIGHT - 10))


Set-Variable -Option Constant INTERVAL_BUTTON ([Int]($BUTTON_HEIGHT + 15))

Set-Variable -Option Constant INTERVAL_CHECKBOX ([Int]($CHECKBOX_HEIGHT + 5))


Set-Variable -Option Constant GROUP_WIDTH ([Int](15 + $BUTTON_WIDTH + 15))

Set-Variable -Option Constant FORM_WIDTH ([Int](($GROUP_WIDTH + 15) * 3 + 30))
Set-Variable -Option Constant FORM_HEIGHT ([Int]570)

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON ([Drawing.Point]'15, 20')

Set-Variable -Option Constant SHIFT_CHECKBOX ([Drawing.Point]"0, $INTERVAL_CHECKBOX")


Set-Variable -Option Constant FONT_NAME ([String]'Microsoft Sans Serif')
Set-Variable -Option Constant BUTTON_FONT ([System.Drawing.Font]"$FONT_NAME, 10")
