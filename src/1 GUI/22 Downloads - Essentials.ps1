$GRP_Essentials = New-Object System.Windows.Forms.GroupBox
$GRP_Essentials.Text = 'Essentials'
$GRP_Essentials.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3 + $INT_CBOX_SHORT - $INT_SHORT
$GRP_Essentials.Width = $GRP_WIDTH
$GRP_Essentials.Location = $GRP_Ninite.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_Essentials)


$BTN_DownloadSDI = New-Object System.Windows.Forms.Button
$BTN_DownloadSDI.Text = 'Snappy Driver Installer'
$BTN_DownloadSDI.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_WIDTH
$BTN_DownloadSDI.Location = $BTN_INIT_LOCATION
$BTN_DownloadSDI.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
$BTN_DownloadSDI.Add_Click( {
        $FileName = Start-Download 'sdi-tool.org/releases/SDI_R1903.zip'
        if ($CBOX_StartSDI.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_StartSDI = New-Object System.Windows.Forms.CheckBox
$CBOX_StartSDI.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartSDI.Size = $CBOX_SIZE
$CBOX_StartSDI.Location = $BTN_DownloadSDI.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartSDI, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartSDI.Add_CheckStateChanged( {$BTN_DownloadSDI.Text = "Snappy Driver Installer$(if ($CBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadUnchecky = New-Object System.Windows.Forms.Button
$BTN_DownloadUnchecky.Text = 'Unchecky'
$BTN_DownloadUnchecky.Height = $BTN_HEIGHT
$BTN_DownloadUnchecky.Width = $BTN_WIDTH
$BTN_DownloadUnchecky.Location = $BTN_DownloadSDI.Location + $SHIFT_BTN_LONG
$BTN_DownloadUnchecky.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadUnchecky, "Download Unchecky installer`rUnchecky clears adware checkboxes when installing software")
$BTN_DownloadUnchecky.Add_Click( {
        $FileName = Start-Download 'unchecky.com/files/unchecky_setup.exe'
        if ($CBOX_StartUnchecky.Checked -and $FileName) {
            Start-File $FileName $(if ($CBOX_SilentlyInstallUnchecky.Checked) {'-install -no_desktop_icon'}) -IsSilentInstall $True
        }
    } )

$CBOX_StartUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_StartUnchecky.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartUnchecky.Size = $CBOX_SIZE
$CBOX_StartUnchecky.Location = $BTN_DownloadUnchecky.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartUnchecky, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartUnchecky.Add_CheckStateChanged( {$CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_StartUnchecky.Checked} )

$CBOX_SilentlyInstallUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CBOX_SilentlyInstallUnchecky.Enabled = $False
$CBOX_SilentlyInstallUnchecky.Size = $CBOX_SIZE
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_StartUnchecky.Location + "0, $CBOX_HEIGHT"
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')
$CBOX_StartUnchecky.Add_CheckStateChanged( {$BTN_DownloadUnchecky.Text = "Unchecky$(if ($CBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadOffice = New-Object System.Windows.Forms.Button
$BTN_DownloadOffice.Text = 'Office 2013 - 2019'
$BTN_DownloadOffice.Height = $BTN_HEIGHT
$BTN_DownloadOffice.Width = $BTN_WIDTH
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $SHIFT_BTN_SHORT + $SHIFT_BTN_NORMAL
$BTN_DownloadOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadOffice, "Download Microsoft Office 2013 - 2019 C2R installer and activator`n`n$TXT_AV_WARNING")
$BTN_DownloadOffice.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/Office_2013-2019.zip'
        if ($CBOX_StartOffice.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_StartOffice = New-Object System.Windows.Forms.CheckBox
$CBOX_StartOffice.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartOffice.Size = $CBOX_SIZE
$CBOX_StartOffice.Location = $BTN_DownloadOffice.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartOffice, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartOffice.Add_CheckStateChanged( {$BTN_DownloadOffice.Text = "Office 2013 - 2019$(if ($CBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})"} )


$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadSDI, $CBOX_StartSDI, $BTN_DownloadUnchecky, $CBOX_StartUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_StartOffice)
)
