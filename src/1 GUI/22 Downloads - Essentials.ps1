Set-Variable -Option Constant GRP_Essentials (New-Object System.Windows.Forms.GroupBox)
$GRP_Essentials.Text = 'Essentials'
$GRP_Essentials.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3 + $INT_CBOX_SHORT - $INT_SHORT
$GRP_Essentials.Width = $GRP_WIDTH
$GRP_Essentials.Location = $GRP_Ninite.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_Essentials)

Set-Variable -Option Constant BTN_DownloadSDI     (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartSDI       (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadUnchecky         (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartUnchecky           (New-Object System.Windows.Forms.CheckBox)
Set-Variable -Option Constant CBOX_SilentlyInstallUnchecky (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadOffice     (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartOffice       (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadUnchecky, "Download Unchecky installer`n$TXT_UNCHECKY_INFO")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadOffice, "Download Microsoft Office 2013 - 2019 C2R installer and activator`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartSDI, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartUnchecky, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartOffice, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadSDI.Font = $BTN_DownloadUnchecky.Font = $BTN_DownloadOffice.Font = $BTN_FONT
$BTN_DownloadSDI.Height = $BTN_DownloadUnchecky.Height = $BTN_DownloadOffice.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_DownloadUnchecky.Width = $BTN_DownloadOffice.Width = $BTN_WIDTH

$CBOX_StartSDI.Checked = $CBOX_StartUnchecky.Checked = $CBOX_StartOffice.Checked = $CBOX_SilentlyInstallUnchecky.Checked = $True
$CBOX_StartSDI.Size = $CBOX_StartUnchecky.Size = $CBOX_StartOffice.Size = $CBOX_SilentlyInstallUnchecky.Size = $CBOX_SIZE
$CBOX_StartSDI.Text = $CBOX_StartUnchecky.Text = $CBOX_StartOffice.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadSDI, $CBOX_StartSDI, $BTN_DownloadUnchecky, $CBOX_StartUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_StartOffice)
)



$BTN_DownloadSDI.Text = "Snappy Driver Installer$REQUIRES_ELEVATION"
$BTN_DownloadSDI.Location = $BTN_INIT_LOCATION
$BTN_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartSDI.Checked 'sdi-tool.org/releases/SDI_R2000.zip' } )

$CBOX_StartSDI.Location = $BTN_DownloadSDI.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartSDI.Add_CheckStateChanged( { $BTN_DownloadSDI.Text = "Snappy Driver Installer$(if ($CBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadUnchecky.Text = "Unchecky$REQUIRES_ELEVATION"
$BTN_DownloadUnchecky.Location = $BTN_DownloadSDI.Location + $SHIFT_BTN_LONG
$BTN_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CBOX_StartUnchecky.Checked 'unchecky.com/files/unchecky_setup.exe' -Params:$Params -SilentInstall:$CBOX_SilentlyInstallUnchecky.Checked
    } )

$CBOX_StartUnchecky.Location = $BTN_DownloadUnchecky.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartUnchecky.Add_CheckStateChanged( { $CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_StartUnchecky.Checked } )

$CBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_StartUnchecky.Location + "0, $CBOX_HEIGHT"
$CBOX_StartUnchecky.Add_CheckStateChanged( { $BTN_DownloadUnchecky.Text = "Unchecky$(if ($CBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadOffice.Text = "Office 2013 - 2019$REQUIRES_ELEVATION"
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $SHIFT_BTN_SHORT + $SHIFT_BTN_NORMAL
$BTN_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CBOX_StartOffice.Checked 'qiiwexc.github.io/d/Office_2013-2019.zip' } )

$CBOX_StartOffice.Location = $BTN_DownloadOffice.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartOffice.Add_CheckStateChanged( { $BTN_DownloadOffice.Text = "Office 2013 - 2019$(if ($CBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})" } )
