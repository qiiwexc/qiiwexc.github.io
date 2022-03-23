Set-Variable -Option Constant GROUP_Updates (New-Object System.Windows.Forms.GroupBox)
$GROUP_Updates.Text = 'Updates'
$GROUP_Updates.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 3
$GROUP_Updates.Width = $WIDTH_GROUP
$GROUP_Updates.Location = $GROUP_Essentials.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_DOWNLOADS.Controls.Add($GROUP_Updates)


Set-Variable -Option Constant BUTTON_UpdateStoreApps (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_UpdateStoreApps, 'Update Microsoft Store apps')
$BUTTON_UpdateStoreApps.Enabled = $OS_VERSION -gt 7
$BUTTON_UpdateStoreApps.Font = $BUTTON_FONT
$BUTTON_UpdateStoreApps.Height = $HEIGHT_BUTTON
$BUTTON_UpdateStoreApps.Width = $WIDTH_BUTTON
$BUTTON_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BUTTON_UpdateStoreApps.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_UpdateStoreApps.Add_Click( { Start-StoreAppUpdate } )
$GROUP_Updates.Controls.Add($BUTTON_UpdateStoreApps)


Set-Variable -Option Constant BUTTON_UpdateOffice (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
$BUTTON_UpdateOffice.Enabled = $OFFICE_INSTALL_TYPE -eq 'C2R'
$BUTTON_UpdateOffice.Font = $BUTTON_FONT
$BUTTON_UpdateOffice.Height = $HEIGHT_BUTTON
$BUTTON_UpdateOffice.Width = $WIDTH_BUTTON
$BUTTON_UpdateOffice.Text = "Update Microsoft Office"
$BUTTON_UpdateOffice.Location = $BUTTON_UpdateStoreApps.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_UpdateOffice.Add_Click( { Start-OfficeUpdate } )
$GROUP_Updates.Controls.Add($BUTTON_UpdateOffice)


Set-Variable -Option Constant BUTTON_WindowsUpdate (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_WindowsUpdate, 'Check for Windows updates, download and install if available')
$BUTTON_WindowsUpdate.Font = $BUTTON_FONT
$BUTTON_WindowsUpdate.Height = $HEIGHT_BUTTON
$BUTTON_WindowsUpdate.Width = $WIDTH_BUTTON
$BUTTON_WindowsUpdate.Text = 'Start Windows Update'
$BUTTON_WindowsUpdate.Location = $BUTTON_UpdateOffice.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_WindowsUpdate.Add_Click( { Start-WindowsUpdate } )
$GROUP_Updates.Controls.Add($BUTTON_WindowsUpdate)
