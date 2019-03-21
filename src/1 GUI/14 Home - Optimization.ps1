$GRP_HomeOptimization = New-Object System.Windows.Forms.GroupBox
$GRP_HomeOptimization.Text = 'Optimization'
$GRP_HomeOptimization.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_HomeOptimization.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeOptimization.Location = $GRP_HomeDiagnostics.Location + "$($GRP_HomeDiagnostics.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_HomeOptimization)


$BTN_CloudFlareDNS = New-Object System.Windows.Forms.Button
$BTN_CloudFlareDNS.Text = 'Setup CloudFlare DNS'
$BTN_CloudFlareDNS.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_WIDTH_NORMAL
$BTN_CloudFlareDNS.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CloudFlareDNS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS to CouldFlare - 1.1.1.1 / 1.0.0.1')
$BTN_CloudFlareDNS.Add_Click( {CloudFlareDNS} )


$BTN_RunCCleaner = New-Object System.Windows.Forms.Button
$BTN_RunCCleaner.Text = 'Run CCleaner silently'
$BTN_RunCCleaner.Height = $BTN_HEIGHT
$BTN_RunCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_RunCCleaner.Location = $BTN_CloudFlareDNS.Location + $BTN_SHIFT_VER_NORMAL
$BTN_RunCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
$BTN_RunCCleaner.Add_Click( {RunCCleaner} )


$BTN_OptimizeDrive = New-Object System.Windows.Forms.Button
$BTN_OptimizeDrive.Text = 'Optimize / defrag drive'
$BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_OptimizeDrive.Width = $BTN_WIDTH_NORMAL
$BTN_OptimizeDrive.Location = $BTN_RunCCleaner.Location + $BTN_SHIFT_VER_NORMAL
$BTN_OptimizeDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BTN_OptimizeDrive.Add_Click( {OptimizeDrive} )


$GRP_HomeOptimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_RunCCleaner, $BTN_OptimizeDrive))
