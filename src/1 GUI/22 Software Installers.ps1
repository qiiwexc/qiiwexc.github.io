$GroupEssentials = New-Object System.Windows.Forms.GroupBox
$GroupEssentials.Text = 'Essentials'
$GroupEssentials.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 3 + $_INTERVAL_SHORT
$GroupEssentials.Width = $GroupNinite.Width
$GroupEssentials.Location = $GroupNinite.Location + "$($GroupNinite.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadChrome = New-Object System.Windows.Forms.Button
$ButtonDownloadChrome.Text = 'Chrome Beta'
$ButtonDownloadChromeToolTipText = "Download Google Chrome Beta installer`r(Opens in browser)"
$ButtonDownloadChrome.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadChrome.Height = $_BUTTON_HEIGHT
$ButtonDownloadChrome.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadChrome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChrome, $ButtonDownloadChromeToolTipText)
$ButtonDownloadChrome.Add_Click( {OpenInBrowser 'google.com/chrome/beta'} )

$ButtonDownloadUnchecky = New-Object System.Windows.Forms.Button
$ButtonDownloadUnchecky.Text = 'Unchecky'
$ButtonDownloadUncheckyToolTipText = "Download Unchecky installer`rUnchecky clears adware checkboxes when installing software"
$ButtonDownloadUnchecky.Location = $ButtonDownloadChrome.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonDownloadUnchecky.Height = $_BUTTON_HEIGHT
$ButtonDownloadUnchecky.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadUnchecky.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadUnchecky, $ButtonDownloadUncheckyToolTipText)
$ButtonDownloadUnchecky.Add_Click( {DownloadFile 'unchecky.com/files/unchecky_setup.exe'} )

$ButtonDownloadOffice = New-Object System.Windows.Forms.Button
$ButtonDownloadOffice.Text = 'Office 2013 - 2019'
$ButtonDownloadOfficeToolTipText = "Download Microsoft Office 2013 - 2019 installer and activator`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadOffice.Location = $ButtonDownloadUnchecky.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonDownloadOffice.Height = $_BUTTON_HEIGHT
$ButtonDownloadOffice.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadOffice.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadOffice, $ButtonDownloadOfficeToolTipText)
$ButtonDownloadOffice.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/Office_2013-2019.zip'
    } )


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupEssentials))
$GroupEssentials.Controls.AddRange(@($ButtonDownloadUnchecky, $ButtonDownloadOffice, $ButtonDownloadChrome))
