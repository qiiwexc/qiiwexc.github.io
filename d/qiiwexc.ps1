$VERSION = '19.3.23'


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

$FONT_NAME = 'Microsoft Sans Serif'
$BTN_FONT = "$FONT_NAME, 10"

$FORM_HEIGHT = 645
$FORM_WIDTH = 665

$INT_SHORT = 5
$INT_NORMAL = 15
$INT_LONG = 40
$INT_TAB_ADJ = 4
$INT_GROUP_TOP = 20

$BTN_HEIGHT = 28
$BTN_WIDTH_NORMAL = 166
$BTN_INT_SHORT = $BTN_HEIGHT + $INT_SHORT
$BTN_INT_NORMAL = $BTN_HEIGHT + $INT_NORMAL
$BTN_SHIFT_HOR_SHORT = "$BTN_INT_SHORT, 0"
$BTN_SHIFT_HOR_NORMAL = "$BTN_INT_NORMAL, 0"
$BTN_SHIFT_VER_SHORT = "0, $BTN_INT_SHORT"
$BTN_SHIFT_VER_NORMAL = "0, $BTN_INT_NORMAL"

$CBOX_HEIGHT = 20
$CBOX_INT_SHORT = $CBOX_HEIGHT + $INT_SHORT
$CBOX_INT_NORMAL = $CBOX_HEIGHT + $INT_NORMAL
$CBOX_SHIFT_HOR_SHORT = "$CBOX_INT_SHORT, 0"
$CBOX_SHIFT_HOR_NORMAL = "$CBOX_INT_NORMAL, 0"
$CBOX_SHIFT_VER_SHORT = "0, $CBOX_INT_SHORT"
$CBOX_SHIFT_VER_NORMAL = "0, $CBOX_INT_NORMAL"

$INF = 'INF'
$WRN = 'WRN'
$ERR = 'ERR'

$REQUIRES_ELEVATION = if (-not $IS_ELEVATED) {' *'}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM = New-Object System.Windows.Forms.Form
$FORM.Text = "qiiwexc v$VERSION"
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( {Initialize-Startup} )


$LOG = New-Object System.Windows.Forms.RichTextBox
$LOG.Height = 200
$LOG.Width = - $INT_SHORT + $FORM_WIDTH - $INT_SHORT
$LOG.Location = "$INT_SHORT, $($FORM_HEIGHT - $LOG.Height - $INT_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
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

$GRP_ThisUtility = New-Object System.Windows.Forms.GroupBox
$GRP_ThisUtility.Text = 'This utility'
$GRP_ThisUtility.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_ThisUtility.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_ThisUtility.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_HOME.Controls.Add($GRP_ThisUtility)


$BTN_Elevate = New-Object System.Windows.Forms.Button
$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_WIDTH_NORMAL
$BTN_Elevate.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_Elevate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
$BTN_Elevate.Add_Click( {Start-Elevated} )


$BTN_BrowserHome = New-Object System.Windows.Forms.Button
$BTN_BrowserHome.Text = 'Open in the browser'
$BTN_BrowserHome.Height = $BTN_HEIGHT
$BTN_BrowserHome.Width = $BTN_WIDTH_NORMAL
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $BTN_SHIFT_VER_NORMAL
$BTN_BrowserHome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
$BTN_BrowserHome.Add_Click( {Open-InBrowser 'qiiwexc.github.io'} )


$BTN_SystemInformation = New-Object System.Windows.Forms.Button
$BTN_SystemInformation.Text = 'System information'
$BTN_SystemInformation.Height = $BTN_HEIGHT
$BTN_SystemInformation.Width = $BTN_WIDTH_NORMAL
$BTN_SystemInformation.Location = $BTN_BrowserHome.Location + $BTN_SHIFT_VER_NORMAL
$BTN_SystemInformation.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInformation, 'Print system information to the log')
$BTN_SystemInformation.Add_Click( {Out-SystemInformation} )


$GRP_ThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInformation))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Updates = New-Object System.Windows.Forms.GroupBox
$GRP_Updates.Text = 'Updates'
$GRP_Updates.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 5 - $INT_SHORT * 2
$GRP_Updates.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Updates.Location = $GRP_ThisUtility.Location + "0, $($GRP_ThisUtility.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_Updates)


$BTN_GoogleUpdate = New-Object System.Windows.Forms.Button
$BTN_GoogleUpdate.Text = 'Update Google Chrome'
$BTN_GoogleUpdate.Height = $BTN_HEIGHT
$BTN_GoogleUpdate.Width = $BTN_WIDTH_NORMAL
$BTN_GoogleUpdate.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_GoogleUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_GoogleUpdate, 'Silently update Google Chrome and other Google software')
$BTN_GoogleUpdate.Add_Click( {Start-GoogleUpdate} )


$BTN_UpdateStoreApps = New-Object System.Windows.Forms.Button
$BTN_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BTN_UpdateStoreApps.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_WIDTH_NORMAL
$BTN_UpdateStoreApps.Location = $BTN_GoogleUpdate.Location + $BTN_SHIFT_VER_NORMAL
$BTN_UpdateStoreApps.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
$BTN_UpdateStoreApps.Add_Click( {Start-StoreAppUpdate} )


$BTN_OfficeInsider = New-Object System.Windows.Forms.Button
$BTN_OfficeInsider.Text = 'Become Office insider'
$BTN_OfficeInsider.Height = $BTN_HEIGHT
$BTN_OfficeInsider.Width = $BTN_WIDTH_NORMAL
$BTN_OfficeInsider.Location = $BTN_UpdateStoreApps.Location + $BTN_SHIFT_VER_NORMAL
$BTN_OfficeInsider.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OfficeInsider, 'Switch Microsoft Office to insider update channel')
$BTN_OfficeInsider.Add_Click( {Set-OfficeInsiderChannel} )

$BTN_UpdateOffice = New-Object System.Windows.Forms.Button
$BTN_UpdateOffice.Text = 'Update Microsoft Office'
$BTN_UpdateOffice.Height = $BTN_HEIGHT
$BTN_UpdateOffice.Width = $BTN_WIDTH_NORMAL
$BTN_UpdateOffice.Location = $BTN_OfficeInsider.Location + $BTN_SHIFT_VER_SHORT
$BTN_UpdateOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
$BTN_UpdateOffice.Add_Click( {Start-OfficeUpdate} )


$BTN_WindowsUpdate = New-Object System.Windows.Forms.Button
$BTN_WindowsUpdate.Text = 'Start Windows Update'
$BTN_WindowsUpdate.Height = $BTN_HEIGHT
$BTN_WindowsUpdate.Width = $BTN_WIDTH_NORMAL
$BTN_WindowsUpdate.Location = $BTN_UpdateOffice.Location + $BTN_SHIFT_VER_NORMAL
$BTN_WindowsUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsUpdate, 'Check for Windows updates, download and install if available')
$BTN_WindowsUpdate.Add_Click( {Start-WindowsUpdate} )

$GRP_Updates.Controls.AddRange(@($BTN_GoogleUpdate, $BTN_UpdateStoreApps, $BTN_OfficeInsider, $BTN_UpdateOffice, $BTN_WindowsUpdate))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Diagnostics = New-Object System.Windows.Forms.GroupBox
$GRP_Diagnostics.Text = 'Diagnostics'
$GRP_Diagnostics.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 4 - $INT_SHORT * 2
$GRP_Diagnostics.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Diagnostics.Location = $GRP_ThisUtility.Location + "$($GRP_ThisUtility.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_Diagnostics)


$BTN_CheckDrive = New-Object System.Windows.Forms.Button
$BTN_CheckDrive.Text = "Check (C:) drive health$REQUIRES_ELEVATION"
$BTN_CheckDrive.Height = $BTN_HEIGHT
$BTN_CheckDrive.Width = $BTN_WIDTH_NORMAL
$BTN_CheckDrive.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CheckDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDrive, 'Perform a (C:) drive health check')
$BTN_CheckDrive.Add_Click( {Start-DriveCheck} )


$BTN_CheckMemory = New-Object System.Windows.Forms.Button
$BTN_CheckMemory.Text = 'RAM checking utility'
$BTN_CheckMemory.Height = $BTN_HEIGHT
$BTN_CheckMemory.Width = $BTN_WIDTH_NORMAL
$BTN_CheckMemory.Location = $BTN_CheckDrive.Location + $BTN_SHIFT_VER_NORMAL
$BTN_CheckMemory.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMemory, 'Start RAM checking utility')
$BTN_CheckMemory.Add_Click( {Start-MemoryCheckTool} )


$BTN_QuickSecurityScan = New-Object System.Windows.Forms.Button
$BTN_QuickSecurityScan.Text = 'Quick security scan'
$BTN_QuickSecurityScan.Height = $BTN_HEIGHT
$BTN_QuickSecurityScan.Width = $BTN_WIDTH_NORMAL
$BTN_QuickSecurityScan.Location = $BTN_CheckMemory.Location + $BTN_SHIFT_VER_NORMAL
$BTN_QuickSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_QuickSecurityScan, 'Perform a quick security scan')
$BTN_QuickSecurityScan.Add_Click( {Start-SecurityScan 'quick'} )

$BTN_FullSecurityScan = New-Object System.Windows.Forms.Button
$BTN_FullSecurityScan.Text = 'Full security scan'
$BTN_FullSecurityScan.Height = $BTN_HEIGHT
$BTN_FullSecurityScan.Width = $BTN_WIDTH_NORMAL
$BTN_FullSecurityScan.Location = $BTN_QuickSecurityScan.Location + $BTN_SHIFT_VER_SHORT
$BTN_FullSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FullSecurityScan, 'Perform a full security scan')
$BTN_FullSecurityScan.Add_Click( {Start-SecurityScan 'full'} )


$GRP_Diagnostics.Controls.AddRange(@($BTN_CheckDrive, $BTN_CheckMemory, $BTN_QuickSecurityScan, $BTN_FullSecurityScan))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Optimization = New-Object System.Windows.Forms.GroupBox
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $BTN_INT_NORMAL * 3
$GRP_Optimization.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Optimization.Location = $GRP_Diagnostics.Location + "$($GRP_Diagnostics.Width + $INT_NORMAL), 0"
$TAB_HOME.Controls.Add($GRP_Optimization)


$BTN_CloudFlareDNS = New-Object System.Windows.Forms.Button
$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_WIDTH_NORMAL
$BTN_CloudFlareDNS.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_CloudFlareDNS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS (1.1.1.1 / 1.0.0.1)')
$BTN_CloudFlareDNS.Add_Click( {Set-CloudFlareDNS} )


$BTN_RunCCleaner = New-Object System.Windows.Forms.Button
$BTN_RunCCleaner.Text = "Run CCleaner silently$REQUIRES_ELEVATION"
$BTN_RunCCleaner.Height = $BTN_HEIGHT
$BTN_RunCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_RunCCleaner.Location = $BTN_CloudFlareDNS.Location + $BTN_SHIFT_VER_NORMAL
$BTN_RunCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
$BTN_RunCCleaner.Add_Click( {Start-CCleaner} )


$BTN_DeleteRestorePoints = New-Object System.Windows.Forms.Button
$BTN_DeleteRestorePoints.Text = "Delete all restore points$REQUIRES_ELEVATION"
$BTN_DeleteRestorePoints.Height = $BTN_HEIGHT
$BTN_DeleteRestorePoints.Width = $BTN_WIDTH_NORMAL
$BTN_DeleteRestorePoints.Location = $BTN_RunCCleaner.Location + $BTN_SHIFT_VER_NORMAL
$BTN_DeleteRestorePoints.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DeleteRestorePoints, 'Delete all restore points (shadow copies)')
$BTN_DeleteRestorePoints.Add_Click( {Remove-RestorePoints} )


$BTN_OptimizeDrive = New-Object System.Windows.Forms.Button
$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_OptimizeDrive.Width = $BTN_WIDTH_NORMAL
$BTN_OptimizeDrive.Location = $BTN_DeleteRestorePoints.Location + $BTN_SHIFT_VER_NORMAL
$BTN_OptimizeDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BTN_OptimizeDrive.Add_Click( {Start-DriveOptimization} )


$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_RunCCleaner, $BTN_DeleteRestorePoints, $BTN_OptimizeDrive))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads (Installers) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_INSTALLERS = New-Object System.Windows.Forms.TabPage
$TAB_INSTALLERS.Text = 'Downloads: Installers'
$TAB_INSTALLERS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_INSTALLERS)


$CBOX_WIDTH_DOWNLOAD = 145
$CBOX_SIZE_DOWNLOAD = "$($CBOX_WIDTH_DOWNLOAD), $($CBOX_HEIGHT)"
$CBOX_SHIFT_EXECUTE = '25, -5'

$LBL_SHIFT_BROWSER = '30, -5'


$TXT_AV_WARNING = "!! THIS FILE MAY TRIGGER ANTI-VIRUS FALSE POSITIVE !!`n!! IT IS RECOMMENDED TO DISABLE A/V SOFTWARE FOR DOWNLOAD AND SUBESEQUENT USE OF THIS FILE !!"
$TXT_EXECUTE_AFTER_DOWNLOAD = 'Start after download'
$TXT_OPENS_IN_BROWSER = 'Opens in the browser'

$TIP_EXECUTE_AFTER_DOWNLOAD = "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Ninite = New-Object System.Windows.Forms.GroupBox
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_NORMAL + $CBOX_INT_SHORT * 10 + $BTN_INT_NORMAL * 2
$GRP_Ninite.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_Ninite.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)


$CBOX_Chrome = New-Object System.Windows.Forms.CheckBox
$CBOX_Chrome.Text = "Google Chrome"
$CBOX_Chrome.Name = "chrome"
$CBOX_Chrome.Checked = $True
$CBOX_Chrome.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_Chrome.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$CBOX_Chrome.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_7zip = New-Object System.Windows.Forms.CheckBox
$CBOX_7zip.Text = "7-Zip"
$CBOX_7zip.Name = "7zip"
$CBOX_7zip.Checked = $True
$CBOX_7zip.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_7zip.Location = $CBOX_Chrome.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_7zip.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_VLC = New-Object System.Windows.Forms.CheckBox
$CBOX_VLC.Text = "VLC"
$CBOX_VLC.Name = "vlc"
$CBOX_VLC.Checked = $True
$CBOX_VLC.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_VLC.Location = $CBOX_7zip.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_VLC.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_TeamViewer = New-Object System.Windows.Forms.CheckBox
$CBOX_TeamViewer.Text = "TeamViewer"
$CBOX_TeamViewer.Name = "teamviewer14"
$CBOX_TeamViewer.Checked = $True
$CBOX_TeamViewer.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_Skype = New-Object System.Windows.Forms.CheckBox
$CBOX_Skype.Text = "Skype"
$CBOX_Skype.Name = "skype"
$CBOX_Skype.Checked = $True
$CBOX_Skype.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_Skype.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_qBittorrent = New-Object System.Windows.Forms.CheckBox
$CBOX_qBittorrent.Text = "qBittorrent"
$CBOX_qBittorrent.Name = "qbittorrent"
$CBOX_qBittorrent.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_GoogleDrive = New-Object System.Windows.Forms.CheckBox
$CBOX_GoogleDrive.Text = "Google Drive"
$CBOX_GoogleDrive.Name = "googlebackupandsync"
$CBOX_GoogleDrive.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_GoogleDrive.Location = $CBOX_qBittorrent.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_GoogleDrive.Add_CheckStateChanged( {Set-NiniteButtonState} )

$CBOX_VSCode = New-Object System.Windows.Forms.CheckBox
$CBOX_VSCode.Text = "Visual Studio Code"
$CBOX_VSCode.Name = "vscode"
$CBOX_VSCode.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_VSCode.Location = $CBOX_GoogleDrive.Location + $CBOX_SHIFT_VER_SHORT
$CBOX_VSCode.Add_CheckStateChanged( {Set-NiniteButtonState} )


$BTN_DownloadNinite = New-Object System.Windows.Forms.Button
$BTN_DownloadNinite.Text = 'Download selected'
$BTN_DownloadNinite.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadNinite.Location = $CBOX_VSCode.Location + $BTN_SHIFT_VER_SHORT
$BTN_DownloadNinite.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
$BTN_DownloadNinite.Add_Click( {
        $FileName = Start-Download "https://ninite.com/$(Build-NiniteQuery)/ninite.exe" (Build-NiniteFileName)
        if ($CBOX_ExecuteNinite.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteNinite = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteNinite.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteNinite.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteNinite.Location = $BTN_DownloadNinite.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteNinite, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteNinite.Add_CheckStateChanged( {$BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_ExecuteNinite.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_OpenNiniteInBrowser = New-Object System.Windows.Forms.Button
$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH_NORMAL
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $CBOX_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_OpenNiniteInBrowser.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
$BTN_OpenNiniteInBrowser.Add_Click( {
        $Query = Build-NiniteQuery
        Open-InBrowser $(if ($Query) {"ninite.com/?select=$($Query)"} else {'ninite.com'})
    } )

$LBL_OpenNiniteInBrowser = New-Object System.Windows.Forms.Label
$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE_DOWNLOAD
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER


$GRP_Ninite.Controls.AddRange(@(
        $BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_ExecuteNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_GoogleDrive, $CBOX_VSCode
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Software Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

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
        $FileName = Start-Download 'unchecky.com/files/unchecky_setup.exe'
        if ($CBOX_ExecuteUnchecky.Checked -and $FileName) {
            Start-File $FileName $(if ($CBOX_SilentlyInstallUnchecky.Checked) {'-install -no_desktop_icon'}) -IsSilentInstall $True
        }
    } )

$CBOX_ExecuteUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteUnchecky.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteUnchecky.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteUnchecky.Location = $BTN_DownloadUnchecky.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteUnchecky, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteUnchecky.Add_CheckStateChanged( {
        $CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_ExecuteUnchecky.Checked
        $BTN_DownloadUnchecky.Text = "Unchecky$(if ($CBOX_ExecuteUnchecky.Checked) {$REQUIRES_ELEVATION})"
    } )

$CBOX_SilentlyInstallUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CBOX_SilentlyInstallUnchecky.Enabled = $False
$CBOX_SilentlyInstallUnchecky.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_ExecuteUnchecky.Location + "0, $CBOX_HEIGHT"
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')


$BTN_DownloadOffice = New-Object System.Windows.Forms.Button
$BTN_DownloadOffice.Text = 'Office 2013 - 2019'
$BTN_DownloadOffice.Height = $BTN_HEIGHT
$BTN_DownloadOffice.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $BTN_SHIFT_VER_NORMAL + $BTN_SHIFT_VER_NORMAL
$BTN_DownloadOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadOffice, "Download Microsoft Office 2013 - 2019 installer and activator`n`n$TXT_AV_WARNING")
$BTN_DownloadOffice.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/Office_2013-2019.zip'
        if ($CBOX_ExecuteOffice.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteOffice = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteOffice.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteOffice.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteOffice.Location = $BTN_DownloadOffice.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteOffice, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteOffice.Add_CheckStateChanged( {$BTN_DownloadOffice.Text = "Office 2013 - 2019$(if ($CBOX_ExecuteOffice.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadChrome = New-Object System.Windows.Forms.Button
$BTN_DownloadChrome.Text = 'Chrome Beta'
$BTN_DownloadChrome.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChrome.Location = $BTN_DownloadOffice.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChrome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Open Google Chrome Beta download page')
$BTN_DownloadChrome.Add_Click( {Open-InBrowser 'google.com/chrome/beta'} )

$LBL_DownloadChrome = New-Object System.Windows.Forms.Label
$LBL_DownloadChrome.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadChrome.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadChrome.Location = $BTN_DownloadChrome.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER


$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadUnchecky, $CBOX_ExecuteUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_ExecuteOffice, $BTN_DownloadChrome, $LBL_DownloadChrome)
)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tool Installers #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_InstallTools = New-Object System.Windows.Forms.GroupBox
$GRP_InstallTools.Text = 'Tools'
$GRP_InstallTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 4 + $INT_NORMAL
$GRP_InstallTools.Width = $GRP_Essentials.Width
$GRP_InstallTools.Location = $GRP_Essentials.Location + "$($GRP_Essentials.Width + $INT_NORMAL), 0"
$TAB_INSTALLERS.Controls.Add($GRP_InstallTools)


$BTN_DownloadCCleaner = New-Object System.Windows.Forms.Button
$BTN_DownloadCCleaner.Text = 'CCleaner'
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadCCleaner.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
$BTN_DownloadCCleaner.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/ccsetup.exe'
        if ($CBOX_ExecuteCCleaner.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteCCleaner = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteCCleaner.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteCCleaner.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteCCleaner.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteCCleaner, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteCCleaner.Add_CheckStateChanged( {$BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_ExecuteCCleaner.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadDefraggler = New-Object System.Windows.Forms.Button
$BTN_DownloadDefraggler.Text = 'Defraggler'
$BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadDefraggler.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')
$BTN_DownloadDefraggler.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/dfsetup.exe'
        if ($CBOX_ExecuteDefraggler.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteDefraggler = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteDefraggler.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteDefraggler.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteDefraggler.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteDefraggler, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteDefraggler.Add_CheckStateChanged( {$BTN_DownloadDefraggler.Text = "Defraggler$(if ($CBOX_ExecuteDefraggler.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadRecuva = New-Object System.Windows.Forms.Button
$BTN_DownloadRecuva.Text = 'Recuva'
$BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_DownloadRecuva.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRecuva.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRecuva.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`rRecuva helps restore deleted files")
$BTN_DownloadRecuva.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/rcsetup.exe'
        if ($CBOX_ExecuteRecuva.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteRecuva = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteRecuva.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteRecuva.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteRecuva.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteRecuva, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteRecuva.Add_CheckStateChanged( {$BTN_DownloadRecuva.Text = "Recuva$(if ($CBOX_ExecuteRecuva.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadMalwarebytes = New-Object System.Windows.Forms.Button
$BTN_DownloadMalwarebytes.Text = 'Malwarebytes'
$BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_DownloadMalwarebytes.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadMalwarebytes.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_NORMAL
$BTN_DownloadMalwarebytes.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware")
$BTN_DownloadMalwarebytes.Add_Click( {
        $FileName = Start-Download 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe'
        if ($CBOX_ExecuteMalwarebytes.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteMalwarebytes = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteMalwarebytes.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteMalwarebytes.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteMalwarebytes, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteMalwarebytes.Add_CheckStateChanged( {$BTN_DownloadMalwarebytes.Text = "Malwarebytes$(if ($CBOX_ExecuteMalwarebytes.Checked) {$REQUIRES_ELEVATION})"} )


$GRP_InstallTools.Controls.AddRange(@(
        $BTN_DownloadCCleaner, $BTN_DownloadDefraggler, $BTN_DownloadRecuva, $BTN_DownloadMalwarebytes,
        $CBOX_ExecuteCCleaner, $CBOX_ExecuteDefraggler, $CBOX_ExecuteRecuva, $CBOX_ExecuteMalwarebytes
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads (Tools and ISO) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_TOOLS_AND_ISO = New-Object System.Windows.Forms.TabPage
$TAB_TOOLS_AND_ISO.Text = 'Downloads: Tools and ISO'
$TAB_TOOLS_AND_ISO.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_TOOLS_AND_ISO)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tools #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadTools = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadTools.Text = 'Tools'
$GRP_DownloadTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 3
$GRP_DownloadTools.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_DownloadTools.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_TOOLS_AND_ISO.Controls.Add($GRP_DownloadTools)


$BTN_DownloadSDI = New-Object System.Windows.Forms.Button
$BTN_DownloadSDI.Text = 'Snappy Driver Installer'
$BTN_DownloadSDI.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadSDI.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadSDI.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
$BTN_DownloadSDI.Add_Click( {
        $FileName = Start-Download 'sdi-tool.org/releases/SDI_R1811.zip'
        if ($CBOX_ExecuteSDI.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteSDI = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteSDI.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteSDI.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteSDI.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteSDI, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteSDI.Add_CheckStateChanged( {$BTN_DownloadSDI.Text = "Snappy Driver Installer$(if ($CBOX_ExecuteSDI.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadVictoria = New-Object System.Windows.Forms.Button
$BTN_DownloadVictoria.Text = 'Victoria'
$BTN_DownloadVictoria.Height = $BTN_HEIGHT
$BTN_DownloadVictoria.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadVictoria.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadVictoria.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
$BTN_DownloadVictoria.Add_Click( {
        $FileName = Start-Download 'qiiwexc.github.io/d/Victoria.zip'
        if ($CBOX_ExecuteVictoria.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteVictoria = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteVictoria.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteVictoria.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteVictoria.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteVictoria, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteVictoria.Add_CheckStateChanged( {$BTN_DownloadVictoria.Text = "Victoria$(if ($CBOX_ExecuteVictoria.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadRufus = New-Object System.Windows.Forms.Button
$BTN_DownloadRufus.Text = 'Rufus'
$BTN_DownloadRufus.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRufus.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRufus.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BTN_DownloadRufus.Add_Click( {
        $FileName = Start-Download 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe'
        if ($CBOX_ExecuteRufus.Checked -and $FileName) {Start-File $FileName '-g'}
    } )

$CBOX_ExecuteRufus = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteRufus.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteRufus.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteRufus.Location = $BTN_DownloadRufus.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteRufus, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteRufus.Add_CheckStateChanged( {$BTN_DownloadRufus.Text = "Rufus$(if ($CBOX_ExecuteRufus.Checked) {$REQUIRES_ELEVATION})"} )


$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadSDI, $BTN_DownloadVictoria, $BTN_DownloadRufus, $CBOX_ExecuteSDI, $CBOX_ExecuteVictoria, $CBOX_ExecuteRufus))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Activators #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Activators = New-Object System.Windows.Forms.GroupBox
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 2
$GRP_Activators.Width = $GRP_DownloadTools.Width
$GRP_Activators.Location = $GRP_DownloadTools.Location + "$($GRP_DownloadTools.Width + $INT_NORMAL), 0"
$TAB_TOOLS_AND_ISO.Controls.Add($GRP_Activators)


$BTN_DownloadKMSAuto = New-Object System.Windows.Forms.Button
$BTN_DownloadKMSAuto.Text = 'KMSAuto Lite'
$BTN_DownloadKMSAuto.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadKMSAuto.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadKMSAuto.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadKMSAuto.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/KMSAuto_Lite.zip'
        if ($CBOX_ExecuteKMSAuto.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteKMSAuto = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteKMSAuto.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteKMSAuto.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteKMSAuto, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteKMSAuto.Add_CheckStateChanged( {$BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_ExecuteKMSAuto.Checked) {$REQUIRES_ELEVATION})"} )


$BTN_DownloadChewWGA = New-Object System.Windows.Forms.Button
$BTN_DownloadChewWGA.Text = 'ChewWGA'
$BTN_DownloadChewWGA.Height = $BTN_HEIGHT
$BTN_DownloadChewWGA.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChewWGA.Location = $BTN_DownloadKMSAuto.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChewWGA.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChewWGA, "Download ChewWGA`rLast resort for activating hopeless Windows 7 cases`n`n$TXT_AV_WARNING")
$BTN_DownloadChewWGA.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/ChewWGA.zip'
        if ($CBOX_ExecuteChewWGA.Checked -and $FileName) {Start-File $FileName}
    } )

$CBOX_ExecuteChewWGA = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteChewWGA.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteChewWGA.Size = $CBOX_SIZE_DOWNLOAD
$CBOX_ExecuteChewWGA.Location = $BTN_DownloadChewWGA.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteChewWGA, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteChewWGA.Add_CheckStateChanged( {$BTN_DownloadChewWGA.Text = "ChewWGA$(if ($CBOX_ExecuteChewWGA.Checked) {$REQUIRES_ELEVATION})"} )


$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $BTN_DownloadChewWGA, $CBOX_ExecuteKMSAuto, $CBOX_ExecuteChewWGA))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Windows Images #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadsWindows = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsWindows.Text = 'Windows ISO Images'
$GRP_DownloadsWindows.Height = $INT_NORMAL + ($BTN_INT_SHORT + $CBOX_INT_SHORT) * 6
$GRP_DownloadsWindows.Width = $GRP_Activators.Width
$GRP_DownloadsWindows.Location = $GRP_Activators.Location + "$($GRP_Activators.Width + $INT_NORMAL), 0"
$TAB_TOOLS_AND_ISO.Controls.Add($GRP_DownloadsWindows)


$BTN_DownloadWindows10 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows10.Text = 'Windows 10'
$BTN_DownloadWindows10.Height = $BTN_HEIGHT
$BTN_DownloadWindows10.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows10.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadWindows10.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows10, 'Download Windows 10 (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image')
$BTN_DownloadWindows10.Add_Click( {Open-InBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )

$LBL_DownloadWindows10 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows10.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows10.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindows10.Location = $BTN_DownloadWindows10.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindows8 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows8.Text = 'Windows 8.1'
$BTN_DownloadWindows8.Height = $BTN_HEIGHT
$BTN_DownloadWindows8.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows8.Location = $BTN_DownloadWindows10.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindows8.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows8, 'Download Windows 8.1 with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image')
$BTN_DownloadWindows8.Add_Click( {Open-InBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )

$LBL_DownloadWindows8 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows8.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows8.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindows8.Location = $BTN_DownloadWindows8.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindows7 = New-Object System.Windows.Forms.Button
$BTN_DownloadWindows7.Text = 'Windows 7'
$BTN_DownloadWindows7.Height = $BTN_HEIGHT
$BTN_DownloadWindows7.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindows7.Location = $BTN_DownloadWindows8.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindows7.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image')
$BTN_DownloadWindows7.Add_Click( {Open-InBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )

$LBL_DownloadWindows7 = New-Object System.Windows.Forms.Label
$LBL_DownloadWindows7.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindows7.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindows7.Location = $BTN_DownloadWindows7.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindowsXPENG = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsXPENG.Text = 'Windows XP (ENG)'
$BTN_DownloadWindowsXPENG.Height = $BTN_HEIGHT
$BTN_DownloadWindowsXPENG.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsXPENG.Location = $BTN_DownloadWindows7.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsXPENG.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsXPENG, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$BTN_DownloadWindowsXPENG.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )

$LBL_DownloadWindowsXPENG = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsXPENG.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsXPENG.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindowsXPENG.Location = $BTN_DownloadWindowsXPENG.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindowsXPRUS = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsXPRUS.Text = 'Windows XP (RUS)'
$BTN_DownloadWindowsXPRUS.Height = $BTN_HEIGHT
$BTN_DownloadWindowsXPRUS.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsXPRUS.Location = $BTN_DownloadWindowsXPENG.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsXPRUS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsXPRUS, 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image')
$BTN_DownloadWindowsXPRUS.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )

$LBL_DownloadWindowsXPRUS = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsXPRUS.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsXPRUS.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindowsXPRUS.Location = $BTN_DownloadWindowsXPRUS.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$BTN_DownloadWindowsPE = New-Object System.Windows.Forms.Button
$BTN_DownloadWindowsPE.Text = 'Windows PE'
$BTN_DownloadWindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadWindowsPE.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadWindowsPE.Location = $BTN_DownloadWindowsXPRUS.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadWindowsPE.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadWindowsPE, 'Download Windows PE (Live CD) ISO image')
$BTN_DownloadWindowsPE.Add_Click( {Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )

$LBL_DownloadWindowsPE = New-Object System.Windows.Forms.Label
$LBL_DownloadWindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadWindowsPE.Size = $CBOX_SIZE_DOWNLOAD
$LBL_DownloadWindowsPE.Location = $BTN_DownloadWindowsPE.Location + $BTN_SHIFT_VER_SHORT + $LBL_SHIFT_BROWSER

$GRP_DownloadsWindows.Controls.AddRange(@(
        $BTN_DownloadWindows10, $LBL_DownloadWindows10, $BTN_DownloadWindows8, $LBL_DownloadWindows8, $BTN_DownloadWindows7, $LBL_DownloadWindows7,
        $BTN_DownloadWindowsXPENG, $LBL_DownloadWindowsXPENG, $BTN_DownloadWindowsXPRUS, $LBL_DownloadWindowsXPRUS, $BTN_DownloadWindowsPE, $LBL_DownloadWindowsPE
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Startup #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Initialize-Startup {
    $FORM.Activate()
    $Timestamp = (Get-Date).ToString()
    Write-Log "[$Timestamp] Initializing..."

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as administrator'
        $BTN_Elevate.Enabled = $False
    }

    Get-SystemInformation
    if ($PS_VERSION -lt 5) {Add-Log $WRN "PowerShell $PS_VERSION detected, while versions >=5 are supported. Some features might not work correctly."}

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Get-CurrentVersion

    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe

    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_OfficeInsider.Enabled = $BTN_UpdateOffice.Enabled

    $BTN_QuickSecurityScan.Enabled = Test-Path $DefenderExe
    $BTN_FullSecurityScan.Enabled = $BTN_QuickSecurityScan.Enabled

    Add-Type -AssemblyName System.IO.Compression.FileSystem
}


function Start-Elevated {
    if (-not $IS_ELEVATED) {
        try {Start-Process 'powershell' $MyInvocation.ScriptName -Verb RunAs}
        catch [Exception] {
            Add-Log $ERR "Failed to restart with administrator privileges: $($_.Exception.Message)"
            return
        }

        Exit-Script
    }
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Common #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Add-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) { $WRN {$LOG.SelectionColor = 'blue'} $ERR {$LOG.SelectionColor = 'red'} Default {$LOG.SelectionColor = 'black'} }
    Write-Log "`n$Text"
}


function Write-Log($Text) {
    Write-Host $Text -NoNewline
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function Set-Success {
    Write-Log(' ')
    $LogDefaultFont = $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)
    Write-Log('Done')
    $LOG.SelectionFont = $LogDefaultFont
}


function Get-Connection {return $(if (-not (Get-NetAdapter -Physical | Where-Object Status -eq 'Up')) {'Computer is not connected to the Internet'})}


function Exit-Script {$FORM.Close()}


function Open-InBrowser ($Url) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    Add-Log $INF "Openning URL in the default browser: $UrlToOpen"

    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Add-Log $ERR "Could not open the URL: $($_.Exception.Message)"}
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Self-Update #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Get-CurrentVersion {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Add-Log $INF 'Checking for updates...'

    $IsNotConnected = Get-Connection
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
        return
    }

    try {$LatestVersion = (Invoke-WebRequest $VersionURL).ToString() -Replace "`n", ''}
    catch [Exception] {
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    }
    else {Write-Log ' No updates available'}
}


function Get-Update {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    $IsNotConnected = Get-Connection
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        return
    }

    try {Invoke-WebRequest $DownloadURL -OutFile $TargetFile}
    catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Set-Success
    Add-Log $WRN 'Restarting...'

    try {Start-Process 'powershell' $TargetFile}
    catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    Exit-Script
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# System Information #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Get-SystemInformation {
    Add-Log $INF 'Gathering system information...'

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:OS_NAME = $OperatingSystem.Caption
    $script:OS_ARCH = $OperatingSystem.OSArchitecture
    $script:OS_VERSION = $OperatingSystem.Version
    $script:PS_VERSION = $PSVersionTable.PSVersion.Major

    $script:CURRENT_DIR = Split-Path ($MyInvocation.ScriptName)

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $script:GoogleUpdateExe = "$(if ($OS_ARCH -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"
    $script:OfficeC2RClientExe = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    $WordRegPath = Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue
    $script:OfficeVersion = if ($WordRegPath) {($WordRegPath.'(default)') -Replace '\D+', ''}
    $script:OfficeInstallType = if ($OfficeVersion) {if (Test-Path $OfficeC2RClientExe) {'C2R'} else {'MSI'}}

    Set-Success
}


function Out-SystemInformation {
    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = {'{0:N2}' -f ($_.TotalPhysicalMemory / 1GB)}}
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $LogicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $LogicalDisk | Select-Object @{L = 'FreeSpaceGB'; E = {'{0:N2}' -f ($_.FreeSpace / 1GB)}}, @{L = 'SizeGB'; E = {'{0:N2}' -f ($_.Size / 1GB)}}
    $OfficeYear = switch ($OfficeVersion) { 16 {'2016 / 2019'} 15 {'2013'} 14 {'2010'} 12 {'2007'} 11 {'2003'} }
    $OfficeName = if ($OfficeYear) {"Microsoft Office $OfficeYear"} else {'Unknown version or not installed'}

    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'
    Add-Log $INF "    Computer type:  $(switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    Add-Log $INF "    Computer manufacturer:  $($ComputerSystem.Manufacturer)"
    Add-Log $INF "    Computer model:  $($ComputerSystem.Model)"
    Add-Log $INF "    CPU name:  $($Processor.Name)"
    Add-Log $INF "    Cores / Threads:  $($Processor.NumberOfCores) / $($Processor.ThreadCount)"
    Add-Log $INF "    RAM available:  $($ComputerSystem.RAM) GB"
    Add-Log $INF "    GPU name:  $((Get-WmiObject Win32_VideoController).Name)"
    Add-Log $INF "    System drive model:  $(($LogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model)"
    Add-Log $INF "    System partition - free space: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($(($SystemPartition.FreeSpaceGB/$SystemPartition.SizeGB).tostring('P')))"
    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    OS version / build number:  v$((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) / $OS_VERSION"
    Add-Log $INF "    PowerShell version:  $PS_VERSION"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-GoogleUpdate {
    Add-Log $INF 'Starting Google Update...'

    try {Start-Process $GoogleUpdateExe '/c'}
    catch [Exception] {
        Add-Log $ERR "Google Update failed: $($_.Exception.Message)"
        return
    }

    try {Start-Process $GoogleUpdateExe '/ua /installsource scheduler'}
    catch [Exception] {
        Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    try {
        $Message = 'Updating Microsoft Store apps...'
        $Command = "(Get-WmiObject -Namespace 'root\cimv2\mdm\dmmap' -Class 'MDM_EnterpriseModernAppManagement_AppManagement01').UpdateScanMethod()"
        Start-Process 'powershell' "-Command `"Write-Host $Message; $Command`"" -Verb RunAs
    }
    catch [Exception] {
        Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Set-OfficeInsiderChannel {
    Add-Log $INF 'Switching Microsoft Office to insider update channel...'

    try {Start-Process $OfficeC2RClientExe '/changesetting Channel="Insiders"' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to switch Microsoft Office update channel: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try {Start-Process $OfficeC2RClientExe '/update user' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try {Start-Process 'UsoClient' 'StartInteractiveScan' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"
        return
    }

    Set-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-DriveCheck {
    Add-Log $INF 'Starting C: drive health check...'

    try {Start-Process 'chkdsk' '/scan' -Verb RunAs}
    catch [Exception] {
        Add-Log $ERR "Failed to check drive health: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try {Start-Process 'mdsched'}
    catch [Exception] {
        Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-SecurityScan ($Mode) {
    if (-not $Mode) {
        Add-Log $WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Add-Log $INF 'Updating security signatures...'

    try {Start-Process $DefenderExe '-SignatureUpdate' -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"
        return
    }

    Set-Success
    Add-Log $INF "Starting $Mode securtiy scan..."

    try {Start-Process $DefenderExe "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})"}
    catch [Exception] {
        Add-Log $ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Set-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Set-CloudFlareDNS {
    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF 'Changing DNS server to CloudFlare DNS (1.1.1.1 / 1.0.0.1)...'

    $CurrentNetworkAdapter = (Get-NetAdapter -Physical | Where-Object Status -eq 'Up').ifIndex

    if (-not $CurrentNetworkAdapter) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        return
    }

    try {
        $Message = 'Changing DNS server to CloudFlare DNS...'
        $Command = "Set-DnsClientServerAddress -InterfaceIndex $CurrentNetworkAdapter -ServerAddresses ('1.1.1.1', '1.0.0.1')"
        Start-Process 'powershell' "-Command `"Write-Host $Message; $Command`"" -Verb RunAs -Wait
    }
    catch [Exception] {
        Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-CCleaner {
    if (-not $CCleanerWarningShown) {
        Add-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Add-Log $WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Add-Log $INF 'Starting CCleaner background task...'

    try {Start-Process $CCleanerExe '/auto'}
    catch [Exception] {
        Add-Log $ERR "Failed to start CCleaner: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Remove-RestorePoints {
    Add-Log $INF 'Deleting all restore points...'

    try {Start-Process 'vssadmin' 'delete shadows /all' -Verb RunAs -Wait}
    catch [Exception] {
        Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"
        return
    }

    Set-Success
}


function Start-DriveOptimization {
    Add-Log $INF 'Starting drive optimization...'

    try {Start-Process 'defrag' '/C /H /U /O' -Verb RunAs}
    catch [Exception] {
        Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"
        return
    }

    Set-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Set-NiniteButtonState () {
    $BTN_DownloadNinite.Enabled = $CBOX_7zip.Checked -or $CBOX_VLC.Checked -or $CBOX_TeamViewer.Checked -or $CBOX_Skype.Checked -or `
        $CBOX_Chrome.Checked -or $CBOX_qBittorrent.Checked -or $CBOX_GoogleDrive.Checked -or $CBOX_VSCode.Checked
    $CBOX_ExecuteNinite.Enabled = $BTN_DownloadNinite.Enabled
}


function Build-NiniteQuery () {
    $Array = @()
    if ($CBOX_7zip.Checked) {$Array += $CBOX_7zip.Name}
    if ($CBOX_VLC.Checked) {$Array += $CBOX_VLC.Name}
    if ($CBOX_TeamViewer.Checked) {$Array += $CBOX_TeamViewer.Name}
    if ($CBOX_Skype.Checked) {$Array += $CBOX_Skype.Name}
    if ($CBOX_Chrome.Checked) {$Array += $CBOX_Chrome.Name}
    if ($CBOX_qBittorrent.Checked) {$Array += $CBOX_qBittorrent.Name}
    if ($CBOX_GoogleDrive.Checked) {$Array += $CBOX_GoogleDrive.Name}
    if ($CBOX_VSCode.Checked) {$Array += $CBOX_VSCode.Name}
    return $Array -Join '-'
}


function Build-NiniteFileName () {
    $Array = @()
    if ($CBOX_7zip.Checked) {$Array += $CBOX_7zip.Text}
    if ($CBOX_VLC.Checked) {$Array += $CBOX_VLC.Text}
    if ($CBOX_TeamViewer.Checked) {$Array += $CBOX_TeamViewer.Text}
    if ($CBOX_Skype.Checked) {$Array += $CBOX_Skype.Text}
    if ($CBOX_Chrome.Checked) {$Array += $CBOX_Chrome.Text}
    if ($CBOX_qBittorrent.Checked) {$Array += $CBOX_qBittorrent.Text}
    if ($CBOX_GoogleDrive.Checked) {$Array += $CBOX_GoogleDrive.Text}
    if ($CBOX_VSCode.Checked) {$Array += $CBOX_VSCode.Text}
    return "Ninite $($Array -Join ' ') Installer.exe"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Download and Execute #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-Download ($Url, $SaveAs) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'Download failed: No download URL specified'
        return
    }

    $DownloadURL = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    $FileName = if ($SaveAs) {$SaveAs} else {$DownloadURL | Split-Path -Leaf}
    $SavePath = "$CURRENT_DIR\$FileName"

    Add-Log $INF "Downloading from $DownloadURL"

    $IsNotConnected = Get-Connection
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        return
    }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) {Set-Success}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        return
    }

    return $FileName
}


function Start-File ($FileName, $Switches, $IsSilentInstall) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') {Start-Extraction $FileName} else {$FileName}

    if ($Switches -and $IsSilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try {Start-Process "$CURRENT_DIR\$Executable" $Switches -Wait}
        catch [Exception] {
            Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"
            return
        }

        Set-Success

        Add-Log $INF "Removing $FileName..."
        Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
        Set-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {if ($Switches) {Start-Process "$CURRENT_DIR\$Executable" $Switches} else {Start-Process "$CURRENT_DIR\$Executable"}}
        catch [Exception] {
            Add-Log $ERR "Failed to execute' $Executable': $($_.Exception.Message)"
            return
        }

        Set-Success
    }
}


function Start-Extraction ($FileName) {
    Add-Log $INF "Extracting $FileName..."

    $ExtractionPath = if ($FileName -eq 'KMSAuto_Lite.zip' -or $FileName -match 'SDI_R*') {$FileName.trimend('.zip')}

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' {$Executable = 'CW.eXe'}
        'Office_2013-2019.zip' {$Executable = 'OInstall.exe'}
        'Victoria.zip' {$Executable = 'Victoria.exe'}
        'KMSAuto_Lite.zip' {$Executable = if ($OS_ARCH -eq '64-bit') {'KMSAuto x64.exe'} else {'KMSAuto.exe'}}
        'SDI_R*' {$Executable = "$ExtractionPath\SDI_auto.bat"}
    }

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath) {Remove-Item $TargetDirName -Recurse -ErrorAction Ignore}

    try {[System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName)}
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        return
    }

    if ($FileName -eq 'KMSAuto_Lite.zip') {
        $TempDir = $TargetDirName
        $TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Set-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
    Set-Success

    return $Executable
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Draw Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM.ShowDialog() | Out-Null
