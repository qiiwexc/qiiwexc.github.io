Set-Variable -Option Constant GRP_DownloadWindows (New-Object System.Windows.Forms.GroupBox)
$GRP_DownloadWindows.Text = 'Windows Images'
$GRP_DownloadWindows.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 4
$GRP_DownloadWindows.Width = $GRP_WIDTH
$GRP_DownloadWindows.Location = $GRP_Essentials.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_DownloadWindows)

Set-Variable -Option Constant BTN_Windows10 (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows10 (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_Windows8  (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows8  (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_Windows7  (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_Windows7  (New-Object System.Windows.Forms.Label)

Set-Variable -Option Constant BTN_WindowsXP (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_WindowsXP (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows10, 'Download Windows 10 (v20H2) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows8, 'Download Windows 8.1 RUS-ENG x86-x64 -20in1- SevenMod v3 (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXP, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')

$BTN_Windows10.Font = $BTN_Windows8.Font = $BTN_Windows7.Font = $BTN_WindowsXP.Font = $BTN_FONT
$BTN_Windows10.Height = $BTN_Windows8.Height = $BTN_Windows7.Height = $BTN_WindowsXP.Height = $BTN_HEIGHT
$BTN_Windows10.Width = $BTN_Windows8.Width = $BTN_Windows7.Width = $BTN_WindowsXP.Width = $BTN_WIDTH

$LBL_Windows10.Size = $LBL_Windows8.Size = $LBL_Windows7.Size = $LBL_WindowsXP.Size = $CBOX_SIZE
$LBL_Windows10.Text = $LBL_Windows8.Text = $LBL_Windows7.Text = $LBL_WindowsXP.Text = $TXT_OPENS_IN_BROWSER

$GRP_DownloadWindows.Controls.AddRange(@($BTN_Windows10, $LBL_Windows10, $BTN_Windows8, $LBL_Windows8, $BTN_Windows7, $LBL_Windows7, $BTN_WindowsXP, $LBL_WindowsXP))



$BTN_Windows10.Text = 'Windows 10 (v20H2)'
$BTN_Windows10.Location = $BTN_INIT_LOCATION
$BTN_Windows10.Add_Click( { Open-InBrowser 'http://monkrus.ws/2020/11/windows-10-v20h2-rus-eng-x86-x64-28in1.html' } )

$LBL_Windows10.Location = $BTN_Windows10.Location + $SHIFT_LBL_BROWSER

$BTN_Windows8.Text = 'Windows 8.1 (Update 3)'
$BTN_Windows8.Location = $BTN_Windows10.Location + $SHIFT_BTN_LONG
$BTN_Windows8.Add_Click( { Open-InBrowser 'http://monkrus.ws/2020/03/windows-81-rus-eng-x86-x64-20in1.html' } )

$LBL_Windows8.Location = $BTN_Windows8.Location + $SHIFT_LBL_BROWSER

$BTN_Windows7.Text = 'Windows 7 SP1'
$BTN_Windows7.Location = $BTN_Windows8.Location + $SHIFT_BTN_LONG
$BTN_Windows7.Add_Click( { Open-InBrowser 'http://monkrus.ws/2020/02/windows-7-sp1-rus-eng-x86-x64-18in1.html' } )

$LBL_Windows7.Location = $BTN_Windows7.Location + $SHIFT_LBL_BROWSER

$BTN_WindowsXP.Text = 'Windows XP SP3 (ENG)'
$BTN_WindowsXP.Location = $BTN_Windows7.Location + $SHIFT_BTN_LONG
$BTN_WindowsXP.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF' } )

$LBL_WindowsXP.Location = $BTN_WindowsXP.Location + $SHIFT_LBL_BROWSER
