Set-Variable -Option Constant GRP_DownloadWindows (New-Object System.Windows.Forms.GroupBox)
$GRP_DownloadWindows.Text = 'Windows Images'
$GRP_DownloadWindows.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadWindows.Width = $GRP_WIDTH
$GRP_DownloadWindows.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadWindows)

Set-Variable -Option Constant BTN_Windows10 (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows10 (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_Windows7  (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows7  (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_WindowsXP (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsXP (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows10, 'Download Windows 10 (v21H1) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXP, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')

$BTN_Windows10.Font = $BTN_Windows7.Font = $BTN_WindowsXP.Font = $BTN_FONT
$BTN_Windows10.Height = $BTN_Windows7.Height = $BTN_WindowsXP.Height = $BTN_HEIGHT
$BTN_Windows10.Width = $BTN_Windows7.Width = $BTN_WindowsXP.Width = $BTN_WIDTH

$LBL_Windows10.Size = $LBL_Windows7.Size = $LBL_WindowsXP.Size = $CBOX_SIZE
$LBL_Windows10.Text = $LBL_Windows7.Text = $LBL_WindowsXP.Text = $TXT_OPENS_IN_BROWSER

$GRP_DownloadWindows.Controls.AddRange(@($BTN_Windows10, $LBL_Windows10, $BTN_Windows7, $LBL_Windows7, $BTN_WindowsXP, $LBL_WindowsXP))



$BTN_Windows10.Text = 'Windows 10 (v21H1)'
$BTN_Windows10.Location = $BTN_INIT_LOCATION
$BTN_Windows10.Add_Click( { Open-InBrowser 'bit.ly/Windows_10_21H1' } )

$LBL_Windows10.Location = $BTN_Windows10.Location + $SHIFT_LBL_BROWSER

$BTN_Windows7.Text = 'Windows 7 SP1'
$BTN_Windows7.Location = $BTN_Windows10.Location + $SHIFT_BTN_LONG
$BTN_Windows7.Add_Click( { Open-InBrowser 'bit.ly/Windows_7_2020' } )

$LBL_Windows7.Location = $BTN_Windows7.Location + $SHIFT_LBL_BROWSER

$BTN_WindowsXP.Text = 'Windows XP SP3 (ENG)'
$BTN_WindowsXP.Location = $BTN_Windows7.Location + $SHIFT_BTN_LONG
$BTN_WindowsXP.Add_Click( { Open-InBrowser 'bit.ly/Windows_XP_SP3_ENG' } )

$LBL_WindowsXP.Location = $BTN_WindowsXP.Location + $SHIFT_LBL_BROWSER
