$_VERSION = "19.2.28"


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Disclaimer #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

<#

To execute, right-click the file, then select "Run with PowerShell".
Double click will simply open the file in Notepad.

#>


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Initialization #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_HOST = Get-Host
$_HOST.UI.RawUI.WindowTitle = "qiiwexc v$_VERSION"

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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_FORM_HEIGHT = 580
$_FORM_WIDTH = 650
$_FORM_FONT_TYPE = 'Microsoft Sans Serif'

$_INTERVAL_SHORT = 5
$_INTERVAL_NORMAL = 15
$_INTERVAL_LONG = 40

$_INTERVAL_TAB_ADJUSTMENT = 4
$_INTERVAL_GROUP_TOP = 20

$_BUTTON_HEIGHT = 28
$_BUTTON_INTERVAL_SHORT = $_BUTTON_HEIGHT + $_INTERVAL_SHORT
$_BUTTON_INTERVAL_NORMAL = $_BUTTON_HEIGHT + $_INTERVAL_NORMAL
$_BUTTON_FONT = "$_FORM_FONT_TYPE, 10"


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
$_FORM.Controls.Add($_LOG)


$_TAB_CONTROL = New-Object System.Windows.Forms.TabControl
$_TAB_CONTROL.Size = "$($_FORM_WIDTH - $_INTERVAL_SHORT - $_INTERVAL_TAB_ADJUSTMENT), $($_FORM_HEIGHT - $_LOG.Height - $_INTERVAL_SHORT - $_INTERVAL_TAB_ADJUSTMENT)"
$_TAB_CONTROL.Location = "$_INTERVAL_SHORT, $_INTERVAL_SHORT"
$_FORM.Controls.Add($_TAB_CONTROL)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Home #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_BUTTON_WIDTH_HOME = 180

$_TAB_HOME = New-Object System.Windows.Forms.TabPage
$_TAB_HOME.Text = 'Home'
$_TAB_HOME.UseVisualStyleBackColor = $True
$_TAB_CONTROL.Controls.Add($_TAB_HOME)

$ButtonSystemInformation = New-Object System.Windows.Forms.Button
$ButtonSystemInformation.Text = 'Show system information'
$ButtonSystemInformation.Height = $_BUTTON_HEIGHT
$ButtonSystemInformation.Width = $_BUTTON_WIDTH_HOME
$ButtonSystemInformation.Location = "$($_INTERVAL_NORMAL + $_INTERVAL_SHORT), $($_INTERVAL_NORMAL + $_INTERVAL_SHORT)"
$ButtonSystemInformation.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSystemInformation, 'Print system information to the log')
$ButtonSystemInformation.Add_Click( {PrintSystemInformation} )
$_TAB_HOME.Controls.Add($ButtonSystemInformation)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# This Utility #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupHomeThisUtility = New-Object System.Windows.Forms.GroupBox
$GroupHomeThisUtility.Text = 'This utility'
$GroupHomeThisUtility.Height = $_INTERVAL_GROUP_TOP + $_BUTTON_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL
$GroupHomeThisUtility.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_HOME + $_INTERVAL_NORMAL
$GroupHomeThisUtility.Location = "$($_TAB_CONTROL.Width - $GroupHomeThisUtility.Width - $_INTERVAL_NORMAL - $_INTERVAL_TAB_ADJUSTMENT), $_INTERVAL_NORMAL"
$_TAB_HOME.Controls.Add($GroupHomeThisUtility)


$ButtonBrowserHome = New-Object System.Windows.Forms.Button
$ButtonBrowserHome.Text = 'Open in browser'
$ButtonBrowserHome.Height = $_BUTTON_HEIGHT
$ButtonBrowserHome.Width = $_BUTTON_WIDTH_HOME
$ButtonBrowserHome.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonBrowserHome.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonBrowserHome, 'Open utility web page in the default browser')
$ButtonBrowserHome.Add_Click( {OpenInBrowser 'qiiwexc.github.io'} )
$GroupHomeThisUtility.Controls.Add($ButtonBrowserHome)


$ButtonCheckForUpdates = New-Object System.Windows.Forms.Button
$ButtonCheckForUpdates.Text = 'Check for updates'
$ButtonCheckForUpdates.Height = $_BUTTON_HEIGHT
$ButtonCheckForUpdates.Width = $_BUTTON_WIDTH_HOME
$ButtonCheckForUpdates.Location = $ButtonBrowserHome.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonCheckForUpdates.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonCheckForUpdates, 'Check if new version of this utility is available')
$ButtonCheckForUpdates.Add_Click( {CheckForUpdates $True} )
$GroupHomeThisUtility.Controls.Add($ButtonCheckForUpdates)

$ButtonDownloadUpdate = New-Object System.Windows.Forms.Button
$ButtonDownloadUpdate.Text = 'Download new version'
$ButtonDownloadUpdate.Height = $ButtonCheckForUpdates.Height
$ButtonDownloadUpdate.Width = $_BUTTON_WIDTH_HOME
$ButtonDownloadUpdate.Location = $ButtonCheckForUpdates.Location
$ButtonDownloadUpdate.Font = $_BUTTON_FONT
$ButtonDownloadUpdate.Visible = $False
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadUpdate, 'Download the new version of this utility')
$ButtonDownloadUpdate.Add_Click( {DownloadUpdate} )
$GroupHomeThisUtility.Controls.Add($ButtonDownloadUpdate)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Downloads #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_BUTTON_WIDTH_DOWNLOAD = 160

$_TAB_DOWNLOADS = New-Object System.Windows.Forms.TabPage
$_TAB_DOWNLOADS.Text = 'Downloads'
$_TAB_DOWNLOADS.UseVisualStyleBackColor = $True
$_TAB_CONTROL.Controls.Add($_TAB_DOWNLOADS)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Installers (Software) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

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
$ButtonDownloadOffice.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Office_2013-2019.zip'} )
$GroupDownloadsInstallersSoftware.Controls.Add($ButtonDownloadOffice)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Installers (Tools) #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsInstallersTools = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsInstallersTools.Text = 'Installers: Tools'
$GroupDownloadsInstallersTools.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 2 + $_BUTTON_INTERVAL_SHORT * 2 + $_INTERVAL_SHORT
$GroupDownloadsInstallersTools.Width = $GroupDownloadsInstallersSoftware.Width
$GroupDownloadsInstallersTools.Location = $GroupDownloadsInstallersSoftware.Location + "$($GroupDownloadsInstallersSoftware.Width + $_INTERVAL_NORMAL), 0"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsInstallersTools)


$ButtonDownloadCCleaner = New-Object System.Windows.Forms.Button
$ButtonDownloadCCleaner.Text = 'CCleaner'
$ButtonDownloadCCleanerToolTipText = "Download CCleaner installer"
$ButtonDownloadCCleaner.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadCCleaner.Height = $_BUTTON_HEIGHT
$ButtonDownloadCCleaner.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadCCleaner, $ButtonDownloadCCleanerToolTipText)
$ButtonDownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadCCleaner)

$ButtonDownloadDefraggler = New-Object System.Windows.Forms.Button
$ButtonDownloadDefraggler.Text = 'Defraggler'
$ButtonDownloadDefragglerToolTipText = "Download Defraggler installer"
$ButtonDownloadDefraggler.Location = $ButtonDownloadCCleaner.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadDefraggler.Height = $_BUTTON_HEIGHT
$ButtonDownloadDefraggler.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadDefraggler.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadDefraggler, $ButtonDownloadDefragglerToolTipText)
$ButtonDownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadDefraggler)

$ButtonDownloadRecuva = New-Object System.Windows.Forms.Button
$ButtonDownloadRecuva.Text = 'Recuva'
$ButtonDownloadRecuvaToolTipText = "Download Recuva installer`rRecuva helps restore deleted files"
$ButtonDownloadRecuva.Location = $ButtonDownloadDefraggler.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadRecuva.Height = $_BUTTON_HEIGHT
$ButtonDownloadRecuva.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadRecuva.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRecuva, $ButtonDownloadRecuvaToolTipText)
$ButtonDownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadRecuva)


$ButtonDownloadMalwarebytes = New-Object System.Windows.Forms.Button
$ButtonDownloadMalwarebytes.Text = 'Malwarebytes'
$ButtonDownloadMalwarebytesToolTipText = "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware"
$ButtonDownloadMalwarebytes.Location = $ButtonDownloadRecuva.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadMalwarebytes.Height = $_BUTTON_HEIGHT
$ButtonDownloadMalwarebytes.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadMalwarebytes.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadMalwarebytes, $ButtonDownloadMalwarebytesToolTipText)
$ButtonDownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'ninite_malwarebytes_setup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadMalwarebytes)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Activators #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsActivators.Text = 'Activators'
$GroupDownloadsActivators.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 2 + $_INTERVAL_SHORT
$GroupDownloadsActivators.Width = $GroupDownloadsInstallersSoftware.Width
$GroupDownloadsActivators.Location = $GroupDownloadsInstallersSoftware.Location + "0, $($GroupDownloadsInstallersSoftware.Height + $_INTERVAL_NORMAL + 2)"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsActivators)


$ButtonDownloadKMS = New-Object System.Windows.Forms.Button
$ButtonDownloadKMS.Text = 'KMSAuto Lite'
$ButtonDownloadKMSToolTipText = "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019"
$ButtonDownloadKMS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadKMS.Height = $_BUTTON_HEIGHT
$ButtonDownloadKMS.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadKMS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadKMS, $ButtonDownloadKMSToolTipText)
$ButtonDownloadKMS.Add_Click( {DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip'} )
$GroupDownloadsActivators.Controls.Add($ButtonDownloadKMS)

$ButtonDownloadChew = New-Object System.Windows.Forms.Button
$ButtonDownloadChew.Text = 'ChewWGA'
$ButtonDownloadChewToolTipText = "Download ChewWGA`rFor activating hopeless Windows 7 installations"
$ButtonDownloadChew.Location = $ButtonDownloadKMS.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadChew.Height = $_BUTTON_HEIGHT
$ButtonDownloadChew.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadChew.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChew, $ButtonDownloadChewToolTipText)
$ButtonDownloadChew.Add_Click( {DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip'} )
$GroupDownloadsActivators.Controls.Add($ButtonDownloadChew)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Tools #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsTools = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsTools.Text = 'Tools'
$GroupDownloadsTools.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_SHORT * 3 + $_INTERVAL_NORMAL
$GroupDownloadsTools.Width = $GroupDownloadsInstallersTools.Width
$GroupDownloadsTools.Location = $GroupDownloadsInstallersTools.Location + "0, $($GroupDownloadsInstallersTools.Height + $_INTERVAL_NORMAL)"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsTools)


$ButtonDownloadSDI = New-Object System.Windows.Forms.Button
$ButtonDownloadSDI.Text = 'Snappy Driver Installer'
$ButtonDownloadSDIToolTipText = "Download Snappy Driver Installer"
$ButtonDownloadSDI.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadSDI.Height = $_BUTTON_HEIGHT
$ButtonDownloadSDI.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadSDI.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadSDI, $ButtonDownloadSDIToolTipText)
$ButtonDownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip'} )
$GroupDownloadsTools.Controls.Add($ButtonDownloadSDI)


$ButtonDownloadVictoria = New-Object System.Windows.Forms.Button
$ButtonDownloadVictoria.Text = 'Victoria'
$ButtonDownloadVictoriaToolTipText = "Download Victoria HDD scanner"
$ButtonDownloadVictoria.Location = $ButtonDownloadSDI.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadVictoria.Height = $_BUTTON_HEIGHT
$ButtonDownloadVictoria.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadVictoria.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadVictoria, $ButtonDownloadVictoriaToolTipText)
$ButtonDownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria_4.47.zip'} )
$GroupDownloadsTools.Controls.Add($ButtonDownloadVictoria)


$ButtonDownloadRufus = New-Object System.Windows.Forms.Button
$ButtonDownloadRufus.Text = 'Rufus'
$ButtonDownloadRufusToolTipText = "Download Rufus - a bootable USB creator"
$ButtonDownloadRufus.Location = $ButtonDownloadVictoria.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadRufus.Height = $_BUTTON_HEIGHT
$ButtonDownloadRufus.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadRufus.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRufus, $ButtonDownloadRufusToolTipText)
$ButtonDownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe'} )
$GroupDownloadsTools.Controls.Add($ButtonDownloadRufus)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Windows Images #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$GroupDownloadsWindows = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsWindows.Text = 'Windows ISO Images'
$GroupDownloadsWindows.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 3 + $_BUTTON_INTERVAL_SHORT * 3 + $_INTERVAL_SHORT
$GroupDownloadsWindows.Width = $GroupDownloadsInstallersTools.Width
$GroupDownloadsWindows.Location = $GroupDownloadsInstallersTools.Location + "$($GroupDownloadsInstallersTools.Width + $_INTERVAL_NORMAL), 0"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsWindows)


$ButtonDownloadWindows10 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows10.Text = 'Windows 10'
$ButtonDownloadWindows10ToolTipText = "Download $($ButtonDownloadWindows10.Text) (v1809-Jan) RUS-ENG x86-x64 -36in1- KMS (AIO) ISO image`r(Opens in browser)"
$ButtonDownloadWindows10.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadWindows10.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows10.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadWindows10.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows10, $ButtonDownloadWindows10ToolTipText)
$ButtonDownloadWindows10.Add_Click( {OpenInBrowser 'http://monkrus.ws/2019/01/windows-10-v1809-jan-rus-eng-x86-x64.html'} )
$GroupDownloadsWindows.Controls.Add($ButtonDownloadWindows10)

$ButtonDownloadWindows8 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows8.Text = 'Windows 8.1'
$ButtonDownloadWindows8ToolTipText = "Download $($ButtonDownloadWindows8.Text) with Update 3 RUS-ENG x86-x64 -16in1- Activated (AIO) ISO image`r(Opens in browser)"
$ButtonDownloadWindows8.Location = $ButtonDownloadWindows10.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadWindows8.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows8.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadWindows8.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows8, $ButtonDownloadWindows8ToolTipText)
$ButtonDownloadWindows8.Add_Click( {OpenInBrowser 'rutracker.org/forum/viewtopic.php?t=5109222'} )
$GroupDownloadsWindows.Controls.Add($ButtonDownloadWindows8)

$ButtonDownloadWindows7 = New-Object System.Windows.Forms.Button
$ButtonDownloadWindows7.Text = 'Windows 7'
$ButtonDownloadWindows7ToolTipText = "Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v5 (AIO) ISO image`r(Opens in browser)"
$ButtonDownloadWindows7.Location = $ButtonDownloadWindows8.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadWindows7.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindows7.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadWindows7.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindows7, $ButtonDownloadWindows7ToolTipText)
$ButtonDownloadWindows7.Add_Click( {OpenInBrowser 'http://monkrus.ws/2018/03/windows-7-sp1-ie11-rus-eng-x86-x64.html'} )
$GroupDownloadsWindows.Controls.Add($ButtonDownloadWindows7)


$ButtonDownloadWindowsXPENG = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsXPENG.Text = 'Windows XP (ENG)'
$ButtonDownloadWindowsXPENGToolTipText = "Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image`r(Opens in browser)"
$ButtonDownloadWindowsXPENG.Location = $ButtonDownloadWindows7.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadWindowsXPENG.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsXPENG.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadWindowsXPENG.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsXPENG, $ButtonDownloadWindowsXPENGToolTipText)
$ButtonDownloadWindowsXPENG.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1TO6cR3QiicCcAxcRba65L7nMvWTaFQaF'} )
$GroupDownloadsWindows.Controls.Add($ButtonDownloadWindowsXPENG)

$ButtonDownloadWindowsXPRUS = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsXPRUS.Text = 'Windows XP (RUS)'
$ButtonDownloadWindowsXPRUSToolTipText = "Download Windows XP SP3 (RUS) + Office 2010 SP2 (RUS) [v17.5.6] ISO image`r(Opens in browser)"
$ButtonDownloadWindowsXPRUS.Location = $ButtonDownloadWindowsXPENG.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadWindowsXPRUS.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsXPRUS.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadWindowsXPRUS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsXPRUS, $ButtonDownloadWindowsXPRUSToolTipText)
$ButtonDownloadWindowsXPRUS.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1mgs56mX2-dQMk9e5KaXhODLBWXipmLCR'} )
$GroupDownloadsWindows.Controls.Add($ButtonDownloadWindowsXPRUS)


$ButtonDownloadWindowsPE = New-Object System.Windows.Forms.Button
$ButtonDownloadWindowsPE.Text = 'Windows PE'
$ButtonDownloadWindowsPEToolTipText = "Download Windows PE (Live CD) ISO image`r(Opens in browser)"
$ButtonDownloadWindowsPE.Location = $ButtonDownloadWindowsXPRUS.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadWindowsPE.Height = $_BUTTON_HEIGHT
$ButtonDownloadWindowsPE.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadWindowsPE.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadWindowsPE, $ButtonDownloadWindowsPEToolTipText)
$ButtonDownloadWindowsPE.Add_Click( {OpenInBrowser 'drive.google.com/uc?id=1IYwATgzmKmlc79lVi0ivmWM2aPJObmq_'} )
$GroupDownloadsWindows.Controls.Add($ButtonDownloadWindowsPE)


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Startup #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Startup {
    $_FORM.Activate()
    $Timestamp = (Get-Date).ToString()
    $_LOG.AppendText("[$Timestamp] Initializing...")
    GatherSystemInformation
    CheckForUpdates
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Logger #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_INF = 'INF'
$_WRN = 'WRN'
$_ERR = 'ERR'

function Write-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    $_LOG.SelectionStart = $_LOG.TextLength

    switch ($Level) { $_WRN {$_LOG.SelectionColor = 'blue'} $_ERR {$_LOG.SelectionColor = 'red'} }

    Write-Host $Text
    $_LOG.AppendText("`n$Text")
    $_LOG.SelectionColor = 'black'
    $_LOG.ScrollToCaret();
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Self-Update #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function CheckForUpdates ($IsManualCheck) {
    $VersionURL = 'https://qiiwexc.github.io/d/version'
    Write-Log $_INF 'Checking for updates...'

    try {$LatestVersion = (Invoke-WebRequest -Uri $VersionURL).ToString() -Replace "`n",''}
    catch [Exception] {Write-Log $_ERR "Failed to check for update: $($_.Exception.Message)"}

    $UpdateAvailable = [DateTime]::ParseExact($LatestVersion, 'yy.M.d', $null) -gt [DateTime]::ParseExact($_VERSION, 'yy.M.d', $null)

    if ($UpdateAvailable) {
        Write-Log $_WRN "Newer version available: v$LatestVersion"
        $ButtonCheckForUpdates.Visible = $False
        $ButtonDownloadUpdate.Visible = $True
        if (!$IsManualCheck) {DownloadUpdate}
    }
    else {Write-Log $_INF 'Currently running the latest version'}
}

function DownloadUpdate {
    $DownloadURL = 'https://qiiwexc.github.io/d/qiiwexc.ps1'
    $TargetFile = $MyInvocation.ScriptName

    Write-Log $_WRN 'Downloading new version...'

    try {Invoke-WebRequest -Uri $DownloadURL -OutFile $TargetFile}
    catch [Exception] {Write-Log $_ERR "Failed to download update: $($_.Exception.Message)"}

    RestartAfterUpdate
}


function RestartAfterUpdate {
    Write-Log $_WRN 'Restarting...'

    try {Start-Process -FilePath 'powershell' -ArgumentList $TargetFile}
    catch [Exception] {Write-Log $_ERR "Failed to start new version: $($_.Exception.Message)"}

    $_FORM.Close()
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


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Open In Browser #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

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


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Download File #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function DownloadFile ($URL, $FileName) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $DownloadURL = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    $SavePath = if ($FileName) {$FileName} else {$DownloadURL | Split-Path -Leaf}

    Write-Log $_INF "Downloading from $DownloadURL"

    try {
        (New-Object System.Net.WebClient).DownloadFile($DownloadURL, $SavePath)

        if (Test-Path "$SavePath") {Write-Log $_WRN 'Download complete'}
        else {throw 'Possibly computer is offline or disk is full'}
    }
    catch [Exception] {Write-Log $_ERR "Download failed: $($_.Exception.Message)"}
}


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# Draw Form #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$_FORM.ShowDialog() | Out-Null
