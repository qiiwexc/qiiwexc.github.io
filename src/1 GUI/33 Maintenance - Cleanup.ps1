Set-Variable -Option Constant GROUP_Cleanup (New-Object System.Windows.Forms.GroupBox)
$GROUP_Cleanup.Text = 'Cleanup'
$GROUP_Cleanup.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 2
$GROUP_Cleanup.Width = $WIDTH_GROUP
$GROUP_Cleanup.Location = $GROUP_Software.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_MAINTENANCE.Controls.Add($GROUP_Cleanup)
$GROUP = $GROUP_Cleanup


Set-Variable -Option Constant BUTTON_FileCleanup (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_FileCleanup, 'Remove temporary files, some log files and empty directories, and some other unnecessary files')
$BUTTON_FileCleanup.Font = $BUTTON_FONT
$BUTTON_FileCleanup.Height = $HEIGHT_BUTTON
$BUTTON_FileCleanup.Width = $WIDTH_BUTTON
$BUTTON_FileCleanup.Text = "File cleanup$REQUIRES_ELEVATION"
$BUTTON_FileCleanup.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_FileCleanup.Add_Click( { Start-FileCleanup } )
$GROUP_Cleanup.Controls.Add($BUTTON_FileCleanup)


Set-Variable -Option Constant BUTTON_DiskCleanup (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_DiskCleanup, 'Start Windows built-in disk cleanup utility')
$BUTTON_DiskCleanup.Font = $BUTTON_FONT
$BUTTON_DiskCleanup.Height = $HEIGHT_BUTTON
$BUTTON_DiskCleanup.Width = $WIDTH_BUTTON
$BUTTON_DiskCleanup.Text = 'Start disk cleanup'
$BUTTON_DiskCleanup.Location = $BUTTON_FileCleanup.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_DiskCleanup.Add_Click( { Start-DiskCleanup } )
$GROUP_Cleanup.Controls.Add($BUTTON_DiskCleanup)
