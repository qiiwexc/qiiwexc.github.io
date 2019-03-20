$GroupHomeUpdate = New-Object System.Windows.Forms.GroupBox
$GroupHomeUpdate.Text = 'Updates'
$GroupHomeUpdate.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 2
$GroupHomeUpdate.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeUpdate.Location = $GroupHomeThisUtility.Location + "0, $($GroupHomeThisUtility.Height + $_INTERVAL_NORMAL)"
$_TAB_HOME.Controls.Add($GroupHomeUpdate)


$ButtonGoogleUpdate = New-Object System.Windows.Forms.Button
$ButtonGoogleUpdate.Text = 'Update Google Chrome'
$ButtonGoogleUpdate.Height = $_BUTTON_HEIGHT
$ButtonGoogleUpdate.Width = $_BUTTON_WIDTH_NORMAL
$ButtonGoogleUpdate.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonGoogleUpdate.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonGoogleUpdate, 'Silently update Google Chrome and other Google software')
$ButtonGoogleUpdate.Add_Click( {UpdateGoogleSoftware} )


$ButtonUpdateStoreApps = New-Object System.Windows.Forms.Button
$ButtonUpdateStoreApps.Text = 'Update Store apps'
$ButtonUpdateStoreApps.Height = $_BUTTON_HEIGHT
$ButtonUpdateStoreApps.Width = $_BUTTON_WIDTH_NORMAL
$ButtonUpdateStoreApps.Location = $ButtonGoogleUpdate.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonUpdateStoreApps.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonUpdateStoreApps, 'Update Microsoft Store apps')
$ButtonUpdateStoreApps.Add_Click( {UpdateStoreApps} )


$GroupHomeUpdate.Controls.AddRange(@($ButtonGoogleUpdate, $ButtonUpdateStoreApps))
