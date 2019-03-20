$_VERSION = '19.3.20'


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Disclaimer #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

<#

To execute, right-click the file, then select "Run with PowerShell".
Double click will simply open the file in Notepad.

#>


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Initialization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_HOST = Get-Host
$_IS_ELEVATED = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$_HOST.UI.RawUI.WindowTitle = "qiiwexc v$_VERSION$(if ($_IS_ELEVATED) {': Administrator'})"

Write-Host 'Initializing...'

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.Windows.Forms.Application]::EnableVisualStyles()
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Constants #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_FORM_FONT_TYPE = 'Microsoft Sans Serif'
$_BUTTON_FONT = "$_FORM_FONT_TYPE, 10"

$_FORM_HEIGHT = 620
$_FORM_WIDTH = 650

$_INTERVAL_SHORT = 5
$_INTERVAL_NORMAL = 15
$_INTERVAL_LONG = 40
$_INTERVAL_TAB_ADJUSTMENT = 4
$_INTERVAL_GROUP_TOP = 20

$_BUTTON_HEIGHT = 28
$_BUTTON_WIDTH_NORMAL = 160
$_BUTTON_INTERVAL_SHORT = $_BUTTON_HEIGHT + $_INTERVAL_SHORT
$_BUTTON_INTERVAL_NORMAL = $_BUTTON_HEIGHT + $_INTERVAL_NORMAL
$_BUTTON_SHIFT_VERTICAL_SHORT = "0, $_BUTTON_INTERVAL_SHORT"
$_BUTTON_SHIFT_HORIZONTAL_SHORT = "$_BUTTON_INTERVAL_SHORT, 0"
$_BUTTON_SHIFT_VERTICAL_NORMAL = "0, $_BUTTON_INTERVAL_NORMAL"
$_BUTTON_SHIFT_HORIZONTAL_NORMAL = "$_BUTTON_INTERVAL_NORMAL, 0"

$_CHECK_BOX_HEIGHT = 20
$_CHECK_BOX_INTERVAL_SHORT = $_CHECK_BOX_HEIGHT + $_INTERVAL_SHORT
$_CHECK_BOX_INTERVAL_NORMAL = $_CHECK_BOX_HEIGHT + $_INTERVAL_NORMAL
$_CHECK_BOX_SHIFT_VERTICAL_SHORT = "0, $_CHECK_BOX_INTERVAL_SHORT"
$_CHECK_BOX_SHIFT_HORIZONTAL_SHORT = "$_CHECK_BOX_INTERVAL_SHORT, 0"
$_CHECK_BOX_SHIFT_VERTICAL_NORMAL = "0, $_CHECK_BOX_INTERVAL_NORMAL"
$_CHECK_BOX_SHIFT_HORIZONTAL_NORMAL = "$_CHECK_BOX_INTERVAL_NORMAL, 0"

$_INF = 'INF'
$_WRN = 'WRN'
$_ERR = 'ERR'


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_FORM = New-Object System.Windows.Forms.Form
$_FORM.Text = "qiiwexc v$_VERSION"
$_FORM.ClientSize = "$_FORM_WIDTH, $_FORM_HEIGHT"
$_FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')
$_FORM.FormBorderStyle = 'Fixed3D'
$_FORM.StartPosition = 'CenterScreen'
$_FORM.MaximizeBox = $False
$_FORM.Top = $True
$_FORM.Add_Shown( {Startup} )


$_LOG = New-Object System.Windows.Forms.RichTextBox
$_LOG.Height = 200
$_LOG.Width = - $_INTERVAL_SHORT + $_FORM_WIDTH - $_INTERVAL_SHORT
$_LOG.Location = "$_INTERVAL_SHORT, $($_FORM_HEIGHT - $_LOG.Height - $_INTERVAL_SHORT)"
$_LOG.Font = "$_FORM_FONT_TYPE, 9"
$_LOG.ReadOnly = $True


$_TAB_CONTROL = New-Object System.Windows.Forms.TabControl
$_TAB_CONTROL.Size = "$($_LOG.Width + $_INTERVAL_SHORT - $_INTERVAL_TAB_ADJUSTMENT), $($_FORM_HEIGHT - $_LOG.Height - $_INTERVAL_SHORT - $_INTERVAL_TAB_ADJUSTMENT)"
$_TAB_CONTROL.Location = "$_INTERVAL_SHORT, $_INTERVAL_SHORT"


$_FORM.Controls.AddRange(@($_LOG, $_TAB_CONTROL))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_TAB_HOME = New-Object System.Windows.Forms.TabPage
$_TAB_HOME.Text = 'Home'
$_TAB_HOME.UseVisualStyleBackColor = $True
$_TAB_CONTROL.Controls.Add($_TAB_HOME)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - This Utility #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupHomeThisUtility = New-Object System.Windows.Forms.GroupBox
$GroupHomeThisUtility.Text = 'This utility'
$GroupHomeThisUtility.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 3
$GroupHomeThisUtility.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeThisUtility.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"
$_TAB_HOME.Controls.Add($GroupHomeThisUtility)


$ButtonElevate = New-Object System.Windows.Forms.Button
$ButtonElevate.Text = 'Run as administrator'
$ButtonElevate.Height = $_BUTTON_HEIGHT
$ButtonElevate.Width = $_BUTTON_WIDTH_NORMAL
$ButtonElevate.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonElevate.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonElevate, 'Restart this utility with administrator privileges')
$ButtonElevate.Add_Click( {Elevate} )


$ButtonBrowserHome = New-Object System.Windows.Forms.Button
$ButtonBrowserHome.Text = 'Open in browser'
$ButtonBrowserHome.Height = $_BUTTON_HEIGHT
$ButtonBrowserHome.Width = $_BUTTON_WIDTH_NORMAL
$ButtonBrowserHome.Location = $ButtonElevate.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonBrowserHome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonBrowserHome, 'Open utility web page in the default browser')
$ButtonBrowserHome.Add_Click( {OpenInBrowser 'qiiwexc.github.io'} )


$ButtonSystemInformation = New-Object System.Windows.Forms.Button
$ButtonSystemInformation.Text = 'System information'
$ButtonSystemInformation.Height = $_BUTTON_HEIGHT
$ButtonSystemInformation.Width = $_BUTTON_WIDTH_NORMAL
$ButtonSystemInformation.Location = $ButtonBrowserHome.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonSystemInformation.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSystemInformation, 'Print system information to the log')
$ButtonSystemInformation.Add_Click( {PrintSystemInformation} )


$GroupHomeThisUtility.Controls.AddRange(@($ButtonElevate, $ButtonBrowserHome, $ButtonSystemInformation))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupHomeUpdate = New-Object System.Windows.Forms.GroupBox
$GroupHomeUpdate.Text = 'Updates'
$GroupHomeUpdate.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 2
$GroupHomeUpdate.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeUpdate.Location = $GroupHomeThisUtility.Location + "0, $($GroupHomeThisUtility.Height + $_INTERVAL_NORMAL)"
$_TAB_HOME.Controls.Add($GroupHomeUpdate)


$ButtonGoogleUpdate = New-Object System.Windows.Forms.Button
$ButtonGoogleUpdate.Text = 'Update Google Chrome'
$ButtonGoogleUpdate.Height = $_BUTTON_HEIGHT
$ButtonGoogleUpdate.Width = $_BUTTON_WIDTH_NORMAL
$ButtonGoogleUpdate.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonGoogleUpdate.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonGoogleUpdate, 'Silently update Google Chrome and other Google software')
$ButtonGoogleUpdate.Add_Click( {UpdateGoogleSoftware} )


$ButtonUpdateStoreApps = New-Object System.Windows.Forms.Button
$ButtonUpdateStoreApps.Text = 'Update Store apps'
$ButtonUpdateStoreApps.Height = $_BUTTON_HEIGHT
$ButtonUpdateStoreApps.Width = $_BUTTON_WIDTH_NORMAL
$ButtonUpdateStoreApps.Location = $ButtonGoogleUpdate.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonUpdateStoreApps.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonUpdateStoreApps, 'Update Microsoft Store apps')
$ButtonUpdateStoreApps.Add_Click( {UpdateStoreApps} )


$GroupHomeUpdate.Controls.AddRange(@($ButtonGoogleUpdate, $ButtonUpdateStoreApps))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupHomeDiagnostics = New-Object System.Windows.Forms.GroupBox
$GroupHomeDiagnostics.Text = 'Diagnostics'
$GroupHomeDiagnostics.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 4 - $_INTERVAL_SHORT * 2
$GroupHomeDiagnostics.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeDiagnostics.Location = $GroupHomeThisUtility.Location + "$($GroupHomeThisUtility.Width + $_INTERVAL_NORMAL), 0"
$_TAB_HOME.Controls.Add($GroupHomeDiagnostics)


$ButtonCheckDrive = New-Object System.Windows.Forms.Button
$ButtonCheckDrive.Text = 'Check C: drive health'
$ButtonCheckDrive.Height = $_BUTTON_HEIGHT
$ButtonCheckDrive.Width = $_BUTTON_WIDTH_NORMAL
$ButtonCheckDrive.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonCheckDrive.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCheckDrive, 'Perform a C: drive health check')
$ButtonCheckDrive.Add_Click( {CheckDrive} )


$ButtonCheckMemory = New-Object System.Windows.Forms.Button
$ButtonCheckMemory.Text = 'Check RAM'
$ButtonCheckMemory.Height = $_BUTTON_HEIGHT
$ButtonCheckMemory.Width = $_BUTTON_WIDTH_NORMAL
$ButtonCheckMemory.Location = $ButtonCheckDrive.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonCheckMemory.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCheckMemory, 'Start RAM checking utility')
$ButtonCheckMemory.Add_Click( {CheckMemory} )


$ButtonSecurityScanQuick = New-Object System.Windows.Forms.Button
$ButtonSecurityScanQuick.Text = 'Quick security scan'
$ButtonSecurityScanQuick.Height = $_BUTTON_HEIGHT
$ButtonSecurityScanQuick.Width = $_BUTTON_WIDTH_NORMAL
$ButtonSecurityScanQuick.Location = $ButtonCheckMemory.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonSecurityScanQuick.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSecurityScanQuick, 'Perform a quick security scan')
$ButtonSecurityScanQuick.Add_Click( {StartSecurityScan 'quick'} )

$ButtonSecurityScanFull = New-Object System.Windows.Forms.Button
$ButtonSecurityScanFull.Text = 'Full security scan'
$ButtonSecurityScanFull.Height = $_BUTTON_HEIGHT
$ButtonSecurityScanFull.Width = $_BUTTON_WIDTH_NORMAL
$ButtonSecurityScanFull.Location = $ButtonSecurityScanQuick.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonSecurityScanFull.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSecurityScanFull, 'Perform a full security scan')
$ButtonSecurityScanFull.Add_Click( {StartSecurityScan 'full'} )


$GroupHomeDiagnostics.Controls.AddRange(@($ButtonCheckDrive, $ButtonCheckMemory, $ButtonSecurityScanQuick, $ButtonSecurityScanFull))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupHomeOptimization = New-Object System.Windows.Forms.GroupBox
$GroupHomeOptimization.Text = 'Optimization'
$GroupHomeOptimization.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL * 3
$GroupHomeOptimization.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupHomeOptimization.Location = $GroupHomeDiagnostics.Location + "$($GroupHomeDiagnostics.Width + $_INTERVAL_NORMAL), 0"
$_TAB_HOME.Controls.Add($GroupHomeOptimization)


$ButtonCloudFlareDNS = New-Object System.Windows.Forms.Button
$ButtonCloudFlareDNS.Text = 'Setup CloudFlare DNS'
$ButtonCloudFlareDNS.Height = $_BUTTON_HEIGHT
$ButtonCloudFlareDNS.Width = $_BUTTON_WIDTH_NORMAL
$ButtonCloudFlareDNS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonCloudFlareDNS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCloudFlareDNS, 'Set DNS to CouldFlare - 1.1.1.1 / 1.0.0.1')
$ButtonCloudFlareDNS.Add_Click( {CloudFlareDNS} )


$ButtonRunCCleaner = New-Object System.Windows.Forms.Button
$ButtonRunCCleaner.Text = 'Run CCleaner silently'
$ButtonRunCCleaner.Height = $_BUTTON_HEIGHT
$ButtonRunCCleaner.Width = $_BUTTON_WIDTH_NORMAL
$ButtonRunCCleaner.Location = $ButtonCloudFlareDNS.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonRunCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonRunCCleaner, 'Clean the system in the background with CCleaner')
$ButtonRunCCleaner.Add_Click( {RunCCleaner} )


$ButtonOptimizeDrive = New-Object System.Windows.Forms.Button
$ButtonOptimizeDrive.Text = 'Optimize / defrag drive'
$ButtonOptimizeDrive.Height = $_BUTTON_HEIGHT
$ButtonOptimizeDrive.Width = $_BUTTON_WIDTH_NORMAL
$ButtonOptimizeDrive.Location = $ButtonRunCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonOptimizeDrive.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonOptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$ButtonOptimizeDrive.Add_Click( {OptimizeDrive} )


$GroupHomeOptimization.Controls.AddRange(@($ButtonCloudFlareDNS, $ButtonRunCCleaner, $ButtonOptimizeDrive))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_TAB_DOWNLOADS_INSTALLERS = New-Object System.Windows.Forms.TabPage
$_TAB_DOWNLOADS_INSTALLERS.Text = 'Downloads: Installers'
$_TAB_DOWNLOADS_INSTALLERS.UseVisualStyleBackColor = $True
$_TAB_CONTROL.Controls.Add($_TAB_DOWNLOADS_INSTALLERS)


$_CHECK_BOX_WIDTH_DOWNLOAD = 145
$_CHECK_BOX_SIZE_DOWNLOAD = "$($_CHECK_BOX_WIDTH_DOWNLOAD), $($_CHECK_BOX_HEIGHT)"
$_CHECK_BOX_SHIFT_EXECUTE = '12, -5'
$_LABEL_SHIFT_BROWSER = '22, -3'

$_AV_WARNING_MESSAGE = "!! THIS FILE MAY TRIGGER ANTI-VIRUS FALSE POSITIVE !!`n!! IT IS RECOMMENDED TO DISABLE A/V SOFTWARE FOR DOWNLOAD AND SUBESEQUENT USE OF THIS FILE !!"
$_TEXT_EXECUTE_AFTER_DOWNLOAD = 'Execute after download'
$_TEXT_OPENS_IN_BROWSER = 'Opens in the browser'
$_TEXT_INSTALL_SILENTLY = 'Install silently'
$_TOOLTIP_EXECUTE_AFTER_DOWNLOAD = "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"
$_TOOLTIP_INSTALL_SILENTLY = 'Perform silent installation with no prompts'


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupNinite = New-Object System.Windows.Forms.GroupBox
$GroupNinite.Text = 'Ninite'
$GroupNinite.Height = $_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT * 10 + $_BUTTON_INTERVAL_NORMAL * 2
$GroupNinite.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupNinite.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"


$CheckBoxNiniteChrome = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteChrome.Text = "Google Chrome"
$CheckBoxNiniteChrome.Name = "chrome"
$CheckBoxNiniteChrome.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$CheckBoxNiniteChrome.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteChrome.Checked = $True
$CheckBoxNiniteChrome.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNinite7zip = New-Object System.Windows.Forms.CheckBox
$CheckBoxNinite7zip.Text = "7-Zip"
$CheckBoxNinite7zip.Name = "7zip"
$CheckBoxNinite7zip.Location = $CheckBoxNiniteChrome.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNinite7zip.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNinite7zip.Checked = $True
$CheckBoxNinite7zip.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteVLC = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteVLC.Text = "VLC"
$CheckBoxNiniteVLC.Name = "vlc"
$CheckBoxNiniteVLC.Location = $CheckBoxNinite7zip.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteVLC.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteVLC.Checked = $True
$CheckBoxNiniteVLC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteTeamViewer = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteTeamViewer.Text = "TeamViewer"
$CheckBoxNiniteTeamViewer.Name = "teamviewer14"
$CheckBoxNiniteTeamViewer.Location = $CheckBoxNiniteVLC.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteTeamViewer.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteTeamViewer.Checked = $True
$CheckBoxNiniteTeamViewer.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteSkype = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteSkype.Text = "Skype"
$CheckBoxNiniteSkype.Name = "skype"
$CheckBoxNiniteSkype.Location = $CheckBoxNiniteTeamViewer.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteSkype.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteSkype.Checked = $True
$CheckBoxNiniteSkype.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteqBittorrent = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteqBittorrent.Text = "qBittorrent"
$CheckBoxNiniteqBittorrent.Name = "qbittorrent"
$CheckBoxNiniteqBittorrent.Location = $CheckBoxNiniteSkype.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteqBittorrent.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteqBittorrent.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteGoogleDrive = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteGoogleDrive.Text = "Google Drive"
$CheckBoxNiniteGoogleDrive.Name = "googlebackupandsync"
$CheckBoxNiniteGoogleDrive.Location = $CheckBoxNiniteqBittorrent.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteGoogleDrive.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteGoogleDrive.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CheckBoxNiniteVSC = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteVSC.Text = "Visual Studio Code"
$CheckBoxNiniteVSC.Name = "vscode"
$CheckBoxNiniteVSC.Location = $CheckBoxNiniteGoogleDrive.Location + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$CheckBoxNiniteVSC.Size = $_CHECK_BOX_SIZE_DOWNLOAD
$CheckBoxNiniteVSC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )


$ButtonNiniteDownload = New-Object System.Windows.Forms.Button
$ButtonNiniteDownload.Text = 'Download selected'
$ButtonNiniteDownloadToolTipText = 'Download Ninite universal installer for selected applications'
$ButtonNiniteDownload.Location = $CheckBoxNiniteVSC.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonNiniteDownload.Height = $_BUTTON_HEIGHT
$ButtonNiniteDownload.Width = $_BUTTON_WIDTH_NORMAL
$ButtonNiniteDownload.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonNiniteDownload, $ButtonNiniteDownloadToolTipText)
$ButtonNiniteDownload.Add_Click( {DownloadFile "https://ninite.com/$(NiniteQueryBuilder)/ninite.exe" $(NiniteNameBuilder) $CheckBoxNiniteExecute.Checked} )

$CheckBoxNiniteExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxNiniteExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxNiniteExecute.Location = $ButtonNiniteDownload.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxNiniteExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxNiniteExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonNiniteOpenInBrowser = New-Object System.Windows.Forms.Button
$ButtonNiniteOpenInBrowser.Text = 'View other'
$ButtonNiniteOpenInBrowserToolTipText = 'Open Ninite universal installer web page'
$ButtonNiniteOpenInBrowser.Location = $ButtonNiniteDownload.Location + $_CHECK_BOX_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonNiniteOpenInBrowser.Height = $_BUTTON_HEIGHT
$ButtonNiniteOpenInBrowser.Width = $_BUTTON_WIDTH_NORMAL
$ButtonNiniteOpenInBrowser.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonNiniteOpenInBrowser, $ButtonNiniteOpenInBrowserToolTipText)
$ButtonNiniteOpenInBrowser.Add_Click( {
        $Query = NiniteQueryBuilder
        OpenInBrowser $(if ($Query) {"ninite.com/?select=$($Query)"} else {'ninite.com'})
    } )

$LabelNiniteOpenInBrowser = New-Object System.Windows.Forms.Label
$LabelNiniteOpenInBrowser.Text = $_TEXT_OPENS_IN_BROWSER
$LabelNiniteOpenInBrowser.Location = $ButtonNiniteOpenInBrowser.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelNiniteOpenInBrowser.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupNinite))
$GroupNinite.Controls.AddRange(@(
        $ButtonNiniteDownload, $ButtonNiniteOpenInBrowser, $CheckBoxNiniteExecute, $LabelNiniteOpenInBrowser,
        $CheckBoxNinite7zip, $CheckBoxNiniteVLC, $CheckBoxNiniteTeamViewer, $CheckBoxNiniteSkype,
        $CheckBoxNiniteChrome, $CheckBoxNiniteqBittorrent, $CheckBoxNiniteGoogleDrive, $CheckBoxNiniteVSC
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Software Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupEssentials = New-Object System.Windows.Forms.GroupBox
$GroupEssentials.Text = 'Essentials'
$GroupEssentials.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 3 + $_INTERVAL_NORMAL
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
$ButtonDownloadUnchecky.Add_Click( {
        DownloadFile 'unchecky.com/files/unchecky_setup.exe' `
            -Execute $CheckBoxExecuteUnchecky.Checked `
            -Switches $(if ($CheckBoxExecuteUnchecky.Checked -and $CheckBoxSilentlyInstallUnchecky.Checked) {'-install -no_desktop_icon'})
    } )

$CheckBoxExecuteUnchecky = New-Object System.Windows.Forms.CheckBox
$CheckBoxExecuteUnchecky.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxExecuteUnchecky.Location = $ButtonDownloadUnchecky.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxExecuteUnchecky, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxExecuteUnchecky.Add_CheckStateChanged( {$CheckBoxSilentlyInstallUnchecky.Enabled = $CheckBoxExecuteUnchecky.Checked} )
$CheckBoxExecuteUnchecky.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$CheckBoxSilentlyInstallUnchecky = New-Object System.Windows.Forms.CheckBox
$CheckBoxSilentlyInstallUnchecky.Text = $_TEXT_INSTALL_SILENTLY
$CheckBoxSilentlyInstallUnchecky.Enabled = $False
$CheckBoxSilentlyInstallUnchecky.Location = $CheckBoxExecuteUnchecky.Location + "0, $_CHECK_BOX_HEIGHT"
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxSilentlyInstallUnchecky, $_TOOLTIP_INSTALL_SILENTLY)
$CheckBoxSilentlyInstallUnchecky.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadOffice = New-Object System.Windows.Forms.Button
$ButtonDownloadOffice.Text = 'Office 2013 - 2019'
$ButtonDownloadOfficeToolTipText = "Download Microsoft Office 2013 - 2019 installer and activator`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadOffice.Location = $ButtonDownloadUnchecky.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_BUTTON_SHIFT_VERTICAL_NORMAL
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
$GroupEssentials.Controls.AddRange(@($ButtonDownloadUnchecky, $CheckBoxExecuteUnchecky, $CheckBoxSilentlyInstallUnchecky,
        $ButtonDownloadOffice, $CheckBoxOfficeExecute, $ButtonDownloadChrome, $LabelDownloadChrome
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tool Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupInstallersTools = New-Object System.Windows.Forms.GroupBox
$GroupInstallersTools.Text = 'Tools'
$GroupInstallersTools.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 4 + $_INTERVAL_NORMAL
$GroupInstallersTools.Width = $GroupEssentials.Width
$GroupInstallersTools.Location = $GroupEssentials.Location + "$($GroupEssentials.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadCCleaner = New-Object System.Windows.Forms.Button
$ButtonDownloadCCleaner.Text = 'CCleaner'
$ButtonDownloadCCleanerToolTipText = 'Download CCleaner installer'
$ButtonDownloadCCleaner.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadCCleaner.Height = $_BUTTON_HEIGHT
$ButtonDownloadCCleaner.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadCCleaner, $ButtonDownloadCCleanerToolTipText)
$ButtonDownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe' -Execute $CheckBoxCCleanerExecute.Checked} )

$CheckBoxCCleanerExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxCCleanerExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxCCleanerExecute.Location = $ButtonDownloadCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxCCleanerExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxCCleanerExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadDefraggler = New-Object System.Windows.Forms.Button
$ButtonDownloadDefraggler.Text = 'Defraggler'
$ButtonDownloadDefragglerToolTipText = 'Download Defraggler installer'
$ButtonDownloadDefraggler.Location = $ButtonDownloadCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadDefraggler.Height = $_BUTTON_HEIGHT
$ButtonDownloadDefraggler.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadDefraggler.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadDefraggler, $ButtonDownloadDefragglerToolTipText)
$ButtonDownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe' -Execute $CheckBoxDefragglerExecute.Checked} )

$CheckBoxDefragglerExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxDefragglerExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxDefragglerExecute.Location = $ButtonDownloadDefraggler.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxDefragglerExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxDefragglerExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadRecuva = New-Object System.Windows.Forms.Button
$ButtonDownloadRecuva.Text = 'Recuva'
$ButtonDownloadRecuvaToolTipText = "Download Recuva installer`rRecuva helps restore deleted files"
$ButtonDownloadRecuva.Location = $ButtonDownloadDefraggler.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadRecuva.Height = $_BUTTON_HEIGHT
$ButtonDownloadRecuva.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadRecuva.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRecuva, $ButtonDownloadRecuvaToolTipText)
$ButtonDownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe' -Execute $CheckBoxRecuvaExecute.Checked} )

$CheckBoxRecuvaExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxRecuvaExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxRecuvaExecute.Location = $ButtonDownloadRecuva.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxRecuvaExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxRecuvaExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadMalwarebytes = New-Object System.Windows.Forms.Button
$ButtonDownloadMalwarebytes.Text = 'Malwarebytes'
$ButtonDownloadMalwarebytesToolTipText = "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware"
$ButtonDownloadMalwarebytes.Location = $ButtonDownloadRecuva.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_NORMAL
$ButtonDownloadMalwarebytes.Height = $_BUTTON_HEIGHT
$ButtonDownloadMalwarebytes.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadMalwarebytes.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadMalwarebytes, $ButtonDownloadMalwarebytesToolTipText)
$ButtonDownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' $CheckBoxMalwarebytesExecute.Checked} )

$CheckBoxMalwarebytesExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxMalwarebytesExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxMalwarebytesExecute.Location = $ButtonDownloadMalwarebytes.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxMalwarebytesExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxMalwarebytesExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupInstallersTools))
$GroupInstallersTools.Controls.AddRange(@(
        $ButtonDownloadCCleaner, $ButtonDownloadDefraggler, $ButtonDownloadRecuva, $ButtonDownloadMalwarebytes,
        $CheckBoxCCleanerExecute, $CheckBoxDefragglerExecute, $CheckBoxRecuvaExecute, $CheckBoxMalwarebytesExecute
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tools and ISO #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_TAB_DOWNLOADS_TOOLS = New-Object System.Windows.Forms.TabPage
$_TAB_DOWNLOADS_TOOLS.Text = 'Downloads: Tools and ISO'
$_TAB_DOWNLOADS_TOOLS.UseVisualStyleBackColor = $True
$_TAB_CONTROL.Controls.Add($_TAB_DOWNLOADS_TOOLS)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tools #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsTools = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsTools.Text = 'Tools'
$GroupDownloadsTools.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 3
$GroupDownloadsTools.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupDownloadsTools.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"
$_TAB_DOWNLOADS_TOOLS.Controls.Add($GroupDownloadsTools)


$ButtonDownloadSDI = New-Object System.Windows.Forms.Button
$ButtonDownloadSDI.Text = 'Snappy Driver Installer'
$ButtonDownloadSDIToolTipText = 'Download Snappy Driver Installer'
$ButtonDownloadSDI.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadSDI.Height = $_BUTTON_HEIGHT
$ButtonDownloadSDI.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadSDI.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadSDI, $ButtonDownloadSDIToolTipText)
$ButtonDownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip' -Execute $CheckBoxSDIExecute.Checked} )

$CheckBoxSDIExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxSDIExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxSDIExecute.Location = $ButtonDownloadSDI.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxSDIExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxSDIExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadVictoria = New-Object System.Windows.Forms.Button
$ButtonDownloadVictoria.Text = 'Victoria'
$ButtonDownloadVictoriaToolTipText = 'Download Victoria HDD scanner'
$ButtonDownloadVictoria.Location = $ButtonDownloadSDI.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadVictoria.Height = $_BUTTON_HEIGHT
$ButtonDownloadVictoria.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadVictoria.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadVictoria, $ButtonDownloadVictoriaToolTipText)
$ButtonDownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria.zip' -Execute $CheckBoxVictoriaExecute.Checked} )

$CheckBoxVictoriaExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxVictoriaExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxVictoriaExecute.Location = $ButtonDownloadVictoria.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxVictoriaExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxVictoriaExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadRufus = New-Object System.Windows.Forms.Button
$ButtonDownloadRufus.Text = 'Rufus'
$ButtonDownloadRufusToolTipText = 'Download Rufus - a bootable USB creator'
$ButtonDownloadRufus.Location = $ButtonDownloadVictoria.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadRufus.Height = $_BUTTON_HEIGHT
$ButtonDownloadRufus.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadRufus.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRufus, $ButtonDownloadRufusToolTipText)
$ButtonDownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe' -Execute $CheckBoxRufusExecute.Checked} )

$CheckBoxRufusExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxRufusExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxRufusExecute.Location = $ButtonDownloadRufus.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxRufusExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxRufusExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$GroupDownloadsTools.Controls.AddRange(
    @($ButtonDownloadSDI, $ButtonDownloadVictoria, $ButtonDownloadRufus, $CheckBoxSDIExecute, $CheckBoxVictoriaExecute, $CheckBoxRufusExecute)
)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Activators #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsActivators.Text = 'Activators'
$GroupDownloadsActivators.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 2
$GroupDownloadsActivators.Width = $GroupDownloadsTools.Width
$GroupDownloadsActivators.Location = $GroupDownloadsTools.Location + "$($GroupDownloadsTools.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadKMS = New-Object System.Windows.Forms.Button
$ButtonDownloadKMS.Text = 'KMSAuto Lite'
$ButtonDownloadKMSToolTipText = "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadKMS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadKMS.Height = $_BUTTON_HEIGHT
$ButtonDownloadKMS.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadKMS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadKMS, $ButtonDownloadKMSToolTipText)
$ButtonDownloadKMS.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -Execute $CheckBoxKMSExecute.Checked
    } )

$CheckBoxKMSExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxKMSExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxKMSExecute.Location = $ButtonDownloadKMS.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxKMSExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxKMSExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadChew = New-Object System.Windows.Forms.Button
$ButtonDownloadChew.Text = 'ChewWGA'
$ButtonDownloadChewToolTipText = "Download ChewWGA`rFor activating hopeless Windows 7 installations`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadChew.Location = $ButtonDownloadKMS.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadChew.Height = $_BUTTON_HEIGHT
$ButtonDownloadChew.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadChew.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChew, $ButtonDownloadChewToolTipText)
$ButtonDownloadChew.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip' -Execute $CheckBoxChewExecute.Checked
    } )

$CheckBoxChewExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxChewExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxChewExecute.Location = $ButtonDownloadChew.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxChewExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxChewExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$_TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GroupDownloadsActivators))
$GroupDownloadsActivators.Controls.AddRange(@($ButtonDownloadKMS, $ButtonDownloadChew, $CheckBoxKMSExecute, $CheckBoxChewExecute))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Windows Images #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsWindows = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsWindows.Text = 'Windows ISO Images'
$GroupDownloadsWindows.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_SHORT + $_CHECK_BOX_INTERVAL_SHORT) * 6
$GroupDownloadsWindows.Width = $GroupDownloadsActivators.Width
$GroupDownloadsWindows.Location = $GroupDownloadsActivators.Location + "$($GroupDownloadsActivators.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadWindows10 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows10.Text = 'Windows 10'
$ButtonDownloadWindows10ToolTipText = 'Download $($ButtonDownloadWindows10.Text) (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image'
$ButtonDownloadWindows10.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadWindows10.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows10.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindows10.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows10, $ButtonDownloadWindows10ToolTipText)
$ButtonDownloadWindows10.Add_Click( {OpenInBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )

$LabelDownloadWindows10 = New-Object System.Windows.Forms.Label
$LabelDownloadWindows10.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindows10.Location = $ButtonDownloadWindows10.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindows10.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindows8 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows8.Text = 'Windows 8.1'
$ButtonDownloadWindows8ToolTipText = 'Download $($ButtonDownloadWindows8.Text) with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image'
$ButtonDownloadWindows8.Location = $ButtonDownloadWindows10.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindows8.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows8.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindows8.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows8, $ButtonDownloadWindows8ToolTipText)
$ButtonDownloadWindows8.Add_Click( {OpenInBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )

$LabelDownloadWindows8 = New-Object System.Windows.Forms.Label
$LabelDownloadWindows8.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindows8.Location = $ButtonDownloadWindows8.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindows8.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindows7 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows7.Text = 'Windows 7'
$ButtonDownloadWindows7ToolTipText = 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image'
$ButtonDownloadWindows7.Location = $ButtonDownloadWindows8.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindows7.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows7.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindows7.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows7, $ButtonDownloadWindows7ToolTipText)
$ButtonDownloadWindows7.Add_Click( {OpenInBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )

$LabelDownloadWindows7 = New-Object System.Windows.Forms.Label
$LabelDownloadWindows7.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindows7.Location = $ButtonDownloadWindows7.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindows7.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindowsXPENG = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsXPENG.Text = 'Windows XP (ENG)'
$ButtonDownloadWindowsXPENGToolTipText = 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image'
$ButtonDownloadWindowsXPENG.Location = $ButtonDownloadWindows7.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindowsXPENG.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsXPENG.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindowsXPENG.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsXPENG, $ButtonDownloadWindowsXPENGToolTipText)
$ButtonDownloadWindowsXPENG.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )

$LabelDownloadWindowsXPENG = New-Object System.Windows.Forms.Label
$LabelDownloadWindowsXPENG.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindowsXPENG.Location = $ButtonDownloadWindowsXPENG.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindowsXPENG.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindowsXPRUS = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsXPRUS.Text = 'Windows XP (RUS)'
$ButtonDownloadWindowsXPRUSToolTipText = 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image'
$ButtonDownloadWindowsXPRUS.Location = $ButtonDownloadWindowsXPENG.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindowsXPRUS.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsXPRUS.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindowsXPRUS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsXPRUS, $ButtonDownloadWindowsXPRUSToolTipText)
$ButtonDownloadWindowsXPRUS.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )

$LabelDownloadWindowsXPRUS = New-Object System.Windows.Forms.Label
$LabelDownloadWindowsXPRUS.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindowsXPRUS.Location = $ButtonDownloadWindowsXPRUS.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindowsXPRUS.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$ButtonDownloadWindowsPE = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsPE.Text = 'Windows PE'
$ButtonDownloadWindowsPEToolTipText = 'Download Windows PE (Live CD) ISO image'
$ButtonDownloadWindowsPE.Location = $ButtonDownloadWindowsXPRUS.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadWindowsPE.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsPE.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadWindowsPE.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsPE, $ButtonDownloadWindowsPEToolTipText)
$ButtonDownloadWindowsPE.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )

$LabelDownloadWindowsPE = New-Object System.Windows.Forms.Label
$LabelDownloadWindowsPE.Text = $_TEXT_OPENS_IN_BROWSER
$LabelDownloadWindowsPE.Location = $ButtonDownloadWindowsPE.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_LABEL_SHIFT_BROWSER
$LabelDownloadWindowsPE.Size = $_CHECK_BOX_SIZE_DOWNLOAD

$_TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GroupDownloadsWindows))
$GroupDownloadsWindows.Controls.AddRange(@(
        $ButtonDownloadWindows10, $LabelDownloadWindows10, $ButtonDownloadWindows8, $LabelDownloadWindows8, $ButtonDownloadWindows7, $LabelDownloadWindows7,
        $ButtonDownloadWindowsXPENG, $LabelDownloadWindowsXPENG, $ButtonDownloadWindowsXPRUS, $LabelDownloadWindowsXPRUS, $ButtonDownloadWindowsPE, $LabelDownloadWindowsPE
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Startup #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Startup {
    $_FORM.Activate()
    $_LOG.AppendText("[$((Get-Date).ToString())] Initializing...")

    if ($_IS_ELEVATED) {
        $_FORM.Text = "$($_FORM.Text): Administrator"
        $ButtonElevate.Text = 'Running as admin'
        $ButtonElevate.Enabled = $False
    }

    GatherSystemInformation
    CheckForUpdates

    if ($_SYSTEM_INFO.PSVersion -lt 5) {Write-Log $_WRN "PowerShell $_PS_VERSION detected, while versions >=5 are supported. Some features might not work."}

    $script:_CURRENT_DIR = (Split-Path ($MyInvocation.ScriptName))

    $script:GoogleUpdateExe = "$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"
    $ButtonGoogleUpdate.Enabled = Test-Path $GoogleUpdateExe

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'64'}).exe"
    $ButtonRunCCleaner.Enabled = Test-Path $CCleanerExe

    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $ButtonSecurityScanQuick.Enabled = Test-Path $DefenderExe
    $ButtonSecurityScanFull.Enabled = $ButtonSecurityScanQuick.Enabled
}


function Elevate {
    if (-not $_IS_ELEVATED) {
        Start-Process -Verb RunAs -FilePath 'powershell' -ArgumentList $MyInvocation.ScriptName
        ExitScript
    }
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Common Functions #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Write-Log($Level, $Message) {
    $Text = "[$((Get-Date).ToString())] $Message"
    $_LOG.SelectionStart = $_LOG.TextLength

    switch ($Level) { $_WRN {$_LOG.SelectionColor = 'blue'} $_ERR {$_LOG.SelectionColor = 'red'} Default {$_LOG.SelectionColor = 'black'} }

    Write-Host $Text
    $_LOG.AppendText("`n$Text")

    $_LOG.SelectionColor = 'black'
    $_LOG.ScrollToCaret();
}


function ExecuteAsAdmin ($Command, $Message) {Start-Process -Wait -Verb RunAs -FilePath 'powershell' -ArgumentList "-Command `"Write-Host $Message; $Command`""}


function ExitScript {$_FORM.Close()}


function OpenInBrowser ($URL) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    Write-Log $_INF "Openning URL in the default browser: $UrlToOpen"

    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Write-Log $_ERR "Could not open the URL: $($_.Exception.Message)"}
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Self-Update #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CheckForUpdates {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Write-Log $_INF 'Checking for updates...'

    try {$LatestVersion = (Invoke-WebRequest -Uri $VersionURL).ToString() -Replace "`n", ''}
    catch [Exception] {
        Write-Log $_ERR "Failed to check for update: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($_VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Write-Log $_WRN "Newer version available: v$LatestVersion"
        DownloadUpdate
    }
    else {Write-Log $_INF 'Currently running the latest version'}
}


function DownloadUpdate {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Write-Log $_WRN 'Downloading new version...'

    try {Invoke-WebRequest -Uri $DownloadURL -OutFile $TargetFile}
    catch [Exception] {
        Write-Log $_ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Restarting...'

    try {Start-Process -FilePath 'powershell' -ArgumentList $TargetFile}
    catch [Exception] {
        Write-Log $_ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    ExitScript
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# System Information #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_SYSTEM_INFO = New-Object System.Object

function GatherSystemInformation {
    Write-Log $_INF 'Gathering system information...'

    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = {[Math]::Round($_.TotalPhysicalMemory, 2) / 1GB}}
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $VideoController = Get-WmiObject Win32_VideoController | Select-Object CurrentHorizontalResolution, CurrentVerticalResolution, CurrentRefreshRate, Name
    $SystemLogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $SystemLogicalDisk | Select-Object -Property @{L = 'FreeSpaceGB'; E = {'{0:N2}' -f ($_.FreeSpace / 1GB)}}, @{L = 'SizeGB'; E = {'{0:N2}' -f ($_.Size / 1GB)}}
    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $PSVersion = $PSVersionTable.PSVersion.Major
    $SystemType = switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} }
    $SystemManufacturer = $ComputerSystem.Manufacturer
    $SystemModel = $ComputerSystem.Model
    $BIOSVersion = (Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion
    $ProcessorName = $Processor.Name
    $NumberOfCores = $Processor.NumberOfCores
    $NumberOfThreads = $Processor.ThreadCount
    $RAMSize = $ComputerSystem.RAM
    $GPUName = $VideoController.Name
    $HorizontalResolution = $VideoController.CurrentHorizontalResolution
    $VerticalResolution = $VideoController.CurrentVerticalResolution
    $RefreshRate = $VideoController.CurrentRefreshRate
    $DriveModel = ($SystemLogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model
    $SystemPartitionSize = $SystemPartition.SizeGB
    $SystemPartitionFreeSpace = $SystemPartition.FreeSpaceGB
    $OSName = $OperatingSystem.Caption
    $OSArchitecture = $OperatingSystem.OSArchitecture
    $OSRelease = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId
    $OSVersion = $OperatingSystem.Version

    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'PSVersion' -Value "$PSVersion" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Type' -Value "$SystemType" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Manufacturer' -Value "$SystemManufacturer" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Model' -Value "$SystemModel" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'BIOSVersion' -Value "$BIOSVersion" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'CPU' -Value "$ProcessorName" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'NumberOfCores' -Value "$NumberOfCores" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'NumberOfThreads' -Value "$NumberOfThreads" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'RAM' -Value "$RAMSize" -Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'GPU' -Value "$GPUName"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'HorizontalResolution' -Value "$HorizontalResolution"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'VerticalResolution' -Value "$VerticalResolution"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'RefreshRate' -Value "$RefreshRate"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'DriveModel' -Value "$DriveModel"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'SystemPartitionSize' -Value "$SystemPartitionSize"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'SystemPartitionFreeSpace' -Value "$SystemPartitionFreeSpace"-Force
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'OperatingSystem' -Value "$OSName"
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'Architecture' -Value "$OSArchitecture"
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'OSVersion' -Value "$OSVersion"
    $_SYSTEM_INFO | Add-Member -MemberType NoteProperty -Name 'OSRelease' -Value "$OSRelease"

    $_LOG.AppendText(' Done')
}


function PrintSystemInformation {
    Write-Log $_INF 'Current system information:'
    Write-Log $_INF "   PowerShell version: $($_SYSTEM_INFO.PSVersion)"
    Write-Log $_INF "   Computer model: $($_SYSTEM_INFO.Manufacturer), $($_SYSTEM_INFO.Model)"
    Write-Log $_INF "   BIOS version: $($_SYSTEM_INFO.BIOSVersion)"
    Write-Log $_INF "   CPU name: $($_SYSTEM_INFO.CPU)"
    Write-Log $_INF "   Cores / Threads: $($_SYSTEM_INFO.NumberOfCores) / $($_SYSTEM_INFO.NumberOfThreads)"
    Write-Log $_INF "   RAM size: $($_SYSTEM_INFO.RAM) GB"
    Write-Log $_INF "   GPU name: $($_SYSTEM_INFO.GPU)"
    Write-Log $_INF "   Main screen resolution: $($_SYSTEM_INFO.HorizontalResolution)x$($_SYSTEM_INFO.VerticalResolution) @$($_SYSTEM_INFO.RefreshRate)GHz"
    Write-Log $_INF "   System drive model: $($_SYSTEM_INFO.DriveModel)"
    Write-Log $_INF "   System partition - free / total: $($_SYSTEM_INFO.SystemPartitionFreeSpace) GB / $($_SYSTEM_INFO.SystemPartitionSize) GB"
    Write-Log $_INF "   Operation system: $($_SYSTEM_INFO.OperatingSystem)"
    Write-Log $_INF "   OS architecture: $($_SYSTEM_INFO.Architecture)"
    Write-Log $_INF "   OS version / build number: v$($_SYSTEM_INFO.OSRelease) / $($_SYSTEM_INFO.OSVersion)"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function UpdateGoogleSoftware {
    Write-Log $_INF 'Starting Google Update'

    try {Start-Process -Wait -FilePath $GoogleUpdateExe -ArgumentList '/c'}
    catch [Exception] {
        Write-Log $_ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    try {Start-Process -Wait -FilePath $GoogleUpdateExe -ArgumentList '/ua /installsource scheduler'}
    catch [Exception] {
        Write-Log $_ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Google software updated successfully'
}


function UpdateStoreApps {
    Write-Log $_INF 'Updating Microsoft Store apps'

    try {
        ExecuteAsAdmin "(Get-WmiObject -Namespace 'root\cimv2\mdm\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()" `
            'Updating Microsoft Store apps...'
    }
    catch [Exception] {
        Write-Log $_ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Microsoft Store apps updated successfully'
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CheckDrive {
    Write-Log $_INF 'Checking C: drive health'

    try {Start-Process -Wait -Verb RunAs -FilePath 'chkdsk' -ArgumentList '/scan'}
    catch [Exception] {
        Write-Log $_ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'C: drive health check completed successfully'
}


function CheckMemory {
    Write-Log $_INF 'Starting memory checking tool'

    try {Start-Process -Wait -FilePath 'mdsched'}
    catch [Exception] {
        Write-Log $_ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Memory checking tool was closed'
}


function StartSecurityScan ($Mode) {
    if (-not $Mode) {
        Write-Log $_WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Write-Log $_INF 'Updating security signatures'

    try {Start-Process -Wait -FilePath $DefenderExe -ArgumentList '-SignatureUpdate'}
    catch [Exception] {
        Write-Log $_ERR "Security signature update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $_INF "Starting $Mode securtiy scan"

    try {Start-Process -FilePath $DefenderExe -ArgumentList "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Write-Log $_ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Securtiy scan started successfully'
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CloudFlareDNS {
    Write-Log $_INF 'Changing DNS address to CloudFlare DNS (1.1.1.1 / 1.0.0.1)'

    $CurrentNetworkAdapter = (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').ifIndex

    if (-not $CurrentNetworkAdapter) {
        Write-Log $_ERR 'Could not determine network adapter used to connect to the Internet'
        Write-Log $_ERR 'This could mean that computer is not connected'
        return
    }

    try {
        ExecuteAsAdmin "Set-DnsClientServerAddress -InterfaceIndex $CurrentNetworkAdapter -ServerAddresses ('1.1.1.1', '1.0.0.1')" `
            'Changing DNS address to CloudFlare DNS'
    }
    catch [Exception] {
        Write-Log $_ERR "Failed to change DNS address: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'CloudFlare DNS set up successfully'
}


function RunCCleaner {
    if (-not $CCleanerWarningShown) {
        Write-Log $_WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Write-Log $_WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Write-Log $_INF 'Cleanup started'

    try {Start-Process -Wait -FilePath $CCleanerExe -ArgumentList '/auto'}
    catch [Exception] {
        Write-Log $_ERR "Cleanup failed: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Cleanup completed successfully'
}


function OptimizeDrive {
    Write-Log $_INF 'Starting drive optimization'

    try {Start-Process -Verb RunAs -FilePath 'defrag' -ArgumentList '/C /H /U /O'}
    catch [Exception] {
        Write-Log $_ERR "Failed to optimize the drive: $($_.Exception.Message)"
        return
    }

    Write-Log $_WRN 'Drive optimization completed'
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function HandleNiniteCheckBoxStateChange () {
    $ButtonNiniteDownload.Enabled = $CheckBoxNinite7zip.Checked -or $CheckBoxNiniteVLC.Checked -or `
        $CheckBoxNiniteTeamViewer.Checked -or $CheckBoxNiniteSkype.Checked -or $CheckBoxNiniteChrome.Checked -or `
        $CheckBoxNiniteqBittorrent.Checked -or $CheckBoxNiniteGoogleDrive.Checked -or $CheckBoxNiniteVSC.Checked
    $CheckBoxNiniteExecute.Enabled = $ButtonNiniteDownload.Enabled
}


function NiniteQueryBuilder () {
    $Array = @()
    if ($CheckBoxNinite7zip.Checked) {$Array += $CheckBoxNinite7zip.Name}
    if ($CheckBoxNiniteVLC.Checked) {$Array += $CheckBoxNiniteVLC.Name}
    if ($CheckBoxNiniteTeamViewer.Checked) {$Array += $CheckBoxNiniteTeamViewer.Name}
    if ($CheckBoxNiniteSkype.Checked) {$Array += $CheckBoxNiniteSkype.Name}
    if ($CheckBoxNiniteChrome.Checked) {$Array += $CheckBoxNiniteChrome.Name}
    if ($CheckBoxNiniteqBittorrent.Checked) {$Array += $CheckBoxNiniteqBittorrent.Name}
    if ($CheckBoxNiniteGoogleDrive.Checked) {$Array += $CheckBoxNiniteGoogleDrive.Name}
    if ($CheckBoxNiniteVSC.Checked) {$Array += $CheckBoxNiniteVSC.Name}
    return $Array -join '-'
}


function NiniteNameBuilder () {
    $Array = @()
    if ($CheckBoxNinite7zip.Checked) {$Array += $CheckBoxNinite7zip.Text}
    if ($CheckBoxNiniteVLC.Checked) {$Array += $CheckBoxNiniteVLC.Text}
    if ($CheckBoxNiniteTeamViewer.Checked) {$Array += $CheckBoxNiniteTeamViewer.Text}
    if ($CheckBoxNiniteSkype.Checked) {$Array += $CheckBoxNiniteSkype.Text}
    if ($CheckBoxNiniteChrome.Checked) {$Array += $CheckBoxNiniteChrome.Text}
    if ($CheckBoxNiniteqBittorrent.Checked) {$Array += $CheckBoxNiniteqBittorrent.Text}
    if ($CheckBoxNiniteGoogleDrive.Checked) {$Array += $CheckBoxNiniteGoogleDrive.Text}
    if ($CheckBoxNiniteVSC.Checked) {$Array += $CheckBoxNiniteVSC.Text}
    return "Ninite $($Array -join ' ') Installer.exe"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Download and Execute #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function DownloadFile ($URL, $SaveAs, $Execute, $Switches) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$_CURRENT_DIR\$FileName"

    Write-Log $_INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path $SavePath) {Write-Log $_WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Write-Log $_ERR "Download failed: $($_.Exception.Message)"
        return
    }

    if ($Execute) {ExecuteFile $FileName $Switches}
}


function ExtractArchive ($FileName) {
    Write-Log $_INF "Extracting $FileName"

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' {
            $ExtractionPath = '.'
            $Executable = 'CW.eXe'
        }
        'Office_2013-2019.zip' {
            $ExtractionPath = '.'
            $Executable = 'OInstall.exe'
        }
        'Victoria.zip' {
            $ExtractionPath = '.'
            $Executable = 'Victoria.exe'
        }
        'KMSAuto_Lite.zip' {
            $ExtractionPath = $FileName.trimend('.zip')
            $Executable = if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'KMSAuto x64.exe'} else {'KMSAuto.exe'}
        }
        "SDI_R*" {
            $ExtractionPath = $FileName.trimend('.zip')
            $Executable = "$ExtractionPath\SDI_auto.bat"
        }
        Default {$ExtractionPath = $FileName.trimend('.zip')}
    }

    $TargetDirName = "$_CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath -ne '.') {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$_CURRENT_DIR\$FileName", $TargetDirName)}
    catch [Exception] {
        Write-Log $_ERR "Extraction failed: $($_.Exception.Message)"
        return
    }

    if ($ExtractionPath -eq 'KMSAuto_Lite') {
        $TempDir = $TargetDirName
        $TargetDirName = $_CURRENT_DIR

        Move-Item -Path "$TempDir\$Executable" -Destination "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Write-Log $_WRN "Files extracted to $TargetDirName"

    Write-Log $_INF "Removing $FileName"
    Remove-Item "$_CURRENT_DIR\$FileName" -ErrorAction Ignore

    Write-Log $_WRN 'Extraction completed'

    return $Executable
}


function ExecuteFile ($FileName, $Switches) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {ExtractArchive $FileName} else {$FileName}

    if ($Switches) {
        Write-Log $_INF "Installing '$Executable' silently"

        try {Start-Process -Wait -FilePath "$_CURRENT_DIR\$Executable" -ArgumentList $Switches}
        catch [Exception] {
            Write-Log $_ERR "'$Executable' silent installation failed: $($_.Exception.Message)"
            return
        }

        Write-Log $_INF "Removing $FileName"
        Remove-Item "$_CURRENT_DIR\$FileName" -ErrorAction Ignore

        Write-Log $_WRN "'$Executable' installation completed"
    }
    else {
        Write-Log $_WRN "Executing '$Executable'"

        try {Start-Process -FilePath "$_CURRENT_DIR\$Executable"}
        catch [Exception] {
            Write-Log $_ERR "'$Executable' execution failed: $($_.Exception.Message)"
            return
        }
    }
}



#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Draw Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_FORM.ShowDialog() | Out-Null
