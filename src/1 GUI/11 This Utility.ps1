$GroupHomeThisUtility = New-Object System.Windows.Forms.GroupBox
$GroupHomeThisUtility.Text = 'This utility'
$GroupHomeThisUtility.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 2
$GroupHomeThisUtility.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_HOME + $_INTERVAL_NORMAL
$GroupHomeThisUtility.Location = "$($_TAB_CONTROL.Width - $GroupHomeThisUtility.Width - $_INTERVAL_NORMAL - $_INTERVAL_TAB_ADJUSTMENT), $_INTERVAL_NORMAL"


$ButtonBrowserHome = New-Object System.Windows.Forms.Button
$ButtonBrowserHome.Text = 'Open in browser'
$ButtonBrowserHome.Height = $_BUTTON_HEIGHT
$ButtonBrowserHome.Width = $_BUTTON_WIDTH_HOME
$ButtonBrowserHome.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonBrowserHome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonBrowserHome, 'Open utility web page in the default browser')
$ButtonBrowserHome.Add_Click( {OpenInBrowser 'qiiwexc.github.io'} )


$ButtonCheckForUpdates = New-Object System.Windows.Forms.Button
$ButtonCheckForUpdates.Text = 'Check for updates'
$ButtonCheckForUpdates.Height = $_BUTTON_HEIGHT
$ButtonCheckForUpdates.Width = $_BUTTON_WIDTH_HOME
$ButtonCheckForUpdates.Location = $ButtonBrowserHome.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonCheckForUpdates.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCheckForUpdates, 'Check if new version of this utility is available')
$ButtonCheckForUpdates.Add_Click( {CheckForUpdates 'Manual'} )

$ButtonDownloadUpdate = New-Object System.Windows.Forms.Button
$ButtonDownloadUpdate.Text = 'Download new version'
$ButtonDownloadUpdate.Height = $ButtonCheckForUpdates.Height
$ButtonDownloadUpdate.Width = $_BUTTON_WIDTH_HOME
$ButtonDownloadUpdate.Location = $ButtonCheckForUpdates.Location
$ButtonDownloadUpdate.Font = $_BUTTON_FONT
$ButtonDownloadUpdate.Visible = $False
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadUpdate, 'Download the new version of this utility')
$ButtonDownloadUpdate.Add_Click( {DownloadUpdate} )


$_TAB_HOME.Controls.AddRange(@($GroupHomeThisUtility))
$GroupHomeThisUtility.Controls.AddRange(@($ButtonBrowserHome, $ButtonCheckForUpdates, $ButtonDownloadUpdate))
