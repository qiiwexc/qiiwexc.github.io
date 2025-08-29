param([String][Parameter(Position = 0)]$CallerPath, [Switch]$HideConsole)

Set-Variable -Option Constant Version ([Version]'25.8.29')


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


Set-Variable -Option Constant PATH_CURRENT_DIR $CallerPath
Set-Variable -Option Constant PATH_TEMP_DIR "$([System.IO.Path]::GetTempPath())qiiwexc"

Set-Variable -Option Constant SYSTEM_LANGUAGE (Get-SystemLanguage)

Set-Variable -Option Constant IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
Set-Variable -Option Constant REQUIRES_ELEVATION $(if (!$IS_ELEVATED) { ' *' } else { '' })


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# URLs #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant URL_VERSION_FILE 'https://bit.ly/qiiwexc_version'
Set-Variable -Option Constant URL_BAT_FILE     'https://bit.ly/qiiwexc_bat'

Set-Variable -Option Constant URL_WINDOWS_11 'https://w16.monkrus.ws/2025/01/windows-11-v24h2-rus-eng-20in1-hwid-act.html'
Set-Variable -Option Constant URL_WINDOWS_10 'https://w16.monkrus.ws/2022/11/windows-10-v22h2-rus-eng-x86-x64-32in1.html'
Set-Variable -Option Constant URL_WINDOWS_7  'https://w16.monkrus.ws/2024/02/windows-7-sp1-rus-eng-x86-x64-18in1.html'

Set-Variable -Option Constant URL_RUFUS    'https://github.com/pbatard/rufus/releases/download/v4.9/rufus-4.9p.exe'
Set-Variable -Option Constant URL_VENTOY   'https://github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-windows.zip'
Set-Variable -Option Constant URL_SDIO     'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.15.5.816.zip'
Set-Variable -Option Constant URL_VICTORIA 'https://hdd.by/Victoria/Victoria537.zip'

Set-Variable -Option Constant URL_AACT        'https://qiiwexc.github.io/d/AAct.zip'
Set-Variable -Option Constant URL_OFFICE      'https://qiiwexc.github.io/d/Office_2013-2024.zip'
Set-Variable -Option Constant URL_OFFICE_INSTALLER   'https://qiiwexc.github.io/d/Office_Installer+.zip'
Set-Variable -Option Constant URL_ACTIVATION_PROGRAM 'https://qiiwexc.github.io/d/ActivationProgram.zip'

Set-Variable -Option Constant URL_UNCHECKY   'https://unchecky.com/files/unchecky_setup.exe'
Set-Variable -Option Constant URL_LIVE_CD    'https://rutracker.org/forum/viewtopic.php?t=4366725'
Set-Variable -Option Constant URL_NINITE     'https://ninite.com'
Set-Variable -Option Constant URL_TRONSCRIPT 'https://github.com/bmrf/tron/blob/master/README.md#use'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Initialization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Write-Host 'Initializing...'

Set-Variable -Option Constant OLD_WINDOW_TITLE $($HOST.UI.RawUI.WindowTitle)
$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"

if ($HideConsole) {
    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
}

try {
    Add-Type -AssemblyName System.Windows.Forms
} catch {
    Throw 'System not supported'
}

[System.Windows.Forms.Application]::EnableVisualStyles()


Set-Variable -Option Constant PS_VERSION $($PSVersionTable.PSVersion.Major)

Set-Variable -Option Constant SHELL $(New-Object -com Shell.Application)

Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)
Set-Variable -Option Constant IsWindows11 ($OperatingSystem.Caption -Match "Windows 11")
Set-Variable -Option Constant OS_NAME $OperatingSystem.Caption
Set-Variable -Option Constant OS_BUILD $OperatingSystem.Version
Set-Variable -Option Constant OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -Like '*64') { $True })
Set-Variable -Option Constant OS_VERSION $(if ($IsWindows11) { 11 } else { Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } } })

Set-Variable -Option Constant WordRegPath (Get-ItemProperty "$(New-PSDrive HKCR Registry HKEY_CLASSES_ROOT):\Word.Application\CurVer" -ErrorAction SilentlyContinue)
Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
Set-Variable -Option Constant PathOfficeC2RClientExe "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PathOfficeC2RClientExe) { 'C2R' } else { 'MSI' } })


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - TabPage #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function New-TabPage {
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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - GroupBox #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

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
    } else {
        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
    }

    if ($GroupIndex -lt 3) {
        Set-Variable -Option Constant Location $(if ($GroupIndex -eq 0) { "15, 15" } else { $PREVIOUS_GROUP.Location + "$($GROUP_WIDTH + 15), 0" })
    } else {
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
    } elseif ($PREVIOUS_BUTTON) {
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

    if ($Function) {
        $Button.Add_Click($Function)
    }

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
        } else {
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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - Label #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Components - RadioButton #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

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
    } elseif ($PREVIOUS_LABEL_OR_CHECKBOX) {
        $InitialLocation = $PREVIOUS_LABEL_OR_CHECKBOX.Location
        $Shift = "-15, 20"
    } elseif ($PREVIOUS_BUTTON) {
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
$FORM.Add_Shown( {
    Initialize-Startup
} )
$FORM.Add_FormClosing( {
    Reset-State
} )


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

Set-Variable -Option Constant TAB_HOME (New-TabPage 'Home')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Run as Administrator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Run as Administrator'


$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Restart as administrator'})"
$BUTTON_FUNCTION = { Start-Elevated }
New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$IS_ELEVATED > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Bootable USB Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Bootable USB Tools'


$BUTTON_DownloadVentoy = New-Button -UAC 'Ventoy'
$BUTTON_DownloadVentoy.Add_Click( {
    Set-Variable -Option Constant FileName $((Split-Path -Leaf $URL_VENTOY) -Replace '-windows', '')
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked $URL_VENTOY -FileName:$FileName
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVentoy.Add_CheckStateChanged( {
    $BUTTON_DownloadVentoy.Text = "Ventoy$(if ($CHECKBOX_StartVentoy.Checked) { $REQUIRES_ELEVATION })"
} )


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked $URL_RUFUS -Params:'-g' }
$BUTTON_DownloadRufus = New-Button -UAC 'Rufus' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartRufus.Add_CheckStateChanged( {
    $BUTTON_DownloadRufus.Text = "Rufus$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })"
} )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Activators (Windows 7+, Office)'

$BUTTON_FUNCTION = { Start-Activator }
$BUTTON_MASActivator = New-Button -UAC 'MAS Activator' $BUTTON_FUNCTION -Disabled:$($OS_VERSION -lt 7)



$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked $URL_ACTIVATION_PROGRAM }
$BUTTON_DownloadActivationProgram = New-Button -UAC 'Activation Program' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartActivationProgram.Add_CheckStateChanged( {
    $BUTTON_DownloadActivationProgram.Text = "Activation Program$(if ($CHECKBOX_StartActivationProgram.Checked) { $REQUIRES_ELEVATION })"
} )



$BUTTON_DownloadAAct = New-Button -UAC 'AAct'
$BUTTON_DownloadAAct.Add_Click( {
    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyRunAAct.Checked) {if ($RADIO_AActWindows.Checked) { '/win=act /taskwin' } elseif ($RADIO_AActOffice.Checked) { '/ofs=act /taskofs' }})
    Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartAAct.Checked $URL_AACT -Params:$Params -Silent:$CHECKBOX_SilentlyRunAAct.Checked
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartAAct = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartAAct.Add_CheckStateChanged( {
    $BUTTON_DownloadAAct.Text = "AAct$(if ($CHECKBOX_StartAAct.Checked) { $REQUIRES_ELEVATION })"
    $CHECKBOX_SilentlyRunAAct.Enabled = $CHECKBOX_StartAAct.Checked
    $RADIO_AActWindows.Enabled = $CHECKBOX_StartAAct.Checked
    $RADIO_AActOffice.Enabled = $CHECKBOX_StartAAct.Checked
} )

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


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home - HDD Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'HDD Diagnostics'


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked $URL_VICTORIA }
$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartVictoria.Add_CheckStateChanged( {
    $BUTTON_DownloadVictoria.Text = "Victoria$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })"
} )


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_DOWNLOADS (New-TabPage 'Downloads')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Ninite'


$CHECKBOX_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
$CHECKBOX_Chrome.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
$CHECKBOX_7zip.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
$CHECKBOX_VLC.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
$CHECKBOX_TeamViewer.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
$CHECKBOX_qBittorrent.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$CHECKBOX_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
$CHECKBOX_Malwarebytes.Add_CheckStateChanged( {
    Set-NiniteButtonState
} )

$BUTTON_DownloadNinite = New-Button -UAC 'Download selected'
$BUTTON_DownloadNinite.Add_Click( {
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "$URL_NINITE/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName)
} )

$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartNinite.Add_CheckStateChanged( {
    $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) { $REQUIRES_ELEVATION })"
} )

$BUTTON_FUNCTION = { Open-InBrowser "$URL_NINITE/?select=$(Set-NiniteQuery)" }
New-ButtonBrowser 'View other' $BUTTON_FUNCTION


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Downloads - Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Essentials'


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked $URL_SDIO }
$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartSDI.Add_CheckStateChanged( {
    $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })"
} )


$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOfficeInstaller.Checked $URL_OFFICE_INSTALLER }
$BUTTON_DownloadOfficeInstaller = New-Button -UAC 'Office Installer+' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOfficeInstaller.Add_CheckStateChanged( {
    $BUTTON_DownloadOfficeInstaller.Text = "Office Installer+$(if ($CHECKBOX_StartOfficeInstaller.Checked) { $REQUIRES_ELEVATION })"
} )



$BUTTON_DownloadOffice = New-Button -UAC 'Office 2013 - 2024'
$BUTTON_DownloadOffice.Add_Click( {
    # Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallOffice.Checked) { '/Standard2024Volume x64 en-gb excludePublisher excludeGroove excludeOneNote excludeOutlook excludeOneDrive excludeTeams /activate' })
    # Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE -Params:$Params
    Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartOffice.Checked $URL_OFFICE
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartOffice = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartOffice.Add_CheckStateChanged( {
    $BUTTON_DownloadOffice.Text = "Office 2013 - 2024$(if ($CHECKBOX_StartOffice.Checked) { $REQUIRES_ELEVATION })"
    # $CHECKBOX_SilentlyInstallOffice.Enabled = $CHECKBOX_StartOffice.Checked
} )

# $CHECKBOX_DISABLED = $PS_VERSION -le 2
# $CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
# $CHECKBOX_SilentlyInstallOffice = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED



$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky'
$BUTTON_DownloadUnchecky.Add_Click( {
    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked $URL_UNCHECKY -Params:$Params -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked
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

$BUTTON_FUNCTION = { Open-InBrowser $URL_LIVE_CD }
New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Set-Variable -Option Constant TAB_CONFIGURATION (New-TabPage 'Config and misc')


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration - Alternative DNS #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Alternative DNS'


$BUTTON_FUNCTION = { Set-CloudFlareDNS }
New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION > $Null

$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
    $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked
} )

$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration - Deboat #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Debloat Windows'


$BUTTON_FUNCTION = { Start-WindowsDebloat }
New-Button -UAC 'Debloat Windows' $BUTTON_FUNCTION > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration - Windows Configurator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Windows Configurator'


$BUTTON_FUNCTION = { Start-WindowsConfigurator }
New-Button -UAC 'Windows Configurator' $BUTTON_FUNCTION > $Null


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration - TronScript #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

New-GroupBox 'Windows Disinfection'


$BUTTON_FUNCTION = { Open-InBrowser $URL_TRONSCRIPT }
New-ButtonBrowser 'Download TronScript' $BUTTON_FUNCTION


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Initialize-Startup {
    $FORM.Activate()
    Write-LogMessage "[$((Get-Date).ToString())] Initializing..."

    if ($IS_ELEVATED) {
        Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'

        if (!(Test-Path $IE_Registry_Key)) {
            New-Item $IE_Registry_Key -Force | Out-Null
        }

        Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1
    }

    if ($PS_VERSION -lt 2) {
        Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly."
    } elseif ($PS_VERSION -eq 2) {
        Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled."
    }

    if ($OS_VERSION -lt 8) {
        Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported."
    }

    if ($PS_VERSION -gt 2) {
        try {
            [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
        } catch [Exception] {
            Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)"
        }

        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
        } catch [Exception] {
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
    Add-Log $INF "    OS language:  $SYSTEM_LANGUAGE"
    Add-Log $INF "    $(if ($OS_VERSION -ge 10) {'OS release / '})Build number:  $(if ($OS_VERSION -ge 10) {"v$WindowsRelease / "})$OS_BUILD"
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
        $WRN {
            $LOG.SelectionColor = 'blue'
        }
        $ERR {
            $LOG.SelectionColor = 'red'
        }
        Default {
            $LOG.SelectionColor = 'black'
        }
    }

    Write-LogMessage "`n[$((Get-Date).ToString())] $Message"
}


Function Write-LogMessage {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Text)

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


Function Out-Status {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Status)

    Write-LogMessage ' '

    Set-Variable -Option Constant LogDefaultFont $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Write-LogMessage $Status

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
}


Function Out-Success {
    Out-Status 'Done'
}

Function Out-Failure {
    Out-Status 'Failed'
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Self-Update #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-CurrentVersion {
    if ($PS_VERSION -le 2) {
        Add-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"
        Return
    }

    Add-Log $INF 'Checking for updates...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
    if ($IsNotConnected) {
        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
        Return
    }

    $ProgressPreference = 'SilentlyContinue'
    try {
        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest $URL_VERSION_FILE).ToString())
        $ProgressPreference = 'Continue'
    } catch [Exception] {
        $ProgressPreference = 'Continue'
        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
        Return
    }

    if ($LatestVersion -gt $VERSION) {
        Add-Log $WRN "Newer version available: v$LatestVersion"
        Get-Update
    } else {
        Out-Status 'No updates available'
    }
}


Function Get-Update {
    Set-Variable -Option Constant TargetFileBat "$PATH_CURRENT_DIR\qiiwexc.bat"

    Add-Log $WRN 'Downloading new version...'

    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)

    if ($IsNotConnected) {
        Add-Log $ERR "Failed to download update: $IsNotConnected"
        Return
    }

    try {
        Invoke-WebRequest $URL_BAT_FILE -OutFile $TargetFileBat
    } catch [Exception] {
        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
        Return
    }

    Out-Success
    Add-Log $WRN 'Restarting...'

    try {
        Start-Script $TargetFileBat
    } catch [Exception] {
        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
        Return
    }

    Exit-Script
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Common #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Get-NetworkAdapter {
    Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

Function Get-ConnectionStatus {
    if (!(Get-NetworkAdapter)) {
        Return 'Computer is not connected to the Internet'
    }
}

Function Reset-State {
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR
    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

Function Exit-Script {
    Reset-State
    $FORM.Close()
}


Function Open-InBrowser {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Add-Log $INF "Opening URL in the default browser: $URL"

    try {
        [System.Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Add-Log $ERR "Could not open the URL: $($_.Exception.Message)"
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Script #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Script {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Command,
        [String]$WorkingDirectory,
        [Switch]$BypassExecutionPolicy,
        [Switch]$Elevated,
        [Switch]$HideConsole,
        [Switch]$HideWindow,
        [Switch]$Wait
    )

    Set-Variable -Option Constant ExecutionPolicy $(if ($BypassExecutionPolicy) { '-ExecutionPolicy Bypass' } else { '' })
    Set-Variable -Option Constant ConsoleState $(if ($HideConsole) { '-HideConsole' } else { '' })
    Set-Variable -Option Constant CallerPath $(if ($WorkingDirectory) { "-CallerPath:$WorkingDirectory" } else { '' })
    Set-Variable -Option Constant Verb $(if ($Elevated) { 'RunAs' } else { 'Open' })
    Set-Variable -Option Constant WindowStyle $(if ($HideWindow) { 'Hidden' } else { 'Normal' })

    Set-Variable -Option Constant FullCommand "$ExecutionPolicy $Command $ConsoleState $CallerPath"

    Start-Process 'PowerShell' $FullCommand -Wait:$Wait -Verb:$Verb -WindowStyle:$WindowStyle
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

        if (Test-Path $SavePath) {
            Add-Log $WRN "Previous download found, returning it"
            Return $SavePath
        } else {
            Return
        }
    }

    try {
        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
        (New-Object System.Net.WebClient).DownloadFile($URL, $TempPath)

        if (!$Temp) {
            Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath
        }

        if (Test-Path $SavePath) {
            Out-Success
        } else {
            Throw 'Possibly computer is offline or disk is full'
        }
    } catch [Exception] {
        Add-Log $ERR "Download failed: $($_.Exception.Message)"
        Return
    }

    Return $SavePath
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Extract ZIP #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Extraction {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
        [Switch]$Execute
    )

    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')

    [Switch]$MultiFileArchive = !($ZipName -eq 'AAct.zip' -or $ZipName -eq 'Office_2013-2024.zip')

    Set-Variable -Option Constant TemporaryPath $(if ($MultiFileArchive) { $ExtractionPath } else { $PATH_TEMP_DIR })
    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
    Set-Variable -Option Constant ExtractionDir $(if ($MultiFileArchive) { Split-Path -Leaf $ExtractionPath })

    [String]$Executable = Switch -Wildcard ($ZipName) {
        'AAct.zip' { "AAct$(if ($OS_64_BIT) {'_x64'}).exe" }
        'ActivationProgram.zip' { "ActivationProgram$(if ($OS_64_BIT) {''} else {'_x86'}).exe" }
        'Office_2013-2024.zip' { 'OInstall.exe' }
        'Office_Installer+.zip' { "Office Installer+$(if ($OS_64_BIT) {''} else {' x86'}).exe" }
        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
        'ventoy*' { "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe" }
        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
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

    Add-Log $INF "Extracting '$ZipPath'..."

    try {
        if ($ZIP_SUPPORTED) {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $TemporaryPath)
        } else {
            ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) {
                $SHELL.NameSpace($TemporaryPath).CopyHere($Item)
            }
        }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to extract '$ZipPath': $($_.Exception.Message)"
        Return
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    if (!$IsDirectory) {
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe

        if ($MultiFileArchive) {
            Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
        }
    }

    if (!$Execute -and $IsDirectory) {
        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryPath $TargetPath
    }

    Out-Success
    Add-Log $INF "Files extracted to '$TargetPath'"

    Return $TargetExe
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Run Executable #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Executable {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
        [String][Parameter(Position = 1)]$Switches,
        [Switch]$Silent
    )

    if ($Switches -and $Silent) {
        Add-Log $INF "Running '$Executable' silently..."

        try {
            Start-Process -Wait $Executable $Switches
        } catch [Exception] {
            Add-Log $ERR "Failed to run '$Executable': $($_.Exception.Message)"
            Return
        }

        Out-Success

        Add-Log $INF "Removing '$Executable'..."
        Remove-Item -Force $Executable
        Out-Success
    } else {
        Add-Log $INF "Running '$Executable'..."

        try {
            if ($Switches) {
                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable)
            } else {
                Start-Process $Executable -WorkingDirectory (Split-Path $Executable)
            }
        } catch [Exception] {
            Add-Log $ERR "Failed to execute '$Executable': $($_.Exception.Message)"
            Return
        }

        Out-Success
    }
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

    if ($PS_VERSION -le 2 -and ($URL -Match '*github.com/*' -or $URL -Match '*github.io/*')) {
        Open-InBrowser $URL
    } else {
        Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
        Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
        Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))

        if ($DownloadedFile) {
            Set-Variable -Option Constant Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -Execute:$Execute } else { $DownloadedFile })

            if ($Execute) {
                Start-Executable $Executable $Params -Silent:$Silent
            }
        }
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Elevated #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Elevated {
    if (!$IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try {
            Start-Script -Elevated -BypassExecutionPolicy -WorkingDirectory:$PATH_CURRENT_DIR -HideConsole:$HideConsole $MyInvocation.ScriptName
        } catch [Exception] {
            Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"
            Return
        }

        Exit-Script
    }
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Activator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-Activator {
    Add-Log $INF "Starting MAS activator..."

    if ($OS_VERSION -eq 7) {
        Start-Script -HideWindow "iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))"
    } else {
        Start-Script -HideWindow "irm https://get.activated.win | iex"
    }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $BUTTON_DownloadNinite.Enabled = $CHECKBOX_7zip.Checked -or $CHECKBOX_VLC.Checked -or `
        $CHECKBOX_TeamViewer.Checked -or $CHECKBOX_Chrome.Checked -or $CHECKBOX_qBittorrent.Checked -or $CHECKBOX_Malwarebytes.Checked
}


Function Set-NiniteQuery {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) {
        $Array += $CHECKBOX_7zip.Name
    }
    if ($CHECKBOX_VLC.Checked) {
        $Array += $CHECKBOX_VLC.Name
    }
    if ($CHECKBOX_TeamViewer.Checked) {
        $Array += $CHECKBOX_TeamViewer.Name
    }
    if ($CHECKBOX_Chrome.Checked) {
        $Array += $CHECKBOX_Chrome.Name
    }
    if ($CHECKBOX_qBittorrent.Checked) {
        $Array += $CHECKBOX_qBittorrent.Name
    }
    if ($CHECKBOX_Malwarebytes.Checked) {
        $Array += $CHECKBOX_Malwarebytes.Name
    }
    Return $Array -Join '-'
}


Function Set-NiniteFileName {
    [String[]]$Array = @()
    if ($CHECKBOX_7zip.Checked) {
        $Array += $CHECKBOX_7zip.Text
    }
    if ($CHECKBOX_VLC.Checked) {
        $Array += $CHECKBOX_VLC.Text
    }
    if ($CHECKBOX_TeamViewer.Checked) {
        $Array += $CHECKBOX_TeamViewer.Text
    }
    if ($CHECKBOX_Chrome.Checked) {
        $Array += $CHECKBOX_Chrome.Text
    }
    if ($CHECKBOX_qBittorrent.Checked) {
        $Array += $CHECKBOX_qBittorrent.Text
    }
    if ($CHECKBOX_Malwarebytes.Checked) {
        $Array += $CHECKBOX_Malwarebytes.Text
    }
    Return "Ninite $($Array -Join ' ') Installer.exe"
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# DNS #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

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

    try {
        Start-Script -Elevated -HideWindow "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('$PreferredDnsServer', '$AlternateDnsServer'))"
    } catch [Exception] {
        Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Debloat Windows #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-WindowsDebloat {
    Add-Log $INF "Starting Windows deboat utility..."

    if ($OS_VERSION -eq 10) {
        Start-Script "iwr -useb https://git.io/debloat | iex"
    } else {
        Start-Script -Elevated -HideWindow "& ([scriptblock]::Create((irm 'https://debloat.raphi.re/')))"
    }

    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Windows Configurator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

Function Start-WindowsConfigurator {
    Add-Log $INF "Starting Windows configuration utility..."
    Start-Script "irm 'https://christitus.com/win' | iex"
    Out-Success
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Draw Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

[Void]$FORM.ShowDialog()

# SIG # Begin signature block
# MIIbuQYJKoZIhvcNAQcCoIIbqjCCG6YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzpoF0qVO9yQE8FAMj4Y4TpYC
# W3mgghYyMIIC9DCCAdygAwIBAgIQXsI0IvjnYrROmtXpEM8jXjANBgkqhkiG9w0B
# AQUFADASMRAwDgYDVQQDDAdxaWl3ZXhjMB4XDTI1MDgwOTIyNDMxOVoXDTI2MDgw
# OTIzMDMxOVowEjEQMA4GA1UEAwwHcWlpd2V4YzCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAMhnu8NP9C+9WtGc5kHCOjJo3ZMzdw/qQIMhafhu736EWnJ5
# j2Ua2afyvPhxUf1d1XUdYLfkbCb7qX9bqCoA8CKzelGgrVFhvXdQVQxI31t6gPPB
# PYc7w85z2rvo7E4R47VvBHx4n5tN0CLCLBitOx9SANscprrJU67Xpz25lKdT8557
# 2mMI/JMblE0nJY7tivun3Suz4Rg9TeX/4Dp3zVfUBeK+Vt+HtXk+uYBUTvKF3oYL
# xKImA680lbd/JPQ7+ukG+LPSvRVENKnI5PVT9CxivuTnQ8eLl6UDosdKVj1Fu/xB
# t+m4xHi83SyE843jVEzanodfQT822bT+rpAPv90CAwEAAaNGMEQwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQQUvLuFhpdcPOA
# LOynGgBzOzueBzANBgkqhkiG9w0BAQUFAAOCAQEAxmeQFnsFSp/ZwWdhErD3HGXi
# JaBiozCNeAqxVMqjGCVK4auPU0lppVRE7J6JmvxzAWCjmajQafxUgZUdjoQ9vmBZ
# NkbhUtzls1x+eV02MMwx82Hukq5llL5atcOp7QtZ4B6aDYmYsl+N8iWJ3Ol6gTDf
# 1+YWop3k4BUqHQ7AtEir1lrwatdwB5l+jksNAFolYrrr1nY8fbCsQjqDqMlA6YqS
# 21MqEoNqc7tt1OYGW/Z9QdG+P0mhjdlU6hMiNRAxz455/LPcxPgkwdxpsmzuXjnj
# KtASPCCVG6IYFlmKKlwF+BPE/aV212/ZGrb7J3WMYgm86cJtX6YO0y79sAk1sTCC
# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDCCBrQwggScoAMCAQICEA3H
# rFcF/yGZLkBDIgw6SYYwDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEh
# MB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTI1MDUwNzAwMDAw
# MFoXDTM4MDExNDIzNTk1OVowaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFt
# cGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMTCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBALR4MdMKmEFyvjxGwBysddujRmh0tFEXnU2tjQ2UtZmWgyxU
# 7UNqEY81FzJsQqr5G7A6c+Gh/qm8Xi4aPCOo2N8S9SLrC6Kbltqn7SWCWgzbNfiR
# +2fkHUiljNOqnIVD/gG3SYDEAd4dg2dDGpeZGKe+42DFUF0mR/vtLa4+gKPsYfwE
# u7EEbkC9+0F2w4QJLVSTEG8yAR2CQWIM1iI5PHg62IVwxKSpO0XaF9DPfNBKS7Za
# zch8NF5vp7eaZ2CVNxpqumzTCNSOxm+SAWSuIr21Qomb+zzQWKhxKTVVgtmUPAW3
# 5xUUFREmDrMxSNlr/NsJyUXzdtFUUt4aS4CEeIY8y9IaaGBpPNXKFifinT7zL2gd
# FpBP9qh8SdLnEut/GcalNeJQ55IuwnKCgs+nrpuQNfVmUB5KlCX3ZA4x5HHKS+rq
# BvKWxdCyQEEGcbLe1b8Aw4wJkhU1JrPsFfxW1gaou30yZ46t4Y9F20HHfIY4/6vH
# espYMQmUiote8ladjS/nJ0+k6MvqzfpzPDOy5y6gqztiT96Fv/9bH7mQyogxG9QE
# PHrPV6/7umw052AkyiLA6tQbZl1KhBtTasySkuJDpsZGKdlsjg4u70EwgWbVRSX1
# Wd4+zoFpp4Ra+MlKM2baoD6x0VR4RjSpWM8o5a6D8bpfm4CLKczsG7ZrIGNTAgMB
# AAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTvb1NK6eQG
# fHrK4pBW9i/USezLTjAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAO
# BgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEE
# azBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYB
# BQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
# ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYG
# Z4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAF877FoAc/gc9
# EXZxML2+C8i1NKZ/zdCHxYgaMH9Pw5tcBnPw6O6FTGNpoV2V4wzSUGvI9NAzaoQk
# 97frPBtIj+ZLzdp+yXdhOP4hCFATuNT+ReOPK0mCefSG+tXqGpYZ3essBS3q8nL2
# UwM+NMvEuBd/2vmdYxDCvwzJv2sRUoKEfJ+nN57mQfQXwcAEGCvRR2qKtntujB71
# WPYAgwPyWLKu6RnaID/B0ba2H3LUiwDRAXx1Neq9ydOal95CHfmTnM4I+ZI2rVQf
# jXQA1WSjjf4J2a7jLzWGNqNX+DF0SQzHU0pTi4dBwp9nEC8EAqoxW6q17r0z0noD
# js6+BFo+z7bKSBwZXTRNivYuve3L2oiKNqetRHdqfMTCW/NmKLJ9M+MtucVGyOxi
# Df06VXxyKkOirv6o02OoXN4bFzK0vlNMsvhlqgF2puE6FndlENSmE+9JGYxOGLS/
# D284NHNboDGcmWXfwXRy4kbu4QFhOm0xJuF2EZAOk5eCkhSxZON3rGlHqhpB/8Ml
# uDezooIs8CVnrpHMiD2wL40mm53+/j7tFaxYKIqL0Q4ssd8xHZnIn/7GELH3IdvG
# 2XlM9q7WP/UwgOkw/HQtyRN62JK4S1C8uw3PdBunvAZapsiI5YKdvlarEvf8EA+8
# hcpSM9LHJmyrxaFtoza2zNaQ9k+5t1wwggbtMIIE1aADAgECAhAKgO8YS43xBYLR
# xHanlXRoMA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1l
# U3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEwHhcNMjUwNjA0MDAwMDAw
# WhcNMzYwOTAzMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFNIQTI1NiBSU0E0MDk2IFRpbWVz
# dGFtcCBSZXNwb25kZXIgMjAyNSAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEA0EasLRLGntDqrmBWsytXum9R/4ZwCgHfyjfMGUIwYzKomd8U1nH7C8Dr
# 0cVMF3BsfAFI54um8+dnxk36+jx0Tb+k+87H9WPxNyFPJIDZHhAqlUPt281mHrBb
# ZHqRK71Em3/hCGC5KyyneqiZ7syvFXJ9A72wzHpkBaMUNg7MOLxI6E9RaUueHTQK
# WXymOtRwJXcrcTTPPT2V1D/+cFllESviH8YjoPFvZSjKs3SKO1QNUdFd2adw44wD
# cKgH+JRJE5Qg0NP3yiSyi5MxgU6cehGHr7zou1znOM8odbkqoK+lJ25LCHBSai25
# CFyD23DZgPfDrJJJK77epTwMP6eKA0kWa3osAe8fcpK40uhktzUd/Yk0xUvhDU6l
# vJukx7jphx40DQt82yepyekl4i0r8OEps/FNO4ahfvAk12hE5FVs9HVVWcO5J4dV
# mVzix4A77p3awLbr89A90/nWGjXMGn7FQhmSlIUDy9Z2hSgctaepZTd0ILIUbWuh
# KuAeNIeWrzHKYueMJtItnj2Q+aTyLLKLM0MheP/9w6CtjuuVHJOVoIJ/DtpJRE7C
# e7vMRHoRon4CWIvuiNN1Lk9Y+xZ66lazs2kKFSTnnkrT3pXWETTJkhd76CIDBbTR
# ofOsNyEhzZtCGmnQigpFHti58CSmvEyJcAlDVcKacJ+A9/z7eacCAwEAAaOCAZUw
# ggGRMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOQ7/PIx7f391/ORcWMZUEPPYYzo
# MB8GA1UdIwQYMBaAFO9vU0rp5AZ8esrikFb2L9RJ7MtOMA4GA1UdDwEB/wQEAwIH
# gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCBlQYIKwYBBQUHAQEEgYgwgYUwJAYI
# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBdBggrBgEFBQcwAoZR
# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGlt
# ZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3J0MF8GA1UdHwRYMFYwVKBS
# oFCGTmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRp
# bWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNybDAgBgNVHSAEGTAXMAgG
# BmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAGUqrfEcJwS5
# rmBB7NEIRJ5jQHIh+OT2Ik/bNYulCrVvhREafBYF0RkP2AGr181o2YWPoSHz9iZE
# N/FPsLSTwVQWo2H62yGBvg7ouCODwrx6ULj6hYKqdT8wv2UV+Kbz/3ImZlJ7YXwB
# D9R0oU62PtgxOao872bOySCILdBghQ/ZLcdC8cbUUO75ZSpbh1oipOhcUT8lD8QA
# GB9lctZTTOJM3pHfKBAEcxQFoHlt2s9sXoxFizTeHihsQyfFg5fxUFEp7W42fNBV
# N4ueLaceRf9Cq9ec1v5iQMWTFQa0xNqItH3CPFTG7aEQJmmrJTV3Qhtfparz+BW6
# 0OiMEgV5GWoBy4RVPRwqxv7Mk0Sy4QHs7v9y69NBqycz0BZwhB9WOfOu/CIJnzkQ
# TwtSSpGGhLdjnQ4eBpjtP+XB3pQCtv4E5UCSDag6+iX8MmB10nfldPF9SVD7weCC
# 3yXZi/uuhqdwkgVxuiMFzGVFwYbQsiGnoa9F5AaAyBjFBtXVLcKtapnMG3VH3EmA
# p/jsJ3FVF3+d1SVDTmjFjLbNFZUWMXuZyvgLfgyPehwJVxwC+UpX2MSey2ueIu9T
# HFVkT+um1vshETaWyQo8gmBto/m3acaP9QsuLj3FNwFlTxq25+T4QwX9xa6ILs84
# ZPvmpovq90K8eWyG2N01c4IhSOxqt81nMYIE8TCCBO0CAQEwJjASMRAwDgYDVQQD
# DAdxaWl3ZXhjAhBewjQi+OditE6a1ekQzyNeMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSM14wC
# jiw3ez2Vjxh69EKmnoWOZjANBgkqhkiG9w0BAQEFAASCAQAeX5t3s85nM86QWbvp
# jbsDioY3rIgHsLEQkEtF2md+7HfimeJTnxh3TTELEZteYMkQ2r0WEOnW38H3QOit
# XlokdZ2l0XMCokbDnQQSd66Rk4/dokUisfG98UgwFBEwYymTAGvi+dGSSYiNC7t3
# iOqME0CII14pYbVeIkcNoZQNvhN9c+xVtEbRPpqa+rPs7cpebyFR7vUSVVFDCcwa
# qEV+nVaZXwGYAWIsOTFxGaT+XetHfoRKtSmpLQES2nXbyvDGXJzhUYKoQS0PtfxJ
# LzsP7YQe1m63gZjRdMpCr3+eE4idJlpiwpdxRUXY2ccrgW862nW4wxUCIV9u8AbU
# /JcBoYIDJjCCAyIGCSqGSIb3DQEJBjGCAxMwggMPAgEBMH0waTELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBU
# cnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMQIQ
# CoDvGEuN8QWC0cR2p5V0aDANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI1MDgyOTEyMzExMVowLwYJKoZI
# hvcNAQkEMSIEIPDXVSXqwCtLZLVs2DzKaWjGdTqwsvOf70L05x69EocaMA0GCSqG
# SIb3DQEBAQUABIICAA6vmoqgP2OlX8GWEJbAT7ClgFCYmai3m4SlTloC04OTBfTC
# bXBGmRQUOXsV5Dh+hqqxoEE+9hD2CrEnSn0SyQaoFXC5b5v8LOKm8A14jn3kqO7+
# 4Ag8Om0KV0/khjSceHZqvnid71uSzCgWaQW7Z0cUaSsSvAvVSeS/t+ZFPtG/PG/G
# S/c0u75grv8+AU0mesRxKmRstcIvJlKy1hKLWIt/NeOOeqJKmGR5XZ7dGRsXXb0S
# v+BkML1ni65kBRXFDYk9nYHmiGldeFnvLtEubYLer0wL4jGxRNiVnhcbRa2sPrTz
# nG7xk4O0hC3wvsq2TbwoRA2ZblmODa2hDm8jWzvJUdOHD6ZcrTASyb9NOFj1XHqJ
# GfWzCP2A4bxgg0J7Mdkshgb8twWicEQSnbjmrUGX5BYCydkG7e6CHDi681c3ny1F
# jYgb7pfyftdt2DwY0CoZnyso0O7I7GhMCYCT/FGYU+65jB4rxEcwIgoG0pLJqbYX
# YRK1U6NxK78opJ9BAo/qzNtfWOMud7BrgJRX2KBib3i/FX7EzLAhwV6odDdpXHEC
# G0Ht8WC8KqVq+tsvZe57HqcASsxfvDB4bkYxig3mezV+lXIyaHJbkGCpZV8k3vMI
# +xDW6S6wUmdpUAsdZ2H+cTNO9GF3++VitrPXW7iNMFBPJHwcMwwRixPdzOnv
# SIG # End signature block
