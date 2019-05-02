Set-Variable GRP_DownloadTools (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_DownloadTools.Text = 'Tools (General)'
$GRP_DownloadTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadTools.Width = $GRP_WIDTH
$GRP_DownloadTools.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadTools)

Set-Variable BTN_DownloadChrome (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartChrome (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadRufus (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartRufus (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_WindowsPE (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_WindowsPE (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Open Google Chrome Beta download page')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 8')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartChrome, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadChrome.Font = $BTN_DownloadRufus.Font = $BTN_WindowsPE.Font = $BTN_FONT
$BTN_DownloadChrome.Height = $BTN_DownloadRufus.Height = $BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_DownloadRufus.Width = $BTN_WindowsPE.Width = $BTN_WIDTH

$CBOX_StartChrome.Checked = $CBOX_StartRufus.Checked = $True
$CBOX_StartChrome.Size = $CBOX_StartRufus.Size = $LBL_WindowsPE.Size = $CBOX_SIZE
$CBOX_StartChrome.Text = $CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadChrome, $CBOX_StartChrome, $BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))



$BTN_DownloadChrome.Text = "Chrome Beta$REQUIRES_ELEVATION"
$BTN_DownloadChrome.Location = $BTN_INIT_LOCATION
$BTN_DownloadChrome.Add_Click( {
        Set-Variable ChromeBetaURL 'dl.google.com/tag/s/appguid%3D%7B8237E44A-0054-442C-B6B6-EA0509993955%7D%26usagestats%3D1%26appname%3DGoogle%2520Chrome%2520Beta%26needsadmin%3Dprefers%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe' -Option Constant
        Start-DownloadExtractExecute $ChromeBetaURL -Execute:$CBOX_StartChrome.Checked
    } )

$CBOX_StartChrome.Location = $BTN_DownloadChrome.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartChrome.Add_CheckStateChanged( { $BTN_DownloadChrome.Text = "Chrome Beta$(if ($CBOX_StartChrome.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BTN_DownloadRufus.Location = $BTN_DownloadChrome.Location + $SHIFT_BTN_LONG
$BTN_DownloadRufus.Add_Click( {
        Set-Variable RufusURL 'github.com/pbatard/rufus/releases/download/v3.5/rufus-3.5p.exe' -Option Constant
        if ($PS_VERSION -gt 2) {
            $DownloadedFile = Start-Download $RufusURL
            if ($CBOX_StartRufus.Checked -and $DownloadedFile) { Start-File $DownloadedFile '-g' }
        }
        else { Open-InBrowser $RufusURL }
    } )

$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_' } )

$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER
