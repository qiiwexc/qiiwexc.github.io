$GRP_Essentials = New-Object System.Windows.Forms.GroupBox
$GRP_Essentials.Text = 'Essentials'
$GRP_Essentials.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 3 + $INT_NORMAL
$GRP_Essentials.Width = $GRP_Ninite.Width
$GRP_Essentials.Location = $GRP_Ninite.Location + "$($GRP_Ninite.Width + $INT_NORMAL), 0"
$TAB_INSTALLERS.Controls.Add($GRP_Essentials)


$BTN_DownloadUnchecky = New-Object System.Windows.Forms.Button
$BTN_DownloadUnchecky.Text = 'Unchecky'
$BTN_DownloadUnchecky.Height = $BTN_HEIGHT
$BTN_DownloadUnchecky.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadUnchecky.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadUnchecky.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadUnchecky, "Download Unchecky installer`rUnchecky clears adware checkboxes when installing software")
$BTN_DownloadUnchecky.Add_Click( {
        $SilentInstallSwitches = if ($CBOX_ExecuteUnchecky.Checked -and $CBOX_SilentlyInstallUnchecky.Checked) {'-install -no_desktop_icon'}
        DownloadFile 'unchecky.com/files/unchecky_setup.exe' -Execute $CBOX_ExecuteUnchecky.Checked -Switches $SilentInstallSwitches
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
$BTN_DownloadOffice.Height = $BTN_HEIGHT
$BTN_DownloadOffice.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $BTN_SHIFT_VER_NORMAL + $BTN_SHIFT_VER_NORMAL
$BTN_DownloadOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadOffice, "Download Microsoft Office 2013 - 2019 installer and activator`n`n$TXT_AV_WARNING")
$BTN_DownloadOffice.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/Office_2013-2019.zip' -Execute $CBOX_ExecuteOffice.Checked
    } )

$CBOX_ExecuteOffice = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteOffice.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteOffice.Location = $BTN_DownloadOffice.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteOffice, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteOffice.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadChrome = New-Object System.Windows.Forms.Button
$BTN_DownloadChrome.Text = 'Chrome Beta'
$BTN_DownloadChrome.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChrome.Location = $BTN_DownloadOffice.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChrome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Download Google Chrome Beta installer')
$BTN_DownloadChrome.Add_Click( {OpenInBrowser 'google.com/chrome/beta'} )

$LBL_DownloadChrome = New-Object System.Windows.Forms.Label
$LBL_DownloadChrome.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadChrome.Location = $BTN_DownloadChrome.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadChrome.Size = $CBOX_SIZE_DOWNLOAD


$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadUnchecky, $CBOX_ExecuteUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_ExecuteOffice, $BTN_DownloadChrome, $LBL_DownloadChrome)
)
