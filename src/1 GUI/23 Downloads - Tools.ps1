Set-Variable -Option Constant GRP_InstallTools (New-Object System.Windows.Forms.GroupBox)
$GRP_InstallTools.Text = 'Tools'
$GRP_InstallTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG
$GRP_InstallTools.Width = $GRP_WIDTH
$GRP_InstallTools.Location = $GRP_Essentials.Location + "0, $($GRP_Essentials.Height + $INT_NORMAL)"
$TAB_INSTALLERS.Controls.Add($GRP_InstallTools)

Set-Variable -Option Constant BTN_DownloadCCleaner (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartCCleaner   (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartCCleaner, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadCCleaner.Font = $BTN_FONT
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH

$CBOX_StartCCleaner.Checked = $True
$CBOX_StartCCleaner.Size = $CBOX_SIZE
$CBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_InstallTools.Controls.AddRange(@($BTN_DownloadCCleaner, $CBOX_StartCCleaner))



$BTN_DownloadCCleaner.Text = "CCleaner$REQUIRES_ELEVATION"
$BTN_DownloadCCleaner.Location = $BTN_INIT_LOCATION
$BTN_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartCCleaner.Checked 'download.ccleaner.com/ccsetup.exe' } )

$CBOX_StartCCleaner.Location = $BTN_DownloadCCleaner.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartCCleaner.Add_CheckStateChanged( { $BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )
