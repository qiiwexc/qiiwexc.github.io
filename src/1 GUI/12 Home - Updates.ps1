$GRP_HomeUpdate = New-Object System.Windows.Forms.GroupBox
$GRP_HomeUpdate.Text = 'Updates'
$GRP_HomeUpdate.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 2
$GRP_HomeUpdate.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeUpdate.Location = $GRP_HomeThisUtility.Location + "0, $($GRP_HomeThisUtility.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_HomeUpdate)


$BTN_GoogleUpdate = New-Object System.Windows.Forms.Button
$BTN_GoogleUpdate.Text = 'Update Google Chrome'
$BTN_GoogleUpdate.Height = $BTN_HEIGHT
$BTN_GoogleUpdate.Width = $BTN_WIDTH_NORMAL
$BTN_GoogleUpdate.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_GoogleUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_GoogleUpdate, 'Silently update Google Chrome and other Google software')
$BTN_GoogleUpdate.Add_Click( {UpdateGoogleSoftware} )


$BTN_UpdateStoreApps = New-Object System.Windows.Forms.Button
$BTN_UpdateStoreApps.Text = 'Update Store apps'
$BTN_UpdateStoreApps.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_WIDTH_NORMAL
$BTN_UpdateStoreApps.Location = $BTN_GoogleUpdate.Location + $BTN_SHIFT_VER_NORMAL
$BTN_UpdateStoreApps.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
$BTN_UpdateStoreApps.Add_Click( {UpdateStoreApps} )


$GRP_HomeUpdate.Controls.AddRange(@($BTN_GoogleUpdate, $BTN_UpdateStoreApps))
