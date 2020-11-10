Set-Variable -Option Constant GRP_Optimization (New-Object System.Windows.Forms.GroupBox)
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL + $INT_BTN_LONG + $INT_CBOX_SHORT - $INT_SHORT
$GRP_Optimization.Width = $GRP_WIDTH
$GRP_Optimization.Location = $GRP_Cleanup.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Optimization)

Set-Variable -Option Constant BTN_CloudFlareDNS (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_CloudFlareAntiMalware    (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_CloudFlareFamilyFriendly (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_OptimizeDrive (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_RunDefraggler (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_CloudFlareAntiMalware, 'Use CloudFlare DNS variation with malware protection (1.1.1.2)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_CloudFlareFamilyFriendly, 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')

$BTN_CloudFlareDNS.Font = $BTN_OptimizeDrive.Font = $BTN_FONT
$BTN_CloudFlareDNS.Height = $BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_OptimizeDrive.Width = $BTN_WIDTH
$CBOX_CloudFlareAntiMalware.Size = $CBOX_CloudFlareFamilyFriendly.Size = $CBOX_SIZE

$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $CBOX_CloudFlareAntiMalware, $CBOX_CloudFlareFamilyFriendly, $BTN_OptimizeDrive))



$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Location = $BTN_INIT_LOCATION
$BTN_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )

$CBOX_CloudFlareAntiMalware.Text = 'Malware protection'
$CBOX_CloudFlareAntiMalware.Checked = $True
$CBOX_CloudFlareAntiMalware.Location = $BTN_CloudFlareDNS.Location + "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)"
$CBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CBOX_CloudFlareFamilyFriendly.Enabled = $CBOX_CloudFlareAntiMalware.Checked } )

$CBOX_CloudFlareFamilyFriendly.Text = 'Adult content filtering'
$CBOX_CloudFlareFamilyFriendly.Location = $CBOX_CloudFlareAntiMalware.Location + "0, $CBOX_HEIGHT"


$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Location = $BTN_CloudFlareDNS.Location + $SHIFT_BTN_SHORT + $SHIFT_BTN_NORMAL
$BTN_OptimizeDrive.Add_Click( { Start-DriveOptimization } )
