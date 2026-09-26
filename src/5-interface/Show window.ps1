# The tabs in the order they appear; every checkbox the handlers read at click time is in CHECKBOXES
Set-Variable -Option Constant CHECKBOXES ([Hashtable]@{})
foreach ($Tab in @($TAB_HOME, $TAB_INSTALLS, $TAB_CONFIGURATION, $TAB_DIAGNOSTICS)) {
    New-Tab -TabControl $TAB_CONTROL -Definition $Tab -Checkboxes $CHECKBOXES
}

[Void]$FORM.ShowDialog()
