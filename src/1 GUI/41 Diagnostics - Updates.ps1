$GRP_Updates = New-Object System.Windows.Forms.GroupBox
$GRP_Updates.Text = 'Updates'
$GRP_Updates.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 4 + $INT_BTN_SHORT
$GRP_Updates.Width = $GRP_WIDTH
$GRP_Updates.Location = $GRP_INIT_LOCATION
$TAB_MAINTENANCE.Controls.Add($GRP_Updates)


$BTN_GoogleUpdate = New-Object System.Windows.Forms.Button
$BTN_GoogleUpdate.Text = 'Update Google Chrome'
$BTN_GoogleUpdate.Height = $BTN_HEIGHT
$BTN_GoogleUpdate.Width = $BTN_WIDTH
$BTN_GoogleUpdate.Location = $BTN_INIT_LOCATION
$BTN_GoogleUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_GoogleUpdate, 'Silently update Google Chrome and other Google software')
$BTN_GoogleUpdate.Add_Click( {Start-GoogleUpdate} )


$BTN_UpdateStoreApps = New-Object System.Windows.Forms.Button
$BTN_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BTN_UpdateStoreApps.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_WIDTH
$BTN_UpdateStoreApps.Location = $BTN_GoogleUpdate.Location + $SHIFT_BTN_NORMAL
$BTN_UpdateStoreApps.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
$BTN_UpdateStoreApps.Add_Click( {Start-StoreAppUpdate} )


$BTN_OfficeInsider = New-Object System.Windows.Forms.Button
$BTN_OfficeInsider.Text = 'Become Office insider'
$BTN_OfficeInsider.Height = $BTN_HEIGHT
$BTN_OfficeInsider.Width = $BTN_WIDTH
$BTN_OfficeInsider.Location = $BTN_UpdateStoreApps.Location + $SHIFT_BTN_NORMAL
$BTN_OfficeInsider.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OfficeInsider, 'Switch Microsoft Office to insider update channel')
$BTN_OfficeInsider.Add_Click( {Set-OfficeInsiderChannel} )

$BTN_UpdateOffice = New-Object System.Windows.Forms.Button
$BTN_UpdateOffice.Text = 'Update Microsoft Office'
$BTN_UpdateOffice.Height = $BTN_HEIGHT
$BTN_UpdateOffice.Width = $BTN_WIDTH
$BTN_UpdateOffice.Location = $BTN_OfficeInsider.Location + $SHIFT_BTN_SHORT
$BTN_UpdateOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
$BTN_UpdateOffice.Add_Click( {Start-OfficeUpdate} )


$BTN_WindowsUpdate = New-Object System.Windows.Forms.Button
$BTN_WindowsUpdate.Text = 'Start Windows Update'
$BTN_WindowsUpdate.Height = $BTN_HEIGHT
$BTN_WindowsUpdate.Width = $BTN_WIDTH
$BTN_WindowsUpdate.Location = $BTN_UpdateOffice.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsUpdate, 'Check for Windows updates, download and install if available')
$BTN_WindowsUpdate.Add_Click( {Start-WindowsUpdate} )


$GRP_Updates.Controls.AddRange(@($BTN_GoogleUpdate, $BTN_UpdateStoreApps, $BTN_OfficeInsider, $BTN_UpdateOffice, $BTN_WindowsUpdate))
