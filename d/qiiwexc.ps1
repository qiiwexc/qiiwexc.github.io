$VERSION = '19.3.21'


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Disclaimer #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

<#

To execute, right-click the file, then select "Run with PowerShell".
Double click will simply open the file in Notepad.

#>


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Initialization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$IS_ELEVATED = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

Write-Host 'Initializing...'

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Constants #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM_FONT_TYPE = 'Microsoft Sans Serif'
$BTN_FONT = "$FORM_FONT_TYPE, 10"

$FORM_HEIGHT = 620
$FORM_WIDTH = 650

$INT_SHORT = 5
$INT_NORMAL = 15
$INT_LONG = 40
$INT_TAB_ADJ = 4
$INT_GROUP_TOP = 20

$BTN_HEIGHT = 28
$BTN_WIDTH_NORMAL = 160
$BTN_INT_SHORT = $BTN_HEIGHT + $INT_SHORT
$BTN_INT_NORMAL = $BTN_HEIGHT + $INT_NORMAL
$BTN_SHIFT_VER_SHORT = "0, $BTN_INT_SHORT"
$BTN_SHIFT_HOR_SHORT = "$BTN_INT_SHORT, 0"
$BTN_SHIFT_VER_NORMAL = "0, $BTN_INT_NORMAL"
$BTN_SHIFT_HOR_NORMAL = "$BTN_INT_NORMAL, 0"

$CBOX_HEIGHT = 20
$CBOX_INT_SHORT = $CBOX_HEIGHT + $INT_SHORT
$CBOX_INT_NORMAL = $CBOX_HEIGHT + $INT_NORMAL
$CBOX_SHIFT_VER_SHORT = "0, $CBOX_INT_SHORT"
$CBOX_SHIFT_HOR_SHORT = "$CBOX_INT_SHORT, 0"
$CBOX_SHIFT_VER_NORMAL = "0, $CBOX_INT_NORMAL"
$CBOX_SHIFT_HOR_NORMAL = "$CBOX_INT_NORMAL, 0"

$INF = 'INF'
$WRN = 'WRN'
$ERR = 'ERR'


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM = New-Object System.Windows.Forms.Form
$FORM.Text = "qiiwexc v$VERSION"
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( {Startup} )


$LOG = New-Object System.Windows.Forms.RichTextBox
$LOG.Height = 200
$LOG.Width = - $INT_SHORT + $FORM_WIDTH - $INT_SHORT
$LOG.Location = "$INT_SHORT, $($FORM_HEIGHT - $LOG.Height - $INT_SHORT)"
$LOG.Font = "$FORM_FONT_TYPE, 9"
$LOG.ReadOnly = $True


$TAB_CONTROL = New-Object System.Windows.Forms.TabControl
$TAB_CONTROL.Size = "$($LOG.Width + $INT_SHORT - $INT_TAB_ADJ), $($FORM_HEIGHT - $LOG.Height - $INT_SHORT - $INT_TAB_ADJ)"
$TAB_CONTROL.Location = "$INT_SHORT, $INT_SHORT"


$FORM.Controls.AddRange(@($LOG, $TAB_CONTROL))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_HOME = New-Object System.Windows.Forms.TabPage
$TAB_HOME.Text = 'Home'
$TAB_HOME.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_HOME)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - This Utility #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_HomeThisUtility = New-Object System.Windows.Forms.GroupBox
$GRP_HomeThisUtility.Text = 'This utility'
$GRP_HomeThisUtility.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_HomeThisUtility.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeThisUtility.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_HOME.Controls.Add($GRP_HomeThisUtility)


$BTN_Elevate = New-Object System.Windows.Forms.Button
$BTN_Elevate.Text = 'Run as administrator'
$BTN_Elevate.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_WIDTH_NORMAL
$BTN_Elevate.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_Elevate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
$BTN_Elevate.Add_Click( {Elevate} )


$BTN_BrowserHome = New-Object System.Windows.Forms.Button
$BTN_BrowserHome.Text = 'Open in browser'
$BTN_BrowserHome.Height = $BTN_HEIGHT
$BTN_BrowserHome.Width = $BTN_WIDTH_NORMAL
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $BTN_SHIFT_VER_NORMAL
$BTN_BrowserHome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
$BTN_BrowserHome.Add_Click( {OpenInBrowser 'qiiwexc.github.io'} )


$BTN_SystemInformation = New-Object System.Windows.Forms.Button
$BTN_SystemInformation.Text = 'System information'
$BTN_SystemInformation.Height = $BTN_HEIGHT
$BTN_SystemInformation.Width = $BTN_WIDTH_NORMAL
$BTN_SystemInformation.Location = $BTN_BrowserHome.Location + $BTN_SHIFT_VER_NORMAL
$BTN_SystemInformation.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInformation, 'Print system information to the log')
$BTN_SystemInformation.Add_Click( {PrintSystemInformation} )


$GRP_HomeThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInformation))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_HomeUpdate = New-Object System.Windows.Forms.GroupBox
$GRP_HomeUpdate.Text = 'Updates'
$GRP_HomeUpdate.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 2
$GRP_HomeUpdate.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeUpdate.Location = $GRP_HomeThisUtility.Location + "0, $($GRP_HomeThisUtility.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_HomeUpdate)


$BTN_GoogleUpdate = New-Object System.Windows.Forms.Button
$BTN_GoogleUpdate.Text = 'Update Google Chrome'
$BTN_GoogleUpdate.Height = $BTN_HEIGHT
$BTN_GoogleUpdate.Width = $BTN_WIDTH_NORMAL
$BTN_GoogleUpdate.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_GoogleUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_GoogleUpdate, 'Silently update Google Chrome and other Google software')
$BTN_GoogleUpdate.Add_Click( {UpdateGoogleSoftware} )


$BTN_UpdateStoreApps = New-Object System.Windows.Forms.Button
$BTN_UpdateStoreApps.Text = 'Update Store apps'
$BTN_UpdateStoreApps.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_WIDTH_NORMAL
$BTN_UpdateStoreApps.Location = $BTN_GoogleUpdate.Location + $BTN_SHIFT_VER_NORMAL
$BTN_UpdateStoreApps.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
$BTN_UpdateStoreApps.Add_Click( {UpdateStoreApps} )


$GRP_HomeUpdate.Controls.AddRange(@($BTN_GoogleUpdate, $BTN_UpdateStoreApps))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_HomeDiagnostics = New-Object System.Windows.Forms.GroupBox
$GRP_HomeDiagnostics.Text = 'Diagnostics'
$GRP_HomeDiagnostics.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 4 - $INT_SHORT * 2
$GRP_HomeDiagnostics.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeDiagnostics.Location = $GRP_HomeThisUtility.Location + "$($GRP_HomeThisUtility.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_HomeDiagnostics)


$BTN_CheckDrive = New-Object System.Windows.Forms.Button
$BTN_CheckDrive.Text = 'Check C: drive health'
$BTN_CheckDrive.Height = $BTN_HEIGHT
$BTN_CheckDrive.Width = $BTN_WIDTH_NORMAL
$BTN_CheckDrive.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CheckDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDrive, 'Perform a C: drive health check')
$BTN_CheckDrive.Add_Click( {CheckDrive} )


$BTN_CheckMemory = New-Object System.Windows.Forms.Button
$BTN_CheckMemory.Text = 'Check RAM'
$BTN_CheckMemory.Height = $BTN_HEIGHT
$BTN_CheckMemory.Width = $BTN_WIDTH_NORMAL
$BTN_CheckMemory.Location = $BTN_CheckDrive.Location + $BTN_SHIFT_VER_NORMAL
$BTN_CheckMemory.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMemory, 'Start RAM checking utility')
$BTN_CheckMemory.Add_Click( {CheckMemory} )


$BTN_SecurityScanQuick = New-Object System.Windows.Forms.Button
$BTN_SecurityScanQuick.Text = 'Quick security scan'
$BTN_SecurityScanQuick.Height = $BTN_HEIGHT
$BTN_SecurityScanQuick.Width = $BTN_WIDTH_NORMAL
$BTN_SecurityScanQuick.Location = $BTN_CheckMemory.Location + $BTN_SHIFT_VER_NORMAL
$BTN_SecurityScanQuick.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SecurityScanQuick, 'Perform a quick security scan')
$BTN_SecurityScanQuick.Add_Click( {StartSecurityScan 'quick'} )

$BTN_SecurityScanFull = New-Object System.Windows.Forms.Button
$BTN_SecurityScanFull.Text = 'Full security scan'
$BTN_SecurityScanFull.Height = $BTN_HEIGHT
$BTN_SecurityScanFull.Width = $BTN_WIDTH_NORMAL
$BTN_SecurityScanFull.Location = $BTN_SecurityScanQuick.Location + $BTN_SHIFT_VER_SHORT
$BTN_SecurityScanFull.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SecurityScanFull, 'Perform a full security scan')
$BTN_SecurityScanFull.Add_Click( {StartSecurityScan 'full'} )


$GRP_HomeDiagnostics.Controls.AddRange(@($BTN_CheckDrive, $BTN_CheckMemory, $BTN_SecurityScanQuick, $BTN_SecurityScanFull))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_HomeOptimization = New-Object System.Windows.Forms.GroupBox
$GRP_HomeOptimization.Text = 'Optimization'
$GRP_HomeOptimization.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_HomeOptimization.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_HomeOptimization.Location = $GRP_HomeDiagnostics.Location + "$($GRP_HomeDiagnostics.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_HomeOptimization)


$BTN_CloudFlareDNS = New-Object System.Windows.Forms.Button
$BTN_CloudFlareDNS.Text = 'Setup CloudFlare DNS'
$BTN_CloudFlareDNS.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_WIDTH_NORMAL
$BTN_CloudFlareDNS.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CloudFlareDNS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS to CouldFlare - 1.1.1.1 / 1.0.0.1')
$BTN_CloudFlareDNS.Add_Click( {CloudFlareDNS} )


$BTN_RunCCleaner = New-Object System.Windows.Forms.Button
$BTN_RunCCleaner.Text = 'Run CCleaner silently'
$BTN_RunCCleaner.Height = $BTN_HEIGHT
$BTN_RunCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_RunCCleaner.Location = $BTN_CloudFlareDNS.Location + $BTN_SHIFT_VER_NORMAL
$BTN_RunCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
$BTN_RunCCleaner.Add_Click( {RunCCleaner} )


$BTN_OptimizeDrive = New-Object System.Windows.Forms.Button
$BTN_OptimizeDrive.Text = 'Optimize / defrag drive'
$BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_OptimizeDrive.Width = $BTN_WIDTH_NORMAL
$BTN_OptimizeDrive.Location = $BTN_RunCCleaner.Location + $BTN_SHIFT_VER_NORMAL
$BTN_OptimizeDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BTN_OptimizeDrive.Add_Click( {OptimizeDrive} )


$GRP_HomeOptimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_RunCCleaner, $BTN_OptimizeDrive))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads (Installers) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_DOWNLOADS_INSTALLERS = New-Object System.Windows.Forms.TabPage
$TAB_DOWNLOADS_INSTALLERS.Text = 'Downloads: Installers'
$TAB_DOWNLOADS_INSTALLERS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_DOWNLOADS_INSTALLERS)


$CBOX_WIDTH_DOWNLOAD = 145
$CBOX_SIZE_DOWNLOAD = "$($CBOX_WIDTH_DOWNLOAD), $($CBOX_HEIGHT)"
$CBOX_SHIFT_EXECUTE = '12, -5'
$LBL_SHIFT_BROWSER = '22, -3'

$TXT_AV_WARNING = "!! THIS FILE MAY TRIGGER ANTI-VIRUS FALSE POSITIVE !!`n!! IT IS RECOMMENDED TO DISABLE A/V SOFTWARE FOR DOWNLOAD AND SUBESEQUENT USE OF THIS FILE !!"
$TXT_EXECUTE_AFTER_DOWNLOAD = 'Execute after download'
$TXT_OPENS_IN_BROWSER = 'Opens in the browser'
$TXT_INSTALL_SILENTLY = 'Install silently'
$TIP_EXECUTE_AFTER_DOWNLOAD = "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"
$TIP_INSTALL_SILENTLY = 'Perform silent installation with no prompts'


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Ninite = New-Object System.Windows.Forms.GroupBox
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_NORMAL + $CBOX_INT_SHORT * 10 + $BTN_INT_NORMAL * 2
$GRP_Ninite.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Ninite.Location = "$INT_NORMAL, $INT_NORMAL"


$CBOX_NiniteChrome = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteChrome.Text = "Google Chrome"
$CBOX_NiniteChrome.Name = "chrome"
$CBOX_NiniteChrome.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$CBOX_NiniteChrome.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteChrome.Checked = $True
$CBOX_NiniteChrome.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_Ninite7zip = New-Object System.Windows.Forms.CheckBox
$CBOX_Ninite7zip.Text = "7-Zip"
$CBOX_Ninite7zip.Name = "7zip"
$CBOX_Ninite7zip.Location = $CBOX_NiniteChrome.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_Ninite7zip.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_Ninite7zip.Checked = $True
$CBOX_Ninite7zip.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteVLC = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteVLC.Text = "VLC"
$CBOX_NiniteVLC.Name = "vlc"
$CBOX_NiniteVLC.Location = $CBOX_Ninite7zip.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteVLC.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteVLC.Checked = $True
$CBOX_NiniteVLC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteTeamViewer = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteTeamViewer.Text = "TeamViewer"
$CBOX_NiniteTeamViewer.Name = "teamviewer14"
$CBOX_NiniteTeamViewer.Location = $CBOX_NiniteVLC.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteTeamViewer.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteTeamViewer.Checked = $True
$CBOX_NiniteTeamViewer.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteSkype = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteSkype.Text = "Skype"
$CBOX_NiniteSkype.Name = "skype"
$CBOX_NiniteSkype.Location = $CBOX_NiniteTeamViewer.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteSkype.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteSkype.Checked = $True
$CBOX_NiniteSkype.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteqBittorrent = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteqBittorrent.Text = "qBittorrent"
$CBOX_NiniteqBittorrent.Name = "qbittorrent"
$CBOX_NiniteqBittorrent.Location = $CBOX_NiniteSkype.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteqBittorrent.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteqBittorrent.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteGoogleDrive = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteGoogleDrive.Text = "Google Drive"
$CBOX_NiniteGoogleDrive.Name = "googlebackupandsync"
$CBOX_NiniteGoogleDrive.Location = $CBOX_NiniteqBittorrent.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteGoogleDrive.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteGoogleDrive.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )

$CBOX_NiniteVSC = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteVSC.Text = "Visual Studio Code"
$CBOX_NiniteVSC.Name = "vscode"
$CBOX_NiniteVSC.Location = $CBOX_NiniteGoogleDrive.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_NiniteVSC.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_NiniteVSC.Add_CheckStateChanged( {HandleNiniteCheckBoxStateChange} )


$BTN_NiniteDownload = New-Object System.Windows.Forms.Button
$BTN_NiniteDownload.Text = 'Download selected'
$BTN_NiniteDownload.Location = $CBOX_NiniteVSC.Location + $BTN_SHIFT_VER_SHORT
$BTN_NiniteDownload.Height = $BTN_HEIGHT
$BTN_NiniteDownload.Width = $BTN_WIDTH_NORMAL
$BTN_NiniteDownload.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_NiniteDownload, 'Download Ninite universal installer for selected applications')
$BTN_NiniteDownload.Add_Click( {DownloadFile "https://ninite.com/$(NiniteQueryBuilder)/ninite.exe" $(NiniteNameBuilder) $CBOX_NiniteExecute.Checked} )

$CBOX_NiniteExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_NiniteExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_NiniteExecute.Location = $BTN_NiniteDownload.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_NiniteExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_NiniteExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_NiniteOpenInBrowser = New-Object System.Windows.Forms.Button
$BTN_NiniteOpenInBrowser.Text = 'View other'
$BTN_NiniteOpenInBrowser.Location = $BTN_NiniteDownload.Location + $CBOX_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_NiniteOpenInBrowser.Height = $BTN_HEIGHT
$BTN_NiniteOpenInBrowser.Width = $BTN_WIDTH_NORMAL
$BTN_NiniteOpenInBrowser.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_NiniteOpenInBrowser, 'Open Ninite universal installer web page')
$BTN_NiniteOpenInBrowser.Add_Click( {
        $Query = NiniteQueryBuilder
        OpenInBrowser $(if ($Query) {"ninite.com/?select=$($Query)"} else {'ninite.com'})
    } )

$LBL_NiniteOpenInBrowser = New-Object System.Windows.Forms.Label
$LBL_NiniteOpenInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_NiniteOpenInBrowser.Location = $BTN_NiniteOpenInBrowser.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_NiniteOpenInBrowser.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GRP_Ninite))
$GRP_Ninite.Controls.AddRange(@(
        $BTN_NiniteDownload, $BTN_NiniteOpenInBrowser, $CBOX_NiniteExecute, $LBL_NiniteOpenInBrowser, $CBOX_Ninite7zip, $CBOX_NiniteVLC,
        $CBOX_NiniteTeamViewer, $CBOX_NiniteSkype, $CBOX_NiniteChrome, $CBOX_NiniteqBittorrent, $CBOX_NiniteGoogleDrive, $CBOX_NiniteVSC
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Software Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

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


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tool Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_InstallersTools = New-Object System.Windows.Forms.GroupBox
$GRP_InstallersTools.Text = 'Tools'
$GRP_InstallersTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 4 + $INT_NORMAL
$GRP_InstallersTools.Width = $GRP_Essentials.Width
$GRP_InstallersTools.Location = $GRP_Essentials.Location + "$($GRP_Essentials.Width + $INT_NORMAL), 0"


$BTN_DownloadCCleaner = New-Object System.Windows.Forms.Button
$BTN_DownloadCCleaner.Text = 'CCleaner'
$BTN_DownloadCCleaner.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
$BTN_DownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe' -Execute $CBOX_CCleanerExecute.Checked} )

$CBOX_CCleanerExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_CCleanerExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_CCleanerExecute.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_CCleanerExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_CCleanerExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadDefraggler = New-Object System.Windows.Forms.Button
$BTN_DownloadDefraggler.Text = 'Defraggler'
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadDefraggler.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')
$BTN_DownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe' -Execute $CBOX_DefragglerExecute.Checked} )

$CBOX_DefragglerExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_DefragglerExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_DefragglerExecute.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_DefragglerExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_DefragglerExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadRecuva = New-Object System.Windows.Forms.Button
$BTN_DownloadRecuva.Text = 'Recuva'
$BTN_DownloadRecuva.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_DownloadRecuva.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRecuva.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`rRecuva helps restore deleted files")
$BTN_DownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe' -Execute $CBOX_RecuvaExecute.Checked} )

$CBOX_RecuvaExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_RecuvaExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_RecuvaExecute.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_RecuvaExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_RecuvaExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadMalwarebytes = New-Object System.Windows.Forms.Button
$BTN_DownloadMalwarebytes.Text = 'Malwarebytes'
$BTN_DownloadMalwarebytes.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_NORMAL
$BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_DownloadMalwarebytes.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadMalwarebytes.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware")
$BTN_DownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' $CBOX_MalwarebytesExecute.Checked} )

$CBOX_MalwarebytesExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_MalwarebytesExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_MalwarebytesExecute.Location = $BTN_DownloadMalwarebytes.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_MalwarebytesExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_MalwarebytesExecute.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GRP_InstallersTools))
$GRP_InstallersTools.Controls.AddRange(@(
        $BTN_DownloadCCleaner, $BTN_DownloadDefraggler, $BTN_DownloadRecuva, $BTN_DownloadMalwarebytes,
        $CBOX_CCleanerExecute, $CBOX_DefragglerExecute, $CBOX_RecuvaExecute, $CBOX_MalwarebytesExecute
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads (Tools and ISO) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_DOWNLOADS_TOOLS = New-Object System.Windows.Forms.TabPage
$TAB_DOWNLOADS_TOOLS.Text = 'Downloads: Tools and ISO'
$TAB_DOWNLOADS_TOOLS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_DOWNLOADS_TOOLS)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tools #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadsTools = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsTools.Text = 'Tools'
$GRP_DownloadsTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 3
$GRP_DownloadsTools.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_DownloadsTools.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_DOWNLOADS_TOOLS.Controls.Add($GRP_DownloadsTools)


$BTN_DownloadSDI = New-Object System.Windows.Forms.Button
$BTN_DownloadSDI.Text = 'Snappy Driver Installer'
$BTN_DownloadSDI.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadSDI.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadSDI.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
$BTN_DownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip' -Execute $CBOX_SDIExecute.Checked} )

$CBOX_SDIExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_SDIExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_SDIExecute.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SDIExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_SDIExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadVictoria = New-Object System.Windows.Forms.Button
$BTN_DownloadVictoria.Text = 'Victoria'
$BTN_DownloadVictoria.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadVictoria.Height = $BTN_HEIGHT
$BTN_DownloadVictoria.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadVictoria.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
$BTN_DownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria.zip' -Execute $CBOX_VictoriaExecute.Checked} )

$CBOX_VictoriaExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_VictoriaExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_VictoriaExecute.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_VictoriaExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_VictoriaExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadRufus = New-Object System.Windows.Forms.Button
$BTN_DownloadRufus.Text = 'Rufus'
$BTN_DownloadRufus.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRufus.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRufus.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BTN_DownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe' -Execute $CBOX_RufusExecute.Checked} )

$CBOX_RufusExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_RufusExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_RufusExecute.Location = $BTN_DownloadRufus.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_RufusExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_RufusExecute.Size = $CBOX_SIZE_DOWNLOAD


$GRP_DownloadsTools.Controls.AddRange(@($BTN_DownloadSDI, $BTN_DownloadVictoria, $BTN_DownloadRufus, $CBOX_SDIExecute, $CBOX_VictoriaExecute, $CBOX_RufusExecute))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Activators #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsActivators.Text = 'Activators'
$GRP_DownloadsActivators.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 2
$GRP_DownloadsActivators.Width = $GRP_DownloadsTools.Width
$GRP_DownloadsActivators.Location = $GRP_DownloadsTools.Location + "$($GRP_DownloadsTools.Width + $INT_NORMAL), 0"


$BTN_DownloadKMS = New-Object System.Windows.Forms.Button
$BTN_DownloadKMS.Text = 'KMSAuto Lite'
$BTN_DownloadKMS.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadKMS.Height = $BTN_HEIGHT
$BTN_DownloadKMS.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadKMS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMS, "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadKMS.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -Execute $CBOX_KMSExecute.Checked
    } )

$CBOX_KMSExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_KMSExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_KMSExecute.Location = $BTN_DownloadKMS.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_KMSExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_KMSExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadChew = New-Object System.Windows.Forms.Button
$BTN_DownloadChew.Text = 'ChewWGA'
$BTN_DownloadChew.Location = $BTN_DownloadKMS.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChew.Height = $BTN_HEIGHT
$BTN_DownloadChew.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChew.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChew, "Download ChewWGA`rFor activating hopeless Windows 7 installations`n`n$TXT_AV_WARNING")
$BTN_DownloadChew.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip' -Execute $CBOX_ChewExecute.Checked
    } )

$CBOX_ChewExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_ChewExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ChewExecute.Location = $BTN_DownloadChew.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ChewExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ChewExecute.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GRP_DownloadsActivators))
$GRP_DownloadsActivators.Controls.AddRange(@($BTN_DownloadKMS, $BTN_DownloadChew, $CBOX_KMSExecute, $CBOX_ChewExecute))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Windows Images #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadsWindows = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsWindows.Text = 'Windows ISO Images'
$GRP_DownloadsWindows.Height = $INT_NORMAL + ($BTN_INT_SHORT + $CBOX_INT_SHORT) * 6
$GRP_DownloadsWindows.Width = $GRP_DownloadsActivators.Width
$GRP_DownloadsWindows.Location = $GRP_DownloadsActivators.Location + "$($GRP_DownloadsActivators.Width + $INT_NORMAL), 0"


$BTN_DownloadWindows10 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows10.Text = 'Windows 10'
$BTN_DownloadWindows10.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadWindows10.Height = $BTN_HEIGHT
$BTN_DownloadWindows10.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows10.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows10, 'Download Windows 10 (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image')
$BTN_DownloadWindows10.Add_Click( {OpenInBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )

$LBL_DownloadWindows10 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows10.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows10.Location = $BTN_DownloadWindows10.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadWindows10.Size = $CBOX_SIZE_DOWNLOAD

$BTN_DownloadWindows8 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows8.Text = 'Windows 8.1'
$BTN_DownloadWindows8.Location = $BTN_DownloadWindows10.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindows8.Height = $BTN_HEIGHT
$BTN_DownloadWindows8.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows8.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows8, 'Download Windows 8.1 with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image')
$BTN_DownloadWindows8.Add_Click( {OpenInBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )

$LBL_DownloadWindows8 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows8.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows8.Location = $BTN_DownloadWindows8.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadWindows8.Size = $CBOX_SIZE_DOWNLOAD

$BTN_DownloadWindows7 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows7.Text = 'Windows 7'
$BTN_DownloadWindows7.Location = $BTN_DownloadWindows8.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindows7.Height = $BTN_HEIGHT
$BTN_DownloadWindows7.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows7.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image')
$BTN_DownloadWindows7.Add_Click( {OpenInBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )

$LBL_DownloadWindows7 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows7.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows7.Location = $BTN_DownloadWindows7.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadWindows7.Size = $CBOX_SIZE_DOWNLOAD

$BTN_DownloadWindowsXPENG = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsXPENG.Text = 'Windows XP (ENG)'
$BTN_DownloadWindowsXPENG.Location = $BTN_DownloadWindows7.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsXPENG.Height = $BTN_HEIGHT
$BTN_DownloadWindowsXPENG.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsXPENG.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsXPENG, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$BTN_DownloadWindowsXPENG.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )

$LBL_DownloadWindowsXPENG = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsXPENG.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsXPENG.Location = $BTN_DownloadWindowsXPENG.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadWindowsXPENG.Size = $CBOX_SIZE_DOWNLOAD

$BTN_DownloadWindowsXPRUS = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsXPRUS.Text = 'Windows XP (RUS)'
$BTN_DownloadWindowsXPRUS.Location = $BTN_DownloadWindowsXPENG.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsXPRUS.Height = $BTN_HEIGHT
$BTN_DownloadWindowsXPRUS.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsXPRUS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsXPRUS, 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image')
$BTN_DownloadWindowsXPRUS.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )

$LBL_DownloadWindowsXPRUS = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsXPRUS.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsXPRUS.Location = $BTN_DownloadWindowsXPRUS.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadWindowsXPRUS.Size = $CBOX_SIZE_DOWNLOAD

$BTN_DownloadWindowsPE = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsPE.Text = 'Windows PE'
$BTN_DownloadWindowsPE.Location = $BTN_DownloadWindowsXPRUS.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadWindowsPE.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsPE.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsPE, 'Download Windows PE (Live CD) ISO image')
$BTN_DownloadWindowsPE.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )

$LBL_DownloadWindowsPE = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsPE.Location = $BTN_DownloadWindowsPE.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER
$LBL_DownloadWindowsPE.Size = $CBOX_SIZE_DOWNLOAD

$TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GRP_DownloadsWindows))
$GRP_DownloadsWindows.Controls.AddRange(@(
        $BTN_DownloadWindows10, $LBL_DownloadWindows10, $BTN_DownloadWindows8, $LBL_DownloadWindows8, $BTN_DownloadWindows7, $LBL_DownloadWindows7,
        $BTN_DownloadWindowsXPENG, $LBL_DownloadWindowsXPENG, $BTN_DownloadWindowsXPRUS, $LBL_DownloadWindowsXPRUS, $BTN_DownloadWindowsPE, $LBL_DownloadWindowsPE
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Startup #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Startup {
    $FORM.Activate()
    $LOG.AppendText("[$((Get-Date).ToString())] Initializing...")

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as admin'
        $BTN_Elevate.Enabled = $False
    }

    GatherSystemInformation
    if ($PS_VERSION -lt 5) {Write-Log $WRN "PowerShell $PS_VERSION detected, while versions >=5 are supported. Some features might not work."}

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    CheckForUpdates

    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_SecurityScanQuick.Enabled = Test-Path $DefenderExe
    $BTN_SecurityScanFull.Enabled = $BTN_SecurityScanQuick.Enabled

    Add-Type -AssemblyName System.IO.Compression.FileSystem
}


function Elevate {
    if (-not $IS_ELEVATED) {
        Start-Process -Verb RunAs -FilePath 'powershell' -ArgumentList $MyInvocation.ScriptName
        ExitScript
    }
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Common Functions #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Write-Log($Level, $Message) {
    $Text = "[$((Get-Date).ToString())] $Message"
    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) { $WRN {$LOG.SelectionColor = 'blue'} $ERR {$LOG.SelectionColor = 'red'} Default {$LOG.SelectionColor = 'black'} }

    Write-Host $Text
    $LOG.AppendText("`n$Text")

    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function ExecuteAsAdmin ($Command, $Message) {Start-Process -Wait -Verb RunAs -FilePath 'powershell' -ArgumentList "-Command `"Write-Host $Message; $Command`""}


function ExitScript {$FORM.Close()}


function OpenInBrowser ($Url) {
    if ($Url.length -lt 1) {
        Write-Log $ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    Write-Log $INF "Openning URL in the default browser: $UrlToOpen"

    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Write-Log $ERR "Could not open the URL: $($_.Exception.Message)"}
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Self-Update #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CheckForUpdates {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Write-Log $INF 'Checking for updates...'

    try {$LatestVersion = (Invoke-WebRequest -Uri $VersionURL).ToString() -Replace "`n", ''}
    catch [Exception] {
        Write-Log $ERR "Failed to check for update: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Write-Log $WRN "Newer version available: v$LatestVersion"
        DownloadUpdate
    }
    else {Write-Log $INF 'Currently running the latest version'}
}


function DownloadUpdate {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Write-Log $WRN 'Downloading new version...'

    try {Invoke-WebRequest -Uri $DownloadURL -OutFile $TargetFile}
    catch [Exception] {
        Write-Log $ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Restarting...'

    try {Start-Process -FilePath 'powershell' -ArgumentList $TargetFile}
    catch [Exception] {
        Write-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    ExitScript
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# System Information #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function GatherSystemInformation {
    Write-Log $INF 'Gathering system information...'

    New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:OS_NAME = $OperatingSystem.Caption
    $script:OS_ARCH = $OperatingSystem.OSArchitecture
    $script:OS_VERSION = $OperatingSystem.Version
    $script:PS_VERSION = $PSVersionTable.PSVersion.Major

    $script:CURRENT_DIR = (Split-Path ($MyInvocation.ScriptName))

    $script:GoogleUpdateExe = "$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"
    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($_SYSTEM_INFO.Architecture -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"

    $LOG.AppendText(' Done')
}


function PrintSystemInformation {
    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = {'{0:N2}' -f ($_.TotalPhysicalMemory / 1GB)}}
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $SystemLogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $SystemLogicalDisk | Select-Object -Property @{L = 'FreeSpaceGB'; E = {'{0:N2}' -f ($_.FreeSpace / 1GB)}}, @{L = 'SizeGB'; E = {'{0:N2}' -f ($_.Size / 1GB)}}

    Write-Log $INF 'Current system information:'
    Write-Log $INF '  Hardware'
    Write-Log $INF "    Computer type:  $(switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    Write-Log $INF "    Computer manufacturer:  $($ComputerSystem.Manufacturer)"
    Write-Log $INF "    Computer model:  $($ComputerSystem.Model)"
    Write-Log $INF "    CPU name:  $($Processor.Name)"
    Write-Log $INF "    Cores / Threads:  $($Processor.NumberOfCores) / $($Processor.ThreadCount)"
    Write-Log $INF "    RAM available:  $($ComputerSystem.RAM) GB"
    Write-Log $INF "    GPU name:  $((Get-WmiObject Win32_VideoController).Name)"
    Write-Log $INF "    System drive model:  $(($SystemLogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model)"
    Write-Log $INF "    System partition - free space: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($(($SystemPartition.FreeSpaceGB/$SystemPartition.SizeGB).tostring('P')))"
    Write-Log $INF '  Software'
    Write-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Write-Log $INF "    Operation system:  $($OS_NAME)"
    Write-Log $INF "    OS architecture:  $($OS_ARCH)"
    Write-Log $INF "    OS version / build number:  v$((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) / $($OS_VERSION)"
    Write-Log $INF "    PowerShell version:  $($PS_VERSION)"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function UpdateGoogleSoftware {
    Write-Log $INF 'Starting Google Update'

    try {Start-Process -Wait -FilePath $GoogleUpdateExe -ArgumentList '/c'}
    catch [Exception] {
        Write-Log $ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    try {Start-Process -Wait -FilePath $GoogleUpdateExe -ArgumentList '/ua /installsource scheduler'}
    catch [Exception] {
        Write-Log $ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Google software updated successfully'
}


function UpdateStoreApps {
    Write-Log $INF 'Updating Microsoft Store apps'

    try {
        ExecuteAsAdmin "(Get-WmiObject -Namespace 'root\cimv2\mdm\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()" `
            'Updating Microsoft Store apps...'
    }
    catch [Exception] {
        Write-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Microsoft Store apps updated successfully'
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CheckDrive {
    Write-Log $INF 'Checking C: drive health'

    try {Start-Process -Wait -Verb RunAs -FilePath 'chkdsk' -ArgumentList '/scan'}
    catch [Exception] {
        Write-Log $ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'C: drive health check completed successfully'
}


function CheckMemory {
    Write-Log $INF 'Starting memory checking tool'

    try {Start-Process -Wait -FilePath 'mdsched'}
    catch [Exception] {
        Write-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Memory checking tool was closed'
}


function StartSecurityScan ($Mode) {
    if (-not $Mode) {
        Write-Log $WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Write-Log $INF 'Updating security signatures'

    try {Start-Process -Wait -FilePath $DefenderExe -ArgumentList '-SignatureUpdate'}
    catch [Exception] {
        Write-Log $ERR "Security signature update failed: $($_.Exception.Message)"
        return
    }

    Write-Log $INF "Starting $Mode securtiy scan"

    try {Start-Process -FilePath $DefenderExe -ArgumentList "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Write-Log $ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Securtiy scan started successfully'
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CloudFlareDNS {
    Write-Log $INF 'Changing DNS address to CloudFlare DNS (1.1.1.1 / 1.0.0.1)'

    $CurrentNetworkAdapter = (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').ifIndex

    if (-not $CurrentNetworkAdapter) {
        Write-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Write-Log $ERR 'This could mean that computer is not connected'
        return
    }

    try {
        ExecuteAsAdmin "Set-DnsClientServerAddress -InterfaceIndex $CurrentNetworkAdapter -ServerAddresses ('1.1.1.1', '1.0.0.1')" `
            'Changing DNS address to CloudFlare DNS'
    }
    catch [Exception] {
        Write-Log $ERR "Failed to change DNS address: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'CloudFlare DNS set up successfully'
}


function RunCCleaner {
    if (-not $CCleanerWarningShown) {
        Write-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Write-Log $WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Write-Log $INF 'Cleanup started'

    try {Start-Process -Wait -FilePath $CCleanerExe -ArgumentList '/auto'}
    catch [Exception] {
        Write-Log $ERR "Cleanup failed: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Cleanup completed successfully'
}


function OptimizeDrive {
    Write-Log $INF 'Starting drive optimization'

    try {Start-Process -Verb RunAs -FilePath 'defrag' -ArgumentList '/C /H /U /O'}
    catch [Exception] {
        Write-Log $ERR "Failed to optimize the drive: $($_.Exception.Message)"
        return
    }

    Write-Log $WRN 'Drive optimization completed'
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function HandleNiniteCheckBoxStateChange () {
    $BTN_NiniteDownload.Enabled = $CBOX_Ninite7zip.Checked -or $CBOX_NiniteVLC.Checked -or $CBOX_NiniteTeamViewer.Checked -or $CBOX_NiniteSkype.Checked -or `
        $CBOX_NiniteChrome.Checked -or $CBOX_NiniteqBittorrent.Checked -or $CBOX_NiniteGoogleDrive.Checked -or $CBOX_NiniteVSC.Checked
    $CBOX_NiniteExecute.Enabled = $BTN_NiniteDownload.Enabled
}


function NiniteQueryBuilder () {
    $Array = @()
    if ($CBOX_Ninite7zip.Checked) {$Array += $CBOX_Ninite7zip.Name}
    if ($CBOX_NiniteVLC.Checked) {$Array += $CBOX_NiniteVLC.Name}
    if ($CBOX_NiniteTeamViewer.Checked) {$Array += $CBOX_NiniteTeamViewer.Name}
    if ($CBOX_NiniteSkype.Checked) {$Array += $CBOX_NiniteSkype.Name}
    if ($CBOX_NiniteChrome.Checked) {$Array += $CBOX_NiniteChrome.Name}
    if ($CBOX_NiniteqBittorrent.Checked) {$Array += $CBOX_NiniteqBittorrent.Name}
    if ($CBOX_NiniteGoogleDrive.Checked) {$Array += $CBOX_NiniteGoogleDrive.Name}
    if ($CBOX_NiniteVSC.Checked) {$Array += $CBOX_NiniteVSC.Name}
    return $Array -join '-'
}


function NiniteNameBuilder () {
    $Array = @()
    if ($CBOX_Ninite7zip.Checked) {$Array += $CBOX_Ninite7zip.Text}
    if ($CBOX_NiniteVLC.Checked) {$Array += $CBOX_NiniteVLC.Text}
    if ($CBOX_NiniteTeamViewer.Checked) {$Array += $CBOX_NiniteTeamViewer.Text}
    if ($CBOX_NiniteSkype.Checked) {$Array += $CBOX_NiniteSkype.Text}
    if ($CBOX_NiniteChrome.Checked) {$Array += $CBOX_NiniteChrome.Text}
    if ($CBOX_NiniteqBittorrent.Checked) {$Array += $CBOX_NiniteqBittorrent.Text}
    if ($CBOX_NiniteGoogleDrive.Checked) {$Array += $CBOX_NiniteGoogleDrive.Text}
    if ($CBOX_NiniteVSC.Checked) {$Array += $CBOX_NiniteVSC.Text}
    return "Ninite $($Array -join ' ') Installer.exe"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Download and Execute #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function DownloadFile ($Url, $SaveAs, $Execute, $Switches) {
    if ($Url.length -lt 1) {
        Write-Log $ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$CURRENT_DIR\$FileName"

    Write-Log $INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path $SavePath) {Write-Log $WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Write-Log $ERR "Download failed: $($_.Exception.Message)"
        return
    }

    if ($Execute) {ExecuteFile $FileName $Switches}
}


function ExtractArchive ($FileName) {
    Write-Log $INF "Extracting $FileName"

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

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath -ne '.') {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName)}
    catch [Exception] {
        Write-Log $ERR "Extraction failed: $($_.Exception.Message)"
        return
    }

    if ($ExtractionPath -eq 'KMSAuto_Lite') {
        $TempDir = $TargetDirName
        $TargetDirName = $CURRENT_DIR

        Move-Item -Path "$TempDir\$Executable" -Destination "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Write-Log $WRN "Files extracted to $TargetDirName"

    Write-Log $INF "Removing $FileName"
    Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore

    Write-Log $WRN 'Extraction completed'

    return $Executable
}


function ExecuteFile ($FileName, $Switches) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {ExtractArchive $FileName} else {$FileName}

    if ($Switches) {
        Write-Log $INF "Installing '$Executable' silently"

        try {Start-Process -Wait -FilePath "$CURRENT_DIR\$Executable" -ArgumentList $Switches}
        catch [Exception] {
            Write-Log $ERR "'$Executable' silent installation failed: $($_.Exception.Message)"
            return
        }

        Write-Log $INF "Removing $FileName"
        Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore

        Write-Log $WRN "'$Executable' installation completed"
    }
    else {
        Write-Log $WRN "Executing '$Executable'"

        try {Start-Process -FilePath "$CURRENT_DIR\$Executable"}
        catch [Exception] {
            Write-Log $ERR "'$Executable' execution failed: $($_.Exception.Message)"
            return
        }
    }
}



#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Draw Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM.ShowDialog() | Out-Null
