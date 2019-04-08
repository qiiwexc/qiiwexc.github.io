$VERSION = '19.4.9'


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

$INF = 'INF'
$WRN = 'WRN'
$ERR = 'ERR'

$REQUIRES_ELEVATION = if (-not $IS_ELEVATED) { ' *' }

$FORM_WIDTH = 670
$FORM_HEIGHT = 625

$BTN_WIDTH = 167
$BTN_HEIGHT = 28

$CBOX_WIDTH = 145
$CBOX_HEIGHT = 20
$CBOX_SIZE = "$CBOX_WIDTH, $CBOX_HEIGHT"

$INT_SHORT = 5
$INT_NORMAL = 15
$INT_LONG = 30
$INT_TAB_ADJ = 4
$INT_GROUP_TOP = 20

$INT_BTN_SHORT = $BTN_HEIGHT + $INT_SHORT
$INT_BTN_NORMAL = $BTN_HEIGHT + $INT_NORMAL
$INT_BTN_LONG = $BTN_HEIGHT + $INT_LONG

$INT_CBOX_SHORT = $CBOX_HEIGHT + $INT_SHORT
$INT_CBOX_NORMAL = $CBOX_HEIGHT + $INT_NORMAL

$GRP_WIDTH = $INT_NORMAL + $BTN_WIDTH + $INT_NORMAL

$BTN_INIT_LOCATION = "$INT_NORMAL, $INT_GROUP_TOP"
$GRP_INIT_LOCATION = "$INT_NORMAL, $INT_NORMAL"

$SHIFT_BTN_SHORT = "0, $INT_BTN_SHORT"
$SHIFT_BTN_NORMAL = "0, $INT_BTN_NORMAL"
$SHIFT_BTN_LONG = "0, $INT_BTN_LONG"

$SHIFT_CBOX_SHORT = "0, $INT_CBOX_SHORT"
$SHIFT_CBOX_NORMAL = "0, $INT_CBOX_NORMAL"
$SHIFT_CBOX_EXECUTE = "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)"

$SHIFT_GRP_HOR_NORMAL = "$($GRP_WIDTH + $INT_NORMAL), 0"

$SHIFT_LBL_BROWSER = "$INT_LONG, $($INT_BTN_SHORT - $INT_SHORT)"

$FONT_NAME = 'Microsoft Sans Serif'
$BTN_FONT = "$FONT_NAME, 10"

$TXT_START_AFTER_DOWNLOAD = 'Start after download'
$TXT_OPENS_IN_BROWSER = 'Opens in the browser'
$TXT_AV_WARNING = "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!"

$TIP_START_AFTER_DOWNLOAD = "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM = New-Object System.Windows.Forms.Form
$FORM.Text = "qiiwexc v$VERSION"
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )


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
$GRP_ThisUtility.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_ThisUtility.Width = $GRP_WIDTH
$GRP_ThisUtility.Location = $GRP_INIT_LOCATION
$TAB_HOME.Controls.Add($GRP_ThisUtility)


$BTN_Elevate = New-Object System.Windows.Forms.Button
$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_WIDTH
$BTN_Elevate.Location = $BTN_INIT_LOCATION
$BTN_Elevate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
$BTN_Elevate.Add_Click( { Start-Elevated } )


$BTN_BrowserHome = New-Object System.Windows.Forms.Button
$BTN_BrowserHome.Text = 'Open in the browser'
$BTN_BrowserHome.Height = $BTN_HEIGHT
$BTN_BrowserHome.Width = $BTN_WIDTH
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $SHIFT_BTN_NORMAL
$BTN_BrowserHome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
$BTN_BrowserHome.Add_Click( { Open-InBrowser 'qiiwexc.github.io' } )


$BTN_SystemInfo = New-Object System.Windows.Forms.Button
$BTN_SystemInfo.Text = 'System information'
$BTN_SystemInfo.Height = $BTN_HEIGHT
$BTN_SystemInfo.Width = $BTN_WIDTH
$BTN_SystemInfo.Location = $BTN_BrowserHome.Location + $SHIFT_BTN_NORMAL
$BTN_SystemInfo.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInfo, 'Print system information to the log')
$BTN_SystemInfo.Add_Click( { Out-SystemInfo } )


$GRP_ThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInfo))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Activators #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Activators = New-Object System.Windows.Forms.GroupBox
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Activators.Width = $GRP_WIDTH
$GRP_Activators.Location = $GRP_ThisUtility.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_Activators)


$BTN_DownloadKMSAuto = New-Object System.Windows.Forms.Button
$BTN_DownloadKMSAuto.Text = 'KMSAuto Lite'
$BTN_DownloadKMSAuto.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_WIDTH
$BTN_DownloadKMSAuto.Location = $BTN_INIT_LOCATION
$BTN_DownloadKMSAuto.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadKMSAuto.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/KMSAuto_Lite.zip'
        if ($CBOX_StartKMSAuto.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartKMSAuto = New-Object System.Windows.Forms.CheckBox
$CBOX_StartKMSAuto.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartKMSAuto.Size = $CBOX_SIZE
$CBOX_StartKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartKMSAuto, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartKMSAuto.Add_CheckStateChanged( { $BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadAAct = New-Object System.Windows.Forms.Button
$BTN_DownloadAAct.Text = 'AAct (Win 7+, Office)'
$BTN_DownloadAAct.Height = $BTN_HEIGHT
$BTN_DownloadAAct.Width = $BTN_WIDTH
$BTN_DownloadAAct.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_BTN_LONG
$BTN_DownloadAAct.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadAAct, "Download AAct`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadAAct.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/AAct.zip'
        if ($CBOX_StartAAct.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartAAct = New-Object System.Windows.Forms.CheckBox
$CBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartAAct.Size = $CBOX_SIZE
$CBOX_StartAAct.Location = $BTN_DownloadAAct.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartAAct, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartAAct.Add_CheckStateChanged( { $BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadChewWGA = New-Object System.Windows.Forms.Button
$BTN_DownloadChewWGA.Text = 'ChewWGA (Win 7)'
$BTN_DownloadChewWGA.Height = $BTN_HEIGHT
$BTN_DownloadChewWGA.Width = $BTN_WIDTH
$BTN_DownloadChewWGA.Location = $BTN_DownloadAAct.Location + $SHIFT_BTN_LONG
$BTN_DownloadChewWGA.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChewWGA, "Download ChewWGA`rLast resort for activating hopeless Windows 7 cases`n`n$TXT_AV_WARNING")
$BTN_DownloadChewWGA.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $FileName = Start-Download 'qiiwexc.github.io/d/ChewWGA.zip'
        if ($CBOX_StartChewWGA.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartChewWGA = New-Object System.Windows.Forms.CheckBox
$CBOX_StartChewWGA.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartChewWGA.Size = $CBOX_SIZE
$CBOX_StartChewWGA.Location = $BTN_DownloadChewWGA.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartChewWGA, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartChewWGA.Add_CheckStateChanged( { $BTN_DownloadChewWGA.Text = "ChewWGA (Win 7)$(if ($CBOX_StartChewWGA.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $CBOX_StartKMSAuto, $BTN_DownloadAAct, $CBOX_StartAAct, $BTN_DownloadChewWGA, $CBOX_StartChewWGA))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home - Tools (General) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadTools = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadTools.Text = 'Tools (General)'
$GRP_DownloadTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadTools.Width = $GRP_WIDTH
$GRP_DownloadTools.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadTools)


$BTN_DownloadChrome = New-Object System.Windows.Forms.Button
$BTN_DownloadChrome.Text = 'Chrome Beta'
$BTN_DownloadChrome.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_WIDTH
$BTN_DownloadChrome.Location = $BTN_INIT_LOCATION
$BTN_DownloadChrome.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Open Google Chrome Beta download page')
$BTN_DownloadChrome.Add_Click( { Open-InBrowser 'google.com/chrome/beta' } )

$LBL_DownloadChrome = New-Object System.Windows.Forms.Label
$LBL_DownloadChrome.Text = $TXT_OPENS_IN_BROWSER
$LBL_DownloadChrome.Size = $CBOX_SIZE
$LBL_DownloadChrome.Location = $BTN_DownloadChrome.Location + $SHIFT_LBL_BROWSER


$BTN_DownloadRufus = New-Object System.Windows.Forms.Button
$BTN_DownloadRufus.Text = 'Rufus (bootable USB)'
$BTN_DownloadRufus.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WIDTH
$BTN_DownloadRufus.Location = $BTN_DownloadChrome.Location + $SHIFT_BTN_LONG
$BTN_DownloadRufus.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BTN_DownloadRufus.Add_Click( {
        $FileName = Start-Download 'github.com/pbatard/rufus/releases/download/v3.5/rufus-3.5p.exe'
        if ($CBOX_StartRufus.Checked -and $FileName) { Start-File $FileName '-g' }
    } )

$CBOX_StartRufus = New-Object System.Windows.Forms.CheckBox
$CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRufus.Size = $CBOX_SIZE
$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE = New-Object System.Windows.Forms.Button
$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_WindowsPE.Width = $BTN_WIDTH
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 8')
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_' } )

$LBL_WindowsPE = New-Object System.Windows.Forms.Label
$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Size = $CBOX_SIZE
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER


$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadChrome, $LBL_DownloadChrome, $BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_INSTALLERS = New-Object System.Windows.Forms.TabPage
$TAB_INSTALLERS.Text = 'Downloads'
$TAB_INSTALLERS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_INSTALLERS)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Ninite = New-Object System.Windows.Forms.GroupBox
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_GROUP_TOP + $INT_CBOX_SHORT * 8 + $INT_SHORT + $INT_BTN_LONG * 2
$GRP_Ninite.Width = $GRP_WIDTH
$GRP_Ninite.Location = $GRP_INIT_LOCATION
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)


$CBOX_Chrome = New-Object System.Windows.Forms.CheckBox
$CBOX_Chrome.Text = "Google Chrome"
$CBOX_Chrome.Name = "chrome"
$CBOX_Chrome.Checked = $True
$CBOX_Chrome.Size = $CBOX_SIZE
$CBOX_Chrome.Location = $BTN_INIT_LOCATION
$CBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_7zip = New-Object System.Windows.Forms.CheckBox
$CBOX_7zip.Text = "7-Zip"
$CBOX_7zip.Name = "7zip"
$CBOX_7zip.Checked = $True
$CBOX_7zip.Size = $CBOX_SIZE
$CBOX_7zip.Location = $CBOX_Chrome.Location + $SHIFT_CBOX_SHORT
$CBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VLC = New-Object System.Windows.Forms.CheckBox
$CBOX_VLC.Text = "VLC"
$CBOX_VLC.Name = "vlc"
$CBOX_VLC.Checked = $True
$CBOX_VLC.Size = $CBOX_SIZE
$CBOX_VLC.Location = $CBOX_7zip.Location + $SHIFT_CBOX_SHORT
$CBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_TeamViewer = New-Object System.Windows.Forms.CheckBox
$CBOX_TeamViewer.Text = "TeamViewer"
$CBOX_TeamViewer.Name = "teamviewer14"
$CBOX_TeamViewer.Checked = $True
$CBOX_TeamViewer.Size = $CBOX_SIZE
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $SHIFT_CBOX_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Skype = New-Object System.Windows.Forms.CheckBox
$CBOX_Skype.Text = "Skype"
$CBOX_Skype.Name = "skype"
$CBOX_Skype.Checked = $True
$CBOX_Skype.Size = $CBOX_SIZE
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $SHIFT_CBOX_SHORT
$CBOX_Skype.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_qBittorrent = New-Object System.Windows.Forms.CheckBox
$CBOX_qBittorrent.Text = "qBittorrent"
$CBOX_qBittorrent.Name = "qbittorrent"
$CBOX_qBittorrent.Size = $CBOX_SIZE
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $SHIFT_CBOX_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_GoogleDrive = New-Object System.Windows.Forms.CheckBox
$CBOX_GoogleDrive.Text = "Google Drive"
$CBOX_GoogleDrive.Name = "googlebackupandsync"
$CBOX_GoogleDrive.Size = $CBOX_SIZE
$CBOX_GoogleDrive.Location = $CBOX_qBittorrent.Location + $SHIFT_CBOX_SHORT
$CBOX_GoogleDrive.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VSCode = New-Object System.Windows.Forms.CheckBox
$CBOX_VSCode.Text = "Visual Studio Code"
$CBOX_VSCode.Name = "vscode"
$CBOX_VSCode.Size = $CBOX_SIZE
$CBOX_VSCode.Location = $CBOX_GoogleDrive.Location + $SHIFT_CBOX_SHORT
$CBOX_VSCode.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BTN_DownloadNinite = New-Object System.Windows.Forms.Button
$BTN_DownloadNinite.Text = 'Download selected'
$BTN_DownloadNinite.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_WIDTH
$BTN_DownloadNinite.Location = $CBOX_VSCode.Location + $SHIFT_BTN_SHORT
$BTN_DownloadNinite.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
$BTN_DownloadNinite.Add_Click( {
        $FileName = Start-Download "https://ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName)
        if ($CBOX_StartNinite.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartNinite = New-Object System.Windows.Forms.CheckBox
$CBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartNinite.Size = $CBOX_SIZE
$CBOX_StartNinite.Location = $BTN_DownloadNinite.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartNinite, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartNinite.Add_CheckStateChanged( { $BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_OpenNiniteInBrowser = New-Object System.Windows.Forms.Button
$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $SHIFT_BTN_LONG
$BTN_OpenNiniteInBrowser.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
$BTN_OpenNiniteInBrowser.Add_Click( {
        $Query = Set-NiniteQuery
        Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )

$LBL_OpenNiniteInBrowser = New-Object System.Windows.Forms.Label
$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $SHIFT_LBL_BROWSER


$GRP_Ninite.Controls.AddRange(@(
        $BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_StartNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_GoogleDrive, $CBOX_VSCode
    ))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Essentials #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

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
        $FileName = Start-Download 'sdi-tool.org/releases/SDI_R1904.zip'
        if ($CBOX_StartSDI.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartSDI = New-Object System.Windows.Forms.CheckBox
$CBOX_StartSDI.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartSDI.Size = $CBOX_SIZE
$CBOX_StartSDI.Location = $BTN_DownloadSDI.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartSDI, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartSDI.Add_CheckStateChanged( { $BTN_DownloadSDI.Text = "Snappy Driver Installer$(if ($CBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )


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
            Start-File $FileName $(if ($CBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' }) -IsSilentInstall $True
        }
    } )

$CBOX_StartUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_StartUnchecky.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartUnchecky.Size = $CBOX_SIZE
$CBOX_StartUnchecky.Location = $BTN_DownloadUnchecky.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartUnchecky, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartUnchecky.Add_CheckStateChanged( { $CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_StartUnchecky.Checked } )

$CBOX_SilentlyInstallUnchecky = New-Object System.Windows.Forms.CheckBox
$CBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CBOX_SilentlyInstallUnchecky.Enabled = $False
$CBOX_SilentlyInstallUnchecky.Size = $CBOX_SIZE
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_StartUnchecky.Location + "0, $CBOX_HEIGHT"
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SilentlyInstallUnchecky, 'Perform silent installation with no prompts')
$CBOX_StartUnchecky.Add_CheckStateChanged( { $BTN_DownloadUnchecky.Text = "Unchecky$(if ($CBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )


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
        if ($CBOX_StartOffice.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartOffice = New-Object System.Windows.Forms.CheckBox
$CBOX_StartOffice.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartOffice.Size = $CBOX_SIZE
$CBOX_StartOffice.Location = $BTN_DownloadOffice.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartOffice, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartOffice.Add_CheckStateChanged( { $BTN_DownloadOffice.Text = "Office 2013 - 2019$(if ($CBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_Essentials.Controls.AddRange(
    @($BTN_DownloadSDI, $CBOX_StartSDI, $BTN_DownloadUnchecky, $CBOX_StartUnchecky, $CBOX_SilentlyInstallUnchecky, $BTN_DownloadOffice, $CBOX_StartOffice)
)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Tools #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_InstallTools = New-Object System.Windows.Forms.GroupBox
$GRP_InstallTools.Text = 'Tools'
$GRP_InstallTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_InstallTools.Width = $GRP_WIDTH
$GRP_InstallTools.Location = $GRP_Essentials.Location + "0, $($GRP_Essentials.Height + $INT_NORMAL)"
$TAB_INSTALLERS.Controls.Add($GRP_InstallTools)


$BTN_DownloadCCleaner = New-Object System.Windows.Forms.Button
$BTN_DownloadCCleaner.Text = 'CCleaner'
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH
$BTN_DownloadCCleaner.Location = $BTN_INIT_LOCATION
$BTN_DownloadCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
$BTN_DownloadCCleaner.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/ccsetup.exe'
        if ($CBOX_StartCCleaner.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartCCleaner = New-Object System.Windows.Forms.CheckBox
$CBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartCCleaner.Size = $CBOX_SIZE
$CBOX_StartCCleaner.Location = $BTN_DownloadCCleaner.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartCCleaner, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartCCleaner.Add_CheckStateChanged( { $BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadDefraggler = New-Object System.Windows.Forms.Button
$BTN_DownloadDefraggler.Text = 'Defraggler'
$BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadDefraggler.Width = $BTN_WIDTH
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $SHIFT_BTN_LONG
$BTN_DownloadDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')
$BTN_DownloadDefraggler.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/dfsetup.exe'
        if ($CBOX_StartDefraggler.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartDefraggler = New-Object System.Windows.Forms.CheckBox
$CBOX_StartDefraggler.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartDefraggler.Size = $CBOX_SIZE
$CBOX_StartDefraggler.Location = $BTN_DownloadDefraggler.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartDefraggler, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartDefraggler.Add_CheckStateChanged( { $BTN_DownloadDefraggler.Text = "Defraggler$(if ($CBOX_StartDefraggler.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_InstallTools.Controls.AddRange(@($BTN_DownloadCCleaner, $CBOX_StartCCleaner, $BTN_DownloadDefraggler, $CBOX_StartDefraggler))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads - Windows Images #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_DownloadWindows = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadWindows.Text = 'Windows Images'
$GRP_DownloadWindows.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 5 + $INT_SHORT
$GRP_DownloadWindows.Width = $GRP_WIDTH
$GRP_DownloadWindows.Location = $GRP_Essentials.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_DownloadWindows)


$BTN_Windows10 = New-Object System.Windows.Forms.Button
$BTN_Windows10.Text = 'Windows 10 (v1809)'
$BTN_Windows10.Height = $BTN_HEIGHT
$BTN_Windows10.Width = $BTN_WIDTH
$BTN_Windows10.Location = $BTN_INIT_LOCATION
$BTN_Windows10.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows10, 'Download Windows 10 (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image')
$BTN_Windows10.Add_Click( { Open-InBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html' } )

$LBL_Windows10 = New-Object System.Windows.Forms.Label
$LBL_Windows10.Text = $TXT_OPENS_IN_BROWSER
$LBL_Windows10.Size = $CBOX_SIZE
$LBL_Windows10.Location = $BTN_Windows10.Location + $SHIFT_LBL_BROWSER

$BTN_Windows8 = New-Object System.Windows.Forms.Button
$BTN_Windows8.Text = 'Windows 8.1 (Update 3)'
$BTN_Windows8.Height = $BTN_HEIGHT
$BTN_Windows8.Width = $BTN_WIDTH
$BTN_Windows8.Location = $BTN_Windows10.Location + $SHIFT_BTN_LONG
$BTN_Windows8.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows8, 'Download Windows 8.1 with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image')
$BTN_Windows8.Add_Click( { Open-InBrowser 'rutracker.org/forum/viewtopic.php?t=5109222' } )

$LBL_Windows8 = New-Object System.Windows.Forms.Label
$LBL_Windows8.Text = $TXT_OPENS_IN_BROWSER
$LBL_Windows8.Size = $CBOX_SIZE
$LBL_Windows8.Location = $BTN_Windows8.Location + $SHIFT_LBL_BROWSER

$BTN_Windows7 = New-Object System.Windows.Forms.Button
$BTN_Windows7.Text = 'Windows 7 SP1'
$BTN_Windows7.Height = $BTN_HEIGHT
$BTN_Windows7.Width = $BTN_WIDTH
$BTN_Windows7.Location = $BTN_Windows8.Location + $SHIFT_BTN_LONG
$BTN_Windows7.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image')
$BTN_Windows7.Add_Click( { Open-InBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html' } )

$LBL_Windows7 = New-Object System.Windows.Forms.Label
$LBL_Windows7.Text = $TXT_OPENS_IN_BROWSER
$LBL_Windows7.Size = $CBOX_SIZE
$LBL_Windows7.Location = $BTN_Windows7.Location + $SHIFT_LBL_BROWSER


$BTN_WindowsXPENG = New-Object System.Windows.Forms.Button
$BTN_WindowsXPENG.Text = 'Windows XP SP3 (ENG)'
$BTN_WindowsXPENG.Height = $BTN_HEIGHT
$BTN_WindowsXPENG.Width = $BTN_WIDTH
$BTN_WindowsXPENG.Location = $BTN_Windows7.Location + $SHIFT_BTN_NORMAL + $SHIFT_CBOX_SHORT
$BTN_WindowsXPENG.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXPENG, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$BTN_WindowsXPENG.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF' } )

$LBL_WindowsXPENG = New-Object System.Windows.Forms.Label
$LBL_WindowsXPENG.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsXPENG.Size = $CBOX_SIZE
$LBL_WindowsXPENG.Location = $BTN_WindowsXPENG.Location + $SHIFT_LBL_BROWSER

$BTN_WindowsXPRUS = New-Object System.Windows.Forms.Button
$BTN_WindowsXPRUS.Text = 'Windows XP SP3 (RUS)'
$BTN_WindowsXPRUS.Height = $BTN_HEIGHT
$BTN_WindowsXPRUS.Width = $BTN_WIDTH
$BTN_WindowsXPRUS.Location = $BTN_WindowsXPENG.Location + $SHIFT_BTN_LONG
$BTN_WindowsXPRUS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXPRUS, 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image')
$BTN_WindowsXPRUS.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR' } )

$LBL_WindowsXPRUS = New-Object System.Windows.Forms.Label
$LBL_WindowsXPRUS.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsXPRUS.Size = $CBOX_SIZE
$LBL_WindowsXPRUS.Location = $BTN_WindowsXPRUS.Location + $SHIFT_LBL_BROWSER


$GRP_DownloadWindows.Controls.AddRange(
    @($BTN_Windows10, $LBL_Windows10, $BTN_Windows8, $LBL_Windows8, $BTN_Windows7, $LBL_Windows7, $BTN_WindowsXPENG, $LBL_WindowsXPENG, $BTN_WindowsXPRUS, $LBL_WindowsXPRUS)
)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_DIAGNOSTICS = New-Object System.Windows.Forms.TabPage
$TAB_DIAGNOSTICS.Text = 'Diagnostics'
$TAB_DIAGNOSTICS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_DIAGNOSTICS)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics - HDD and RAM #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_HDDandRAM = New-Object System.Windows.Forms.GroupBox
$GRP_HDDandRAM.Text = 'HDD and RAM'
$GRP_HDDandRAM.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2 + $INT_BTN_NORMAL * 2
$GRP_HDDandRAM.Width = $GRP_WIDTH
$GRP_HDDandRAM.Location = $GRP_INIT_LOCATION
$TAB_DIAGNOSTICS.Controls.Add($GRP_HDDandRAM)


$BTN_CheckDrive = New-Object System.Windows.Forms.Button
$BTN_CheckDrive.Text = "Check (C:) drive health$REQUIRES_ELEVATION"
$BTN_CheckDrive.Height = $BTN_HEIGHT
$BTN_CheckDrive.Width = $BTN_WIDTH
$BTN_CheckDrive.Location = $BTN_INIT_LOCATION
$BTN_CheckDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDrive, 'Perform a (C:) drive health check')
$BTN_CheckDrive.Add_Click( { Start-DriveCheck } )


$BTN_DownloadVictoria = New-Object System.Windows.Forms.Button
$BTN_DownloadVictoria.Text = 'Victoria (HDD scan)'
$BTN_DownloadVictoria.Height = $BTN_HEIGHT
$BTN_DownloadVictoria.Width = $BTN_WIDTH
$BTN_DownloadVictoria.Location = $BTN_CheckDrive.Location + $SHIFT_BTN_NORMAL
$BTN_DownloadVictoria.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
$BTN_DownloadVictoria.Add_Click( {
        $FileName = Start-Download 'qiiwexc.github.io/d/Victoria.zip'
        if ($CBOX_StartVictoria.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartVictoria = New-Object System.Windows.Forms.CheckBox
$CBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartVictoria.Size = $CBOX_SIZE
$CBOX_StartVictoria.Location = $BTN_DownloadVictoria.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartVictoria.Add_CheckStateChanged( { $BTN_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRecuva = New-Object System.Windows.Forms.Button
$BTN_DownloadRecuva.Text = 'Recuva (restore data)'
$BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_DownloadRecuva.Width = $BTN_WIDTH
$BTN_DownloadRecuva.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_DownloadRecuva.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`rRecuva helps restore deleted files")
$BTN_DownloadRecuva.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/rcsetup.exe'
        if ($CBOX_StartRecuva.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartRecuva = New-Object System.Windows.Forms.CheckBox
$CBOX_StartRecuva.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRecuva.Size = $CBOX_SIZE
$CBOX_StartRecuva.Location = $BTN_DownloadRecuva.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRecuva, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartRecuva.Add_CheckStateChanged( { $BTN_DownloadRecuva.Text = "Recuva (restore data)$(if ($CBOX_StartRecuva.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_CheckRAM = New-Object System.Windows.Forms.Button
$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Height = $BTN_HEIGHT
$BTN_CheckRAM.Width = $BTN_WIDTH
$BTN_CheckRAM.Location = $BTN_DownloadRecuva.Location + $SHIFT_BTN_LONG
$BTN_CheckRAM.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )


$GRP_HDDandRAM.Controls.AddRange(@($BTN_CheckDrive, $BTN_DownloadVictoria, $CBOX_StartVictoria, $BTN_DownloadRecuva, $CBOX_StartRecuva, $BTN_CheckRAM))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics - Other Hardware #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Hardware = New-Object System.Windows.Forms.GroupBox
$GRP_Hardware.Text = 'Other hardware'
$GRP_Hardware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Hardware.Width = $GRP_WIDTH
$GRP_Hardware.Location = $GRP_HDDandRAM.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Hardware)


$BTN_CheckKeyboard = New-Object System.Windows.Forms.Button
$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Height = $BTN_HEIGHT
$BTN_CheckKeyboard.Width = $BTN_WIDTH
$BTN_CheckKeyboard.Location = $BTN_INIT_LOCATION
$BTN_CheckKeyboard.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')
$BTN_CheckKeyboard.Add_Click( { Open-InBrowser 'onlinemictest.com/keyboard-test' } )

$LBL_CheckKeyboard = New-Object System.Windows.Forms.Label
$LBL_CheckKeyboard.Text = $TXT_OPENS_IN_BROWSER
$LBL_CheckKeyboard.Size = $CBOX_SIZE
$LBL_CheckKeyboard.Location = $BTN_CheckKeyboard.Location + $SHIFT_LBL_BROWSER


$BTN_CheckMic = New-Object System.Windows.Forms.Button
$BTN_CheckMic.Text = 'Check microphone'
$BTN_CheckMic.Height = $BTN_HEIGHT
$BTN_CheckMic.Width = $BTN_WIDTH
$BTN_CheckMic.Location = $BTN_CheckKeyboard.Location + $SHIFT_BTN_LONG
$BTN_CheckMic.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMic, 'Open webpage with a microphone test')
$BTN_CheckMic.Add_Click( { Open-InBrowser 'onlinemictest.com' } )

$LBL_CheckMic = New-Object System.Windows.Forms.Label
$LBL_CheckMic.Text = $TXT_OPENS_IN_BROWSER
$LBL_CheckMic.Size = $CBOX_SIZE
$LBL_CheckMic.Location = $BTN_CheckMic.Location + $SHIFT_LBL_BROWSER


$BTN_CheckWebCam = New-Object System.Windows.Forms.Button
$BTN_CheckWebCam.Text = 'Check webcam'
$BTN_CheckWebCam.Height = $BTN_HEIGHT
$BTN_CheckWebCam.Width = $BTN_WIDTH
$BTN_CheckWebCam.Location = $BTN_CheckMic.Location + $SHIFT_BTN_LONG
$BTN_CheckWebCam.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWebCam, 'Open webpage with a webcam test')
$BTN_CheckWebCam.Add_Click( { Open-InBrowser 'onlinemictest.com/webcam-test' } )

$LBL_CheckWebCam = New-Object System.Windows.Forms.Label
$LBL_CheckWebCam.Text = $TXT_OPENS_IN_BROWSER
$LBL_CheckWebCam.Size = $CBOX_SIZE
$LBL_CheckWebCam.Location = $BTN_CheckWebCam.Location + $SHIFT_LBL_BROWSER


$GRP_Hardware.Controls.AddRange(@($BTN_CheckKeyboard, $LBL_CheckKeyboard, $BTN_CheckMic, $LBL_CheckMic, $BTN_CheckWebCam, $LBL_CheckWebCam))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics - Windows #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Windows = New-Object System.Windows.Forms.GroupBox
$GRP_Windows.Text = 'Windows'
$GRP_Windows.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Windows.Width = $GRP_WIDTH
$GRP_Windows.Location = $GRP_Hardware.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Windows)


$BTN_CheckWindowsHealth = New-Object System.Windows.Forms.Button
$BTN_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BTN_CheckWindowsHealth.Height = $BTN_HEIGHT
$BTN_CheckWindowsHealth.Width = $BTN_WIDTH
$BTN_CheckWindowsHealth.Location = $BTN_INIT_LOCATION
$BTN_CheckWindowsHealth.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWindowsHealth, 'Check Windows health')
$BTN_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )


$BTN_RepairWindows = New-Object System.Windows.Forms.Button
$BTN_RepairWindows.Text = "Repair Windows$REQUIRES_ELEVATION"
$BTN_RepairWindows.Height = $BTN_HEIGHT
$BTN_RepairWindows.Width = $BTN_WIDTH
$BTN_RepairWindows.Location = $BTN_CheckWindowsHealth.Location + $SHIFT_BTN_NORMAL
$BTN_RepairWindows.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RepairWindows, 'Attempt to restore Windows health')
$BTN_RepairWindows.Add_Click( { Repair-Windows } )


$BTN_CheckSystemFiles = New-Object System.Windows.Forms.Button
$BTN_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BTN_CheckSystemFiles.Height = $BTN_HEIGHT
$BTN_CheckSystemFiles.Width = $BTN_WIDTH
$BTN_CheckSystemFiles.Location = $BTN_RepairWindows.Location + $SHIFT_BTN_NORMAL
$BTN_CheckSystemFiles.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckSystemFiles, 'Check system file integrity')
$BTN_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )


$GRP_Windows.Controls.AddRange(@($BTN_CheckWindowsHealth, $BTN_RepairWindows, $BTN_CheckSystemFiles))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Diagnostics - Security #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Malware = New-Object System.Windows.Forms.GroupBox
$GRP_Malware.Text = 'Security'
$GRP_Malware.Height = $INT_GROUP_TOP + $INT_BTN_SHORT + $INT_BTN_NORMAL + $INT_BTN_LONG
$GRP_Malware.Width = $GRP_WIDTH
$GRP_Malware.Location = $GRP_Windows.Location + "0, $($GRP_Windows.Height + $INT_NORMAL)"
$TAB_DIAGNOSTICS.Controls.Add($GRP_Malware)


$BTN_QuickSecurityScan = New-Object System.Windows.Forms.Button
$BTN_QuickSecurityScan.Text = 'Quick security scan'
$BTN_QuickSecurityScan.Height = $BTN_HEIGHT
$BTN_QuickSecurityScan.Width = $BTN_WIDTH
$BTN_QuickSecurityScan.Location = $BTN_INIT_LOCATION
$BTN_QuickSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_QuickSecurityScan, 'Perform a quick security scan')
$BTN_QuickSecurityScan.Add_Click( { Start-SecurityScan 'quick' } )

$BTN_FullSecurityScan = New-Object System.Windows.Forms.Button
$BTN_FullSecurityScan.Text = 'Full security scan'
$BTN_FullSecurityScan.Height = $BTN_HEIGHT
$BTN_FullSecurityScan.Width = $BTN_WIDTH
$BTN_FullSecurityScan.Location = $BTN_QuickSecurityScan.Location + $SHIFT_BTN_SHORT
$BTN_FullSecurityScan.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FullSecurityScan, 'Perform a full security scan')
$BTN_FullSecurityScan.Add_Click( { Start-SecurityScan 'full' } )


$BTN_DownloadMalwarebytes = New-Object System.Windows.Forms.Button
$BTN_DownloadMalwarebytes.Text = 'Malwarebytes'
$BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_DownloadMalwarebytes.Width = $BTN_WIDTH
$BTN_DownloadMalwarebytes.Location = $BTN_FullSecurityScan.Location + $SHIFT_BTN_NORMAL
$BTN_DownloadMalwarebytes.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware")
$BTN_DownloadMalwarebytes.Add_Click( {
        $FileName = Start-Download 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe'
        if ($CBOX_StartMalwarebytes.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartMalwarebytes = New-Object System.Windows.Forms.CheckBox
$CBOX_StartMalwarebytes.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartMalwarebytes.Size = $CBOX_SIZE
$CBOX_StartMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartMalwarebytes, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartMalwarebytes.Add_CheckStateChanged( { $BTN_DownloadMalwarebytes.Text = "Malwarebytes$(if ($CBOX_StartMalwarebytes.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_Malware.Controls.AddRange(@($BTN_QuickSecurityScan, $BTN_FullSecurityScan, $BTN_DownloadMalwarebytes, $CBOX_StartMalwarebytes))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Maintenace #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TAB_MAINTENANCE = New-Object System.Windows.Forms.TabPage
$TAB_MAINTENANCE.Text = 'Maintenace'
$TAB_MAINTENANCE.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_MAINTENANCE)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Maintenace - Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Updates = New-Object System.Windows.Forms.GroupBox
$GRP_Updates.Text = 'Updates'
$GRP_Updates.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 4 + $INT_BTN_SHORT
$GRP_Updates.Width = $GRP_WIDTH
$GRP_Updates.Location = $GRP_INIT_LOCATION
$TAB_MAINTENANCE.Controls.Add($GRP_Updates)


$BTN_GoogleUpdate = New-Object System.Windows.Forms.Button
$BTN_GoogleUpdate.Text = 'Update Google Chrome'
$BTN_GoogleUpdate.Height = $BTN_HEIGHT
$BTN_GoogleUpdate.Width = $BTN_WIDTH
$BTN_GoogleUpdate.Location = $BTN_INIT_LOCATION
$BTN_GoogleUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_GoogleUpdate, 'Silently update Google Chrome and other Google software')
$BTN_GoogleUpdate.Add_Click( { Start-GoogleUpdate } )


$BTN_UpdateStoreApps = New-Object System.Windows.Forms.Button
$BTN_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BTN_UpdateStoreApps.Height = $BTN_HEIGHT
$BTN_UpdateStoreApps.Width = $BTN_WIDTH
$BTN_UpdateStoreApps.Location = $BTN_GoogleUpdate.Location + $SHIFT_BTN_NORMAL
$BTN_UpdateStoreApps.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
$BTN_UpdateStoreApps.Add_Click( { Start-StoreAppUpdate } )


$BTN_OfficeInsider = New-Object System.Windows.Forms.Button
$BTN_OfficeInsider.Text = "Become Office insider$REQUIRES_ELEVATION"
$BTN_OfficeInsider.Height = $BTN_HEIGHT
$BTN_OfficeInsider.Width = $BTN_WIDTH
$BTN_OfficeInsider.Location = $BTN_UpdateStoreApps.Location + $SHIFT_BTN_NORMAL
$BTN_OfficeInsider.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OfficeInsider, 'Switch Microsoft Office to insider update channel')
$BTN_OfficeInsider.Add_Click( { Set-OfficeInsiderChannel } )

$BTN_UpdateOffice = New-Object System.Windows.Forms.Button
$BTN_UpdateOffice.Text = 'Update Microsoft Office'
$BTN_UpdateOffice.Height = $BTN_HEIGHT
$BTN_UpdateOffice.Width = $BTN_WIDTH
$BTN_UpdateOffice.Location = $BTN_OfficeInsider.Location + $SHIFT_BTN_SHORT
$BTN_UpdateOffice.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
$BTN_UpdateOffice.Add_Click( { Start-OfficeUpdate } )


$BTN_WindowsUpdate = New-Object System.Windows.Forms.Button
$BTN_WindowsUpdate.Text = 'Start Windows Update'
$BTN_WindowsUpdate.Height = $BTN_HEIGHT
$BTN_WindowsUpdate.Width = $BTN_WIDTH
$BTN_WindowsUpdate.Location = $BTN_UpdateOffice.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsUpdate.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsUpdate, 'Check for Windows updates, download and install if available')
$BTN_WindowsUpdate.Add_Click( { Start-WindowsUpdate } )


$GRP_Updates.Controls.AddRange(@($BTN_GoogleUpdate, $BTN_UpdateStoreApps, $BTN_OfficeInsider, $BTN_UpdateOffice, $BTN_WindowsUpdate))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Maintenace - Cleanup #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Cleanup = New-Object System.Windows.Forms.GroupBox
$GRP_Cleanup.Text = 'Cleanup'
$GRP_Cleanup.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 5
$GRP_Cleanup.Width = $GRP_WIDTH
$GRP_Cleanup.Location = $GRP_Updates.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Cleanup)


$BTN_EmptyRecycleBin = New-Object System.Windows.Forms.Button
$BTN_EmptyRecycleBin.Text = 'Empty Recycle Bin'
$BTN_EmptyRecycleBin.Height = $BTN_HEIGHT
$BTN_EmptyRecycleBin.Width = $BTN_WIDTH
$BTN_EmptyRecycleBin.Location = $BTN_INIT_LOCATION
$BTN_EmptyRecycleBin.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_EmptyRecycleBin, 'Empty Recycle Bin')
$BTN_EmptyRecycleBin.Add_Click( { Remove-Trash } )


$BTN_DiskCleanup = New-Object System.Windows.Forms.Button
$BTN_DiskCleanup.Text = 'Start disk cleanup'
$BTN_DiskCleanup.Height = $BTN_HEIGHT
$BTN_DiskCleanup.Width = $BTN_WIDTH
$BTN_DiskCleanup.Location = $BTN_EmptyRecycleBin.Location + $SHIFT_BTN_NORMAL
$BTN_DiskCleanup.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DiskCleanup, 'Start Windows built-in disk cleanup utility')
$BTN_DiskCleanup.Add_Click( { Start-DiskCleanup } )


$BTN_RunCCleaner = New-Object System.Windows.Forms.Button
$BTN_RunCCleaner.Text = "Run CCleaner silently$REQUIRES_ELEVATION"
$BTN_RunCCleaner.Height = $BTN_HEIGHT
$BTN_RunCCleaner.Width = $BTN_WIDTH
$BTN_RunCCleaner.Location = $BTN_DiskCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_RunCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
$BTN_RunCCleaner.Add_Click( { Start-CCleaner } )


$BTN_WindowsCleanup = New-Object System.Windows.Forms.Button
$BTN_WindowsCleanup.Text = "Cleanup Windows files$REQUIRES_ELEVATION"
$BTN_WindowsCleanup.Height = $BTN_HEIGHT
$BTN_WindowsCleanup.Width = $BTN_WIDTH
$BTN_WindowsCleanup.Location = $BTN_RunCCleaner.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsCleanup.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsCleanup, 'Remove old versions of system files, which have been changed via updates')
$BTN_WindowsCleanup.Add_Click( { Start-WindowsCleanup } )


$BTN_DeleteRestorePoints = New-Object System.Windows.Forms.Button
$BTN_DeleteRestorePoints.Text = "Delete all restore points$REQUIRES_ELEVATION"
$BTN_DeleteRestorePoints.Height = $BTN_HEIGHT
$BTN_DeleteRestorePoints.Width = $BTN_WIDTH
$BTN_DeleteRestorePoints.Location = $BTN_WindowsCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DeleteRestorePoints.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DeleteRestorePoints, 'Delete all restore points (shadow copies)')
$BTN_DeleteRestorePoints.Add_Click( { Remove-RestorePoints } )


$GRP_Cleanup.Controls.AddRange(@($BTN_EmptyRecycleBin, $BTN_DiskCleanup, $BTN_RunCCleaner, $BTN_WindowsCleanup, $BTN_DeleteRestorePoints))


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Maintenace - Optimization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GRP_Optimization = New-Object System.Windows.Forms.GroupBox
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Optimization.Width = $GRP_WIDTH
$GRP_Optimization.Location = $GRP_Cleanup.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Optimization)


$BTN_CloudFlareDNS = New-Object System.Windows.Forms.Button
$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_WIDTH
$BTN_CloudFlareDNS.Location = $BTN_INIT_LOCATION
$BTN_CloudFlareDNS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS (1.1.1.1 / 1.0.0.1)')
$BTN_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )


$BTN_OptimizeDrive = New-Object System.Windows.Forms.Button
$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Height = $BTN_HEIGHT
$BTN_OptimizeDrive.Width = $BTN_WIDTH
$BTN_OptimizeDrive.Location = $BTN_CloudFlareDNS.Location + $SHIFT_BTN_NORMAL
$BTN_OptimizeDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
$BTN_OptimizeDrive.Add_Click( { Start-DriveOptimization } )


$BTN_RunDefraggler = New-Object System.Windows.Forms.Button
$BTN_RunDefraggler.Text = "Run Defraggler for (C:)$REQUIRES_ELEVATION"
$BTN_RunDefraggler.Height = $BTN_HEIGHT
$BTN_RunDefraggler.Width = $BTN_WIDTH
$BTN_RunDefraggler.Location = $BTN_OptimizeDrive.Location + $SHIFT_BTN_NORMAL
$BTN_RunDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunDefraggler, 'Perform (C:) drive defragmentation with Defraggler')
$BTN_RunDefraggler.Add_Click( { Start-Defraggler } )


$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_OptimizeDrive, $BTN_RunDefraggler))


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

    Get-SystemInfo
    if ($PS_VERSION -lt 5) { Add-Log $WRN "PowerShell $PS_VERSION detected, while versions >=5 are supported. Some features might not work correctly." }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Get-CurrentVersion

    $script:CURRENT_DIR = Split-Path ($MyInvocation.ScriptName)

    $script:CCleanerExe = "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefragglerExe = "$env:ProgramFiles\Defraggler\df$(if ($OS_ARCH -eq '64-bit') {'64'}).exe"
    $script:DefenderExe = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
    $script:GoogleUpdateExe = "$(if ($OS_ARCH -eq '64-bit') {${env:ProgramFiles(x86)}} else {$env:ProgramFiles})\Google\Update\GoogleUpdate.exe"

    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_RunDefraggler.Enabled = Test-Path $DefragglerExe
    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe

    $BTN_UpdateOffice.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_OfficeInsider.Enabled = $BTN_UpdateOffice.Enabled

    $BTN_QuickSecurityScan.Enabled = Test-Path $DefenderExe
    $BTN_FullSecurityScan.Enabled = $BTN_QuickSecurityScan.Enabled

    Add-Type -AssemblyName System.IO.Compression.FileSystem
}


function Exit-Script { $FORM.Close() }


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Logger #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Add-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) { $WRN { $LOG.SelectionColor = 'blue' } $ERR { $LOG.SelectionColor = 'red' } Default { $LOG.SelectionColor = 'black' } }
    Write-Log "`n$Text"
}


function Write-Log($Text) {
    Write-Host $Text -NoNewline
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function Out-Success {
    Write-Log(' ')
    $LogDefaultFont = $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)
    Write-Log('Done')
    $LOG.SelectionFont = $LogDefaultFont
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Self-Update #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Get-CurrentVersion {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Add-Log $INF 'Checking for updates...'

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
        return
    }

    try { $LatestVersion = (Invoke-WebRequest $VersionURL).ToString() -Replace "`n", '' }
    catch [Exception] {
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        return
    }

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    }
    else { Write-Log ' No updates available' }
}


function Get-Update {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        return
    }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        return
    }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-Process 'powershell' $TargetFile }
    catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        return
    }

    Exit-Script
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Common #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Open-InBrowser ($Url) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($Url -like 'http*') { $Url } else { 'https://' + $Url }
    Add-Log $INF "Openning URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


function Get-ConnectionStatus {
    if ($PS_VERSION -gt 2) {
        return $(if (-not (Get-NetAdapter -Physical | Where-Object Status -eq 'Up')) { 'Computer is not connected to the Internet' })
    }
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Download File #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-Download ($Url, $SaveAs) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'Download failed: No download URL specified'
        return
    }

    $DownloadURL = if ($Url -like 'http*') { $Url } else { 'https://' + $Url }
    $FileName = if ($SaveAs) { $SaveAs } else { $DownloadURL | Split-Path -Leaf }
    $SavePath = "$CURRENT_DIR\$FileName"

    Add-Log $INF "Downloading from $DownloadURL"

    $IsNotConnected = Get-ConnectionStatus
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        return
    }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) { Out-Success }
        else { throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        return
    }

    return $FileName
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Extract ZIP #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-Extraction ($FileName) {
    Add-Log $INF "Extracting $FileName..."

    $ExtractionPath = if ($FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip' -or $FileName -match 'SDI_R*') { $FileName.trimend('.zip') }

    switch -Wildcard ($FileName) {
        'ChewWGA.zip' { $Executable = 'CW.eXe' }
        'Office_2013-2019.zip' { $Executable = 'OInstall.exe' }
        'Victoria.zip' { $Executable = 'Victoria.exe' }
        'AAct.zip' { $Executable = "AAct$(if ($OS_ARCH -eq '64-bit') {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { $Executable = "KMSAuto$(if ($OS_ARCH -eq '64-bit') {' x64'}).exe" }
        'SDI_R*' { $Executable = "$ExtractionPath\$(if ($OS_ARCH -eq '64-bit') {"$($ExtractionPath.Split('_') -Join '_x64_').exe"} else {"$ExtractionPath.exe"})" }
    }

    $TargetDirName = "$CURRENT_DIR\$ExtractionPath"
    if ($ExtractionPath) { Remove-Item $TargetDirName -Recurse -ErrorAction Ignore }

    try { [System.IO.Compression.ZipFile]::ExtractToDirectory("$CURRENT_DIR\$FileName", $TargetDirName) }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        return
    }

    if ($FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip') {
        $TempDir = $TargetDirName
        $TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -ErrorAction Ignore
    }

    Out-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
    Out-Success

    return $Executable
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Execute File #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-File ($FileName, $Switches, $IsSilentInstall) {
    $Executable = if ($FileName.Substring($FileName.Length - 4) -eq '.zip') { Start-Extraction $FileName } else { $FileName }

    if ($Switches -and $IsSilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try { Start-Process "$CURRENT_DIR\$Executable" $Switches -Wait }
        catch [Exception] {
            Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"
            return
        }

        Out-Success

        Add-Log $INF "Removing $FileName..."
        Remove-Item "$CURRENT_DIR\$FileName" -ErrorAction Ignore
        Out-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try { if ($Switches) { Start-Process "$CURRENT_DIR\$Executable" $Switches } else { Start-Process "$CURRENT_DIR\$Executable" } }
        catch [Exception] {
            Add-Log $ERR "Failed to execute' $Executable': $($_.Exception.Message)"
            return
        }

        Out-Success
    }
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Start Elevated #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-Elevated {
    if (-not $IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-Process 'powershell' $MyInvocation.ScriptName -Verb RunAs }
        catch [Exception] {
            Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"
            return
        }

        Exit-Script
    }
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# System Information #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    $OperatingSystem = Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version

    $script:OS_NAME = $OperatingSystem.Caption
    $script:OS_ARCH = $OperatingSystem.OSArchitecture
    $script:OS_VERSION = $OperatingSystem.Version
    $script:PS_VERSION = $PSVersionTable.PSVersion.Major

    $script:OfficeC2RClientExe = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    $WordRegPath = Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue
    $script:OfficeVersion = if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' }
    $script:OfficeInstallType = if ($OfficeVersion) { if (Test-Path $OfficeC2RClientExe) { 'C2R' } else { 'MSI' } }

    Out-Success
}


function Out-SystemInfo {
    $ComputerSystem = Get-WmiObject Win32_ComputerSystem | Select-Object Manufacturer, Model, PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } }
    $Processor = Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, ThreadCount
    $LogicalDisk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType = '3'"
    $SystemPartition = $LogicalDisk | Select-Object @{L = 'FreeSpaceGB'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'SizeGB'; E = { '{0:N2}' -f ($_.Size / 1GB) } }
    $OfficeYear = switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } }
    $OfficeName = if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' }

    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'
    Add-Log $INF "    Computer type:  $(switch ($ComputerSystem.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    Add-Log $INF "    Computer manufacturer:  $($ComputerSystem.Manufacturer)"
    Add-Log $INF "    Computer model:  $($ComputerSystem.Model)"
    Add-Log $INF "    CPU name:  $($Processor.Name -Join '; ')"
    Add-Log $INF "    Cores / Threads:  $($Processor.NumberOfCores) / $($Processor.ThreadCount)"
    Add-Log $INF "    RAM available:  $($ComputerSystem.RAM) GB"
    Add-Log $INF "    GPU name:  $((Get-WmiObject Win32_VideoController).Name -Join '; ')"
    Add-Log $INF "    System drive model:  $(($LogicalDisk.GetRelated('Win32_DiskPartition').GetRelated('Win32_DiskDrive')).Model -Join '; ')"
    Add-Log $INF "    System partition - free space: $($SystemPartition.FreeSpaceGB) GB / $($SystemPartition.SizeGB) GB ($(($SystemPartition.FreeSpaceGB/$SystemPartition.SizeGB).tostring('P')))"
    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    OS version / build number:  v$((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) / $OS_VERSION"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Ninite #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Set-NiniteButtonState () {
    $BTN_DownloadNinite.Enabled = $CBOX_7zip.Checked -or $CBOX_VLC.Checked -or $CBOX_TeamViewer.Checked -or $CBOX_Skype.Checked -or `
        $CBOX_Chrome.Checked -or $CBOX_qBittorrent.Checked -or $CBOX_GoogleDrive.Checked -or $CBOX_VSCode.Checked
    $CBOX_StartNinite.Enabled = $BTN_DownloadNinite.Enabled
}


function Set-NiniteQuery () {
    $Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Name }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Name }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Name }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Name }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Name }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Name }
    if ($CBOX_GoogleDrive.Checked) { $Array += $CBOX_GoogleDrive.Name }
    if ($CBOX_VSCode.Checked) { $Array += $CBOX_VSCode.Name }
    return $Array -Join '-'
}


function Set-NiniteFileName () {
    $Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Text }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Text }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Text }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Text }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Text }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Text }
    if ($CBOX_GoogleDrive.Checked) { $Array += $CBOX_GoogleDrive.Text }
    if ($CBOX_VSCode.Checked) { $Array += $CBOX_VSCode.Text }
    return "Ninite $($Array -Join ' ') Installer.exe"
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Check HDD and RAM #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-DriveCheck {
    Add-Log $INF 'Starting (C:) drive health check...'

    try { Start-Process 'chkdsk' '/scan' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to check (C:) drive health: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try { Start-Process 'mdsched' }
    catch [Exception] {
        Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"
        return
    }

    Out-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Check Windows Health #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    try { Start-Process 'DISM' '/Online /Cleanup-Image /ScanHealth' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    try { Start-Process 'DISM' '/Online /Cleanup-Image /RestoreHealth' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-Process 'sfc' '/scannow' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"
        return
    }

    Out-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Security #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-SecurityScan ($Mode) {
    if (-not $Mode) {
        Add-Log $WRN "Scan mode not specified, assuming 'quick'"
        $Mode = 'quick'
    }

    Add-Log $INF 'Updating security signatures...'

    try { Start-Process $DefenderExe '-SignatureUpdate' -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"
        return
    }

    Out-Success
    Add-Log $INF "Starting $Mode securtiy scan..."

    try { Start-Process $DefenderExe "-Scan -ScanType $(if ($Mode -eq 'full') {2} else {1})" }
    catch [Exception] {
        Add-Log $ERR "Failed to perform a $Mode securtiy scan: $($_.Exception.Message)"
        return
    }

    Out-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Updates #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Start-GoogleUpdate {
    Add-Log $INF 'Starting Google Update...'

    try { Start-Process $GoogleUpdateExe '/c' }
    catch [Exception] {
        Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"
        return
    }

    try { Start-Process $GoogleUpdateExe '/ua /installsource scheduler' }
    catch [Exception] {
        Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"
        return
    }

    Out-Success
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

    Out-Success
}


function Set-OfficeInsiderChannel {
    Add-Log $INF 'Switching Microsoft Office to insider update channel...'

    try { Start-Process $OfficeC2RClientExe '/changesetting Channel="InsiderFast"' -Verb RunAs -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to switch Microsoft Office update channel: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try { Start-Process $OfficeC2RClientExe '/update user' -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try { Start-Process 'UsoClient' 'StartInteractiveScan' -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"
        return
    }

    Out-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Cleanup #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Remove-Trash {
    Add-Log $INF 'Emptying Recycle Bin...'

    try {
        if ($PS_VERSION -ge 5) { Clear-RecycleBin -Force }
        else { (New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to empty Recycle Bin: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process 'cleanmgr' '/lowdisk' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-CCleaner {
    if (-not $CCleanerWarningShown) {
        Add-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Add-Log $WRN 'Click the button again to contunue'
        $script:CCleanerWarningShown = $True
        return
    }

    Add-Log $INF 'Starting CCleaner background task...'

    try { Start-Process $CCleanerExe '/auto' }
    catch [Exception] {
        Add-Log $ERR "Failed to start CCleaner: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-WindowsCleanup {
    Add-Log $INF 'Starting Windows update cleanup...'

    try { Start-Process 'DISM' '/Online /Cleanup-Image /StartComponentCleanup' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to cleanup Windows updates: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Remove-RestorePoints {
    Add-Log $INF 'Deleting all restore points...'

    try { Start-Process 'vssadmin' 'delete shadows /all' -Verb RunAs -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"
        return
    }

    Out-Success
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

    Out-Success
}


function Start-DriveOptimization {
    Add-Log $INF 'Starting drive optimization...'

    try { Start-Process 'defrag' '/C /H /U /O' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-Defraggler {
    Add-Log $INF 'Starting (C:) drive optimization with Defraggler...'

    try { Start-Process $DefragglerExe 'C:\' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed start Defraggler: $($_.Exception.Message)"
        return
    }

    Out-Success
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Draw Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$FORM.ShowDialog() | Out-Null
