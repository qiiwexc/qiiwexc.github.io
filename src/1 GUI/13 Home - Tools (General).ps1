$GRP_DownloadTools = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadTools.Text = 'Tools (General)'
$GRP_DownloadTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadTools.Width = $GRP_WIDTH
$GRP_DownloadTools.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadTools)


$BTN_DownloadChrome = New-Object System.Windows.Forms.Button
$BTN_DownloadChrome.Text = 'Chrome Beta'
$BTN_DownloadChrome.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_WIDTH
$BTN_DownloadChrome.Location = $BTN_INIT_LOCATION
$BTN_DownloadChrome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Open Google Chrome Beta download page')
$BTN_DownloadChrome.Add_Click( {Open-InBrowser 'google.com/chrome/beta'} )

$LBL_DownloadChrome = New-Object System.Windows.Forms.Label
$LBL_DownloadChrome.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadChrome.Size = $CBOX_SIZE
$LBL_DownloadChrome.Location = $BTN_DownloadChrome.Location + $SHIFT_LBL_BROWSER


$BTN_DownloadRufus = New-Object System.Windows.Forms.Button
$BTN_DownloadRufus.Text = 'Rufus (bootable USB)'
$BTN_DownloadRufus.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WIDTH
$BTN_DownloadRufus.Location = $BTN_DownloadChrome.Location + $SHIFT_BTN_LONG
$BTN_DownloadRufus.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BTN_DownloadRufus.Add_Click( {
        $FileName = Start-Download 'github.com/pbatard/rufus/releases/download/v3.5/rufus-3.5p.exe'
        if ($CBOX_StartRufus.Checked -and $FileName) {Start-File $FileName '-g'}
    } )

$CBOX_StartRufus = New-Object System.Windows.Forms.CheckBox
$CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRufus.Size = $CBOX_SIZE
$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartRufus.Add_CheckStateChanged( {$BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_WindowsPE = New-Object System.Windows.Forms.Button
$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_WindowsPE.Width = $BTN_WIDTH
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 8')
$BTN_WindowsPE.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )

$LBL_WindowsPE = New-Object System.Windows.Forms.Label
$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Size = $CBOX_SIZE
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER


$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadChrome, $LBL_DownloadChrome, $BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))
