$GroupHomeThisUtility = New-Object System.Windows.Forms.GroupBox
$GroupHomeThisUtility.Text = 'This utility'
$GroupHomeThisUtility.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 3
$GroupHomeThisUtility.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeThisUtility.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"
$_TAB_HOME.Controls.Add($GroupHomeThisUtility)


$ButtonElevate = New-Object System.Windows.Forms.Button
$ButtonElevate.Text = 'Run as administrator'
$ButtonElevate.Height = $_BUTTON_HEIGHT
$ButtonElevate.Width = $_BUTTON_WIDTH_NORMAL
$ButtonElevate.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonElevate.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonElevate, 'Restart this utility with administrator privileges')
$ButtonElevate.Add_Click( {Elevate} )


$ButtonBrowserHome = New-Object System.Windows.Forms.Button
$ButtonBrowserHome.Text = 'Open in browser'
$ButtonBrowserHome.Height = $_BUTTON_HEIGHT
$ButtonBrowserHome.Width = $_BUTTON_WIDTH_NORMAL
$ButtonBrowserHome.Location = $ButtonElevate.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonBrowserHome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonBrowserHome, 'Open utility web page in the default browser')
$ButtonBrowserHome.Add_Click( {OpenInBrowser 'qiiwexc.github.io'} )


$ButtonSystemInformation = New-Object System.Windows.Forms.Button
$ButtonSystemInformation.Text = 'System information'
$ButtonSystemInformation.Height = $_BUTTON_HEIGHT
$ButtonSystemInformation.Width = $_BUTTON_WIDTH_NORMAL
$ButtonSystemInformation.Location = $ButtonBrowserHome.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonSystemInformation.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSystemInformation, 'Print system information to the log')
$ButtonSystemInformation.Add_Click( {PrintSystemInformation} )


$GroupHomeThisUtility.Controls.AddRange(@($ButtonElevate, $ButtonBrowserHome, $ButtonSystemInformation))
