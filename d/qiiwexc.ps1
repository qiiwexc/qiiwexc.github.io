Set-Variable -Option Constant Version ([Version]'25.7.2')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Info #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

<#

-=-=-=-=-=-= README =-=-=-=-=-=-

To execute, right-click the file, then select "Run with PowerShell".

Double click will simply open the file in Notepad.


-=-=-=-= TROUBLESHOOTING =-=-=-=-

If a window briefly opens and closes, press Win+R on the keyboard, paste the following and click OK:

    PowerShell -Command "Start-Process 'PowerShell' -Verb RunAs '-Command Set-ExecutionPolicy RemoteSigned -Force'"

Now you can try starting the utility again

#>


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Constants #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant BUTTON_WIDTH    170
Set-Variable -Option Constant BUTTON_HEIGHT   30

Set-Variable -Option Constant CHECKBOX_HEIGHT ($BUTTON_HEIGHT - 10)


Set-Variable -Option Constant INTERVAL_BUTTON ($BUTTON_HEIGHT + 15)

Set-Variable -Option Constant INTERVAL_CHECKBOX ($CHECKBOX_HEIGHT + 5)


Set-Variable -Option Constant GROUP_WIDTH (15 + $BUTTON_WIDTH + 15)

Set-Variable -Option Constant FORM_WIDTH  (($GROUP_WIDTH + 15) * 3 + 30)
Set-Variable -Option Constant FORM_HEIGHT 560

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "15, 20"

Set-Variable -Option Constant SHIFT_CHECKBOX "0, $INTERVAL_CHECKBOX"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"


Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Set-Variable -Option Constant PATH_TEMP_DIR "$env:TMP\qiiwexc"
Set-Variable -Option Constant PATH_PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })

Set-Variable -Option Constant IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
Set-Variable -Option Constant REQUIRES_ELEVATION $(if (!$IS_ELEVATED) { ' *' } else { '' })


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# URLs #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant URL_WINDOWS_11 'https://w16.monkrus.ws/2025/01/windows-11-v24h2-rus-eng-20in1-hwid-act.html'
Set-Variable -Option Constant URL_WINDOWS_10 'https://w16.monkrus.ws/2022/11/windows-10-v22h2-rus-eng-x86-x64-32in1.html'
Set-Variable -Option Constant URL_WINDOWS_7  'https://w16.monkrus.ws/2024/02/windows-7-sp1-rus-eng-x86-x64-18in1.html'

Set-Variable -Option Constant URL_RUFUS    'https://github.com/pbatard/rufus/releases/download/v4.9/rufus-4.9p.exe'
Set-Variable -Option Constant URL_VENTOY   'https://github.com/ventoy/Ventoy/releases/download/v1.1.05/ventoy-1.1.05-windows.zip'
Set-Variable -Option Constant URL_SDIO     'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.15.5.816.zip'
Set-Variable -Option Constant URL_VICTORIA 'https://hdd.by/Victoria/Victoria537.zip'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Initialization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Write-Host 'Initializing...'

Set-Variable -Option Constant OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

Set-Variable -Option Constant StartedFromGUI $($MyInvocation.Line -Match 'if((Get-ExecutionPolicy ) -ne ''AllSigned'')*')
Set-Variable -Option Constant HIDE_CONSOLE ($args[0] -eq '-HideConsole' -or $StartedFromGUI -or !$MyInvocation.Line)

if ($HIDE_CONSOLE) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try { Add-Type -AssemblyName System.Windows.Forms } catch { Throw 'System not supported' }

[System.Windows.Forms.Application]::EnableVisualStyles()


Set-Variable -Option Constant PS_VERSION $($PSVersionTable.PSVersion.Major)

Set-Variable -Option Constant SHELL $(New-Object -com Shell.Application)

Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)
Set-Variable -Option Constant OS_NAME $OperatingSystem.Caption
Set-Variable -Option Constant OS_BUILD $OperatingSystem.Version
Set-Variable -Option Constant OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -Like '*64') { $True })
Set-Variable -Option Constant OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } })

Set-Variable -Option Constant WordRegPath (Get-ItemProperty "$(New-PSDrive HKCR Registry HKEY_CLASSES_ROOT):\Word.Application\CurVer" -ErrorAction SilentlyContinue)
Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
Set-Variable -Option Constant PathOfficeC2RClientExe "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PathOfficeC2RClientExe) { 'C2R' } else { 'MSI' } })


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Structural #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-Tab {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant TabPage (New-Object System.Windows.Forms.TabPage)

    $TabPage.UseVisualStyleBackColor = $True
    $TabPage.Text = $Text

    $TAB_CONTROL.Controls.Add($TabPage)

    Set-Variable -Scope Script PREVIOUS_GROUP $Null
    Set-Variable -Scope Script CURRENT_TAB $TabPage
}

Function New-GroupBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [Int][Parameter(Position = 1)]$IndexOverride
    )

    Set-Variable -Option Constant GroupBox (New-Object System.Windows.Forms.GroupBox)

    Set-Variable -Scope Script PREVIOUS_GROUP $CURRENT_GROUP

    [Int]$GroupIndex = 0

    if ($IndexOverride) {
        $GroupIndex = $IndexOverride
    }
    else {
        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
    }

    if ($GroupIndex -lt 3) {
        Set-Variable -Option Constant Location $(if ($GroupIndex -eq 0) { "15, 15" } else { $PREVIOUS_GROUP.Location + "$($GROUP_WIDTH + 15), 0" })
    }
    else {
        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
        Set-Variable -Option Constant Location ($PreviousGroup.Location + "0, $($PreviousGroup.Height + 15)")
    }

    $GroupBox.Width = $GROUP_WIDTH
    $GroupBox.Text = $Text
    $GroupBox.Location = $Location

    $CURRENT_TAB.Controls.Add($GroupBox)

    Set-Variable -Scope Script PREVIOUS_BUTTON $Null
    Set-Variable -Scope Script PREVIOUS_RADIO $Null
    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null

    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Button #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-ButtonBrowser {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function
    )

    New-Button $Text $Function > $Null

    New-Label 'Opens in the browser' > $Null
}

Function New-Button {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [ScriptBlock][Parameter(Position = 1)]$Function,
        [Switch]$Disabled,
        [Switch]$UAC
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_RADIO) {
        $PreviousLabelOrCheckboxY = if ($PREVIOUS_LABEL_OR_CHECKBOX) { $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y } else { 0 }
        $PreviousRadioY = if ($PREVIOUS_RADIO) { $PREVIOUS_RADIO.Location.Y } else { 0 }

        $PreviousMiscElement = if ($PreviousLabelOrCheckboxY -gt $PreviousRadioY) { $PreviousLabelOrCheckboxY } else { $PreviousRadioY }

        $InitialLocation.Y = $PreviousMiscElement
        $Shift = "0, 30"
    }
    elseif ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "0, $INTERVAL_BUTTON"
    }


    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $Button.Font = $BUTTON_FONT
    $Button.Height = $BUTTON_HEIGHT
    $Button.Width = $BUTTON_WIDTH
    $Button.Enabled = !$Disabled
    $Button.Location = $Location

    $Button.Text = if ($UAC) { "$Text$REQUIRES_ELEVATION" } else { $Text }

    if ($Function) { $Button.Add_Click($Function) }

    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON
    $CURRENT_GROUP.Controls.Add($Button)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
    Set-Variable -Scope Script PREVIOUS_RADIO $Null
    Set-Variable -Scope Script PREVIOUS_BUTTON $Button

    Return $Button
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - CheckBox #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-CheckBoxRunAfterDownload {
    Param(
        [Switch]$Disabled,
        [Switch]$Checked
    )

    Return New-CheckBox 'Start after download' -Disabled:$Disabled -Checked:$Checked
}

Function New-CheckBox {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [String][Parameter(Position = 1)]$Name,
        [Switch]$Disabled,
        [Switch]$Checked
    )

    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "$INTERVAL_CHECKBOX, 30"
    }

    if ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $InitialLocation.Y = $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y

        if ($CURRENT_GROUP.Text -eq "Ninite") {
            $Shift = "0, $INTERVAL_CHECKBOX"
        }
        else {
            $Shift = "$INTERVAL_CHECKBOX, $CHECKBOX_HEIGHT"
        }
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $CheckBox.Text = $Text
    $CheckBox.Name = $Name
    $CheckBox.Checked = $Checked
    $CheckBox.Enabled = !$Disabled
    $CheckBox.Size = "145, $CHECKBOX_HEIGHT"
    $CheckBox.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($CheckBox)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $CheckBox

    Return $CheckBox
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Misc #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-Label {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)

    [System.Drawing.Point]$Location = ($PREVIOUS_BUTTON.Location + "30, $BUTTON_HEIGHT")

    $Label.Size = "145, $CHECKBOX_HEIGHT"
    $Label.Text = $Text
    $Label.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($Label)

    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Label
}

Function New-RadioButton {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
        [Switch]$Checked,
        [Switch]$Disabled
    )

    Set-Variable -Option Constant RadioButton (New-Object System.Windows.Forms.RadioButton)

    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
    [System.Drawing.Point]$Shift = "0, 0"

    if ($PREVIOUS_RADIO) {
        $InitialLocation.X = $PREVIOUS_BUTTON.Location.X
        $InitialLocation.Y = $PREVIOUS_RADIO.Location.Y
        $Shift = "90, 0"
    }
    elseif ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $InitialLocation = $PREVIOUS_LABEL_OR_CHECKBOX.Location
        $Shift = "-15, 20"
    }
    elseif ($PREVIOUS_BUTTON) {
        $InitialLocation = $PREVIOUS_BUTTON.Location
        $Shift = "10, $BUTTON_HEIGHT"
    }

    [System.Drawing.Point]$Location = $InitialLocation + $Shift

    $RadioButton.Text = $Text
    $RadioButton.Checked = $Checked
    $RadioButton.Enabled = !$Disabled
    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
    $RadioButton.Location = $Location

    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
    $CURRENT_GROUP.Controls.Add($RadioButton)

    Set-Variable -Scope Script PREVIOUS_RADIO $RadioButton

    Return $RadioButton
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
$FORM.Text = $HOST.UI.RawUI.WindowTitle
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
$LOG.Height = 200
$LOG.Width = $FORM_WIDTH - 10
$LOG.Location = "5, $($FORM_HEIGHT - $LOG.Height - 5)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True
$FORM.Controls.Add($LOG)


Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
$TAB_CONTROL.Size = "$($LOG.Width + 1), $($FORM_HEIGHT - $LOG.Height - 1)"
$TAB_CONTROL.Location = "5, 5"
$FORM.Controls.Add($TAB_CONTROL)


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_HOME (New-Tab 'Home')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - General #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'General'


$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Restart as administrator'})"
$BUTTON_FUNCTION = { Start-Elevated }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$IS_ELEVATED > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - HDD Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'HDD Diagnostics'


$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria'
$BUTTON_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVictoria.Add_CheckStateChanged( { $BUTTON_DownloadVictoria.Text = "Victoria$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Activators (Windows 7+, Office)'


$BUTTON_DownloadAAct = New-Button -UAC 'AAct'
$BUTTON_DownloadAAct.Add_Click( {
        Set-Variable -Option Constant Params $(if ($RADIO_AActWindows.Checked) { '/win=act /taskwin' } elseif ($RADIO_AActOffice.Checked) { '/ofs=act /taskofs' })
        Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked 'https://qiiwexc.github.io/d/AAct.zip' -Params:$Params -Silent:$CHECKBOX_SilentlyRunAAct.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( { $BUTTON_DownloadAAct.Text = "AAct$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })" } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyRunAAct = New-CheckBox 'Activate silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_SilentlyRunAAct.Add_CheckStateChanged( {
        $RADIO_AActWindows.Enabled = $CHECKBOX_SilentlyRunAAct.Checked
        $RADIO_AActOffice.Enabled = $OFFICE_VERSION -and $CHECKBOX_SilentlyRunAAct.Checked
    } )

$RADIO_AActWindows = New-RadioButton 'Windows' -Checked

$RADIO_DISABLED = !$OFFICE_VERSION
$RADIO_AActOffice = New-RadioButton 'Office' -Disabled:$RADIO_DISABLED


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Bootable USB Tools'


$BUTTON_DownloadVentoy = New-Button -UAC 'Ventoy'
$BUTTON_DownloadVentoy.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked $URL_VENTOY $((Split-Path -Leaf $URL_VENTOY) -Replace '-windows', '') } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVentoy.Add_CheckStateChanged( { $BUTTON_DownloadVentoy.Text = "Ventoy$(if ($CHECKBOX_StartVentoy.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadRufus = New-Button -UAC 'Rufus'
$BUTTON_DownloadRufus.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( { $BUTTON_DownloadRufus.Text = "Rufus$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })" } )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Optimization'


$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION > $Null

$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( { $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked } )

$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'


$BUTTON_FUNCTION = { Start-DiskCleanup }
New-Button 'Start disk cleanup' $BUTTON_FUNCTION > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_DOWNLOADS (New-Tab 'Downloads')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Ninite'


$CHECKBOX_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
$CHECKBOX_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CHECKBOX_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
$CHECKBOX_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CHECKBOX_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
$CHECKBOX_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CHECKBOX_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
$CHECKBOX_TeamViewer.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CHECKBOX_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
$CHECKBOX_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

$CHECKBOX_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )

$BUTTON_DownloadNinite = New-Button -UAC 'Download selected'
$BUTTON_DownloadNinite.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "https://ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName) } )

$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartNinite.Add_CheckStateChanged( { $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) { $REQUIRES_ELEVATION })" } )

$BUTTON_FUNCTION = { Open-InBrowser "https://ninite.com/?select=$(Set-NiniteQuery)" }
New-ButtonBrowser 'View other' $BUTTON_FUNCTION


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Essentials'


$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer'
$BUTTON_DownloadSDI.Add_Click( { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDIO } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartSDI.Add_CheckStateChanged( { $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })" } )


$BUTTON_DownloadOffice = New-Button -UAC 'Office 2013 - 2024'
$BUTTON_DownloadOffice.Add_Click( { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked 'https://qiiwexc.github.io/d/Office_2013-2024.zip' } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOffice = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOffice.Add_CheckStateChanged( { $BUTTON_DownloadOffice.Text = "Office 2013 - 2024$(if ($CHECKBOX_StartOffice.Checked) { $REQUIRES_ELEVATION })" } )



$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky'
$BUTTON_DownloadUnchecky.Add_Click( {
        Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
        Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked 'https://unchecky.com/files/unchecky_setup.exe' -Params:$Params -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
        $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) { $REQUIRES_ELEVATION })"
        $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
    } )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Windows Images #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Windows Images'


$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_11 }
New-ButtonBrowser 'Windows 11' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_10 }
New-ButtonBrowser 'Windows 10' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser $URL_WINDOWS_7 }
New-ButtonBrowser 'Windows 7' $BUTTON_FUNCTION

$BUTTON_FUNCTION = { Open-InBrowser 'https://rutracker.org/forum/viewtopic.php?t=4366725' }
New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Initialize-Startup {
    $FORM.Activate()
    Write-Log "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
        if (!(Test-Path $IE_Registry_Key)) { New-Item $IE_Registry_Key -Force | Out-Null }
        Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1
    }

    Set-Variable -Option Constant -Scope Script PATH_CURRENT_DIR $(Split-Path $MyInvocation.ScriptName)

    if ($PS_VERSION -lt 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly." }
    elseif ($PS_VERSION -eq 2) { Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled." }

    if ($OS_VERSION -lt 7) { Add-Log $WRN "Windows $OS_VERSION detected, while Windows 7 and newer are supported. Some features might not work correctly." }
    elseif ($OS_VERSION -lt 8) { Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported and are disabled." }

    if ($PS_VERSION -gt 2) {
        try { [Net.ServicePointManager]::SecurityProtocol = 'Tls12' }
        catch [Exception] { Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)" }

        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
        }
        catch [Exception] {
            Add-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
        }
    }

    Add-Log $INF 'Current system information:'

    Set-Variable -Option Constant ComputerSystem (Get-WmiObject Win32_ComputerSystem)
    Set-Variable -Option Constant Computer ($ComputerSystem | Select-Object PCSystemType)
    if ($Computer) {
        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
    }

    Set-Variable -Option Constant OfficeYear $(Switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021 / 2024' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)

    Add-Log $INF "    Operation system:  $OS_NAME"
    Add-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
    Add-Log $INF "    $(if ($OS_VERSION -eq 10) {'OS release / '})Build number:  $(if ($OS_VERSION -eq 10) {"v$WindowsRelease / "})$OS_BUILD"
    Add-Log $INF "    Office version:  $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"

    Get-CurrentVersion

    if ($OFFICE_INSTALL_TYPE -eq 'MSI' -and $OFFICE_VERSION -ge 15) {
        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Logger #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) {
        $WRN { $LOG.SelectionColor = 'blue' }
        $ERR { $LOG.SelectionColor = 'red' }
        Default { $LOG.SelectionColor = 'black' }
    }

    Write-Log "`n[$((Get-Date).ToString())] $Message"
}


Function Write-Log {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Text)

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


Function Out-Status {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Status)

    Write-Log ' '

    Set-Variable -Option Constant LogDefaultFont $LOG.Font
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

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) { Add-Log $ERR "Failed to check for updates: $IsNotConnected"; Return }

    $ProgressPreference = 'SilentlyContinue'
    try {
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest 'https://bit.ly/qiiwexc_version').ToString())
        $ProgressPreference = 'Continue'
    }
    catch [Exception] {
        $ProgressPreference = 'Continue'
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        Return
    }

    if ($LatestVersion -gt $VERSION) { Add-Log $WRN "Newer version available: v$LatestVersion"; Get-Update }
    else { Out-Status 'No updates available' }
}


Function Get-Update {
    Set-Variable -Option Constant DownloadURL 'https://bit.ly/qiiwexc_ps1'
    Set-Variable -Option Constant TargetFile $MyInvocation.ScriptName

    Add-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) { Add-Log $ERR "Failed to download update: $IsNotConnected"; Return }

    try { Invoke-WebRequest $DownloadURL -OutFile $TargetFile }
    catch [Exception] { Add-Log $ERR "Failed to download update: $($_.Exception.Message)"; Return }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try { Start-ExternalProcess "PowerShell '$TargetFile' '-HideConsole'" }
    catch [Exception] { Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"; Return }

    Exit-Script
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Common #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-NetworkAdapter { Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True') }

Function Get-ConnectionStatus { if (!(Get-NetworkAdapter)) { Return 'Computer is not connected to the Internet' } }

Function Reset-StateOnExit { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR; $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE; Write-Host '' }

Function Exit-Script { Reset-StateOnExit; $FORM.Close() }


Function Open-InBrowser {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Add-Log $INF "Opening URL in the default browser: $URL"

    try { [System.Diagnostics.Process]::Start($URL) }
    catch [Exception] { Add-Log $ERR "Could not open the URL: $($_.Exception.Message)" }
}


Function Start-ExternalProcess {
    Param(
        [String[]][Parameter(Position = 0, Mandatory = $True)]$Commands,
        [String][Parameter(Position = 1)]$Title,
        [Switch]$Elevated,
        [Switch]$Wait,
        [Switch]$Hidden
    )

    if ($Title) { $Commands = , "(Get-Host).UI.RawUI.WindowTitle = '$Title'" + $Commands }
    Set-Variable -Option Constant FullCommand $([String]$($Commands | Where-Object { $_ -ne '' } | ForEach-Object { "$_;" }))

    Start-Process 'PowerShell' "-Command $FullCommand" -Wait:$Wait -Verb:$(if ($Elevated) { 'RunAs' } else { 'Open' }) -WindowStyle:$(if ($Hidden) { 'Hidden' } else { 'Normal' })
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download Extract Execute #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DownloadExtractExecute {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$FileName,
        [String][Parameter(Position = 2)]$Params,
        [Switch]$AVWarning,
        [Switch]$Execute,
        [Switch]$Silent
    )

    if ($AVWarning -and !$AVWarningShown) {
        Add-Log $WRN 'This file may trigger anti-virus false positive!'
        Add-Log $WRN 'It is recommended to disable anti-virus software for download and subsequent use of this file!'
        Add-Log $WRN 'Click the button again to continue'
        Set-Variable -Option Constant -Scope Script AVWarningShown $True
        Return
    }

    if ($PS_VERSION -le 2 -and ($URL -Match '*github.com/*' -or $URL -Match '*github.io/*')) { Open-InBrowser $URL }
    else {
        Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
        Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
        Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))

        if ($DownloadedFile) {
            Set-Variable -Option Constant Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -Execute:$Execute } else { $DownloadedFile })
            if ($Execute) { Start-File $Executable $Params -Silent:$Silent }
        }
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Download {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
        [String][Parameter(Position = 1)]$SaveAs,
        [Switch]$Temp
    )

    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
    Set-Variable -Option Constant TempPath "$PATH_TEMP_DIR\$FileName"
    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_CURRENT_DIR\$FileName" })

    New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null

    Add-Log $INF "Downloading from $URL"

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Download failed: $IsNotConnected"
        if (Test-Path $SavePath) { Add-Log $WRN "Previous download found, returning it"; Return $SavePath } else { Return }
    }

    try {
        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
        (New-Object System.Net.WebClient).DownloadFile($URL, $TempPath)
        if (!$Temp) { Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath }

        if (Test-Path $SavePath) { Out-Success }
        else { Throw 'Possibly computer is offline or disk is full' }
    }
    catch [Exception] { Add-Log $ERR "Download failed: $($_.Exception.Message)"; Return }

    Return $SavePath
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Extract ZIP #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Execute
    )

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant MultiFileArchive ($ZipName -eq 'AAct.zip' -or `
            $ZipName -eq 'KMSAuto_Lite.zip' -or `
            $URL -Match 'SDIO_' -or $URL -Match 'Victoria')

    Set-Variable -Option Constant ExtractionPath $(if ($MultiFileArchive) { $ZipPath.TrimEnd('.zip') })
    Set-Variable -Option Constant TemporaryPath $(if ($ExtractionPath) { $ExtractionPath } else { $PATH_TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant ExtractionDir $(if ($ExtractionPath) { Split-Path -Leaf $ExtractionPath })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'Office_2013-2024.zip' { "OInstall$(if ($OS_64_BIT) {'_x64'}).exe" }
        'AAct.zip' { "AAct$(if ($OS_64_BIT) {'_x64'}).exe" }
        'KMSAuto_Lite.zip' { "KMSAuto$(if ($OS_64_BIT) {' x64'}).exe" }
        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
        'ventoy*' { $ZipName.TrimEnd('.zip') + '\Ventoy2Disk.exe' }
        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
        Default { $ZipName.TrimEnd('.zip') + '.exe' }
    }

    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -Like "$ExtractionDir\*")
    Set-Variable -Option Constant TemporaryExe "$TemporaryPath\$Executable"
    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"

    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryExe
    if ($MultiFileArchive) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $TemporaryPath
        New-Item -Force -ItemType Directory $TemporaryPath | Out-Null
    }

    Add-Log $INF "Extracting $ZipPath..."

    try {
        if ($ZIP_SUPPORTED) { [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $TemporaryPath) }
        else { ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) { $SHELL.NameSpace($TemporaryPath).CopyHere($Item) } }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract' $ZipPath': $($_.Exception.Message)"
        Return
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    if (!$IsDirectory) {
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe
        if ($ExtractionPath) { Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath }
    }

    if (!$Execute -and $IsDirectory) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryPath $TargetPath
    }

    Out-Success
    Add-Log $INF "Files extracted to $TemporaryPath"

    Return $TargetExe
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Execute File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-File {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    if ($Switches -and $Silent) {
        Add-Log $INF "Installing '$Executable' silently..."

        try { Start-Process -Wait $Executable $Switches }
        catch [Exception] { Add-Log $ERR "Failed to install '$Executable': $($_.Exception.Message)"; Return }

        Out-Success

        Add-Log $INF "Removing $Executable..."
        Remove-Item -Force $Executable
        Out-Success
    }
    else {
        Add-Log $INF "Starting '$Executable'..."

        try {
            if ($Switches) { Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable) }
            else { Start-Process $Executable -WorkingDirectory (Split-Path $Executable) }
        }
        catch [Exception] { Add-Log $ERR "Failed to execute '$Executable': $($_.Exception.Message)"; Return }

        Out-Success
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Elevated #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Elevated {
    if (!$IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-ExternalProcess -Elevated "$($MyInvocation.ScriptName)$(if ($HIDE_CONSOLE) {' -HideConsole'})" }
        catch [Exception] { Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"; Return }

        Exit-Script
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Optimization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process -Verb RunAs 'cleanmgr' '/lowdisk' }
    catch [Exception] { Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"; Return }

    Out-Success
}

Function Set-CloudFlareDNS {
    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } };
    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } };

    Add-Log $WRN 'Internet connection may get interrupted briefly'
    Add-Log $INF "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."

    if (!(Get-NetworkAdapter)) {
        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
        Add-Log $ERR 'This could mean that computer is not connected'
        Return
    }

    try { Start-ExternalProcess -Elevated -Hidden "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('$PreferredDnsServer', '$AlternateDnsServer'))" }
    catch [Exception] { Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"; Return }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $BUTTON_DownloadNinite.Enabled = $CHECKBOX_7zip.Checked -or $CHECKBOX_VLC.Checked -or `
        $CHECKBOX_TeamViewer.Checked -or $CHECKBOX_Chrome.Checked -or $CHECKBOX_qBittorrent.Checked -or $CHECKBOX_Malwarebytes.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) { $Array += $CHECKBOX_7zip.Name }
    if ($CHECKBOX_VLC.Checked) { $Array += $CHECKBOX_VLC.Name }
    if ($CHECKBOX_TeamViewer.Checked) { $Array += $CHECKBOX_TeamViewer.Name }
    if ($CHECKBOX_Chrome.Checked) { $Array += $CHECKBOX_Chrome.Name }
    if ($CHECKBOX_qBittorrent.Checked) { $Array += $CHECKBOX_qBittorrent.Name }
    if ($CHECKBOX_Malwarebytes.Checked) { $Array += $CHECKBOX_Malwarebytes.Name }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) { $Array += $CHECKBOX_7zip.Text }
    if ($CHECKBOX_VLC.Checked) { $Array += $CHECKBOX_VLC.Text }
    if ($CHECKBOX_TeamViewer.Checked) { $Array += $CHECKBOX_TeamViewer.Text }
    if ($CHECKBOX_Chrome.Checked) { $Array += $CHECKBOX_Chrome.Text }
    if ($CHECKBOX_qBittorrent.Checked) { $Array += $CHECKBOX_qBittorrent.Text }
    if ($CHECKBOX_Malwarebytes.Checked) { $Array += $CHECKBOX_Malwarebytes.Text }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Draw Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

[Void]$FORM.ShowDialog()
