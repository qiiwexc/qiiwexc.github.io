$GRP_Cleanup = New-Object System.Windows.Forms.GroupBox
$GRP_Cleanup.Text = 'Cleanup'
$GRP_Cleanup.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 5
$GRP_Cleanup.Width = $GRP_WIDTH
$GRP_Cleanup.Location = $GRP_Updates.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Cleanup)


$BTN_EmptyRecycleBin = New-Object System.Windows.Forms.Button
$BTN_EmptyRecycleBin.Text = 'Empty Recycle Bin'
$BTN_EmptyRecycleBin.Height = $BTN_HEIGHT
$BTN_EmptyRecycleBin.Width = $BTN_WIDTH
$BTN_EmptyRecycleBin.Location = $BTN_INIT_LOCATION
$BTN_EmptyRecycleBin.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_EmptyRecycleBin, 'Empty Recycle Bin')
$BTN_EmptyRecycleBin.Add_Click( { Remove-Trash } )


$BTN_DiskCleanup = New-Object System.Windows.Forms.Button
$BTN_DiskCleanup.Text = 'Start disk cleanup'
$BTN_DiskCleanup.Height = $BTN_HEIGHT
$BTN_DiskCleanup.Width = $BTN_WIDTH
$BTN_DiskCleanup.Location = $BTN_EmptyRecycleBin.Location + $SHIFT_BTN_NORMAL
$BTN_DiskCleanup.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DiskCleanup, 'Start Windows built-in disk cleanup utility')
$BTN_DiskCleanup.Add_Click( { Start-DiskCleanup } )


$BTN_RunCCleaner = New-Object System.Windows.Forms.Button
$BTN_RunCCleaner.Text = "Run CCleaner silently$REQUIRES_ELEVATION"
$BTN_RunCCleaner.Height = $BTN_HEIGHT
$BTN_RunCCleaner.Width = $BTN_WIDTH
$BTN_RunCCleaner.Location = $BTN_DiskCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_RunCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
$BTN_RunCCleaner.Add_Click( { Start-CCleaner } )


$BTN_WindowsCleanup = New-Object System.Windows.Forms.Button
$BTN_WindowsCleanup.Text = "Cleanup Windows files$REQUIRES_ELEVATION"
$BTN_WindowsCleanup.Height = $BTN_HEIGHT
$BTN_WindowsCleanup.Width = $BTN_WIDTH
$BTN_WindowsCleanup.Location = $BTN_RunCCleaner.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsCleanup.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsCleanup, 'Remove old versions of system files, which have been changed via updates')
$BTN_WindowsCleanup.Add_Click( { Start-WindowsCleanup } )


$BTN_DeleteRestorePoints = New-Object System.Windows.Forms.Button
$BTN_DeleteRestorePoints.Text = "Delete all restore points$REQUIRES_ELEVATION"
$BTN_DeleteRestorePoints.Height = $BTN_HEIGHT
$BTN_DeleteRestorePoints.Width = $BTN_WIDTH
$BTN_DeleteRestorePoints.Location = $BTN_WindowsCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DeleteRestorePoints.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DeleteRestorePoints, 'Delete all restore points (shadow copies)')
$BTN_DeleteRestorePoints.Add_Click( { Remove-RestorePoints } )


$GRP_Cleanup.Controls.AddRange(@($BTN_EmptyRecycleBin, $BTN_DiskCleanup, $BTN_RunCCleaner, $BTN_WindowsCleanup, $BTN_DeleteRestorePoints))
