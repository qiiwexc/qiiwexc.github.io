Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'

Set-Variable -Option Constant REQUIRES_ELEVATION $(if (-not $IS_ELEVATED) { ' *' })


Set-Variable -Option Constant FORM_WIDTH    670
Set-Variable -Option Constant FORM_HEIGHT   625

Set-Variable -Option Constant BTN_WIDTH     167
Set-Variable -Option Constant BTN_HEIGHT    28

Set-Variable -Option Constant CBOX_WIDTH    145
Set-Variable -Option Constant CBOX_HEIGHT   20

Set-Variable -Option Constant RBTN_WIDTH    80
Set-Variable -Option Constant RBTN_HEIGHT   20

Set-Variable -Option Constant INT_SHORT     5
Set-Variable -Option Constant INT_NORMAL    15
Set-Variable -Option Constant INT_LONG      30
Set-Variable -Option Constant INT_TAB_ADJ   4
Set-Variable -Option Constant INT_GROUP_TOP 20


Set-Variable -Option Constant INT_BTN_SHORT   ($BTN_HEIGHT + $INT_SHORT)
Set-Variable -Option Constant INT_BTN_NORMAL  ($BTN_HEIGHT + $INT_NORMAL)
Set-Variable -Option Constant INT_BTN_LONG    ($BTN_HEIGHT + $INT_LONG)

Set-Variable -Option Constant INT_CBOX_SHORT  ($CBOX_HEIGHT + $INT_SHORT)
Set-Variable -Option Constant INT_CBOX_NORMAL ($CBOX_HEIGHT + $INT_NORMAL)


Set-Variable -Option Constant GRP_WIDTH ($INT_NORMAL + $BTN_WIDTH + $INT_NORMAL)

Set-Variable -Option Constant CBOX_SIZE "$CBOX_WIDTH, $CBOX_HEIGHT"
Set-Variable -Option Constant RBTN_SIZE "$RBTN_WIDTH, $RBTN_HEIGHT"

Set-Variable -Option Constant BTN_INIT_LOCATION "$INT_NORMAL, $INT_GROUP_TOP"
Set-Variable -Option Constant GRP_INIT_LOCATION "$INT_NORMAL, $INT_NORMAL"


Set-Variable -Option Constant SHIFT_BTN_SHORT    "0, $INT_BTN_SHORT"
Set-Variable -Option Constant SHIFT_BTN_NORMAL   "0, $INT_BTN_NORMAL"
Set-Variable -Option Constant SHIFT_BTN_LONG     "0, $INT_BTN_LONG"

Set-Variable -Option Constant SHIFT_CBOX_SHORT   "0, $INT_CBOX_SHORT"
Set-Variable -Option Constant SHIFT_CBOX_NORMAL  "0, $INT_CBOX_NORMAL"
Set-Variable -Option Constant SHIFT_CBOX_EXECUTE "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)"

Set-Variable -Option Constant SHIFT_RBTN_QUICK_SCAN "10, $($INT_BTN_SHORT - $INT_SHORT)"
Set-Variable -Option Constant SHIFT_RBTN_FULL_SCAN  "$RBTN_WIDTH, 0"

Set-Variable -Option Constant SHIFT_GRP_HOR_NORMAL "$($GRP_WIDTH + $INT_NORMAL), 0"

Set-Variable -Option Constant SHIFT_LBL_BROWSER "$INT_LONG, $($INT_BTN_SHORT - $INT_SHORT)"


Set-Variable -Option Constant FONT_NAME 'Microsoft Sans Serif'
Set-Variable -Option Constant BTN_FONT  "$FONT_NAME, 10"


Set-Variable -Option Constant TXT_START_AFTER_DOWNLOAD 'Start after download'
Set-Variable -Option Constant TXT_OPENS_IN_BROWSER 'Opens in the browser'
Set-Variable -Option Constant TXT_UNCHECKY_INFO 'Unchecky clears adware checkboxes when installing software'
Set-Variable -Option Constant TXT_AV_WARNING "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!"

Set-Variable -Option Constant TIP_START_AFTER_DOWNLOAD "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"

Set-Variable -Option Constant TEMP_DIR "$env:TMP\qiiwexc"
