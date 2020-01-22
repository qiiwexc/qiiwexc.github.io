Set-Variable GRP_Updates (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Updates.Text = 'Updates'
$GRP_Updates.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Updates.Width = $GRP_WIDTH
$GRP_Updates.Location = $GRP_INIT_LOCATION
$TAB_MAINTENANCE.Controls.Add($GRP_Updates)

Set-Variable BTN_UpdateStoreApps (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_UpdateOffice (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_WindowsUpdate (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsUpdate, 'Check for Windows updates, download and install if available')

$BTN_UpdateStoreApps.Font = $BTN_UpdateOffice.Font = $BTN_WindowsUpdate.Font = $BTN_FONT
$BTN_UpdateStoreApps.Height = $BTN_UpdateOffice.Height = $BTN_WindowsUpdate.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_UpdateOffice.Width = $BTN_WindowsUpdate.Width = $BTN_WIDTH

$GRP_Updates.Controls.AddRange(@($BTN_UpdateStoreApps, $BTN_UpdateOffice, $BTN_WindowsUpdate))



$BTN_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BTN_UpdateStoreApps.Location = $BTN_INIT_LOCATION
$BTN_UpdateStoreApps.Add_Click( { Start-StoreAppUpdate } )


$BTN_UpdateOffice.Text = 'Update Microsoft Office'
$BTN_UpdateOffice.Location = $BTN_UpdateStoreApps.Location + $SHIFT_BTN_NORMAL
$BTN_UpdateOffice.Add_Click( { Start-OfficeUpdate } )


$BTN_WindowsUpdate.Text = 'Start Windows Update'
$BTN_WindowsUpdate.Location = $BTN_UpdateOffice.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsUpdate.Add_Click( { Start-WindowsUpdate } )
