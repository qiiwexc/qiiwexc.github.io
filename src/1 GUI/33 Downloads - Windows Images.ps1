$GroupDownloadsWindows = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsWindows.Text = 'Windows ISO Images'
$GroupDownloadsWindows.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_SHORT + $_CHECK_BOX_INTERVAL_SHORT) * 6
$GroupDownloadsWindows.Width = $GroupDownloadsActivators.Width
$GroupDownloadsWindows.Location = $GroupDownloadsActivators.Location + "$($GroupDownloadsActivators.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadWindows10 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows10.Text = 'Windows 10'
$ButtonDownloadWindows10ToolTipText = 'Download $($ButtonDownloadWindows10.Text) (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image'
$ButtonDownloadWindows10.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadWindows10.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows10.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindows10.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows10, $ButtonDownloadWindows10ToolTipText)
$ButtonDownloadWindows10.Add_Click( {OpenInBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )

$LabelDownloadWindows10 = New-Object System.Windows.Forms.Label
$LabelDownloadWindows10.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindows10.Location = $ButtonDownloadWindows10.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindows10.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindows8 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows8.Text = 'Windows 8.1'
$ButtonDownloadWindows8ToolTipText = 'Download $($ButtonDownloadWindows8.Text) with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image'
$ButtonDownloadWindows8.Location = $ButtonDownloadWindows10.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindows8.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows8.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindows8.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows8, $ButtonDownloadWindows8ToolTipText)
$ButtonDownloadWindows8.Add_Click( {OpenInBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )

$LabelDownloadWindows8 = New-Object System.Windows.Forms.Label
$LabelDownloadWindows8.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindows8.Location = $ButtonDownloadWindows8.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindows8.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindows7 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows7.Text = 'Windows 7'
$ButtonDownloadWindows7ToolTipText = 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image'
$ButtonDownloadWindows7.Location = $ButtonDownloadWindows8.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindows7.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows7.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindows7.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows7, $ButtonDownloadWindows7ToolTipText)
$ButtonDownloadWindows7.Add_Click( {OpenInBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )

$LabelDownloadWindows7 = New-Object System.Windows.Forms.Label
$LabelDownloadWindows7.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindows7.Location = $ButtonDownloadWindows7.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindows7.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindowsXPENG = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsXPENG.Text = 'Windows XP (ENG)'
$ButtonDownloadWindowsXPENGToolTipText = 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image'
$ButtonDownloadWindowsXPENG.Location = $ButtonDownloadWindows7.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindowsXPENG.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsXPENG.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindowsXPENG.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsXPENG, $ButtonDownloadWindowsXPENGToolTipText)
$ButtonDownloadWindowsXPENG.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )

$LabelDownloadWindowsXPENG = New-Object System.Windows.Forms.Label
$LabelDownloadWindowsXPENG.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindowsXPENG.Location = $ButtonDownloadWindowsXPENG.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindowsXPENG.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindowsXPRUS = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsXPRUS.Text = 'Windows XP (RUS)'
$ButtonDownloadWindowsXPRUSToolTipText = 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image'
$ButtonDownloadWindowsXPRUS.Location = $ButtonDownloadWindowsXPENG.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindowsXPRUS.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsXPRUS.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindowsXPRUS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsXPRUS, $ButtonDownloadWindowsXPRUSToolTipText)
$ButtonDownloadWindowsXPRUS.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )

$LabelDownloadWindowsXPRUS = New-Object System.Windows.Forms.Label
$LabelDownloadWindowsXPRUS.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindowsXPRUS.Location = $ButtonDownloadWindowsXPRUS.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindowsXPRUS.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindowsPE = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsPE.Text = 'Windows PE'
$ButtonDownloadWindowsPEToolTipText = 'Download Windows PE (Live CD) ISO image'
$ButtonDownloadWindowsPE.Location = $ButtonDownloadWindowsXPRUS.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindowsPE.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsPE.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindowsPE.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsPE, $ButtonDownloadWindowsPEToolTipText)
$ButtonDownloadWindowsPE.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )

$LabelDownloadWindowsPE = New-Object System.Windows.Forms.Label
$LabelDownloadWindowsPE.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindowsPE.Location = $ButtonDownloadWindowsPE.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindowsPE.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$_TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GroupDownloadsWindows))
$GroupDownloadsWindows.Controls.AddRange(@(
        $ButtonDownloadWindows10, $LabelDownloadWindows10, $ButtonDownloadWindows8, $LabelDownloadWindows8, $ButtonDownloadWindows7, $LabelDownloadWindows7,
        $ButtonDownloadWindowsXPENG, $LabelDownloadWindowsXPENG, $ButtonDownloadWindowsXPRUS, $LabelDownloadWindowsXPRUS, $ButtonDownloadWindowsPE, $LabelDownloadWindowsPE
    ))