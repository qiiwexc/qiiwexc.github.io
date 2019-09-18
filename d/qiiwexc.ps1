Set-Variable Version ([Version]'19.9.18') -Option Constant


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Info #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

<#

-=-=-=-=-=-= README =-=-=-=-=-=-

To execute, right-click the file, then select "Run with PowerShell".
Double click will simply open the file in Notepad.


-=-=-=-= TROUBLESHOOTING =-=-=-=-

If a window briefly opens and closes, press Win+R on the keyboard, paste the following and click OK:
    PowerShell -Command "Start-Process 'PowerShell' -Verb RunAs"

Then paste the following and hit Enter:
    Set-ExecutionPolicy RemoteSigned -Force; Exit

Now you can try starting the utility again

#>


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Initialization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Write-Host 'Initializing...'

Set-Variable IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) -Option Constant

Set-Variable OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle) -Option Constant
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

Set-Variable PSShellInvocationCommand $((Get-ItemProperty 'HKLM:\SOFTWARE\Classes\Microsoft.PowerShellScript.1\Shell\0\Command').'(default)') -Option Constant
Set-Variable StartedFromGUI $("`"$($MyInvocation.Line)`"" -eq $PSShellInvocationCommand.Split(' ', 3)[2].Replace('%1', $MyInvocation.MyCommand.Definition)) -Option Constant
Set-Variable HIDE_CONSOLE ($args[0] -eq '-HideConsole' -or $StartedFromGUI -or -not $MyInvocation.Line) -Option Constant

if ($HIDE_CONSOLE) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try { Add-Type -AssemblyName System.Windows.Forms } catch { Throw 'System not supported' }

[System.Windows.Forms.Application]::EnableVisualStyles()

Set-Variable PS_VERSION $($PSVersionTable.PSVersion.Major) -Option Constant


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Constants #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable INF 'INF' -Option Constant
Set-Variable WRN 'WRN' -Option Constant
Set-Variable ERR 'ERR' -Option Constant

Set-Variable REQUIRES_ELEVATION $(if (-not $IS_ELEVATED) { ' *' }) -Option Constant


Set-Variable FORM_WIDTH 670 -Option Constant
Set-Variable FORM_HEIGHT 625 -Option Constant

Set-Variable BTN_WIDTH 167 -Option Constant
Set-Variable BTN_HEIGHT 28 -Option Constant

Set-Variable CBOX_WIDTH 145 -Option Constant
Set-Variable CBOX_HEIGHT 20 -Option Constant

Set-Variable RBTN_WIDTH 80 -Option Constant
Set-Variable RBTN_HEIGHT 20 -Option Constant

Set-Variable INT_SHORT 5 -Option Constant
Set-Variable INT_NORMAL 15 -Option Constant
Set-Variable INT_LONG 30 -Option Constant
Set-Variable INT_TAB_ADJ 4 -Option Constant
Set-Variable INT_GROUP_TOP 20 -Option Constant


Set-Variable INT_BTN_SHORT ($BTN_HEIGHT + $INT_SHORT) -Option Constant
Set-Variable INT_BTN_NORMAL ($BTN_HEIGHT + $INT_NORMAL) -Option Constant
Set-Variable INT_BTN_LONG ($BTN_HEIGHT + $INT_LONG) -Option Constant

Set-Variable INT_CBOX_SHORT ($CBOX_HEIGHT + $INT_SHORT) -Option Constant
Set-Variable INT_CBOX_NORMAL ($CBOX_HEIGHT + $INT_NORMAL) -Option Constant


Set-Variable GRP_WIDTH ($INT_NORMAL + $BTN_WIDTH + $INT_NORMAL) -Option Constant

Set-Variable CBOX_SIZE "$CBOX_WIDTH, $CBOX_HEIGHT" -Option Constant
Set-Variable RBTN_SIZE "$RBTN_WIDTH, $RBTN_HEIGHT" -Option Constant

Set-Variable BTN_INIT_LOCATION "$INT_NORMAL, $INT_GROUP_TOP" -Option Constant
Set-Variable GRP_INIT_LOCATION "$INT_NORMAL, $INT_NORMAL" -Option Constant


Set-Variable SHIFT_BTN_SHORT "0, $INT_BTN_SHORT" -Option Constant
Set-Variable SHIFT_BTN_NORMAL "0, $INT_BTN_NORMAL" -Option Constant
Set-Variable SHIFT_BTN_LONG "0, $INT_BTN_LONG" -Option Constant

Set-Variable SHIFT_CBOX_SHORT "0, $INT_CBOX_SHORT" -Option Constant
Set-Variable SHIFT_CBOX_NORMAL "0, $INT_CBOX_NORMAL" -Option Constant
Set-Variable SHIFT_CBOX_EXECUTE "$($INT_LONG - $INT_SHORT), $($INT_BTN_SHORT - $INT_SHORT)" -Option Constant

Set-Variable SHIFT_RBTN_QUICK_SCAN "10, $($INT_BTN_SHORT - $INT_SHORT)" -Option Constant
Set-Variable SHIFT_RBTN_FULL_SCAN "$RBTN_WIDTH, 0" -Option Constant

Set-Variable SHIFT_GRP_HOR_NORMAL "$($GRP_WIDTH + $INT_NORMAL), 0" -Option Constant

Set-Variable SHIFT_LBL_BROWSER "$INT_LONG, $($INT_BTN_SHORT - $INT_SHORT)" -Option Constant


Set-Variable FONT_NAME 'Microsoft Sans Serif' -Option Constant
Set-Variable BTN_FONT "$FONT_NAME, 10" -Option Constant


Set-Variable TXT_QUICK_SCAN 'Quick scan' -Option Constant
Set-Variable TXT_FULL_SCAN 'Full scan' -Option Constant
Set-Variable TXT_START_AFTER_DOWNLOAD 'Start after download' -Option Constant
Set-Variable TXT_OPENS_IN_BROWSER 'Opens in the browser' -Option Constant
Set-Variable TXT_UNCHECKY_INFO 'Unchecky clears adware checkboxes when installing software' -Option Constant
Set-Variable TXT_AV_WARNING "This file may trigger anti-virus false positive!`nIt is recommended to disable anti-virus software for download and subsequent use of this file!" -Option Constant

Set-Variable TIP_START_AFTER_DOWNLOAD "Execute after download has finished`nIf download is a ZIP file, it will get extracted first" -Option Constant

Set-Variable TEMP_DIR "$env:TMP\qiiwexc" -Option Constant


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable FORM (New-Object System.Windows.Forms.Form) -Option Constant
Set-Variable LOG (New-Object System.Windows.Forms.RichTextBox) -Option Constant
Set-Variable TAB_CONTROL (New-Object System.Windows.Forms.TabControl) -Option Constant

Set-Variable TAB_HOME (New-Object System.Windows.Forms.TabPage) -Option Constant
Set-Variable TAB_INSTALLERS (New-Object System.Windows.Forms.TabPage) -Option Constant
Set-Variable TAB_DIAGNOSTICS (New-Object System.Windows.Forms.TabPage) -Option Constant
Set-Variable TAB_MAINTENANCE (New-Object System.Windows.Forms.TabPage) -Option Constant

$TAB_HOME.UseVisualStyleBackColor = $TAB_INSTALLERS.UseVisualStyleBackColor = $TAB_DIAGNOSTICS.UseVisualStyleBackColor = $TAB_MAINTENANCE.UseVisualStyleBackColor = $True

$TAB_CONTROL.Controls.AddRange(@($TAB_HOME, $TAB_INSTALLERS, $TAB_DIAGNOSTICS, $TAB_MAINTENANCE))
$FORM.Controls.AddRange(@($LOG, $TAB_CONTROL))



$FORM.Text = "qiiwexc v$VERSION"
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


$LOG.Height = 200
$LOG.Width = - $INT_SHORT + $FORM_WIDTH - $INT_SHORT
$LOG.Location = "$INT_SHORT, $($FORM_HEIGHT - $LOG.Height - $INT_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True


$TAB_CONTROL.Size = "$($LOG.Width + $INT_SHORT - $INT_TAB_ADJ), $($FORM_HEIGHT - $LOG.Height - $INT_SHORT - $INT_TAB_ADJ)"
$TAB_CONTROL.Location = "$INT_SHORT, $INT_SHORT"


$TAB_HOME.Text = 'Home'
$TAB_INSTALLERS.Text = 'Downloads'
$TAB_DIAGNOSTICS.Text = 'Diagnostics'
$TAB_MAINTENANCE.Text = 'Maintenance'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - This Utility #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_ThisUtility (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_ThisUtility.Text = 'This utility'
$GRP_ThisUtility.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_ThisUtility.Width = $GRP_WIDTH
$GRP_ThisUtility.Location = $GRP_INIT_LOCATION
$TAB_HOME.Controls.Add($GRP_ThisUtility)

Set-Variable BTN_Elevate (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_BrowserHome (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_SystemInfo (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Elevate, 'Restart this utility with administrator privileges')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_BrowserHome, 'Open utility web page in the default browser')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_SystemInfo, 'Print system information to the log')

$BTN_Elevate.Font = $BTN_BrowserHome.Font = $BTN_SystemInfo.Font = $BTN_FONT
$BTN_Elevate.Height = $BTN_BrowserHome.Height = $BTN_SystemInfo.Height = $BTN_HEIGHT
$BTN_Elevate.Width = $BTN_BrowserHome.Width = $BTN_SystemInfo.Width = $BTN_WIDTH

$GRP_ThisUtility.Controls.AddRange(@($BTN_Elevate, $BTN_BrowserHome, $BTN_SystemInfo))



$BTN_Elevate.Text = "Run as administrator$REQUIRES_ELEVATION"
$BTN_Elevate.Location = $BTN_INIT_LOCATION
$BTN_Elevate.Add_Click( { Start-Elevated } )


$BTN_BrowserHome.Text = 'Open in the browser'
$BTN_BrowserHome.Location = $BTN_Elevate.Location + $SHIFT_BTN_NORMAL
$BTN_BrowserHome.Add_Click( { Open-InBrowser 'qiiwexc.github.io' } )


$BTN_SystemInfo.Text = 'System information'
$BTN_SystemInfo.Location = $BTN_BrowserHome.Location + $SHIFT_BTN_NORMAL
$BTN_SystemInfo.Add_Click( { Out-SystemInfo } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Activators (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Activators.Width = $GRP_WIDTH
$GRP_Activators.Location = $GRP_ThisUtility.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_Activators)

Set-Variable BTN_DownloadKMSAuto (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartKMSAuto (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadAAct (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartAAct (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadChewWGA (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartChewWGA (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadAAct, "Download AAct`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChewWGA, "Download ChewWGA`nLast resort for activating hopeless Windows 7 cases`n`n$TXT_AV_WARNING")

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartKMSAuto, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartAAct, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartChewWGA, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadKMSAuto.Font = $BTN_DownloadAAct.Font = $BTN_DownloadChewWGA.Font = $BTN_FONT
$BTN_DownloadKMSAuto.Height = $BTN_DownloadAAct.Height = $BTN_DownloadChewWGA.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_DownloadAAct.Width = $BTN_DownloadChewWGA.Width = $BTN_WIDTH

$CBOX_StartKMSAuto.Checked = $CBOX_StartAAct.Checked = $CBOX_StartChewWGA.Checked = $True
$CBOX_StartKMSAuto.Size = $CBOX_StartAAct.Size = $CBOX_StartChewWGA.Size = $CBOX_SIZE
$CBOX_StartKMSAuto.Text = $CBOX_StartAAct.Text = $CBOX_StartChewWGA.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $CBOX_StartKMSAuto, $BTN_DownloadAAct, $CBOX_StartAAct, $BTN_DownloadChewWGA, $CBOX_StartChewWGA))



$BTN_DownloadKMSAuto.Text = "KMSAuto Lite$REQUIRES_ELEVATION"
$BTN_DownloadKMSAuto.Location = $BTN_INIT_LOCATION
$BTN_DownloadKMSAuto.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -AVWarning -MultiFile -Execute:$CBOX_StartKMSAuto.Checked } )

$CBOX_StartKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartKMSAuto.Add_CheckStateChanged( { $BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$REQUIRES_ELEVATION"
$BTN_DownloadAAct.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_BTN_LONG
$BTN_DownloadAAct.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/AAct.zip' -AVWarning -MultiFile -Execute:$CBOX_StartAAct.Checked } )

$CBOX_StartAAct.Location = $BTN_DownloadAAct.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartAAct.Add_CheckStateChanged( { $BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadChewWGA.Text = "ChewWGA (Win 7)$REQUIRES_ELEVATION"
$BTN_DownloadChewWGA.Location = $BTN_DownloadAAct.Location + $SHIFT_BTN_LONG
$BTN_DownloadChewWGA.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/ChewWGA.zip' -AVWarning -Execute:$CBOX_StartChewWGA.Checked } )

$CBOX_StartChewWGA.Location = $BTN_DownloadChewWGA.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartChewWGA.Add_CheckStateChanged( { $BTN_DownloadChewWGA.Text = "ChewWGA (Win 7)$(if ($CBOX_StartChewWGA.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Tools (General) #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_DownloadTools (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_DownloadTools.Text = 'Tools (General)'
$GRP_DownloadTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_DownloadTools.Width = $GRP_WIDTH
$GRP_DownloadTools.Location = $GRP_Activators.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_DownloadTools)

Set-Variable BTN_DownloadChrome (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartChrome (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadRufus (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartRufus (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_WindowsPE (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_WindowsPE (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChrome, 'Open Google Chrome Beta download page')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsPE, 'Download Windows PE (Live CD) ISO image based on Windows 8')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartChrome, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRufus, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadChrome.Font = $BTN_DownloadRufus.Font = $BTN_WindowsPE.Font = $BTN_FONT
$BTN_DownloadChrome.Height = $BTN_DownloadRufus.Height = $BTN_WindowsPE.Height = $BTN_HEIGHT
$BTN_DownloadChrome.Width = $BTN_DownloadRufus.Width = $BTN_WindowsPE.Width = $BTN_WIDTH

$CBOX_StartChrome.Checked = $CBOX_StartRufus.Checked = $True
$CBOX_StartChrome.Size = $CBOX_StartRufus.Size = $LBL_WindowsPE.Size = $CBOX_SIZE
$CBOX_StartChrome.Text = $CBOX_StartRufus.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadChrome, $CBOX_StartChrome, $BTN_DownloadRufus, $CBOX_StartRufus, $BTN_WindowsPE, $LBL_WindowsPE))



$BTN_DownloadChrome.Text = "Chrome Beta$REQUIRES_ELEVATION"
$BTN_DownloadChrome.Location = $BTN_INIT_LOCATION
$BTN_DownloadChrome.Add_Click( {
        Set-Variable ChromeBetaURL 'dl.google.com/tag/s/appguid%3D%7B8237E44A-0054-442C-B6B6-EA0509993955%7D%26usagestats%3D1%26appname%3DGoogle%2520Chrome%2520Beta%26needsadmin%3Dprefers%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe' -Option Constant
        Start-DownloadExtractExecute $ChromeBetaURL -Execute:$CBOX_StartChrome.Checked
    } )

$CBOX_StartChrome.Location = $BTN_DownloadChrome.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartChrome.Add_CheckStateChanged( { $BTN_DownloadChrome.Text = "Chrome Beta$(if ($CBOX_StartChrome.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRufus.Text = "Rufus (bootable USB)$REQUIRES_ELEVATION"
$BTN_DownloadRufus.Location = $BTN_DownloadChrome.Location + $SHIFT_BTN_LONG
$BTN_DownloadRufus.Add_Click( {
        Set-Variable RufusURL 'github.com/pbatard/rufus/releases/download/v3.6/rufus-3.6.exe' -Option Constant
        if ($PS_VERSION -gt 2) {
            $DownloadedFile = Start-Download $RufusURL
            if ($CBOX_StartRufus.Checked -and $DownloadedFile) { Start-File $DownloadedFile '-g' }
        }
        else { Open-InBrowser $RufusURL }
    } )

$CBOX_StartRufus.Location = $BTN_DownloadRufus.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRufus.Add_CheckStateChanged( { $BTN_DownloadRufus.Text = "Rufus (bootable USB)$(if ($CBOX_StartRufus.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_WindowsPE.Text = 'Windows PE (Live CD)'
$BTN_WindowsPE.Location = $BTN_DownloadRufus.Location + $SHIFT_BTN_LONG
$BTN_WindowsPE.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_' } )

$LBL_WindowsPE.Text = $TXT_OPENS_IN_BROWSER
$LBL_WindowsPE.Location = $BTN_WindowsPE.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Ninite (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Ninite.Text = 'Ninite'
$GRP_Ninite.Height = $INT_GROUP_TOP + $INT_CBOX_SHORT * 8 + $INT_SHORT + $INT_BTN_LONG * 2
$GRP_Ninite.Width = $GRP_WIDTH
$GRP_Ninite.Location = $GRP_INIT_LOCATION
$TAB_INSTALLERS.Controls.Add($GRP_Ninite)

Set-Variable CBOX_Chrome (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_7zip (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_VLC (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_TeamViewer (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_Skype (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_qBittorrent (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_GoogleDrive (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_VSCode (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadNinite (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartNinite (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_OpenNiniteInBrowser (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_OpenNiniteInBrowser (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadNinite, 'Download Ninite universal installer for selected applications')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OpenNiniteInBrowser, 'Open Ninite universal installer web page for other installation options')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartNinite, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadNinite.Font = $BTN_OpenNiniteInBrowser.Font = $BTN_FONT
$BTN_DownloadNinite.Height = $BTN_OpenNiniteInBrowser.Height = $BTN_HEIGHT
$BTN_DownloadNinite.Width = $BTN_OpenNiniteInBrowser.Width = $BTN_WIDTH

$CBOX_Chrome.Checked = $CBOX_7zip.Checked = $CBOX_VLC.Checked = $CBOX_TeamViewer.Checked = $CBOX_Skype.Checked = $CBOX_StartNinite.Checked = $True
$CBOX_Chrome.Size = $CBOX_7zip.Size = $CBOX_VLC.Size = $CBOX_TeamViewer.Size = $CBOX_Skype.Size = $CBOX_qBittorrent.Size = `
    $CBOX_GoogleDrive.Size = $CBOX_VSCode.Size = $CBOX_StartNinite.Size = $LBL_OpenNiniteInBrowser.Size = $CBOX_SIZE

$GRP_Ninite.Controls.AddRange(
    @($BTN_DownloadNinite, $BTN_OpenNiniteInBrowser, $LBL_OpenNiniteInBrowser, $CBOX_StartNinite,
        $CBOX_7zip, $CBOX_VLC, $CBOX_TeamViewer, $CBOX_Skype, $CBOX_Chrome, $CBOX_qBittorrent, $CBOX_GoogleDrive, $CBOX_VSCode)
)



$CBOX_Chrome.Text = 'Google Chrome'
$CBOX_Chrome.Name = 'chrome'
$CBOX_Chrome.Location = $BTN_INIT_LOCATION
$CBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_7zip.Text = '7-Zip'
$CBOX_7zip.Name = '7zip'
$CBOX_7zip.Location = $CBOX_Chrome.Location + $SHIFT_CBOX_SHORT
$CBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VLC.Text = 'VLC'
$CBOX_VLC.Name = 'vlc'
$CBOX_VLC.Location = $CBOX_7zip.Location + $SHIFT_CBOX_SHORT
$CBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_TeamViewer.Text = 'TeamViewer'
$CBOX_TeamViewer.Name = 'teamviewer14'
$CBOX_TeamViewer.Location = $CBOX_VLC.Location + $SHIFT_CBOX_SHORT
$CBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_Skype.Text = 'Skype'
$CBOX_Skype.Name = 'skype'
$CBOX_Skype.Location = $CBOX_TeamViewer.Location + $SHIFT_CBOX_SHORT
$CBOX_Skype.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_qBittorrent.Text = 'qBittorrent'
$CBOX_qBittorrent.Name = 'qbittorrent'
$CBOX_qBittorrent.Location = $CBOX_Skype.Location + $SHIFT_CBOX_SHORT
$CBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_GoogleDrive.Text = 'Google Drive'
$CBOX_GoogleDrive.Name = 'googlebackupandsync'
$CBOX_GoogleDrive.Location = $CBOX_qBittorrent.Location + $SHIFT_CBOX_SHORT
$CBOX_GoogleDrive.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CBOX_VSCode.Text = 'Visual Studio Code'
$CBOX_VSCode.Name = 'vscode'
$CBOX_VSCode.Location = $CBOX_GoogleDrive.Location + $SHIFT_CBOX_SHORT
$CBOX_VSCode.Add_CheckStateChanged( { Set-NiniteButtonState } )


$BTN_DownloadNinite.Text = "Download selected$REQUIRES_ELEVATION"
$BTN_DownloadNinite.Location = $CBOX_VSCode.Location + $SHIFT_BTN_SHORT
$BTN_DownloadNinite.Add_Click( { Start-DownloadExtractExecute "ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) -Execute:$CBOX_StartNinite.Checked } )

$CBOX_StartNinite.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartNinite.Location = $BTN_DownloadNinite.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartNinite.Add_CheckStateChanged( { $BTN_DownloadNinite.Text = "Download selected$(if ($CBOX_StartNinite.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_OpenNiniteInBrowser.Text = 'View other'
$BTN_OpenNiniteInBrowser.Location = $BTN_DownloadNinite.Location + $SHIFT_BTN_LONG
$BTN_OpenNiniteInBrowser.Add_Click( {
        Set-Variable Query (Set-NiniteQuery) -Option Constant; Open-InBrowser $(if ($Query) { "ninite.com/?select=$($Query)" } else { 'ninite.com' })
    } )

$LBL_OpenNiniteInBrowser.Text = $TXT_OPENS_IN_BROWSER
$LBL_OpenNiniteInBrowser.Location = $BTN_OpenNiniteInBrowser.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Essentials (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Essentials.Text = 'Essentials'
$GRP_Essentials.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3 + $INT_CBOX_SHORT - $INT_SHORT
$GRP_Essentials.Width = $GRP_WIDTH
$GRP_Essentials.Location = $GRP_Ninite.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_Essentials)

Set-Variable BTN_DownloadSDI (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartSDI (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadUnchecky (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartUnchecky (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_SilentlyInstallUnchecky (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadOffice (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartOffice (New-Object System.Windows.Forms.CheckBox) -Option Constant

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
$BTN_DownloadSDI.Add_Click( { Start-DownloadExtractExecute 'sdi-tool.org/releases/SDI_R1909.zip' -MultiFile -Execute:$CBOX_StartSDI.Checked } )

$CBOX_StartSDI.Location = $BTN_DownloadSDI.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartSDI.Add_CheckStateChanged( { $BTN_DownloadSDI.Text = "Snappy Driver Installer$(if ($CBOX_StartSDI.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadUnchecky.Text = "Unchecky$REQUIRES_ELEVATION"
$BTN_DownloadUnchecky.Location = $BTN_DownloadSDI.Location + $SHIFT_BTN_LONG
$BTN_DownloadUnchecky.Add_Click( {
        Set-Variable DownloadedFile (Start-Download 'unchecky.com/files/unchecky_setup.exe') -Option Constant
        if ($CBOX_StartUnchecky.Checked -and $DownloadedFile) { Start-File $DownloadedFile $(if ($CBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' }) -SilentInstall }
    } )

$CBOX_StartUnchecky.Location = $BTN_DownloadUnchecky.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartUnchecky.Add_CheckStateChanged( { $CBOX_SilentlyInstallUnchecky.Enabled = $CBOX_StartUnchecky.Checked } )

$CBOX_SilentlyInstallUnchecky.Text = 'Install silently'
$CBOX_SilentlyInstallUnchecky.Location = $CBOX_StartUnchecky.Location + "0, $CBOX_HEIGHT"
$CBOX_StartUnchecky.Add_CheckStateChanged( { $BTN_DownloadUnchecky.Text = "Unchecky$(if ($CBOX_StartUnchecky.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadOffice.Text = "Office 2013 - 2019$REQUIRES_ELEVATION"
$BTN_DownloadOffice.Location = $BTN_DownloadUnchecky.Location + $SHIFT_BTN_SHORT + $SHIFT_BTN_NORMAL
$BTN_DownloadOffice.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/Office_2013-2019.zip' -AVWarning -Execute:$CBOX_StartOffice.Checked } )

$CBOX_StartOffice.Location = $BTN_DownloadOffice.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartOffice.Add_CheckStateChanged( { $BTN_DownloadOffice.Text = "Office 2013 - 2019$(if ($CBOX_StartOffice.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_InstallTools (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_InstallTools.Text = 'Tools'
$GRP_InstallTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_InstallTools.Width = $GRP_WIDTH
$GRP_InstallTools.Location = $GRP_Essentials.Location + "0, $($GRP_Essentials.Height + $INT_NORMAL)"
$TAB_INSTALLERS.Controls.Add($GRP_InstallTools)

Set-Variable BTN_DownloadCCleaner (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartCCleaner (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadDefraggler (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartDefraggler (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartCCleaner, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartDefraggler, $TIP_START_AFTER_DOWNLOAD)

$BTN_DownloadCCleaner.Font = $BTN_DownloadDefraggler.Font = $BTN_FONT
$BTN_DownloadCCleaner.Height = $BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_DownloadDefraggler.Width = $BTN_WIDTH

$CBOX_StartCCleaner.Checked = $CBOX_StartDefraggler.Checked = $True
$CBOX_StartCCleaner.Size = $CBOX_StartDefraggler.Size = $CBOX_SIZE
$CBOX_StartCCleaner.Text = $CBOX_StartDefraggler.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_InstallTools.Controls.AddRange(@($BTN_DownloadCCleaner, $CBOX_StartCCleaner, $BTN_DownloadDefraggler, $CBOX_StartDefraggler))



$BTN_DownloadCCleaner.Text = "CCleaner$REQUIRES_ELEVATION"
$BTN_DownloadCCleaner.Location = $BTN_INIT_LOCATION
$BTN_DownloadCCleaner.Add_Click( { Start-DownloadExtractExecute 'download.ccleaner.com/ccsetup.exe' -Execute:$CBOX_StartCCleaner.Checked } )

$CBOX_StartCCleaner.Location = $BTN_DownloadCCleaner.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartCCleaner.Add_CheckStateChanged( { $BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadDefraggler.Text = "Defraggler$REQUIRES_ELEVATION"
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $SHIFT_BTN_LONG
$BTN_DownloadDefraggler.Add_Click( { Start-DownloadExtractExecute 'download.ccleaner.com/dfsetup.exe' -Execute:$CBOX_StartDefraggler.Checked } )

$CBOX_StartDefraggler.Location = $BTN_DownloadDefraggler.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartDefraggler.Add_CheckStateChanged( { $BTN_DownloadDefraggler.Text = "Defraggler$(if ($CBOX_StartDefraggler.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Windows Images #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_DownloadWindows (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_DownloadWindows.Text = 'Windows Images'
$GRP_DownloadWindows.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 5 + $INT_SHORT
$GRP_DownloadWindows.Width = $GRP_WIDTH
$GRP_DownloadWindows.Location = $GRP_Essentials.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_INSTALLERS.Controls.Add($GRP_DownloadWindows)

Set-Variable BTN_Windows10 (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_Windows10 (New-Object System.Windows.Forms.Label) -Option Constant

Set-Variable BTN_Windows8 (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_Windows8 (New-Object System.Windows.Forms.Label) -Option Constant

Set-Variable BTN_Windows7 (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_Windows7 (New-Object System.Windows.Forms.Label) -Option Constant

Set-Variable BTN_WindowsXPENG (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_WindowsXPENG (New-Object System.Windows.Forms.Label) -Option Constant

Set-Variable BTN_WindowsXPRUS (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_WindowsXPRUS (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows10, 'Download Windows 10 (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows8, 'Download Windows 8.1 with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXPENG, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsXPRUS, 'Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image')

$BTN_Windows10.Font = $BTN_Windows8.Font = $BTN_Windows7.Font = $BTN_WindowsXPENG.Font = $BTN_WindowsXPRUS.Font = $BTN_FONT
$BTN_Windows10.Height = $BTN_Windows8.Height = $BTN_Windows7.Height = $BTN_WindowsXPENG.Height = $BTN_WindowsXPRUS.Height = $BTN_HEIGHT
$BTN_Windows10.Width = $BTN_Windows8.Width = $BTN_Windows7.Width = $BTN_WindowsXPENG.Width = $BTN_WindowsXPRUS.Width = $BTN_WIDTH

$LBL_Windows10.Size = $LBL_Windows8.Size = $LBL_Windows7.Size = $LBL_WindowsXPENG.Size = $LBL_WindowsXPRUS.Size = $CBOX_SIZE
$LBL_Windows10.Text = $LBL_Windows8.Text = $LBL_Windows7.Text = $LBL_WindowsXPENG.Text = $LBL_WindowsXPRUS.Text = $TXT_OPENS_IN_BROWSER

$GRP_DownloadWindows.Controls.AddRange(
    @($BTN_Windows10, $LBL_Windows10, $BTN_Windows8, $LBL_Windows8, $BTN_Windows7, $LBL_Windows7, $BTN_WindowsXPENG, $LBL_WindowsXPENG, $BTN_WindowsXPRUS, $LBL_WindowsXPRUS)
)



$BTN_Windows10.Text = 'Windows 10 (v1809)'
$BTN_Windows10.Location = $BTN_INIT_LOCATION
$BTN_Windows10.Add_Click( { Open-InBrowser 'http://monkrus.ws/2019/07/windows-10-v1903-jun-rus-eng-x86-x64.html' } )

$LBL_Windows10.Location = $BTN_Windows10.Location + $SHIFT_LBL_BROWSER

$BTN_Windows8.Text = 'Windows 8.1 (Update 3)'
$BTN_Windows8.Location = $BTN_Windows10.Location + $SHIFT_BTN_LONG
$BTN_Windows8.Add_Click( { Open-InBrowser 'rutracker.org/forum/viewtopic.php?t=5109222' } )

$LBL_Windows8.Location = $BTN_Windows8.Location + $SHIFT_LBL_BROWSER

$BTN_Windows7.Text = 'Windows 7 SP1'
$BTN_Windows7.Location = $BTN_Windows8.Location + $SHIFT_BTN_LONG
$BTN_Windows7.Add_Click( { Open-InBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html' } )

$LBL_Windows7.Location = $BTN_Windows7.Location + $SHIFT_LBL_BROWSER


$BTN_WindowsXPENG.Text = 'Windows XP SP3 (ENG)'
$BTN_WindowsXPENG.Location = $BTN_Windows7.Location + $SHIFT_BTN_NORMAL + $SHIFT_CBOX_SHORT
$BTN_WindowsXPENG.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF' } )

$LBL_WindowsXPENG.Location = $BTN_WindowsXPENG.Location + $SHIFT_LBL_BROWSER

$BTN_WindowsXPRUS.Text = 'Windows XP SP3 (RUS)'
$BTN_WindowsXPRUS.Location = $BTN_WindowsXPENG.Location + $SHIFT_BTN_LONG
$BTN_WindowsXPRUS.Add_Click( { Open-InBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR' } )

$LBL_WindowsXPRUS.Location = $BTN_WindowsXPRUS.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Diagnostics - HDD #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_HDD (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_HDD.Text = 'HDD'
$GRP_HDD.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_HDD.Width = $GRP_WIDTH
$GRP_HDD.Location = $GRP_INIT_LOCATION
$TAB_DIAGNOSTICS.Controls.Add($GRP_HDD)

Set-Variable BTN_CheckDisk (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable RBTN_QuickDiskCheck (New-Object System.Windows.Forms.RadioButton) -Option Constant
Set-Variable RBTN_FullDiskCheck (New-Object System.Windows.Forms.RadioButton) -Option Constant

Set-Variable BTN_DownloadVictoria (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartVictoria (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_DownloadRecuva (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartRecuva (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDisk, 'Start (C:) disk health check')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`nRecuva helps restore deleted files")

(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_QuickDiskCheck, 'Perform a quick disk scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_FullDiskCheck, 'Schedule a full disk scan on next restart')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRecuva, $TIP_START_AFTER_DOWNLOAD)

$BTN_CheckDisk.Font = $BTN_DownloadVictoria.Font = $BTN_DownloadRecuva.Font = $BTN_FONT
$BTN_CheckDisk.Height = $BTN_DownloadVictoria.Height = $BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_CheckDisk.Width = $BTN_DownloadVictoria.Width = $BTN_DownloadRecuva.Width = $BTN_WIDTH

$CBOX_StartVictoria.Checked = $CBOX_StartRecuva.Checked = $RBTN_QuickDiskCheck.Checked = $True
$CBOX_StartVictoria.Size = $CBOX_StartRecuva.Size = $CBOX_SIZE
$RBTN_QuickDiskCheck.Size = $RBTN_FullDiskCheck.Size = $RBTN_SIZE
$CBOX_StartVictoria.Text = $CBOX_StartRecuva.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_HDD.Controls.AddRange(@($BTN_CheckDisk, $RBTN_QuickDiskCheck, $RBTN_FullDiskCheck, $BTN_DownloadVictoria, $CBOX_StartVictoria, $BTN_DownloadRecuva, $CBOX_StartRecuva))



$BTN_CheckDisk.Text = "Check (C:) disk health$REQUIRES_ELEVATION"
$BTN_CheckDisk.Location = $BTN_INIT_LOCATION
$BTN_CheckDisk.Add_Click( { Start-DiskCheck $RBTN_FullDiskCheck.Checked } )

$RBTN_QuickDiskCheck.Text = $TXT_QUICK_SCAN
$RBTN_QuickDiskCheck.Location = $BTN_CheckDisk.Location + $SHIFT_RBTN_QUICK_SCAN

$RBTN_FullDiskCheck.Text = $TXT_FULL_SCAN
$RBTN_FullDiskCheck.Location = $RBTN_QuickDiskCheck.Location + $SHIFT_RBTN_FULL_SCAN


$BTN_DownloadVictoria.Text = "Victoria (HDD scan)$REQUIRES_ELEVATION"
$BTN_DownloadVictoria.Location = $BTN_CheckDisk.Location + $SHIFT_BTN_LONG
$BTN_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/Victoria.zip' -Execute:$CBOX_StartVictoria.Checked } )

$CBOX_StartVictoria.Location = $BTN_DownloadVictoria.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartVictoria.Add_CheckStateChanged( { $BTN_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRecuva.Text = "Recuva (restore data)$REQUIRES_ELEVATION"
$BTN_DownloadRecuva.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_DownloadRecuva.Add_Click( { Start-DownloadExtractExecute 'ccleaner.com/recuva/download/portable/downloadfile' 'Recuva.zip' -MultiFile -Execute:$CBOX_StartRecuva.Checked } )

$CBOX_StartRecuva.Location = $BTN_DownloadRecuva.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRecuva.Add_CheckStateChanged( { $BTN_DownloadRecuva.Text = "Recuva (restore data)$(if ($CBOX_StartRecuva.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Diagnostics - RAM and CPU #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_RAMandCPU (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_RAMandCPU.Text = 'RAM and CPU'
$GRP_RAMandCPU.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL + $INT_BTN_LONG * 2
$GRP_RAMandCPU.Width = $GRP_WIDTH
$GRP_RAMandCPU.Location = $GRP_HDD.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_RAMandCPU)

Set-Variable BTN_CheckRAM (New-Object System.Windows.Forms.Button) -Option Constant

Set-Variable BTN_HardwareMonitor (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_HardwareMonitor (New-Object System.Windows.Forms.CheckBox) -Option Constant

Set-Variable BTN_StressTest (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable LBL_StressTest (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HardwareMonitor, 'A utility for measuring CPU and GPU temperature, voltage and frequency')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StressTest, 'Open webpage with a CPU benchmark / stress test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_HardwareMonitor, $TIP_START_AFTER_DOWNLOAD)

$BTN_CheckRAM.Font = $BTN_HardwareMonitor.Font = $BTN_StressTest.Font = $BTN_FONT
$BTN_CheckRAM.Height = $BTN_HardwareMonitor.Height = $BTN_StressTest.Height = $BTN_HEIGHT
$BTN_CheckRAM.Width = $BTN_HardwareMonitor.Width = $BTN_StressTest.Width = $BTN_WIDTH

$GRP_RAMandCPU.Controls.AddRange(@($BTN_CheckRAM, $BTN_HardwareMonitor, $CBOX_HardwareMonitor, $BTN_StressTest, $LBL_StressTest))



$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Location = $BTN_INIT_LOCATION
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )


$BTN_HardwareMonitor.Text = "CPUID HWMonitor$REQUIRES_ELEVATION"
$BTN_HardwareMonitor.Location = $BTN_CheckRAM.Location + $SHIFT_BTN_NORMAL
$BTN_HardwareMonitor.Add_Click( { Start-DownloadExtractExecute 'http://download.cpuid.com/hwmonitor/hwmonitor_1.40.zip' -MultiFile -Execute:$CBOX_HardwareMonitor.Checked } )

$CBOX_HardwareMonitor.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_HardwareMonitor.Checked = $True
$CBOX_HardwareMonitor.Location = $BTN_HardwareMonitor.Location + $SHIFT_CBOX_EXECUTE
$CBOX_HardwareMonitor.Add_CheckStateChanged( { $BTN_HardwareMonitor.Text = "CPUID HWMonitor$(if ($CBOX_HardwareMonitor.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_StressTest.Text = 'CPU Stress Test'
$BTN_StressTest.Location = $BTN_HardwareMonitor.Location + $SHIFT_BTN_LONG
$BTN_StressTest.Add_Click( { Open-InBrowser 'silver.urih.com' } )

$LBL_StressTest.Text = $TXT_OPENS_IN_BROWSER
$LBL_StressTest.Size = $CBOX_SIZE
$LBL_StressTest.Location = $BTN_StressTest.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Diagnostics - Perepherals #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Perepherals (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Perepherals.Text = 'Perepherals'
$GRP_Perepherals.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Perepherals.Width = $GRP_WIDTH
$GRP_Perepherals.Location = $GRP_RAMandCPU.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Perepherals)

Set-Variable BTN_CheckKeyboard (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckMic (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckWebCam (New-Object System.Windows.Forms.Button) -Option Constant

Set-Variable LBL_CheckKeyboard (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckMic (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckWebCam (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMic, 'Open webpage with a microphone test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWebCam, 'Open webpage with a webcam test')

$BTN_CheckKeyboard.Font = $BTN_CheckMic.Font = $BTN_CheckWebCam.Font = $BTN_FONT
$BTN_CheckKeyboard.Height = $BTN_CheckMic.Height = $BTN_CheckWebCam.Height = $BTN_HEIGHT
$BTN_CheckKeyboard.Width = $BTN_CheckMic.Width = $BTN_CheckWebCam.Width = $BTN_WIDTH

$LBL_CheckKeyboard.Size = $LBL_CheckMic.Size = $LBL_CheckWebCam.Size = $CBOX_HardwareMonitor.Size = $CBOX_SIZE
$LBL_CheckKeyboard.Text = $LBL_CheckMic.Text = $LBL_CheckWebCam.Text = $TXT_OPENS_IN_BROWSER

$GRP_Perepherals.Controls.AddRange(@($BTN_CheckKeyboard, $LBL_CheckKeyboard, $BTN_CheckMic, $LBL_CheckMic, $BTN_CheckWebCam, $LBL_CheckWebCam))



$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Location = $BTN_INIT_LOCATION
$BTN_CheckKeyboard.Add_Click( { Open-InBrowser 'onlinemictest.com/keyboard-test' } )

$LBL_CheckKeyboard.Location = $BTN_CheckKeyboard.Location + $SHIFT_LBL_BROWSER


$BTN_CheckMic.Text = 'Check microphone'
$BTN_CheckMic.Location = $BTN_CheckKeyboard.Location + $SHIFT_BTN_LONG
$BTN_CheckMic.Add_Click( { Open-InBrowser 'onlinemictest.com' } )

$LBL_CheckMic.Location = $BTN_CheckMic.Location + $SHIFT_LBL_BROWSER


$BTN_CheckWebCam.Text = 'Check webcam'
$BTN_CheckWebCam.Location = $BTN_CheckMic.Location + $SHIFT_BTN_LONG
$BTN_CheckWebCam.Add_Click( { Open-InBrowser 'onlinemictest.com/webcam-test' } )

$LBL_CheckWebCam.Location = $BTN_CheckWebCam.Location + $SHIFT_LBL_BROWSER


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Diagnostics - Windows #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Windows (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Windows.Text = 'Windows'
$GRP_Windows.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Windows.Width = $GRP_WIDTH
$GRP_Windows.Location = $GRP_HDD.Location + "0, $($GRP_HDD.Height + $INT_NORMAL)"
$TAB_DIAGNOSTICS.Controls.Add($GRP_Windows)

Set-Variable BTN_CheckWindowsHealth (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_RepairWindows (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckSystemFiles (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWindowsHealth, 'Check Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RepairWindows, 'Attempt to restore Windows health')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckSystemFiles, 'Check system file integrity')

$BTN_CheckWindowsHealth.Font = $BTN_RepairWindows.Font = $BTN_CheckSystemFiles.Font = $BTN_FONT
$BTN_CheckWindowsHealth.Height = $BTN_RepairWindows.Height = $BTN_CheckSystemFiles.Height = $BTN_HEIGHT
$BTN_CheckWindowsHealth.Width = $BTN_RepairWindows.Width = $BTN_CheckSystemFiles.Width = $BTN_WIDTH

$GRP_Windows.Controls.AddRange(@($BTN_CheckWindowsHealth, $BTN_RepairWindows, $BTN_CheckSystemFiles))



$BTN_CheckWindowsHealth.Text = "Check Windows health$REQUIRES_ELEVATION"
$BTN_CheckWindowsHealth.Location = $BTN_INIT_LOCATION
$BTN_CheckWindowsHealth.Add_Click( { Test-WindowsHealth } )


$BTN_RepairWindows.Text = "Repair Windows$REQUIRES_ELEVATION"
$BTN_RepairWindows.Location = $BTN_CheckWindowsHealth.Location + $SHIFT_BTN_NORMAL
$BTN_RepairWindows.Add_Click( { Repair-Windows } )


$BTN_CheckSystemFiles.Text = "Check system files$REQUIRES_ELEVATION"
$BTN_CheckSystemFiles.Location = $BTN_RepairWindows.Location + $SHIFT_BTN_NORMAL
$BTN_CheckSystemFiles.Add_Click( { Repair-SystemFiles } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Diagnostics - Security #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Malware (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Malware.Text = 'Security'
$GRP_Malware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_Malware.Width = $GRP_WIDTH
$GRP_Malware.Location = $GRP_Windows.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Malware)

Set-Variable BTN_StartSecurityScan (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable RBTN_QuickSecurityScan (New-Object System.Windows.Forms.RadioButton) -Option Constant
Set-Variable RBTN_FullSecurityScan (New-Object System.Windows.Forms.RadioButton) -Option Constant

Set-Variable BTN_DownloadMalwarebytes (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable CBOX_StartMalwarebytes (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StartSecurityScan, 'Start security scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_QuickSecurityScan, 'Perform a quick security scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_FullSecurityScan, 'Perform a full security scan')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`nMalwarebytes helps remove malware and adware")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartMalwarebytes, $TIP_START_AFTER_DOWNLOAD)

$BTN_StartSecurityScan.Font = $BTN_DownloadMalwarebytes.Font = $BTN_FONT
$BTN_StartSecurityScan.Height = $BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_StartSecurityScan.Width = $BTN_DownloadMalwarebytes.Width = $BTN_WIDTH

$RBTN_QuickSecurityScan.Size = $RBTN_FullSecurityScan.Size = $RBTN_SIZE
$RBTN_QuickSecurityScan.Checked = $CBOX_StartMalwarebytes.Checked = $True

$GRP_Malware.Controls.AddRange(@($BTN_StartSecurityScan, $RBTN_QuickSecurityScan, $RBTN_FullSecurityScan, $BTN_DownloadMalwarebytes, $CBOX_StartMalwarebytes))



$BTN_StartSecurityScan.Text = 'Perform security scan'
$BTN_StartSecurityScan.Location = $BTN_INIT_LOCATION
$BTN_StartSecurityScan.Add_Click( { Start-SecurityScan $RBTN_FullSecurityScan.Checked } )

$RBTN_QuickSecurityScan.Text = $TXT_QUICK_SCAN
$RBTN_QuickSecurityScan.Location = $BTN_StartSecurityScan.Location + $SHIFT_RBTN_QUICK_SCAN

$RBTN_FullSecurityScan.Text = $TXT_FULL_SCAN
$RBTN_FullSecurityScan.Location = $RBTN_QuickSecurityScan.Location + $SHIFT_RBTN_FULL_SCAN


$BTN_DownloadMalwarebytes.Text = "Malwarebytes$REQUIRES_ELEVATION"
$BTN_DownloadMalwarebytes.Location = $BTN_StartSecurityScan.Location + $SHIFT_BTN_LONG
$BTN_DownloadMalwarebytes.Add_Click( { Start-DownloadExtractExecute 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' -Execute:$CBOX_StartMalwarebytes.Checked } )

$CBOX_StartMalwarebytes.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartMalwarebytes.Size = $CBOX_SIZE
$CBOX_StartMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartMalwarebytes.Add_CheckStateChanged( { $BTN_DownloadMalwarebytes.Text = "Malwarebytes$(if ($CBOX_StartMalwarebytes.Checked) {$REQUIRES_ELEVATION})" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Updates #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Updates (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Updates.Text = 'Updates'
$GRP_Updates.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 4 + $INT_BTN_SHORT
$GRP_Updates.Width = $GRP_WIDTH
$GRP_Updates.Location = $GRP_INIT_LOCATION
$TAB_MAINTENANCE.Controls.Add($GRP_Updates)

Set-Variable BTN_GoogleUpdate (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_UpdateStoreApps (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_OfficeInsider (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_UpdateOffice (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_WindowsUpdate (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_GoogleUpdate, 'Silently update Google Chrome and other Google software')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateStoreApps, 'Update Microsoft Store apps')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OfficeInsider, 'Switch Microsoft Office to insider update channel')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_UpdateOffice, 'Update Microsoft Office (for C2R installations only)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsUpdate, 'Check for Windows updates, download and install if available')

$BTN_GoogleUpdate.Font = $BTN_UpdateStoreApps.Font = $BTN_OfficeInsider.Font = $BTN_UpdateOffice.Font = $BTN_WindowsUpdate.Font = $BTN_FONT
$BTN_GoogleUpdate.Height = $BTN_UpdateStoreApps.Height = $BTN_OfficeInsider.Height = $BTN_UpdateOffice.Height = $BTN_WindowsUpdate.Height = $BTN_HEIGHT
$BTN_GoogleUpdate.Width = $BTN_UpdateStoreApps.Width = $BTN_OfficeInsider.Width = $BTN_UpdateOffice.Width = $BTN_WindowsUpdate.Width = $BTN_WIDTH

$GRP_Updates.Controls.AddRange(@($BTN_GoogleUpdate, $BTN_UpdateStoreApps, $BTN_OfficeInsider, $BTN_UpdateOffice, $BTN_WindowsUpdate))



$BTN_GoogleUpdate.Text = 'Update Google Chrome'
$BTN_GoogleUpdate.Location = $BTN_INIT_LOCATION
$BTN_GoogleUpdate.Add_Click( { Start-GoogleUpdate } )


$BTN_UpdateStoreApps.Text = "Update Store apps$REQUIRES_ELEVATION"
$BTN_UpdateStoreApps.Location = $BTN_GoogleUpdate.Location + $SHIFT_BTN_NORMAL
$BTN_UpdateStoreApps.Add_Click( { Start-StoreAppUpdate } )


$BTN_OfficeInsider.Text = "Become Office insider$REQUIRES_ELEVATION"
$BTN_OfficeInsider.Location = $BTN_UpdateStoreApps.Location + $SHIFT_BTN_NORMAL
$BTN_OfficeInsider.Add_Click( { Set-OfficeInsiderChannel } )

$BTN_UpdateOffice.Text = 'Update Microsoft Office'
$BTN_UpdateOffice.Location = $BTN_OfficeInsider.Location + $SHIFT_BTN_SHORT
$BTN_UpdateOffice.Add_Click( { Start-OfficeUpdate } )


$BTN_WindowsUpdate.Text = 'Start Windows Update'
$BTN_WindowsUpdate.Location = $BTN_UpdateOffice.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsUpdate.Add_Click( { Start-WindowsUpdate } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Cleanup (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Cleanup.Text = 'Cleanup'
$GRP_Cleanup.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 6
$GRP_Cleanup.Width = $GRP_WIDTH
$GRP_Cleanup.Location = $GRP_Updates.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Cleanup)

Set-Variable BTN_EmptyRecycleBin (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_FileCleanup (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DiskCleanup (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_RunCCleaner (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_WindowsCleanup (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DeleteRestorePoints (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_EmptyRecycleBin, 'Empty Recycle Bin')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_FileCleanup, 'Remove temporary files, some log files and empty directories, and some other unnecessary files')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DiskCleanup, 'Start Windows built-in disk cleanup utility')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunCCleaner, 'Clean the system in the background with CCleaner')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_WindowsCleanup, 'Remove old versions of system files, which have been changed via updates')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DeleteRestorePoints, 'Delete all restore points (shadow copies)')

$BTN_EmptyRecycleBin.Font = $BTN_FileCleanup.Font = $BTN_DiskCleanup.Font = $BTN_RunCCleaner.Font = $BTN_WindowsCleanup.Font = $BTN_DeleteRestorePoints.Font = $BTN_FONT
$BTN_EmptyRecycleBin.Height = $BTN_FileCleanup.Height = $BTN_DiskCleanup.Height = $BTN_RunCCleaner.Height = $BTN_WindowsCleanup.Height = $BTN_DeleteRestorePoints.Height = $BTN_HEIGHT
$BTN_EmptyRecycleBin.Width = $BTN_FileCleanup.Width = $BTN_DiskCleanup.Width = $BTN_RunCCleaner.Width = $BTN_WindowsCleanup.Width = $BTN_DeleteRestorePoints.Width = $BTN_WIDTH

$GRP_Cleanup.Controls.AddRange(@($BTN_EmptyRecycleBin, $BTN_FileCleanup, $BTN_DiskCleanup, $BTN_RunCCleaner, $BTN_WindowsCleanup, $BTN_DeleteRestorePoints))



$BTN_EmptyRecycleBin.Text = "Empty Recycle Bin$(if($PS_VERSION -le 2) {$REQUIRES_ELEVATION})"
$BTN_EmptyRecycleBin.Location = $BTN_INIT_LOCATION
$BTN_EmptyRecycleBin.Add_Click( { Remove-Trash } )


$BTN_FileCleanup.Text = "File cleanup$REQUIRES_ELEVATION"
$BTN_FileCleanup.Location = $BTN_EmptyRecycleBin.Location + $SHIFT_BTN_NORMAL
$BTN_FileCleanup.Add_Click( { Start-FileCleanup } )


$BTN_DiskCleanup.Text = 'Start disk cleanup'
$BTN_DiskCleanup.Location = $BTN_FileCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DiskCleanup.Add_Click( { Start-DiskCleanup } )


$BTN_RunCCleaner.Text = "Run CCleaner silently$REQUIRES_ELEVATION"
$BTN_RunCCleaner.Location = $BTN_DiskCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_RunCCleaner.Add_Click( { Start-CCleaner } )


$BTN_WindowsCleanup.Text = "Cleanup Windows files$REQUIRES_ELEVATION"
$BTN_WindowsCleanup.Location = $BTN_RunCCleaner.Location + $SHIFT_BTN_NORMAL
$BTN_WindowsCleanup.Add_Click( { Start-WindowsCleanup } )


$BTN_DeleteRestorePoints.Text = "Delete all restore points$REQUIRES_ELEVATION"
$BTN_DeleteRestorePoints.Location = $BTN_WindowsCleanup.Location + $SHIFT_BTN_NORMAL
$BTN_DeleteRestorePoints.Add_Click( { Remove-RestorePoints } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Maintenance - Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable GRP_Optimization (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Optimization.Text = 'Optimization'
$GRP_Optimization.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_Optimization.Width = $GRP_WIDTH
$GRP_Optimization.Location = $GRP_Cleanup.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_MAINTENANCE.Controls.Add($GRP_Optimization)

Set-Variable BTN_CloudFlareDNS (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_OptimizeDrive (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_RunDefraggler (New-Object System.Windows.Forms.Button) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CloudFlareDNS, 'Set DNS server to CouldFlare DNS (1.1.1.1 / 1.0.0.1)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_OptimizeDrive, 'Perform drive optimization (SSD) or defragmentation (HDD)')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_RunDefraggler, 'Perform (C:) drive defragmentation with Defraggler')

$BTN_CloudFlareDNS.Font = $BTN_OptimizeDrive.Font = $BTN_RunDefraggler.Font = $BTN_FONT
$BTN_CloudFlareDNS.Height = $BTN_OptimizeDrive.Height = $BTN_RunDefraggler.Height = $BTN_HEIGHT
$BTN_CloudFlareDNS.Width = $BTN_OptimizeDrive.Width = $BTN_RunDefraggler.Width = $BTN_WIDTH

$GRP_Optimization.Controls.AddRange(@($BTN_CloudFlareDNS, $BTN_OptimizeDrive, $BTN_RunDefraggler))



$BTN_CloudFlareDNS.Text = "Setup CloudFlare DNS$REQUIRES_ELEVATION"
$BTN_CloudFlareDNS.Location = $BTN_INIT_LOCATION
$BTN_CloudFlareDNS.Add_Click( { Set-CloudFlareDNS } )


$BTN_OptimizeDrive.Text = "Optimize / defrag drives$REQUIRES_ELEVATION"
$BTN_OptimizeDrive.Location = $BTN_CloudFlareDNS.Location + $SHIFT_BTN_NORMAL
$BTN_OptimizeDrive.Add_Click( { Start-DriveOptimization } )


$BTN_RunDefraggler.Text = "Run Defraggler for (C:)$REQUIRES_ELEVATION"
$BTN_RunDefraggler.Location = $BTN_OptimizeDrive.Location + $SHIFT_BTN_NORMAL
$BTN_RunDefraggler.Add_Click( { Start-Defraggler } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        $FORM.Text = "$($FORM.Text): Administrator"
        $BTN_Elevate.Text = 'Running as administrator'
        $BTN_Elevate.Enabled = $False
    }

    Get-SystemInfo

    $CBOX_StartAAct.Checked = $CBOX_StartAAct.Enabled = $CBOX_StartChewWGA.Checked = $CBOX_StartChewWGA.Enabled = `
        $CBOX_StartKMSAuto.Checked = $CBOX_StartKMSAuto.Enabled = $CBOX_StartOffice.Checked = $CBOX_StartOffice.Enabled = `
        $CBOX_StartRufus.Checked = $CBOX_StartRufus.Enabled = $CBOX_StartVictoria.Checked = $CBOX_StartVictoria.Enabled = $PS_VERSION -gt 2

    $BTN_WindowsCleanup.Enabled = $BTN_RepairWindows.Enabled = $BTN_UpdateStoreApps.Enabled = $OS_VERSION -gt 7
    $BTN_StartSecurityScan.Enabled = Test-Path $DefenderExe

    Set-ButtonState

    if ($PS_VERSION -lt 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly." }
    elseif ($PS_VERSION -eq 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled." }

    if ($OS_VERSION -lt 7) { Add-Log $WRN "Windows $OS_VERSION detected, while Windows 7 and newer are supported. Some features might not work correctly." }
    elseif ($OS_VERSION -lt 8) { Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported and are disabled." }

    if ($PS_VERSION -gt 2) {
        try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12' }
        catch [Exception] { Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)" }

        try { Add-Type -AssemblyName System.IO.Compression.FileSystem }
        catch [Exception] {
            Add-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
            Set-Variable Shell $(New-Object -com Shell.Application) -Option Constant -Scope Script
        }
    }
    else { Set-Variable Shell $(New-Object -com Shell.Application) -Option Constant -Scope Script }

    Get-CurrentVersion

    if (-not (Test-Path "$PROGRAM_FILES_86\Unchecky\unchecky.exe")) {
        Add-Log $WRN 'Unchecky is not installed.'
        Add-Log $INF 'It is highly recommended to install Unchecky (see Downloads -> Essentials -> Unchecky).'
        Add-Log $INF "$TXT_UNCHECKY_INFO."
    }

    if ($OfficeInstallType -eq 'MSI' -and $OfficeVersion -ge 15) {
        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
        Add-Log $INF 'It is highly recommended to install Click-To-Run (C2R) version instead'
        Add-Log $INF '  (see Downloads -> Essentials -> Office 2013 - 2019).'
        Add-Log $INF 'C2R versions of Office install updates silently in the background with no need to restart computer.'
    }

    if ($SystemPartition) {
        Set-Variable FreeDiskSpace (Get-FreeDiskSpace) -Option Constant
        if ($FreeDiskSpace -le 0.15) {
            Add-Log $WRN "System partition has only $($FreeDiskSpace.ToString('P')) of free space."
            Add-Log $INF 'It is recommended to clean up the disk (see Maintenance -> Cleanup).'
        }
    }

    Set-Variable NetworkAdapter (Get-NetworkAdapter) -Option Constant
    if ($NetworkAdapter) {
        Set-Variable CurrentDnsServer $NetworkAdapter.DNSServerSearchOrder -Option Constant
        if (-not ($CurrentDnsServer -Contains '1.1.1.1' -or $CurrentDnsServer -Contains '1.0.0.1')) {
            Add-Log $WRN 'System is not configured to use CouldFlare DNS.'
            Add-Log $INF 'It is recommended to use CouldFlare DNS for faster domain name resolution and improved'
            Add-Log $INF '  privacy online (see Maintenance -> Optimization -> Setup CouldFlare DNS).'
        }
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Logger #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1)]$Message = $(Write-Host "`n$($MyInvocation.MyCommand.Name): Log message missing" -NoNewline)
    )
    if (-not $Message) { Return }

    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) { $WRN { $LOG.SelectionColor = 'blue' } $ERR { $LOG.SelectionColor = 'red' } Default { $LOG.SelectionColor = 'black' } }
    Write-Log "`n[$((Get-Date).ToString())] $Message"
}


Function Write-Log {
    Param([String]$Text = $(Write-Host "`n$($MyInvocation.MyCommand.Name): Log message missing" -NoNewline))
    if (-not $Text) { Return }

    Write-Host $Text -NoNewline
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


Function Out-Status {
    Param([String]$Status = $(Write-Host "`n$($MyInvocation.MyCommand.Name): No status specified" -NoNewline))
    if (-not $Status) { Return }

    Write-Log ' '

    Set-Variable LogDefaultFont $LOG.Font -Option Constant
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Write-Log $Status

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
}


Function Out-Success { Out-Status 'Done' }

Function Out-Failure { Out-Status 'Failed' }


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Self-Update #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-CurrentVersion {
    if ($PS_VERSION -le 2) { Add-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"; Return }

    Add-Log $INF 'Checking for updates...'

    Set-Variable IsNotConnected (Get-ConnectionStatus) -Option Constant
    if ($IsNotConnected) { Add-Log $ERR "Failed to check for updates: $IsNotConnected"; Return }

    try { Set-Variable LatestVersion ([Version](Invoke-WebRequest 'https://qiiwexc.github.io/d/version').ToString()) -Option Constant }
    catch [Exception] { Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"; Return }

    if ($LatestVersion -gt $VERSION) { Add-Log $WRN "Newer version available: v$LatestVersion"; Get-Update }
    else { Out-Status 'No updates available' }
}


Function Get-Update {
    Set-Variable DownloadURL 'https://qiiwexc.github.io/d/qiiwexc.ps1' -Option Constant
    Set-Variable TargetFile $MyInvocation.ScriptName -Option Constant

    Add-Log $WRN 'Downloading new version...'

    Set-Variable IsNotConnected (Get-ConnectionStatus) -Option Constant
    if ($IsNotConnected) { Add-Log $ERR "Failed to download update: $IsNotConnected"; Return }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to download update: $($_.Exception.Message)"; Return }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-Process 'PowerShell' $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"; Return }

    Exit-Script
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Common #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Open-InBrowser {
    Param([String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"))
    if (-not $URL) { Return }

    Set-Variable UrlToOpen $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL }) -Option Constant
    Add-Log $INF "Opening URL in the default browser: $UrlToOpen"

    try { [System.Diagnostics.Process]::Start($UrlToOpen) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Set-ButtonState {
    $BTN_UpdateOffice.Enabled = $BTN_OfficeInsider.Enabled = $OfficeInstallType -eq 'C2R'
    $BTN_RunCCleaner.Enabled = Test-Path $CCleanerExe
    $BTN_RunDefraggler.Enabled = Test-Path $DefragglerExe
    $BTN_GoogleUpdate.Enabled = Test-Path $GoogleUpdateExe
}


Function Get-FreeDiskSpace { Return ($SystemPartition.FreeSpace / $SystemPartition.Size) }

Function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

Function Get-ConnectionStatus { if (-not (Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download Extract Execute #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No URL specified"),
        [String][Parameter(Position = 1)]$FileName,
        [Switch]$AVWarning, [Switch]$MultiFile, [Switch]$Execute
    )
    if (-not $URL) { Return }

    if ($AVWarning) { Add-Log $WRN $TXT_AV_WARNING }

    if ($PS_VERSION -le 2 -and ($URL -Match 'github.com/*' -or $URL -Match 'github.io/*')) { Open-InBrowser $URL }
    else {
        Set-Variable DownloadedFile (Start-Download $URL $FileName -Temp:$Execute) -Option Constant

        if ($DownloadedFile) {
            Set-Variable IsZip ($DownloadedFile.Substring($DownloadedFile.Length - 4) -eq '.zip') -Option Constant
            Set-Variable Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -MF:$MultiFile } else { $DownloadedFile }) -Option Constant
            if ($Execute) { Start-File $Executable }
        }
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Download {
    Param(
        [String][Parameter(Position = 0)]$URL = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No download URL specified"),
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )
    if (-not $URL) { Return }

    Set-Variable DownloadURL $(if ($URL -like 'http*') { $URL } else { 'https://' + $URL }) -Option Constant
    Set-Variable FileName $(if ($SaveAs) { $SaveAs } else { $DownloadURL.Split('/') | Select-Object -Last 1 }) -Option Constant
    Set-Variable BaseDir $(if ($Temp) { $TEMP_DIR } else { $CURRENT_DIR }) -Option Constant
    Set-Variable SavePath "$BaseDir\$FileName" -Option Constant

    if (-not (Test-Path $BaseDir)) {
        Add-Log $WRN "Download path $BaseDir does not exist. Creating it."
        New-Item $BaseDir -ItemType Directory -Force | Out-Null
    }

    Add-Log $INF "Downloading from $DownloadURL"

    Set-Variable IsNotConnected (Get-ConnectionStatus) -Option Constant
    if ($IsNotConnected) { Add-Log $ERR "Download failed: $IsNotConnected"; Return }

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)
        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] { Add-Log $ERR "Download failed: $($_.Exception.Message)"; Return }

    Return $SavePath
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Extract ZIP #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0)]$FileName = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No file name specified"),
        [Switch][Parameter(Position = 1)][Alias('MF')]$MultiFileArchive
    )
    if (-not $FileName) { Return }

    Add-Log $INF "Extracting $FileName..."

    Set-Variable ExtractionPath $(if ($MultiFileArchive) { $FileName.TrimEnd('.zip') }) -Option Constant

    [String]$TargetDirName = $ExtractionPath
    if ($MultiFileArchive) {
        Remove-Item $TargetDirName -Recurse -Force -ErrorAction SilentlyContinue
        New-Item $TargetDirName -ItemType Directory -Force | Out-Null
    }

    # FIXME: relative vs absolute path
    [String]$Executable = Switch -Wildcard ($FileName) {
        'ChewWGA.zip' { 'CW.eXe' }
        'Office_2013-2019.zip' { 'OInstall.exe' }
        'AAct.zip' { "AAct$(if ($OS_ARCH -eq '64-bit') {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { "KMSAuto$(if ($OS_ARCH -eq '64-bit') {' x64'}).exe" }
        'hwmonitor_*' { "HWMonitor_$(if ($OS_ARCH -eq '64-bit') {'x64'} else {'x32'}).exe" }
        'Recuva.zip' { "$ExtractionPath\recuva$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" }
        'SDI_R*' { "$ExtractionPath\$(if ($OS_ARCH -eq '64-bit') {"$($ExtractionPath.Split('_') -Join '_x64_').exe"} else {"$ExtractionPath.exe"})" }
        Default { $FileName.TrimEnd('.zip') + '.exe' }
    }

    Remove-Item $Executable -Force -ErrorAction SilentlyContinue

    try {
        if (-not $Shell) { [System.IO.Compression.ZipFile]::ExtractToDirectory($FileName, $TargetDirName) }
        else { ForEach ($Item In $Shell.NameSpace($FileName).Items()) { $Shell.NameSpace($TargetDirName).CopyHere($Item) } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $FileName': $($_.Exception.Message)"
        Return
    }

    if ($FileName -eq 'AAct.zip' -or $FileName -eq 'KMSAuto_Lite.zip' -or $FileName -Match 'hwmonitor_*') {
        Set-Variable TempDir $TargetDirName -Option Constant
        [String]$TargetDirName = $CURRENT_DIR

        Move-Item "$TempDir\$Executable" "$TargetDirName\$Executable"
        Remove-Item $TempDir -Recurse -Force
    }

    Out-Success
    Add-Log $INF "Files extracted to $TargetDirName"

    Add-Log $INF "Removing $FileName..."
    Remove-Item $FileName -Force
    Out-Success

    Return $Executable
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Execute File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-File {
    Param(
        [String][Parameter(Position = 0)]$Executable = $(Add-Log $ERR "$($MyInvocation.MyCommand.Name): No executable specified"),
        [String][Parameter(Position = 1)]$Switches, [Switch]$SilentInstall
    )
    if (-not $Executable) { Return }

    if ($Switches -and $SilentInstall) {
        Add-Log $INF "Installing '$Executable' silently..."

        try { Start-Process $Executable $Switches -Wait }
        catch [Exception] { Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"; Return }

        Out-Success

        Add-Log $INF "Removing $Executable..."
        Remove-Item $Executable -Force
        Out-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {
            if ($Switches) { Start-Process $Executable $Switches }
            elseif ($Executable -Match 'SDI_R*') { Start-Process $Executable -WorkingDirectory $Executable.Split('\')[0] }
            else { Start-Process $Executable }
        }
        catch [Exception] { Add-Log $ERR "Failed to execute '$Executable': $($_.Exception.Message)"; Return }

        Out-Success
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Elevated #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Elevated {
    if (-not $IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-Process 'PowerShell' "$($MyInvocation.ScriptName)$(if ($HIDE_CONSOLE) {' -HideConsole'})" -Verb RunAs }
        catch [Exception] { Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"; Return }

        Exit-Script
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# System Information #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-SystemInfo {
    Add-Log $INF 'Gathering system information...'

    Set-Variable OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version) -Option Constant

    Set-Variable OS_NAME $OperatingSystem.Caption -Option Constant -Scope Script
    Set-Variable OS_BUILD $OperatingSystem.Version -Option Constant -Scope Script
    Set-Variable OS_ARCH $(if ($OperatingSystem.OSArchitecture -like '64-*') { '64-bit' } else { '32-bit' }) -Option Constant -Scope Script
    Set-Variable OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } }) -Option Constant -Scope Script

    Set-Variable CURRENT_DIR $(Split-Path $MyInvocation.ScriptName) -Option Constant -Scope Script
    Set-Variable PROGRAM_FILES_86 $(if ($OS_ARCH -eq '64-bit') { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles }) -Option Constant -Scope Script

    New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
    Set-Variable WordRegPath (Get-ItemProperty 'HKCR:\Word.Application\CurVer' -ErrorAction SilentlyContinue) -Option Constant
    Set-Variable OfficeVersion $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' }) -Option Constant -Scope Script
    Set-Variable OfficeC2RClientExe "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -Option Constant -Scope Script
    Set-Variable OfficeInstallType $(if ($OfficeVersion) { if (Test-Path $OfficeC2RClientExe) { 'C2R' } else { 'MSI' } }) -Option Constant -Scope Script

    Set-Variable CCleanerExe "$env:ProgramFiles\CCleaner\CCleaner$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" -Option Constant -Scope Script
    Set-Variable DefragglerExe "$env:ProgramFiles\Defraggler\df$(if ($OS_ARCH -eq '64-bit') {'64'}).exe" -Option Constant -Scope Script
    Set-Variable DefenderExe "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" -Option Constant -Scope Script
    Set-Variable GoogleUpdateExe "$PROGRAM_FILES_86\Google\Update\GoogleUpdate.exe" -Option Constant -Scope Script

    Set-Variable LogicalDisk (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'") -Option Constant
    Set-Variable SystemPartition ($LogicalDisk | Select-Object @{L = 'FreeSpace'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }) -Option Constant -Scope Script

    Out-Success
}


Function Out-SystemInfo {
    Add-Log $INF 'Current system information:'
    Add-Log $INF '  Hardware'

    Set-Variable ComputerSystem (Get-WmiObject Win32_ComputerSystem) -Option Constant
    Set-Variable Computer ($ComputerSystem | Select-Object Manufacturer, Model, SystemSKUNumber, PCSystemType, @{L = 'RAM'; E = { '{0:N2}' -f ($_.TotalPhysicalMemory / 1GB) } }) -Option Constant
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
        Add-Log $INF "    Computer model:  $($Computer.Manufacturer) $($Computer.Model) $(if ($Computer.SystemSKUNumber) {"($($Computer.SystemSKUNumber))"})"
        Add-Log $INF "    RAM:  $($Computer.RAM) GB"
    }

    [Array]$Processors = (Get-WmiObject Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors)
    if ($Processors) {
        ForEach ($Item In $Processors) {
            Add-Log $INF "    CPU $([Array]::IndexOf($Processors, $Item)) Name:  $($Item.Name)"
            Add-Log $INF "    CPU $([Array]::IndexOf($Processors, $Item)) Cores / Threads:  $($Item.NumberOfCores) / $($Item.NumberOfLogicalProcessors)"
        }
    }

    [Array]$VideoControllers = ((Get-WmiObject Win32_VideoController).Name)
    if ($VideoControllers) { ForEach ($Item In $VideoControllers) { Add-Log $INF "    GPU $([Array]::IndexOf($VideoControllers, $Item)):  $Item" } }

    if ($OS_VERSION -gt 7) {
        Set-Variable Storage (Get-PhysicalDisk | Select-Object BusType, FriendlyName, HealthStatus, MediaType, FirmwareVersion, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } }) -Option Constant
        if ($Storage) {
            ForEach ($Item In $Storage) {
                $Details = "$($Item.BusType)$(if ($Item.MediaType -ne 'Unspecified') {' ' + $Item.MediaType}), $($Item.Size) GB, $($Item.HealthStatus), Firmware: $($Item.FirmwareVersion)"
                Add-Log $INF "    Storage $([Array]::IndexOf($Storage, $Item)):  $($Item.FriendlyName) ($Details)"
            }
        }
    }
    else {
        [Array]$Storage = (Get-WmiObject Win32_DiskDrive | Select-Object Model, Status, FirmwareRevision, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })
        if ($Storage) { ForEach ($Item In $Storage) { Add-Log $INF "    Storage:  $($Item.Model) ($($Item.Size) GB, Health: $($Item.Status), Firmware: $($Item.FirmwareRevision))" } }
    }

    if ($SystemPartition) {
        Add-Log $INF "    Free space on system partition: $($SystemPartition.FreeSpace) GB / $($SystemPartition.Size) GB ($((Get-FreeDiskSpace).ToString('P')))"
    }

    Set-Variable OfficeYear $(Switch ($OfficeVersion) { 16 { '2016 / 2019' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } }) -Option Constant
    Set-Variable OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' }) -Option Constant
    Set-Variable Win10Release ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId) -Option Constant

    Add-Log $INF '  Software'
    Add-Log $INF "    BIOS version:  $((Get-WmiObject Win32_BIOS).SMBIOSBIOSVersion)"
    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $OS_ARCH"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$Win10Release / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OfficeInstallType) {`"($OfficeInstallType installation type)`"})"
    Add-Log $INF "    PowerShell version:  $PS_VERSION.$($PSVersionTable.PSVersion.Minor)"

    Set-ButtonState
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-NiniteButtonState {
    $CBOX_StartNinite.Enabled = $BTN_DownloadNinite.Enabled = $CBOX_7zip.Checked -or $CBOX_VLC.Checked -or $CBOX_TeamViewer.Checked -or `
        $CBOX_Skype.Checked -or $CBOX_Chrome.Checked -or $CBOX_qBittorrent.Checked -or $CBOX_GoogleDrive.Checked -or $CBOX_VSCode.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Name }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Name }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Name }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Name }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Name }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Name }
    if ($CBOX_GoogleDrive.Checked) { $Array += $CBOX_GoogleDrive.Name }
    if ($CBOX_VSCode.Checked) { $Array += $CBOX_VSCode.Name }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CBOX_7zip.Checked) { $Array += $CBOX_7zip.Text }
    if ($CBOX_VLC.Checked) { $Array += $CBOX_VLC.Text }
    if ($CBOX_TeamViewer.Checked) { $Array += $CBOX_TeamViewer.Text }
    if ($CBOX_Skype.Checked) { $Array += $CBOX_Skype.Text }
    if ($CBOX_Chrome.Checked) { $Array += $CBOX_Chrome.Text }
    if ($CBOX_qBittorrent.Checked) { $Array += $CBOX_qBittorrent.Text }
    if ($CBOX_GoogleDrive.Checked) { $Array += $CBOX_GoogleDrive.Text }
    if ($CBOX_VSCode.Checked) { $Array += $CBOX_VSCode.Text }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Check HDD #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DiskCheck {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    Add-Log $INF 'Starting (C:) disk health check...'

    Set-Variable Parameters $(if ($FullScan) { "'/B'" } elseif ($OS_VERSION -gt 7) { "'/scan /perf'" }) -Option Constant

    try { Start-Process 'PowerShell' "-Command `"(Get-Host).UI.RawUI.WindowTitle = 'Disk check running...'; Start-Process 'chkdsk' $Parameters -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check (C:) disk health: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Check RAM #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-MemoryCheckTool {
    Add-Log $INF 'Starting memory checking tool...'

    try { Start-Process 'mdsched' }
    catch [Exception] { Add-Log $ERR "Failed to start memory checking tool: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Check Windows Health #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Test-WindowsHealth {
    Add-Log $INF 'Starting Windows health check...'

    Set-Variable SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Checking Windows health...'" -Option Constant

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /ScanHealth' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check Windows health: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-Windows {
    Add-Log $INF 'Starting Windows repair...'

    Set-Variable SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Repairing Windows...'" -Option Constant

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /RestoreHealth' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to repair Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Repair-SystemFiles {
    Add-Log $INF 'Starting system file integrity check...'

    try { Start-Process 'PowerShell' "-Command (Get-Host).UI.RawUI.WindowTitle = 'Checking system files...'; Start-Process 'sfc' '/scannow' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check system file integrity: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Security #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-SecurityScan {
    Param([Switch][Parameter(Position = 0)]$FullScan)

    if ($OS_VERSION -gt 7) {
        Add-Log $INF 'Updating security signatures...'

        [String]$SetTitle = "(Get-Host).UI.RawUI.WindowTitle = 'Updating security signatures...'"

        try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process '$DefenderExe' '-SignatureUpdate' -NoNewWindow`"" -Wait }
        catch [Exception] { Add-Log $ERR "Failed to update security signatures: $($_.Exception.Message)"; Return }

        Out-Success
    }

    Set-Variable Mode $(if ($FullScan) { 'full' } else { 'quick' }) -Option Constant

    Add-Log $INF "Starting $Mode security scan..."

    [String]$SetTitle = "(Get-Host).UI.RawUI.WindowTitle = '$((Get-Culture).TextInfo.ToTitleCase($Mode)) security scan running...'"

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process '$DefenderExe' '-Scan -ScanType $(if ($FullScan) {2} else {1})' -NoNewWindow`"" -Wait }
    catch [Exception] { Add-Log $ERR "Failed to perform a $Mode security scan: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Updates #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-GoogleUpdate {
    Add-Log $INF 'Starting Google Update...'

    try { Start-Process $GoogleUpdateExe '/c' }
    catch [Exception] { Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"; Return }

    try { Start-Process $GoogleUpdateExe '/ua /installsource scheduler' }
    catch [Exception] { Add-Log $ERR "Failed to update Google software: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-StoreAppUpdate {
    Add-Log $INF 'Starting Microsoft Store apps update...'

    Set-Variable Command "(Get-WmiObject MDM_EnterpriseModernAppManagement_AppManagement01 -Namespace 'root\cimv2\mdm\dmmap').UpdateScanMethod()" -Option Constant
    try { Start-Process 'PowerShell' "-Command `"$Command`"" -Verb RunAs -Wait -WindowStyle Hidden }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Store apps: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Set-OfficeInsiderChannel {
    Add-Log $INF 'Switching Microsoft Office to insider update channel...'

    try { Start-Process $OfficeC2RClientExe '/changesetting Channel="InsiderFast"' -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to switch Microsoft Office update channel: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-OfficeUpdate {
    Add-Log $INF 'Starting Microsoft Office update...'

    try { Start-Process $OfficeC2RClientExe '/update user' -Wait }
    catch [Exception] { Add-Log $ERR "Failed to update Microsoft Office: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-WindowsUpdate {
    Add-Log $INF 'Starting Windows Update...'

    try { if ($OS_VERSION -gt 7) { Start-Process 'UsoClient' 'StartInteractiveScan' -Wait } else { Start-Process 'wuauclt' '/detectnow /updatenow' -Wait } }
    catch [Exception] { Add-Log $ERR "Failed to update Windows: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# File Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-FileCleanup {
    Set-Variable LogMessage 'Removing unnecessary files...' -Option Constant
    Add-Log $INF $LogMessage

    Set-Variable ContainerJava86 "${env:ProgramFiles(x86)}\Java" -Option Constant
    Set-Variable ContainerJava "$env:ProgramFiles\Java" -Option Constant
    Set-Variable ContainerOpera "$env:ProgramFiles\Opera" -Option Constant
    Set-Variable ContainerChrome "$PROGRAM_FILES_86\Google\Chrome\Application" -Option Constant
    Set-Variable ContainerChromeBeta "$PROGRAM_FILES_86\Google\Chrome Beta\Application" -Option Constant
    Set-Variable ContainerChromeDev "$PROGRAM_FILES_86\Google\Chrome Dev\Application" -Option Constant
    Set-Variable ContainerGoogleUpdate "$PROGRAM_FILES_86\Google\Update" -Option Constant

    Set-Variable NonVersionedDirectories @('Assets', 'Download', 'Install', 'Offline', 'SetupMetrics') -Option Constant
    Set-Variable Containers @($ContainerJava86, $ContainerJava, $ContainerOpera, $ContainerChrome, $ContainerChromeBeta, $ContainerChromeDev, $ContainerGoogleUpdate) -Option Constant

    Set-Variable NewestJava86 $(if (Test-Path $ContainerJava86) { Get-ChildItem $ContainerJava86 -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant
    Set-Variable NewestJava $(if (Test-Path $ContainerJava) { Get-ChildItem $ContainerJava -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant
    Set-Variable NewestOpera $(if (Test-Path $ContainerOpera) { Get-ChildItem $ContainerOpera -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant
    Set-Variable NewestChrome $(if (Test-Path $ContainerChrome) { Get-ChildItem $ContainerChrome -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant
    Set-Variable NewestChromeBeta $(if (Test-Path $ContainerChromeBeta) { Get-ChildItem $ContainerChromeBeta -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant
    Set-Variable NewestChromeDev $(if (Test-Path $ContainerChromeDev) { Get-ChildItem $ContainerChromeDev -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant
    Set-Variable NewestGoogleUpdate $(if (Test-Path $ContainerGoogleUpdate) { Get-ChildItem $ContainerGoogleUpdate -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }) -Option Constant

    ForEach ($Path In $Containers) {
        if (Test-Path $Path) {
            Add-Log $INF "Removing older versions from $Path"

            [String]$Newest = (Get-ChildItem $Path -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1).Name
            Get-ChildItem $Path -Exclude $NonVersionedDirectories $Newest | Where-Object { $_.PSIsContainer } | ForEach-Object { Remove-Item $_ -Recurse -Force }

            if (Test-Path $Path) { Out-Failure } else { Out-Success }
        }
    }

    Set-Variable ItemsToDeleteWithExclusions -Option Constant -Value @(
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Resource*.dll;TeamViewer_Resource_en.dll,TeamViewer_Resource_ru.dll"
        "$PROGRAM_FILES_86\WinSCP\Translations;WinSCP.ru"
        "$env:ProgramFiles\7-Zip\Lang;en.ttt,lv.txt,ru.txt"
        "$env:ProgramFiles\CCleaner\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\Defraggler\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\Google\Drive\Languages;lv,ru"
        "$env:ProgramFiles\Malwarebytes\Anti-Malware\Languages;lang_ru.qm"
        "$env:ProgramFiles\Microsoft VS Code\locales;en-US.pak,lv.pak,ru.pak"
        "$env:ProgramFiles\Oracle\VirtualBox\nls;qt_ru.qm,VirtualBox_ru.qm"
        "$env:ProgramFiles\paint.net\Resources;ru"
        "$env:ProgramFiles\qBittorrent\translations;qt_lv.qm,qt_ru.qm,qtbase_lv.qm,qtbase_ru.qm"
        "$env:ProgramFiles\Recuva\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\VideoLAN\VLC\locale;lv,ru"
        "$NewestOpera\localization;en-US.pak,lv.pak,ru.pak"
        "$NewestChrome\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestChromeBeta\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestChromeDev\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestGoogleUpdate\goopdateres_*.dll;goopdateres_en-GB.dll,goopdateres_en-US.dll,goopdateres_lv.dll,goopdateres_ru.dll"
        "$env:LocalAppData\Microsoft\Teams\locales;en-US.pak,lv.pak,ru.pak"
        "$env:LocalAppData\Microsoft\Teams\resources\locales;locale-en-us.json,locale-lv-lv.json,locale-ru-ru.json"
    )

    ForEach ($Item In $ItemsToDeleteWithExclusions) {
        [String]$Path, [String]$Exclusions = $Item.Split(';')

        if (Test-Path $Path) {
            Add-Log $INF "Cleaning $Path"
            Get-ChildItem $Path -Exclude $Exclusions.Split(',') | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
            Out-Success
        }
    }

    Set-Variable ItemsToDelete -Option Constant -Value @(
        "$NewestJava86\COPYRIGHT"
        "$NewestJava86\LICENSE"
        "$NewestJava86\release"
        "$NewestJava86\*.html"
        "$NewestJava86\*.txt"
        "$NewestJava\COPYRIGHT"
        "$NewestJava\LICENSE"
        "$NewestJava\release"
        "$NewestJava\*.html"
        "$NewestJava\*.txt"
        "$NewestChrome\default_apps"
        "$NewestChrome\default_apps\*"
        "$NewestChrome\Installer"
        "$NewestChrome\Installer\*"
        "$NewestChromeBeta\default_apps"
        "$NewestChromeBeta\default_apps\*"
        "$NewestChromeBeta\Installer"
        "$NewestChromeBeta\Installer\*"
        "$NewestChromeDev\default_apps"
        "$NewestChromeDev\default_apps\*"
        "$NewestChromeDev\Installer"
        "$NewestChromeDev\Installer\*"
        "$NewestGoogleUpdate\Recovery"
        "$NewestGoogleUpdate\Recovery\*"
        "$env:SystemDrive\Intel"
        "$env:SystemDrive\Intel\*"
        "$env:SystemDrive\Intel\Logs\*"
        "$env:SystemDrive\PerfLogs"
        "$env:SystemDrive\PerfLogs\*"
        "$env:SystemDrive\temp"
        "$env:SystemDrive\temp\*"
        "$env:ProgramData\Adobe"
        "$env:ProgramData\Adobe\*"
        "$env:ProgramData\Kontiki\*.log"
        "$env:ProgramData\Kollective\*.log"
        "$env:ProgramData\Pulse Secure\Logging"
        "$env:ProgramData\SymEFASI"
        "$env:ProgramData\SymEFASI\*"
        "$env:ProgramData\UIU"
        "$env:ProgramData\UIU\*"
        "$env:ProgramData\Pulse Secure\Logging\*"
        "$env:ProgramData\Microsoft\Windows Defender\Scans\History\Results\Quick\*"
        "$env:ProgramData\Microsoft\Windows Defender\Scans\History\Results\Resource\*"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip\7-Zip Help.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Docs.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Sheets.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Slides.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\CCleaner\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Defraggler\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\About Java.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\License (English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\User manual (CHM, English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\User manual (PDF, English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY (64-bit)\PuTTY Manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY (64-bit)\PuTTY Web Site.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY\PuTTY Manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY\PuTTY Web Site.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Recuva\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Steam\Steam Support Center.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\Documentation.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\Release Notes.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VideoLAN Website.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VLC media player - reset preferences and cache files.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN\VLC media player skinned.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\Console RAR manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\What is new in the latest version.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\WinRAR\WinRAR help.lnk"
        "$env:ProgramData\Microsoft\Windows\WER\ReportArchive\*"
        "$env:ProgramData\Mozilla"
        "$env:ProgramData\Mozilla\*"
        "$env:ProgramData\NVIDIA Corporation\NvFBCPlugin"
        "$env:ProgramData\NVIDIA Corporation\umdlogs"
        "$env:ProgramData\NVIDIA Corporation\umdlogs\*"
        "$env:ProgramData\NVIDIA\*.log_backup1"
        "$env:ProgramData\Oracle"
        "$env:ProgramData\Oracle\*"
        "$env:ProgramData\Package Cache"
        "$env:ProgramData\Package Cache\*"
        "$env:ProgramData\Razer\GameManager\Logs"
        "$env:ProgramData\Razer\GameManager\Logs\*"
        "$env:ProgramData\Razer\Installer\Logs"
        "$env:ProgramData\Razer\Installer\Logs\*"
        "$env:ProgramData\Razer\Razer Central\Logs"
        "$env:ProgramData\Razer\Razer Central\Logs\*"
        "$env:ProgramData\Razer\Razer Central\WebAppCache\Service Worker\Database\*.log"
        "$env:ProgramData\Razer\Synapse3\CrashDumps"
        "$env:ProgramData\Razer\Synapse3\CrashDumps\*"
        "$env:ProgramData\Razer\Synapse3\Log"
        "$env:ProgramData\Razer\Synapse3\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Charlotte\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Charlotte\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Lib\DetectManager\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Lib\DetectManager\Log\*"
        "$env:ProgramData\Razer\Synapse3\Service\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Log\*"
        "$env:ProgramData\Roaming"
        "$env:ProgramData\Roaming\*"
        "$env:ProgramData\USOShared"
        "$env:ProgramData\USOShared\*"
        "$env:ProgramData\VirtualBox"
        "$env:ProgramData\VirtualBox\*"
        "$env:ProgramData\WindowsHolographicDevices"
        "$env:ProgramData\WindowsHolographicDevices\*"
        "$PROGRAM_FILES_86\7-Zip\7-zip.chm"
        "$PROGRAM_FILES_86\7-Zip\7-zip.dll.tmp"
        "$PROGRAM_FILES_86\7-Zip\descript.ion"
        "$PROGRAM_FILES_86\7-Zip\History.txt"
        "$PROGRAM_FILES_86\7-Zip\License.txt"
        "$PROGRAM_FILES_86\7-Zip\readme.txt"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\Legal\ENU\*"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\ReadMe.htm"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Resource\ENUtxt.pdf"
        "$PROGRAM_FILES_86\CCleaner\Setup"
        "$PROGRAM_FILES_86\CCleaner\Setup\*"
        "$PROGRAM_FILES_86\Dolby\Dolby DAX3\API\amd64\Microsoft.VC90.CRT\README_ENU.txt"
        "$PROGRAM_FILES_86\Dolby\Dolby DAX3\API\x86\Microsoft.VC90.CRT\README_ENU.txt"
        "$PROGRAM_FILES_86\FileZilla FTP Client\AUTHORS"
        "$PROGRAM_FILES_86\FileZilla FTP Client\GPL.html"
        "$PROGRAM_FILES_86\FileZilla FTP Client\NEWS"
        "$PROGRAM_FILES_86\Foxit Software\Foxit Reader\notice.txt"
        "$PROGRAM_FILES_86\Git\LICENSE.txt"
        "$PROGRAM_FILES_86\Git\mingw64\doc"
        "$PROGRAM_FILES_86\Git\mingw64\doc\*"
        "$PROGRAM_FILES_86\Git\ReleaseNotes.html"
        "$PROGRAM_FILES_86\Git\tmp"
        "$PROGRAM_FILES_86\Git\tmp\*"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics\*"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Temp"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Temp\*"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics\*"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Temp"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Temp\*"
        "$PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics\*"
        "$PROGRAM_FILES_86\Google\Chrome\Temp"
        "$PROGRAM_FILES_86\Google\Chrome\Temp\*"
        "$PROGRAM_FILES_86\Google\CrashReports"
        "$PROGRAM_FILES_86\Google\CrashReports\*"
        "$PROGRAM_FILES_86\Google\Update\Download"
        "$PROGRAM_FILES_86\Google\Update\Download\*"
        "$PROGRAM_FILES_86\Google\Update\Install"
        "$PROGRAM_FILES_86\Google\Update\Install\*"
        "$PROGRAM_FILES_86\Google\Update\Offline"
        "$PROGRAM_FILES_86\Google\Update\Offline\*"
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\*.html"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses\*"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$PROGRAM_FILES_86\Mozilla Firefox\install.log"
        "$PROGRAM_FILES_86\Mozilla Maintenance Service\logs"
        "$PROGRAM_FILES_86\Mozilla Maintenance Service\logs\*"
        "$PROGRAM_FILES_86\Notepad++\change.log"
        "$PROGRAM_FILES_86\Notepad++\readme.txt"
        "$PROGRAM_FILES_86\Notepad++\updater\LICENSE"
        "$PROGRAM_FILES_86\Notepad++\updater\README.md"
        "$PROGRAM_FILES_86\NVIDIA Corporation\Ansel\Tools\tools_licenses.txt"
        "$PROGRAM_FILES_86\NVIDIA Corporation\license.txt"
        "$PROGRAM_FILES_86\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\doc"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\doc\*"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\License_en_US.rtf"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\VirtualBox.chm"
        "$PROGRAM_FILES_86\paint.net\License.txt"
        "$PROGRAM_FILES_86\paint.net\Staging"
        "$PROGRAM_FILES_86\paint.net\Staging\*"
        "$PROGRAM_FILES_86\PuTTY\LICENCE"
        "$PROGRAM_FILES_86\PuTTY\putty.chm"
        "$PROGRAM_FILES_86\PuTTY\README.txt"
        "$PROGRAM_FILES_86\PuTTY\website.url"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\Licenses"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\Licenses\*"
        "$PROGRAM_FILES_86\Steam\dumps"
        "$PROGRAM_FILES_86\Steam\dumps\*"
        "$PROGRAM_FILES_86\Steam\logs"
        "$PROGRAM_FILES_86\Steam\logs\*"
        "$PROGRAM_FILES_86\TeamViewer\*.log"
        "$PROGRAM_FILES_86\TeamViewer\*.txt"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Note.exe"
        "$PROGRAM_FILES_86\VideoLAN\VLC\AUTHORS.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\COPYING.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\Documentation.url"
        "$PROGRAM_FILES_86\VideoLAN\VLC\New_Skins.url"
        "$PROGRAM_FILES_86\VideoLAN\VLC\NEWS.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\README.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\THANKS.txt"
        "$PROGRAM_FILES_86\VideoLAN\VLC\VideoLAN Website.url"
        "$PROGRAM_FILES_86\WinRAR\Descript.ion"
        "$PROGRAM_FILES_86\WinRAR\License.txt"
        "$PROGRAM_FILES_86\WinRAR\Order.htm"
        "$PROGRAM_FILES_86\WinRAR\Rar.txt"
        "$PROGRAM_FILES_86\WinRAR\ReadMe.txt"
        "$PROGRAM_FILES_86\WinRAR\WhatsNew.txt"
        "$PROGRAM_FILES_86\WinRAR\WinRAR.chm"
        "$PROGRAM_FILES_86\WinSCP\license.txt"
        "$PROGRAM_FILES_86\WinSCP\PuTTY\LICENCE"
        "$PROGRAM_FILES_86\WinSCP\PuTTY\putty.chm"
        "$env:ProgramFiles\7-Zip\7-zip.chm"
        "$env:ProgramFiles\7-Zip\7-zip.dll.tmp"
        "$env:ProgramFiles\7-Zip\descript.ion"
        "$env:ProgramFiles\7-Zip\History.txt"
        "$env:ProgramFiles\7-Zip\License.txt"
        "$env:ProgramFiles\7-Zip\readme.txt"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\Legal\ENU\*"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\ReadMe.htm"
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Resource\ENUtxt.pdf"
        "$env:ProgramFiles\CCleaner\Setup"
        "$env:ProgramFiles\CCleaner\Setup\*"
        "$env:ProgramFiles\Dolby\Dolby DAX3\API\amd64\Microsoft.VC90.CRT\README_ENU.txt"
        "$env:ProgramFiles\Dolby\Dolby DAX3\API\x86\Microsoft.VC90.CRT\README_ENU.txt"
        "$env:ProgramFiles\FileZilla FTP Client\AUTHORS"
        "$env:ProgramFiles\FileZilla FTP Client\GPL.html"
        "$env:ProgramFiles\FileZilla FTP Client\NEWS"
        "$env:ProgramFiles\Foxit Software\Foxit Reader\notice.txt"
        "$env:ProgramFiles\Git\LICENSE.txt"
        "$env:ProgramFiles\Git\mingw64\doc"
        "$env:ProgramFiles\Git\ReleaseNotes.html"
        "$env:ProgramFiles\Git\tmp"
        "$env:ProgramFiles\Git\tmp\*"
        "$env:ProgramFiles\Google\Chrome Beta\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome Beta\Application\SetupMetrics\*"
        "$env:ProgramFiles\Google\Chrome Beta\Temp"
        "$env:ProgramFiles\Google\Chrome Beta\Temp\*"
        "$env:ProgramFiles\Google\Chrome Dev\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome Dev\Application\SetupMetrics\*"
        "$env:ProgramFiles\Google\Chrome Dev\Temp"
        "$env:ProgramFiles\Google\Chrome Dev\Temp\*"
        "$env:ProgramFiles\Google\Chrome\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome\Application\SetupMetrics\*"
        "$env:ProgramFiles\Google\Chrome\Temp"
        "$env:ProgramFiles\Google\Chrome\Temp\*"
        "$env:ProgramFiles\Google\CrashReports"
        "$env:ProgramFiles\Google\CrashReports\*"
        "$env:ProgramFiles\Google\Update\Download"
        "$env:ProgramFiles\Google\Update\Download\*"
        "$env:ProgramFiles\Google\Update\Install"
        "$env:ProgramFiles\Google\Update\Install\*"
        "$env:ProgramFiles\Google\Update\Offline"
        "$env:ProgramFiles\Google\Update\Offline\*"
        "$env:ProgramFiles\Microsoft\Skype for Desktop\*.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses\*"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$env:ProgramFiles\Mozilla Firefox\install.log"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs\*"
        "$env:ProgramFiles\NVIDIA Corporation\Ansel\Tools\tools_licenses.txt"
        "$env:ProgramFiles\NVIDIA Corporation\license.txt"
        "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$env:ProgramFiles\Oracle\VirtualBox\doc"
        "$env:ProgramFiles\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$env:ProgramFiles\Oracle\VirtualBox\License_en_US.rtf"
        "$env:ProgramFiles\Oracle\VirtualBox\VirtualBox.chm"
        "$env:ProgramFiles\paint.net\License.txt"
        "$env:ProgramFiles\PuTTY\LICENCE"
        "$env:ProgramFiles\PuTTY\putty.chm"
        "$env:ProgramFiles\PuTTY\README.txt"
        "$env:ProgramFiles\PuTTY\website.url"
        "$env:ProgramFiles\Razer\Razer Services\Razer Central\Licenses"
        "$env:ProgramFiles\Razer\Razer Services\Razer Central\Licenses\*"
        "$env:ProgramFiles\Steam\dumps"
        "$env:ProgramFiles\Steam\dumps\*"
        "$env:ProgramFiles\Steam\logs"
        "$env:ProgramFiles\Steam\logs\*"
        "$env:ProgramFiles\TeamViewer\*.log"
        "$env:ProgramFiles\TeamViewer\*.txt"
        "$env:ProgramFiles\TeamViewer\TeamViewer_Note.exe"
        "$env:ProgramFiles\VideoLAN\VLC\AUTHORS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\COPYING.txt"
        "$env:ProgramFiles\VideoLAN\VLC\Documentation.url"
        "$env:ProgramFiles\VideoLAN\VLC\New_Skins.url"
        "$env:ProgramFiles\VideoLAN\VLC\NEWS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\README.txt"
        "$env:ProgramFiles\VideoLAN\VLC\THANKS.txt"
        "$env:ProgramFiles\VideoLAN\VLC\VideoLAN Website.url"
        "$env:ProgramFiles\WinRAR\Descript.ion"
        "$env:ProgramFiles\WinRAR\License.txt"
        "$env:ProgramFiles\WinRAR\Order.htm"
        "$env:ProgramFiles\WinRAR\Rar.txt"
        "$env:ProgramFiles\WinRAR\ReadMe.txt"
        "$env:ProgramFiles\WinRAR\WhatsNew.txt"
        "$env:ProgramFiles\WinRAR\WinRAR.chm"
        "$env:ProgramFiles\WinSCP\license.txt"
        "$env:ProgramFiles\WinSCP\PuTTY\LICENCE"
        "$env:ProgramFiles\WinSCP\PuTTY\putty.chm"
        "$env:WinDir\*.log"
        "$env:WinDir\debug\*.log"
        "$env:WinDir\INF\*.log"
        "$env:WinDir\Logs\*"
        "$env:WinDir\Microsoft.NET\Framework\*\*.log"
        "$env:WinDir\Microsoft.NET\Framework64\*\*.log"
        "$env:WinDir\Performance\WinSAT\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0_32\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v2.0\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0_32\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0\*.log"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0\UsageLogs"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\CLR_v4.0\UsageLogs\*"
        "$env:WinDir\ServiceProfiles\NetworkService\AppData\Local\Temp\*"
        "$env:WinDir\SoftwareDistribution\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0_32\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0_32\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v2.0\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0_32\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\*.log"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\UsageLogs"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Microsoft\CLR_v4.0\UsageLogs\*"
        "$env:WinDir\System32\config\systemprofile\AppData\Local\Temp\*"
        "$env:WinDir\Temp\*"
        "$env:WinDir\SoftwareDistribution\Download\*"
        "$env:TMP\*"
        "$env:Public\Foxit Software"
        "$env:Public\Foxit Software\*"
        "$env:UserProfile\.VirtualBox\*.log*"
        "$env:UserProfile\MicrosoftEdgeBackups"
        "$env:UserProfile\MicrosoftEdgeBackups\*"
        "$env:AppData\Code\logs"
        "$env:AppData\Code\logs\*"
        "$env:AppData\Google"
        "$env:AppData\Google\*"
        "$env:AppData\hpqLog"
        "$env:AppData\hpqLog\*"
        "$env:AppData\Microsoft\Office\Recent"
        "$env:AppData\Microsoft\Office\Recent\*"
        "$env:AppData\Microsoft\Skype for Desktop\logs"
        "$env:AppData\Microsoft\Skype for Desktop\logs\*"
        "$env:AppData\Microsoft Teams\logs"
        "$env:AppData\Microsoft Teams\logs\*"
        "$env:AppData\Microsoft\Windows\Recent\*.*"
        "$env:AppData\Opera Software\Opera Stable\*.log"
        "$env:AppData\Opera Software\Opera Stable\Crash Reports"
        "$env:AppData\Opera Software\Opera Stable\Crash Reports\*"
        "$env:AppData\Skype"
        "$env:AppData\Skype\*"
        "$env:AppData\Sun"
        "$env:AppData\Sun\*"
        "$env:AppData\Synapse3"
        "$env:AppData\Synapse3\*"
        "$env:AppData\TeamViewer\*.log"
        "$env:AppData\Visual Studio Code"
        "$env:AppData\Visual Studio Code\*"
        "$env:AppData\vlc\art"
        "$env:AppData\vlc\art\*"
        "$env:AppData\vlc\crashdump"
        "$env:AppData\vlc\crashdump\*"
        "$env:LocalAppData\CrashDumps"
        "$env:LocalAppData\CrashDumps\*"
        "$env:LocalAppData\DBG"
        "$env:LocalAppData\DBG\*"
        "$env:LocalAppData\Deployment"
        "$env:LocalAppData\Deployment\*"
        "$env:LocalAppData\Diagnostics"
        "$env:LocalAppData\Diagnostics\*"
        "$env:LocalAppData\Google\CrashReports"
        "$env:LocalAppData\Google\CrashReports\*"
        "$env:LocalAppData\Google\Software Reporter Tool"
        "$env:LocalAppData\Google\Software Reporter Tool\*"
        "$env:LocalAppData\LocalLow\AuthClient-4-VIP\logs"
        "$env:LocalAppData\LocalLow\AuthClient-4-VIP\logs\*"
        "$env:LocalAppData\LocalLow\PKI Client"
        "$env:LocalAppData\LocalLow\PKI Client\*"
        "$env:LocalAppData\LocalLow\Sun"
        "$env:LocalAppData\LocalLow\Sun\*"
        "$env:LocalAppData\Microsoft\CLR_v2.0_32\*.log"
        "$env:LocalAppData\Microsoft\CLR_v2.0_32\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v2.0_32\UsageLogs\*"
        "$env:LocalAppData\Microsoft\CLR_v2.0\*.log"
        "$env:LocalAppData\Microsoft\CLR_v2.0\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v2.0\UsageLogs\*"
        "$env:LocalAppData\Microsoft\CLR_v4.0_32\*.log"
        "$env:LocalAppData\Microsoft\CLR_v4.0_32\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v4.0_32\UsageLogs\*"
        "$env:LocalAppData\Microsoft\CLR_v4.0\*.log"
        "$env:LocalAppData\Microsoft\CLR_v4.0\UsageLogs"
        "$env:LocalAppData\Microsoft\CLR_v4.0\UsageLogs\*"
        "$env:LocalAppData\Microsoft\Media Player\lastplayed.wpl"
        "$env:LocalAppData\Microsoft\Office\16.0\WebServiceCache"
        "$env:LocalAppData\Microsoft\Office\16.0\WebServiceCache\*"
        "$env:LocalAppData\Microsoft\OneDrive\logs"
        "$env:LocalAppData\Microsoft\OneDrive\logs\*"
        "$env:LocalAppData\Microsoft\OneDrive\setup"
        "$env:LocalAppData\Microsoft\OneDrive\setup\*"
        "$env:LocalAppData\Microsoft\Teams\*.log"
        "$env:LocalAppData\Microsoft\Teams\*.log"
        "$env:LocalAppData\Microsoft\Teams\current\resources\ThirdPartyNotices.txt"
        "$env:LocalAppData\Microsoft\Teams\packages\*.nupkg"
        "$env:LocalAppData\Microsoft\Teams\packages\SquirrelTemp"
        "$env:LocalAppData\Microsoft\Teams\packages\SquirrelTemp\*"
        "$env:LocalAppData\Microsoft\Teams\previous"
        "$env:LocalAppData\Microsoft\Teams\previous\*"
        "$env:LocalAppData\Microsoft\Windows\Explorer\thumbcache_*.db"
        "$env:LocalAppData\Microsoft\Windows\SettingSync\metastore\*.log"
        "$env:LocalAppData\Microsoft\Windows\SettingSync\remotemetastore\v1\*.log"
        "$env:LocalAppData\Microsoft\Windows\WebCache\*.log"
        "$env:LocalAppData\PeerDistRepub"
        "$env:LocalAppData\PeerDistRepub\*"
        "$env:LocalAppData\Razer\Synapse3\Log"
        "$env:LocalAppData\Razer\Synapse3\Log\*"
        "$env:LocalAppData\VirtualStore"
        "$env:LocalAppData\VirtualStore\*"
    )

    ForEach ($Item In $ItemsToDelete) {
        if (Test-Path $Item) {
            Add-Log $INF "Removing $Item"
            Remove-Item $Item -Recurse -Force -ErrorAction SilentlyContinue
            if (Test-Path $Item) { Out-Failure } else { Out-Success }
        }
    }

    if (-not $IS_ELEVATED) {
        Add-Log $WRN 'Removal of certain files requires administrator privileges. To remove them, restart the utility'
        Add-Log $WRN '  as administrator (see Home -> This utility -> Run as administrator) and run this task again.'
    }
    else { Add-Log $INF 'Some files are in use, so they cannot be deleted.' }

    Add-Log $INF $LogMessage
    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# System Cleanup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Remove-Trash {
    Add-Log $INF 'Emptying Recycle Bin...'

    try {
        if ($PS_VERSION -ge 5) { Clear-RecycleBin -Force }
        else {
            Set-Variable Command '(New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force }' -Option Constant
            Start-Process 'PowerShell' "-Command `"$Command`"" -Verb RunAs -WindowStyle Hidden
        }
    }
    catch [Exception] { Add-Log $ERR "Failed to empty Recycle Bin: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process 'cleanmgr' '/lowdisk' -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-CCleaner {
    if (-not $CCleanerWarningShown) {
        Add-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Add-Log $WRN 'Click the button again to continue'
        Set-Variable CCleanerWarningShown $True -Option Constant -Scope Script
        Return
    }

    Add-Log $INF 'Starting CCleaner background task...'

    try { Start-Process $CCleanerExe '/auto' }
    catch [Exception] { Add-Log $ERR "Failed to start CCleaner: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-WindowsCleanup {
    Add-Log $INF 'Starting Windows update cleanup...'

    Set-Variable SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Cleaning Windows...'" -Option Constant

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process 'DISM' '/Online /Cleanup-Image /StartComponentCleanup' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to cleanup Windows updates: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Remove-RestorePoints {
    Add-Log $INF 'Deleting all restore points...'

    Set-Variable SetTitle "(Get-Host).UI.RawUI.WindowTitle = 'Deleting restore points...'" -Option Constant

    try { Start-Process 'PowerShell' "-Command `"$SetTitle; Start-Process 'vssadmin' 'delete shadows /all /quiet' -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-CloudFlareDNS {
    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF 'Changing DNS server to CloudFlare DNS (1.1.1.1 / 1.0.0.1)...'

    if (-not (Get-NetworkAdapter)) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        Return
    }

    Set-Variable Command "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('1.1.1.1', '1.0.0.1'))" -Option Constant
    try { Start-Process 'PowerShell' "-Command `"$Command`"" -Verb RunAs -WindowStyle Hidden }
    catch [Exception] { Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-DriveOptimization {
    Add-Log $INF 'Starting drive optimization...'

    Set-Variable Parameters $(if ($OS_VERSION -gt 7) { "'/C /H /U /O'" } else { "'C: /H /U'" }) -Option Constant

    try { Start-Process 'PowerShell' "-Command `"(Get-Host).UI.RawUI.WindowTitle = 'Optimizing drives...'; Start-Process 'defrag' $Parameters -NoNewWindow`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to optimize drives: $($_.Exception.Message)"; Return }

    Out-Success
}


Function Start-Defraggler {
    Add-Log $INF 'Starting (C:) drive optimization with Defraggler...'

    try { Start-Process $DefragglerExe 'C:' -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed start Defraggler: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Draw Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

[Void]$FORM.ShowDialog()
