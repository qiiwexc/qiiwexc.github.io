$GRP_DownloadWindows = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadWindows.Text = 'Windows Images'
$GRP_DownloadWindows.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 5 + $INT_SHORT
$GRP_DownloadWindows.Width = $GRP_WIDTH
$GRP_DownloadWindows.Location = $GRP_Essentials.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_DownloadWindows)


$BTN_Windows10 = New-Object System.Windows.Forms.Button
$BTN_Windows10.Text = 'Windows 10 (v1809)'
$BTN_Windows10.Height = $BTN_HEIGHT
$BTN_Windows10.Width = $BTN_WIDTH
$BTN_Windows10.Location = $BTN_INIT_LOCATION
$BTN_Windows10.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows10, 'Download Windows 10 (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image')
$BTN_Windows10.Add_Click( {Open-InBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )

$LBL_Windows10 = New-Object System.Windows.Forms.Label
$LBL_Windows10.Text = $TXT_OPENS_IN_BROWSER
$LBL_Windows10.Size = $CBOX_SIZE
$LBL_Windows10.Location = $BTN_Windows10.Location + $SHIFT_LBL_BROWSER

$BTN_Windows8 = New-Object System.Windows.Forms.Button
$BTN_Windows8.Text = 'Windows 8.1 (Update 3)'
$BTN_Windows8.Height = $BTN_HEIGHT
$BTN_Windows8.Width = $BTN_WIDTH
$BTN_Windows8.Location = $BTN_Windows10.Location + $SHIFT_BTN_LONG
$BTN_Windows8.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows8, 'Download Windows 8.1 with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image')
$BTN_Windows8.Add_Click( {Open-InBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )

$LBL_Windows8 = New-Object System.Windows.Forms.Label
$LBL_Windows8.Text = $TXT_OPENS_IN_BROWSER
$LBL_Windows8.Size = $CBOX_SIZE
$LBL_Windows8.Location = $BTN_Windows8.Location + $SHIFT_LBL_BROWSER

$BTN_Windows7 = New-Object System.Windows.Forms.Button
$BTN_Windows7.Text = 'Windows 7 SP1'
$BTN_Windows7.Height = $BTN_HEIGHT
$BTN_Windows7.Width = $BTN_WIDTH
$BTN_Windows7.Location = $BTN_Windows8.Location + $SHIFT_BTN_LONG
$BTN_Windows7.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image')
$BTN_Windows7.Add_Click( {Open-InBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )

$LBL_Windows7 = New-Object System.Windows.Forms.Label
$LBL_Windows7.Text = $TXT_OPENS_IN_BROWSER
$LBL_Windows7.Size = $CBOX_SIZE
$LBL_Windows7.Location = $BTN_Windows7.Location + $SHIFT_LBL_BROWSER


$BTN_WindowsXPENG = New-Object System.Windows.Forms.Button
$BTN_WindowsXPENG.Text = 'Windows XP SP3 (ENG)'
$BTN_WindowsXPENG.Height = $BTN_HEIGHT
$BTN_WindowsXPENG.Width = $BTN_WIDTH
$BTN_WindowsXPENG.Location = $BTN_Windows7.Location + $SHIFT_BTN_NORMAL + $SHIFT_CBOX_SHORT
$BTN_WindowsXPENG.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXPENG, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$BTN_WindowsXPENG.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )

$LBL_WindowsXPENG = New-Object System.Windows.Forms.Label
$LBL_WindowsXPENG.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsXPENG.Size = $CBOX_SIZE
$LBL_WindowsXPENG.Location = $BTN_WindowsXPENG.Location + $SHIFT_LBL_BROWSER

$BTN_WindowsXPRUS = New-Object System.Windows.Forms.Button
$BTN_WindowsXPRUS.Text = 'Windows XP SP3 (RUS)'
$BTN_WindowsXPRUS.Height = $BTN_HEIGHT
$BTN_WindowsXPRUS.Width = $BTN_WIDTH
$BTN_WindowsXPRUS.Location = $BTN_WindowsXPENG.Location + $SHIFT_BTN_LONG
$BTN_WindowsXPRUS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXPRUS, 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image')
$BTN_WindowsXPRUS.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )

$LBL_WindowsXPRUS = New-Object System.Windows.Forms.Label
$LBL_WindowsXPRUS.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsXPRUS.Size = $CBOX_SIZE
$LBL_WindowsXPRUS.Location = $BTN_WindowsXPRUS.Location + $SHIFT_LBL_BROWSER


$GRP_DownloadWindows.Controls.AddRange(
    @($BTN_Windows10, $LBL_Windows10, $BTN_Windows8, $LBL_Windows8, $BTN_Windows7, $LBL_Windows7, $BTN_WindowsXPENG, $LBL_WindowsXPENG, $BTN_WindowsXPRUS, $LBL_WindowsXPRUS)
)