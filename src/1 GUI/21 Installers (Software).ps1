$GroupDownloadsInstallersSoftware = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsInstallersSoftware.Text = 'Installers: Software'
$GroupDownloadsInstallersSoftware.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 4 + $_INTERVAL_SHORT
$GroupDownloadsInstallersSoftware.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_DOWNLOAD + $_INTERVAL_NORMAL
$GroupDownloadsInstallersSoftware.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsInstallersSoftware)


$ButtonDownloadNinite = New-Object System.Windows.Forms.Button
$ButtonDownloadNinite.Text = 'Ninite'
$ButtonDownloadNiniteToolTipText = "Open Ninite universal installer web page`r(Opens in browser)"
$ButtonDownloadNinite.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadNinite.Height = $_BUTTON_HEIGHT
$ButtonDownloadNinite.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadNinite.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadNinite, $ButtonDownloadNiniteToolTipText)
$ButtonDownloadNinite.Add_Click( {OpenInBrowser 'ninite.com/?select=7zip-vlc-teamviewer14-skype-chrome'} )
$GroupDownloadsInstallersSoftware.Controls.Add($ButtonDownloadNinite)


$ButtonDownloadChrome = New-Object System.Windows.Forms.Button
$ButtonDownloadChrome.Text = 'Chrome Beta'
$ButtonDownloadChromeToolTipText = "Download Google Chrome Beta installer`r(Opens in browser)"
$ButtonDownloadChrome.Location = $ButtonDownloadNinite.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadChrome.Height = $_BUTTON_HEIGHT
$ButtonDownloadChrome.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadChrome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChrome, $ButtonDownloadChromeToolTipText)
$ButtonDownloadChrome.Add_Click( {OpenInBrowser 'google.com/chrome/beta'} )
$GroupDownloadsInstallersSoftware.Controls.Add($ButtonDownloadChrome)


$ButtonDownloadUnchecky = New-Object System.Windows.Forms.Button
$ButtonDownloadUnchecky.Text = 'Unchecky'
$ButtonDownloadUncheckyToolTipText = "Download Unchecky installer`rUnchecky clears adware checkboxes when installing software"
$ButtonDownloadUnchecky.Location = $ButtonDownloadChrome.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadUnchecky.Height = $_BUTTON_HEIGHT
$ButtonDownloadUnchecky.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadUnchecky.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadUnchecky, $ButtonDownloadUncheckyToolTipText)
$ButtonDownloadUnchecky.Add_Click( {DownloadFile 'unchecky.com/files/unchecky_setup.exe'} )
$GroupDownloadsInstallersSoftware.Controls.Add($ButtonDownloadUnchecky)


$ButtonDownloadOffice = New-Object System.Windows.Forms.Button
$ButtonDownloadOffice.Text = 'Office 2013 - 2019'
$ButtonDownloadOfficeToolTipText = "Download Microsoft Office 2013 - 2019 installer and activator"
$ButtonDownloadOffice.Location = $ButtonDownloadUnchecky.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadOffice.Height = $_BUTTON_HEIGHT
$ButtonDownloadOffice.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadOffice.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadOffice, $ButtonDownloadOfficeToolTipText)
$ButtonDownloadOffice.Add_Click( {DownloadFile 'qiiwexc.github.io/Office_2013-2019.zip'} )
$GroupDownloadsInstallersSoftware.Controls.Add($ButtonDownloadOffice)
