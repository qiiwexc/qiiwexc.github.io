Set-Variable -Option Constant GROUP_Optimization (New-Object System.Windows.Forms.GroupBox)
$GROUP_Optimization.Text = 'Optimization'
$GROUP_Optimization.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL + $INTERVAL_BUTTON_LONG + $INTERVAL_CHECKBOX_SHORT - $INTERVAL_SHORT
$GROUP_Optimization.Width = $WIDTH_GROUP
$GROUP_Optimization.Location = $GROUP_Cleanup.Location + "0, $($GROUP_Cleanup.Height + $INTERVAL_NORMAL)"
$TAB_MAINTENANCE.Controls.Add($GROUP_Optimization)
$GROUP = $GROUP_Optimization


Set-Variable -Option Constant BUTTON_CloudFlareDNS (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_CloudFlareDNS, 'Set DNS server to CouldFlare DNS')
$BUTTON_CloudFlareDNS.Font = $BUTTON_FONT
$BUTTON_CloudFlareDNS.Height = $HEIGHT_BUTTON
$BUTTON_CloudFlareDNS.Width = $WIDTH_BUTTON
$BUTTON_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BUTTON_CloudFlareDNS.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )
$GROUP_Optimization.Controls.Add($BUTTON_CloudFlareDNS)


Set-Variable -Option Constant CHECKBOX_CloudFlareAntiMalware (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_CloudFlareAntiMalware, 'Use CloudFlare DNS variation with malware protection (1.1.1.2)')
$CHECKBOX_CloudFlareAntiMalware.Size = $CHECKBOX_SIZE
$CHECKBOX_CloudFlareAntiMalware.Text = 'Malware protection'
$CHECKBOX_CloudFlareAntiMalware.Checked = $True
$CHECKBOX_CloudFlareAntiMalware.Location = $BUTTON_CloudFlareDNS.Location + "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )
$GROUP_Optimization.Controls.Add($CHECKBOX_CloudFlareAntiMalware)


Set-Variable -Option Constant CHECKBOX_CloudFlareFamilyFriendly (New-Object System.Windows.Forms.CheckBox)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CHECKBOX_CloudFlareFamilyFriendly, 'Use CloudFlare DNS variation with malware protection and adult content filtering (1.1.1.3)')
$CHECKBOX_CloudFlareFamilyFriendly.Size = $CHECKBOX_SIZE
$CHECKBOX_CloudFlareFamilyFriendly.Text = 'Adult content filtering'
$CHECKBOX_CloudFlareFamilyFriendly.Location = $CHECKBOX_CloudFlareAntiMalware.Location + "0, $HEIGHT_CHECKBOX"
$GROUP_Optimization.Controls.Add($CHECKBOX_CloudFlareFamilyFriendly)


Set-Variable -Option Constant BUTTON_OptimizeDrive (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BUTTON_OptimizeDrive.Font = $BUTTON_FONT
$BUTTON_OptimizeDrive.Height = $HEIGHT_BUTTON
$BUTTON_OptimizeDrive.Width = $WIDTH_BUTTON
$BUTTON_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BUTTON_OptimizeDrive.Location = $BUTTON_CloudFlareDNS.Location + $SHIFT_BUTTON_SHORT + $SHIFT_BUTTON_NORMAL
$BUTTON_OptimizeDrive.Add_Click( { Start-DriveOptimization } )
$GROUP_Optimization.Controls.Add($BUTTON_OptimizeDrive)
