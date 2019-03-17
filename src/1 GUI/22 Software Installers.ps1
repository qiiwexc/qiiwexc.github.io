$GroupEssentials = New-Object System.Windows.Forms.GroupBox
$GroupEssentials.Text = 'Essentials'
$GroupEssentials.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 3
$GroupEssentials.Width = $GroupNinite.Width
$GroupEssentials.Location = $GroupNinite.Location + "$($GroupNinite.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadUnchecky = New-Object System.Windows.Forms.Button
$ButtonDownloadUnchecky.Text = 'Unchecky'
$ButtonDownloadUncheckyToolTipText = "Download Unchecky installer`rUnchecky clears adware checkboxes when installing software"
$ButtonDownloadUnchecky.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadUnchecky.Height = $_BUTTON_HEIGHT
$ButtonDownloadUnchecky.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadUnchecky.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadUnchecky, $ButtonDownloadUncheckyToolTipText)
$ButtonDownloadUnchecky.Add_Click( {DownloadFile 'unchecky.com/files/unchecky_setup.exe' -Execute $CheckBoxUncheckyExecute.Checked} )

$CheckBoxUncheckyExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxUncheckyExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxUncheckyExecute.Location = $ButtonDownloadUnchecky.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxUncheckyExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxUncheckyExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadOffice = New-Object System.Windows.Forms.Button
$ButtonDownloadOffice.Text = 'Office 2013 - 2019'
$ButtonDownloadOfficeToolTipText = "Download Microsoft Office 2013 - 2019 installer and activator`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadOffice.Location = $ButtonDownloadUnchecky.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadOffice.Height = $_BUTTON_HEIGHT
$ButtonDownloadOffice.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadOffice.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadOffice, $ButtonDownloadOfficeToolTipText)
$ButtonDownloadOffice.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/Office_2013-2019.zip' -Execute $CheckBoxOfficeExecute.Checked
    } )

$CheckBoxOfficeExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxOfficeExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxOfficeExecute.Location = $ButtonDownloadOffice.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxOfficeExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxOfficeExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadChrome = New-Object System.Windows.Forms.Button
$ButtonDownloadChrome.Text = 'Chrome Beta'
$ButtonDownloadChromeToolTipText = 'Download Google Chrome Beta installer'
$ButtonDownloadChrome.Location = $ButtonDownloadOffice.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadChrome.Height = $_BUTTON_HEIGHT
$ButtonDownloadChrome.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadChrome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChrome, $ButtonDownloadChromeToolTipText)
$ButtonDownloadChrome.Add_Click( {OpenInBrowser 'google.com/chrome/beta'} )

$LabelDownloadChrome = New-Object System.Windows.Forms.Label
$LabelDownloadChrome.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadChrome.Location = $ButtonDownloadChrome.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadChrome.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupEssentials))
$GroupEssentials.Controls.AddRange(
    @($ButtonDownloadUnchecky, $CheckBoxUncheckyExecute, $ButtonDownloadOffice, $CheckBoxOfficeExecute, $ButtonDownloadChrome, $LabelDownloadChrome)
)
