Set-Variable -Option Constant GRP_Cleanup (New-Object System.Windows.Forms.GroupBox)
$GRP_Cleanup.Text = 'Cleanup'
$GRP_Cleanup.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 2
$GRP_Cleanup.Width = $GRP_WIDTH
$GRP_Cleanup.Location = $GRP_Software.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Cleanup)

Set-Variable -Option Constant BTN_FileCleanup (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_DiskCleanup (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FileCleanup, 'Remove temporary files, some log files and empty directories, and some other unnecessary files')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DiskCleanup, 'Start Windows built-in disk cleanup utility')

$BTN_FileCleanup.Font = $BTN_DiskCleanup.Font = $BTN_FONT
$BTN_FileCleanup.Height = $BTN_DiskCleanup.Height = $BTN_HEIGHT
$BTN_FileCleanup.Width = $BTN_DiskCleanup.Width = $BTN_WIDTH

$GRP_Cleanup.Controls.AddRange(@($BTN_FileCleanup, $BTN_DiskCleanup))



$BTN_FileCleanup.Text = "File cleanup$REQUIRES_ELEVATION"
$BTN_FileCleanup.Location = $BTN_INIT_LOCATION
$BTN_FileCleanup.Add_Click( { Start-FileCleanup } )


$BTN_DiskCleanup.Text = 'Start disk cleanup'
$BTN_DiskCleanup.Location = $BTN_FileCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DiskCleanup.Add_Click( { Start-DiskCleanup } )
