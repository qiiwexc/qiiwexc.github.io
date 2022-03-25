Set-Variable -Option Constant WIDTH_BUTTON    170
Set-Variable -Option Constant HEIGHT_BUTTON   30

Set-Variable -Option Constant WIDTH_CHECKBOX   145
Set-Variable -Option Constant HEIGHT_CHECKBOX  20

Set-Variable -Option Constant INTERVAL_SHORT     5
Set-Variable -Option Constant INTERVAL_NORMAL    15
Set-Variable -Option Constant INTERVAL_LONG      30
Set-Variable -Option Constant INTERVAL_GROUP_TOP 20


Set-Variable -Option Constant INTERVAL_BUTTON_SHORT    ($HEIGHT_BUTTON + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_BUTTON_NORMAL   ($HEIGHT_BUTTON + $INTERVAL_NORMAL)
Set-Variable -Option Constant INTERVAL_BUTTON_LONG     ($HEIGHT_BUTTON + $INTERVAL_LONG)

Set-Variable -Option Constant INTERVAL_CHECKBOX_SHORT  ($HEIGHT_CHECKBOX + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_CHECKBOX_NORMAL ($HEIGHT_CHECKBOX + $INTERVAL_NORMAL)


Set-Variable -Option Constant WIDTH_GROUP ($INTERVAL_NORMAL + $WIDTH_BUTTON + $INTERVAL_NORMAL)

Set-Variable -Option Constant WIDTH_FORM  (($WIDTH_GROUP + $INTERVAL_NORMAL) * 3 + ($INTERVAL_NORMAL * 2))
Set-Variable -Option Constant HEIGHT_FORM ($INTERVAL_BUTTON_NORMAL * 13)

Set-Variable -Option Constant CHECKBOX_SIZE "$WIDTH_CHECKBOX, $HEIGHT_CHECKBOX"

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "$INTERVAL_NORMAL, $INTERVAL_GROUP_TOP"
Set-Variable -Option Constant INITIAL_LOCATION_GROUP  "$INTERVAL_NORMAL, $INTERVAL_NORMAL"


Set-Variable -Option Constant SHIFT_BUTTON_SHORT      "0, $INTERVAL_BUTTON_SHORT"
Set-Variable -Option Constant SHIFT_BUTTON_NORMAL     "0, $INTERVAL_BUTTON_NORMAL"
Set-Variable -Option Constant SHIFT_BUTTON_LONG       "0, $INTERVAL_BUTTON_LONG"

Set-Variable -Option Constant SHIFT_CHECKBOX          "0, $INTERVAL_CHECKBOX_SHORT"
Set-Variable -Option Constant SHIFT_CHECKBOX_EXECUTE  "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"

Set-Variable -Option Constant SHIFT_GROUP_HORIZONTAL  "$($WIDTH_GROUP + $INTERVAL_NORMAL), 0"

Set-Variable -Option Constant SHIFT_LABEL_BROWSER     "$INTERVAL_LONG, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"
