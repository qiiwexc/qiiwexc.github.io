$GRP_Optimization = New-Object System.Windows.Forms.GroupBox
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_Optimization.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Optimization.Location = $GRP_Diagnostics.Location + "$($GRP_Diagnostics.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_Optimization)


$BTN_CloudFlareDNS = New-Object System.Windows.Forms.Button
$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_WIDTH_NORMAL
$BTN_CloudFlareDNS.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CloudFlareDNS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS (1.1.1.1 / 1.0.0.1)')
$BTN_CloudFlareDNS.Add_Click( {Set-CloudFlareDNS} )


$BTN_RunCCleaner = New-Object System.Windows.Forms.Button
$BTN_RunCCleaner.Text = "Run CCleaner silently$REQUIRES_ELEVATION"
$BTN_RunCCleaner.Height = $BTN_HEIGHT
$BTN_RunCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_RunCCleaner.Location = $BTN_CloudFlareDNS.Location + $BTN_SHIFT_VER_NORMAL
$BTN_RunCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
$BTN_RunCCleaner.Add_Click( {Start-CCleaner} )


$BTN_DeleteRestorePoints = New-Object System.Windows.Forms.Button
$BTN_DeleteRestorePoints.Text = "Delete all restore points$REQUIRES_ELEVATION"
$BTN_DeleteRestorePoints.Height = $BTN_HEIGHT
$BTN_DeleteRestorePoints.Width = $BTN_WIDTH_NORMAL
$BTN_DeleteRestorePoints.Location = $BTN_RunCCleaner.Location + $BTN_SHIFT_VER_NORMAL
$BTN_DeleteRestorePoints.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DeleteRestorePoints, 'Delete all restore points (shadow copies)')
$BTN_DeleteRestorePoints.Add_Click( {Remove-RestorePoints} )


$BTN_OptimizeDrive = New-Object System.Windows.Forms.Button
$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_OptimizeDrive.Width = $BTN_WIDTH_NORMAL
$BTN_OptimizeDrive.Location = $BTN_DeleteRestorePoints.Location + $BTN_SHIFT_VER_NORMAL
$BTN_OptimizeDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BTN_OptimizeDrive.Add_Click( {Start-DriveOptimization} )


$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_RunCCleaner, $BTN_DeleteRestorePoints, $BTN_OptimizeDrive))
