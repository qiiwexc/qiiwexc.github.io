$GRP_ThisUtility = New-Object System.Windows.Forms.GroupBox
$GRP_ThisUtility.Text = 'This utility'
$GRP_ThisUtility.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_ThisUtility.Width = $GRP_WIDTH
$GRP_ThisUtility.Location = $GRP_INIT_LOCATION
$TAB_HOME.Controls.Add($GRP_ThisUtility)


$BTN_Elevate = New-Object System.Windows.Forms.Button
$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_WIDTH
$BTN_Elevate.Location = $BTN_INIT_LOCATION
$BTN_Elevate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
$BTN_Elevate.Add_Click( {Start-Elevated} )


$BTN_BrowserHome = New-Object System.Windows.Forms.Button
$BTN_BrowserHome.Text = 'Open in the browser'
$BTN_BrowserHome.Height = $BTN_HEIGHT
$BTN_BrowserHome.Width = $BTN_WIDTH
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $SHIFT_BTN_NORMAL
$BTN_BrowserHome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
$BTN_BrowserHome.Add_Click( {Open-InBrowser 'qiiwexc.github.io'} )


$BTN_SystemInfo = New-Object System.Windows.Forms.Button
$BTN_SystemInfo.Text = 'System information'
$BTN_SystemInfo.Height = $BTN_HEIGHT
$BTN_SystemInfo.Width = $BTN_WIDTH
$BTN_SystemInfo.Location = $BTN_BrowserHome.Location + $SHIFT_BTN_NORMAL
$BTN_SystemInfo.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInfo, 'Print system information to the log')
$BTN_SystemInfo.Add_Click( {Out-SystemInfo} )


$GRP_ThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInfo))
