# The tabs in the order they appear; every checkbox the handlers read at click time is in CHECKBOXES, and every
# named button in BUTTONS
Set-Variable -Option Constant CHECKBOXES ([Hashtable]@{})
Set-Variable -Option Constant BUTTONS ([Hashtable]@{})
foreach ($Tab in @($TAB_HOME, $TAB_INSTALLS, $TAB_CONFIGURATION, $TAB_DIAGNOSTICS)) {
    New-Tab -TabControl $TAB_CONTROL -Definition $Tab -Checkboxes $CHECKBOXES -Buttons $BUTTONS
}

[Void]$FORM.ShowDialog()
