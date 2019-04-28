Set-Variable GRP_ThisUtility (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_ThisUtility.Text = 'This utility'
$GRP_ThisUtility.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_ThisUtility.Width = $GRP_WIDTH
$GRP_ThisUtility.Location = $GRP_INIT_LOCATION
$TAB_HOME.Controls.Add($GRP_ThisUtility)

Set-Variable BTN_Elevate (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_BrowserHome (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_SystemInfo (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInfo, 'Print system information to the log')

$BTN_Elevate.Font = $BTN_BrowserHome.Font = $BTN_SystemInfo.Font = $BTN_FONT
$BTN_Elevate.Height = $BTN_BrowserHome.Height = $BTN_SystemInfo.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_BrowserHome.Width = $BTN_SystemInfo.Width = $BTN_WIDTH

$GRP_ThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInfo))



$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Location = $BTN_INIT_LOCATION
$BTN_Elevate.Add_Click( { Start-Elevated } )


$BTN_BrowserHome.Text = 'Open in the browser'
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $SHIFT_BTN_NORMAL
$BTN_BrowserHome.Add_Click( { Open-InBrowser 'qiiwexc.github.io' } )


$BTN_SystemInfo.Text = 'System information'
$BTN_SystemInfo.Location = $BTN_BrowserHome.Location + $SHIFT_BTN_NORMAL
$BTN_SystemInfo.Add_Click( { Out-SystemInfo } )
