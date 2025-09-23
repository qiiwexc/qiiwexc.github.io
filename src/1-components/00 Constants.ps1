Set-Variable -Option Constant BUTTON_WIDTH    170
Set-Variable -Option Constant BUTTON_HEIGHT   30

Set-Variable -Option Constant CHECKBOX_HEIGHT ($BUTTON_HEIGHT - 10)


Set-Variable -Option Constant INTERVAL_BUTTON ($BUTTON_HEIGHT + 15)

Set-Variable -Option Constant INTERVAL_CHECKBOX ($CHECKBOX_HEIGHT + 5)


Set-Variable -Option Constant GROUP_WIDTH (15 + $BUTTON_WIDTH + 15)

Set-Variable -Option Constant FORM_WIDTH  (($GROUP_WIDTH + 15) * 3 + 30)
Set-Variable -Option Constant FORM_HEIGHT 560

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "15, 20"

Set-Variable -Option Constant SHIFT_CHECKBOX "0, $INTERVAL_CHECKBOX"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"
