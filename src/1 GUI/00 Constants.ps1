Set-Variable INF 'INF' -Option Constant
Set-Variable WRN 'WRN' -Option Constant
Set-Variable ERR 'ERR' -Option Constant

Set-Variable REQUIRES_ELEVATION $(if (-not $IS_ELEVATED) { ' *' }) -Option Constant


Set-Variable FORM_WIDTH 670 -Option Constant
Set-Variable FORM_HEIGHT 625 -Option Constant

Set-Variable BTN_WIDTH 167 -Option Constant
Set-Variable BTN_HEIGHT 28 -Option Constant

Set-Variable CBOX_WIDTH 145 -Option Constant
Set-Variable CBOX_HEIGHT 20 -Option Constant

Set-Variable RBTN_WIDTH 80 -Option Constant
Set-Variable RBTN_HEIGHT 20 -Option Constant

Set-Variable INT_SHORT 5 -Option Constant
Set-Variable INT_NORMAL 15 -Option Constant
Set-Variable INT_LONG 30 -Option Constant
Set-Variable INT_TAB_ADJ 4 -Option Constant
Set-Variable INT_GROUP_TOP 20 -Option Constant


Set-Variable INT_BTN_SHORT ($BTN_HEIGHT + $INT_SHORT) -Option Constant
Set-Variable INT_BTN_NORMAL ($BTN_HEIGHT + $INT_NORMAL) -Option Constant
Set-Variable INT_BTN_LONG ($BTN_HEIGHT + $INT_LONG) -Option Constant

Set-Variable INT_CBOX_SHORT ($CBOX_HEIGHT + $INT_SHORT) -Option Constant
Set-Variable INT_CBOX_NORMAL ($CBOX_HEIGHT + $INT_NORMAL) -Option Constant


Set-Variable GRP_WIDTH ($INT_NORMAL + $BTN_WIDTH + $INT_NORMAL) -Option Constant

Set-Variable CBOX_SIZE "$CBOX_WIDTH, $CBOX_HEIGHT" -Option Constant
Set-Variable RBTN_SIZE "$RBTN_WIDTH, $RBTN_HEIGHT" -Option Constant

Set-Variable BTN_INIT_LOCATION "$INT_NORMAL, $INT_GROUP_TOP" -Option Constant
Set-Variable GRP_INIT_LOCATION "$INT_NORMAL, $INT_NORMAL" -Option Constant


Set-Variable SHIFT_BTN_SHORT "0, $INT_BTN_SHORT" -Option Constant
Set-Variable SHIFT_BTN_NORMAL "0, $INT_BTN_NORMAL" -Option Constant
Set-Variable SHIFT_BTN_LONG "0, $INT_BTN_LONG" -Option Constant

Set-Variable SHIFT_CBOX_SHORT "0, $INT_CBOX_SHORT" -Option Constant
Set-Variable SHIFT_CBOX_NORMAL "0, $INT_CBOX_NORMAL" -Option Constant
Set-Variable SHIFT_CBOX_EXECUTE "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)" -Option Constant

Set-Variable SHIFT_RBTN_QUICK_SCAN "10, $($INT_BTN_SHORT - $INT_SHORT)" -Option Constant
Set-Variable SHIFT_RBTN_FULL_SCAN "$RBTN_WIDTH, 0" -Option Constant

Set-Variable SHIFT_GRP_HOR_NORMAL "$($GRP_WIDTH + $INT_NORMAL), 0" -Option Constant

Set-Variable SHIFT_LBL_BROWSER "$INT_LONG, $($INT_BTN_SHORT - $INT_SHORT)" -Option Constant


Set-Variable FONT_NAME 'Microsoft Sans Serif' -Option Constant
Set-Variable BTN_FONT "$FONT_NAME, 10" -Option Constant


Set-Variable TXT_START_AFTER_DOWNLOAD 'Start after download' -Option Constant
Set-Variable TXT_OPENS_IN_BROWSER 'Opens in the browser' -Option Constant
Set-Variable TXT_UNCHECKY_INFO 'Unchecky clears adware checkboxes when installing software' -Option Constant
Set-Variable TXT_AV_WARNING "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!" -Option Constant

Set-Variable TIP_START_AFTER_DOWNLOAD "Execute after download has finished`nIf download is a ZIP file, it will get extracted first" -Option Constant

Set-Variable TEMP_DIR "$env:TMP\qiiwexc" -Option Constant
