$GRP_ThisUtility = New-Object System.Windows.Forms.GroupBox
$GRP_ThisUtility.Text = 'This utility'
$GRP_ThisUtility.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_ThisUtility.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_ThisUtility.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_HOME.Controls.Add($GRP_ThisUtility)


$BTN_Elevate = New-Object System.Windows.Forms.Button
$BTN_Elevate.Text = 'Run as administrator'
$BTN_Elevate.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_WIDTH_NORMAL
$BTN_Elevate.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_Elevate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
$BTN_Elevate.Add_Click( {Elevate} )


$BTN_BrowserHome = New-Object System.Windows.Forms.Button
$BTN_BrowserHome.Text = 'Open in browser'
$BTN_BrowserHome.Height = $BTN_HEIGHT
$BTN_BrowserHome.Width = $BTN_WIDTH_NORMAL
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $BTN_SHIFT_VER_NORMAL
$BTN_BrowserHome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
$BTN_BrowserHome.Add_Click( {OpenInBrowser 'qiiwexc.github.io'} )


$BTN_SystemInformation = New-Object System.Windows.Forms.Button
$BTN_SystemInformation.Text = 'System information'
$BTN_SystemInformation.Height = $BTN_HEIGHT
$BTN_SystemInformation.Width = $BTN_WIDTH_NORMAL
$BTN_SystemInformation.Location = $BTN_BrowserHome.Location + $BTN_SHIFT_VER_NORMAL
$BTN_SystemInformation.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInformation, 'Print system information to the log')
$BTN_SystemInformation.Add_Click( {PrintSystemInformation} )


$GRP_ThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInformation))
