Set-Variable GRP_Cleanup (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Cleanup.Text = 'Cleanup'
$GRP_Cleanup.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 6
$GRP_Cleanup.Width = $GRP_WIDTH
$GRP_Cleanup.Location = $GRP_Updates.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Cleanup)


Set-Variable BTN_EmptyRecycleBin (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_FileCleanup (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DiskCleanup (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_RunCCleaner (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_WindowsCleanup (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DeleteRestorePoints (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_EmptyRecycleBin, 'Empty Recycle Bin')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FileCleanup, 'Remove temporary files, some log files and empty directories, and some other unnecessary files')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DiskCleanup, 'Start Windows built-in disk cleanup utility')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsCleanup, 'Remove old versions of system files, which have been changed via updates')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DeleteRestorePoints, 'Delete all restore points (shadow copies)')

$BTN_EmptyRecycleBin.Font = $BTN_FileCleanup.Font = $BTN_DiskCleanup.Font = $BTN_RunCCleaner.Font = $BTN_WindowsCleanup.Font = $BTN_DeleteRestorePoints.Font = $BTN_FONT
$BTN_EmptyRecycleBin.Height = $BTN_FileCleanup.Height = $BTN_DiskCleanup.Height = $BTN_RunCCleaner.Height = $BTN_WindowsCleanup.Height = $BTN_DeleteRestorePoints.Height = $BTN_HEIGHT
$BTN_EmptyRecycleBin.Width = $BTN_FileCleanup.Width = $BTN_DiskCleanup.Width = $BTN_RunCCleaner.Width = $BTN_WindowsCleanup.Width = $BTN_DeleteRestorePoints.Width = $BTN_WIDTH

$GRP_Cleanup.Controls.AddRange(@($BTN_EmptyRecycleBin, $BTN_FileCleanup, $BTN_DiskCleanup, $BTN_RunCCleaner, $BTN_WindowsCleanup, $BTN_DeleteRestorePoints))



$BTN_EmptyRecycleBin.Text = "Empty Recycle Bin$(if($PS_VERSION -le 2) {$REQUIRES_ELEVATION})"
$BTN_EmptyRecycleBin.Location = $BTN_INIT_LOCATION
$BTN_EmptyRecycleBin.Add_Click( { Remove-Trash } )


$BTN_FileCleanup.Text = "File cleanup$REQUIRES_ELEVATION"
$BTN_FileCleanup.Location = $BTN_EmptyRecycleBin.Location + $SHIFT_BTN_NORMAL
$BTN_FileCleanup.Add_Click( { Start-FileCleanup } )


$BTN_DiskCleanup.Text = 'Start disk cleanup'
$BTN_DiskCleanup.Location = $BTN_FileCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DiskCleanup.Add_Click( { Start-DiskCleanup } )


$BTN_RunCCleaner.Text = "Run CCleaner silently$REQUIRES_ELEVATION"
$BTN_RunCCleaner.Location = $BTN_DiskCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_RunCCleaner.Add_Click( { Start-CCleaner } )


$BTN_WindowsCleanup.Text = "Cleanup Windows files$REQUIRES_ELEVATION"
$BTN_WindowsCleanup.Location = $BTN_RunCCleaner.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsCleanup.Add_Click( { Start-WindowsCleanup } )


$BTN_DeleteRestorePoints.Text = "Delete all restore points$REQUIRES_ELEVATION"
$BTN_DeleteRestorePoints.Location = $BTN_WindowsCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DeleteRestorePoints.Add_Click( { Remove-RestorePoints } )
