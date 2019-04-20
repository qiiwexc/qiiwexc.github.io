$GRP_Optimization = New-Object System.Windows.Forms.GroupBox
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Optimization.Width = $GRP_WIDTH
$GRP_Optimization.Location = $GRP_Cleanup.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Optimization)


$BTN_CloudFlareDNS = New-Object System.Windows.Forms.Button
$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_WIDTH
$BTN_CloudFlareDNS.Location = $BTN_INIT_LOCATION
$BTN_CloudFlareDNS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS (1.1.1.1 / 1.0.0.1)')
$BTN_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )


$BTN_OptimizeDrive = New-Object System.Windows.Forms.Button
$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_OptimizeDrive.Width = $BTN_WIDTH
$BTN_OptimizeDrive.Location = $BTN_CloudFlareDNS.Location + $SHIFT_BTN_NORMAL
$BTN_OptimizeDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BTN_OptimizeDrive.Add_Click( { Start-DriveOptimization } )


$BTN_RunDefraggler = New-Object System.Windows.Forms.Button
$BTN_RunDefraggler.Text = "Run Defraggler for (C:)$REQUIRES_ELEVATION"
$BTN_RunDefraggler.Height = $BTN_HEIGHT
$BTN_RunDefraggler.Width = $BTN_WIDTH
$BTN_RunDefraggler.Location = $BTN_OptimizeDrive.Location + $SHIFT_BTN_NORMAL
$BTN_RunDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunDefraggler, 'Perform (C:) drive defragmentation with Defraggler')
$BTN_RunDefraggler.Add_Click( { Start-Defraggler } )


$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_OptimizeDrive, $BTN_RunDefraggler))
