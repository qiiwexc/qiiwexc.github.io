$GRP_DownloadsWindows = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsWindows.Text = 'Windows ISO Images'
$GRP_DownloadsWindows.Height = $INT_NORMAL + ($BTN_INT_SHORT + $CBOX_INT_SHORT) * 6
$GRP_DownloadsWindows.Width = $GRP_Activators.Width
$GRP_DownloadsWindows.Location = $GRP_Activators.Location + "$($GRP_Activators.Width + $INT_NORMAL), 0"
$TAB_TOOLS_AND_ISO.Controls.Add($GRP_DownloadsWindows)


$BTN_DownloadWindows10 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows10.Text = 'Windows 10'
$BTN_DownloadWindows10.Height = $BTN_HEIGHT
$BTN_DownloadWindows10.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows10.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadWindows10.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows10, 'Download Windows 10 (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image')
$BTN_DownloadWindows10.Add_Click( {Open-InBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )

$LBL_DownloadWindows10 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows10.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows10.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindows10.Location = $BTN_DownloadWindows10.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindows8 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows8.Text = 'Windows 8.1'
$BTN_DownloadWindows8.Height = $BTN_HEIGHT
$BTN_DownloadWindows8.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows8.Location = $BTN_DownloadWindows10.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindows8.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows8, 'Download Windows 8.1 with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image')
$BTN_DownloadWindows8.Add_Click( {Open-InBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )

$LBL_DownloadWindows8 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows8.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows8.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindows8.Location = $BTN_DownloadWindows8.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindows7 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows7.Text = 'Windows 7'
$BTN_DownloadWindows7.Height = $BTN_HEIGHT
$BTN_DownloadWindows7.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows7.Location = $BTN_DownloadWindows8.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindows7.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image')
$BTN_DownloadWindows7.Add_Click( {Open-InBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )

$LBL_DownloadWindows7 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows7.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows7.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindows7.Location = $BTN_DownloadWindows7.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindowsXPENG = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsXPENG.Text = 'Windows XP (ENG)'
$BTN_DownloadWindowsXPENG.Height = $BTN_HEIGHT
$BTN_DownloadWindowsXPENG.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsXPENG.Location = $BTN_DownloadWindows7.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsXPENG.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsXPENG, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$BTN_DownloadWindowsXPENG.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )

$LBL_DownloadWindowsXPENG = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsXPENG.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsXPENG.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindowsXPENG.Location = $BTN_DownloadWindowsXPENG.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindowsXPRUS = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsXPRUS.Text = 'Windows XP (RUS)'
$BTN_DownloadWindowsXPRUS.Height = $BTN_HEIGHT
$BTN_DownloadWindowsXPRUS.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsXPRUS.Location = $BTN_DownloadWindowsXPENG.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsXPRUS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsXPRUS, 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image')
$BTN_DownloadWindowsXPRUS.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )

$LBL_DownloadWindowsXPRUS = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsXPRUS.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsXPRUS.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindowsXPRUS.Location = $BTN_DownloadWindowsXPRUS.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindowsPE = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsPE.Text = 'Windows PE'
$BTN_DownloadWindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadWindowsPE.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsPE.Location = $BTN_DownloadWindowsXPRUS.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsPE.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsPE, 'Download Windows PE (Live CD) ISO image')
$BTN_DownloadWindowsPE.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )

$LBL_DownloadWindowsPE = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsPE.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindowsPE.Location = $BTN_DownloadWindowsPE.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$GRP_DownloadsWindows.Controls.AddRange(@(
        $BTN_DownloadWindows10, $LBL_DownloadWindows10, $BTN_DownloadWindows8, $LBL_DownloadWindows8, $BTN_DownloadWindows7, $LBL_DownloadWindows7,
        $BTN_DownloadWindowsXPENG, $LBL_DownloadWindowsXPENG, $BTN_DownloadWindowsXPRUS, $LBL_DownloadWindowsXPRUS, $BTN_DownloadWindowsPE, $LBL_DownloadWindowsPE
    ))
