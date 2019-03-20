$GroupHomeOptimization = New-Object System.Windows.Forms.GroupBox
$GroupHomeOptimization.Text = 'Optimization'
$GroupHomeOptimization.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 3
$GroupHomeOptimization.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeOptimization.Location = $GroupHomeDiagnostics.Location + "$($GroupHomeDiagnostics.Width + $_INTERVAL_NORMAL), 0"
$_TAB_HOME.Controls.Add($GroupHomeOptimization)


$ButtonCloudFlareDNS = New-Object System.Windows.Forms.Button
$ButtonCloudFlareDNS.Text = 'Setup CloudFlare DNS'
$ButtonCloudFlareDNS.Height = $_BUTTON_HEIGHT
$ButtonCloudFlareDNS.Width = $_BUTTON_WIDTH_NORMAL
$ButtonCloudFlareDNS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonCloudFlareDNS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCloudFlareDNS, 'Set DNS to CouldFlare - 1.1.1.1 / 1.0.0.1')
$ButtonCloudFlareDNS.Add_Click( {CloudFlareDNS} )


$ButtonRunCCleaner = New-Object System.Windows.Forms.Button
$ButtonRunCCleaner.Text = 'Run CCleaner silently'
$ButtonRunCCleaner.Height = $_BUTTON_HEIGHT
$ButtonRunCCleaner.Width = $_BUTTON_WIDTH_NORMAL
$ButtonRunCCleaner.Location = $ButtonCloudFlareDNS.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonRunCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonRunCCleaner, 'Clean the system in the background with CCleaner')
$ButtonRunCCleaner.Add_Click( {RunCCleaner} )


$ButtonOptimizeDrive = New-Object System.Windows.Forms.Button
$ButtonOptimizeDrive.Text = 'Optimize / defrag drive'
$ButtonOptimizeDrive.Height = $_BUTTON_HEIGHT
$ButtonOptimizeDrive.Width = $_BUTTON_WIDTH_NORMAL
$ButtonOptimizeDrive.Location = $ButtonRunCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonOptimizeDrive.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonOptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$ButtonOptimizeDrive.Add_Click( {OptimizeDrive} )


$GroupHomeOptimization.Controls.AddRange(@($ButtonCloudFlareDNS, $ButtonRunCCleaner, $ButtonOptimizeDrive))
