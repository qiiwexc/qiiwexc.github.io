$GRP_Essentials = New-Object System.Windows.Forms.GroupBox
$GRP_Essentials.Text = 'Essentials'
$GRP_Essentials.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 3 + $INT_NORMAL
$GRP_Essentials.Width = $GRP_Ninite.Width
$GRP_Essentials.Location = $GRP_Ninite.Location + "$($GRP_Ninite.Width + $INT_NORMAL), 0"


$BTN_DownloadUnchecky = New-Object System.Windows.Forms.Button
$BTN_DownloadUnchecky.Text = 'Unchecky'
$BTN_DownloadUnchecky.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadUnchecky.Height = $BTN_HEIGHT
$BTN_DownloadUnchecky.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadUnchecky.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadUnchecky, "Download Unchecky installer`rUnchecky clears adware checkboxes when installing software")
$BTN_DownloadUnchecky.Add_Click( {
        DownloadFile 'unchecky.com/files/unchecky_setup.exe' -Execute $CBOX_ExecuteUnchecky.Checked `
            -Switches $(if ($CBOX_ExecuteUnchecky.Checked -and $CBOX_SilentlyInstallUnchecky.Checked) {'-install -no_desktop_icon'})
    } )

$CBOX_ExecuteUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteUnchecky.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteUnchecky.Location = $BTN_DownloadUnchecky.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteUnchecky, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteUnchecky.Add_CheckStateChanged( {$CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_ExecuteUnchecky.Checked} )
$CBOX_ExecuteUnchecky.Size = $CBOX_SIZE_DOWNLOAD

$CBOX_SilentlyInstallUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_SilentlyInstallUnchecky.Text = $TXT_INSTALL_SILENTLY
$CBOX_SilentlyInstallUnchecky.Enabled = $False
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_ExecuteUnchecky.Location + "0, $CBOX_HEIGHT"
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SilentlyInstallUnchecky, $TIP_INSTALL_SILENTLY)
$CBOX_SilentlyInstallUnchecky.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadOffice = New-Object System.Windows.Forms.Button
$BTN_DownloadOffice.Text = 'Office 2013 - 2019'
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $BTN_SHIFT_VER_NORMAL + $BTN_SHIFT_VER_NORMAL
$BTN_DownloadOffice.Height = $BTN_HEIGHT
$BTN_DownloadOffice.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadOffice, "Download Microsoft Office 2013 - 2019 installer and activator`n`n$TXT_AV_WARNING")
$BTN_DownloadOffice.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/Office_2013-2019.zip' -Execute $CBOX_OfficeExecute.Checked
    } )

$CBOX_OfficeExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_OfficeExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_OfficeExecute.Location = $BTN_DownloadOffice.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_OfficeExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_OfficeExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadChrome = New-Object System.Windows.Forms.Button
$BTN_DownloadChrome.Text = 'Chrome Beta'
$BTN_DownloadChrome.Location = $BTN_DownloadOffice.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChrome.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChrome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Download Google Chrome Beta installer')
$BTN_DownloadChrome.Add_Click( {OpenInBrowser 'google.com/chrome/beta'} )

$LBL_DownloadChrome = New-Object System.Windows.Forms.Label
$LBL_DownloadChrome.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadChrome.Location = $BTN_DownloadChrome.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadChrome.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GRP_Essentials))
$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadUnchecky, $CBOX_ExecuteUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_OfficeExecute, $BTN_DownloadChrome, $LBL_DownloadChrome)
)
