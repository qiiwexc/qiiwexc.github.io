#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to Function properly.
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "&" + $MyInvocation.MyCommand.Definition + ""
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator." -ForegroundColor "White"
    Start-Sleep 1
    Start-Process "PowerShell.exe" -Verb RunAs -ArgumentList $arguments
    Break
}

<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Untitled
#>
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#region begin GUI{

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '408,523'
$Form.text = "Windows10Debloater"
$Form.TopMost = $false

$Debloat = New-Object system.Windows.Forms.Label
$Debloat.text = "Debloat Options"
$Debloat.AutoSize = $true
$Debloat.width = 25
$Debloat.height = 10
$Debloat.location = New-Object System.Drawing.Point(9, 8)
$Debloat.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$RemoveAllBloatware = New-Object system.Windows.Forms.Button
$RemoveAllBloatware.text = "Remove All Bloatware"
$RemoveAllBloatware.width = 142
$RemoveAllBloatware.height = 40
$RemoveAllBloatware.location = New-Object System.Drawing.Point(8, 32)
$RemoveAllBloatware.Font = 'Microsoft Sans Serif,10'

$RemoveBlacklist = New-Object system.Windows.Forms.Button
$RemoveBlacklist.text = "Remove Bloatware With Blacklist"
$RemoveBlacklist.width = 205
$RemoveBlacklist.height = 37
$RemoveBlacklist.location = New-Object System.Drawing.Point(9, 79)
$RemoveBlacklist.Font = 'Microsoft Sans Serif,10'

$LBL_1 = New-Object system.Windows.Forms.Label
$LBL_1.text = "Revert Debloat "
$LBL_1.AutoSize = $true
$LBL_1.width = 25
$LBL_1.height = 10
$LBL_1.location = New-Object System.Drawing.Point(254, 7)
$LBL_1.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$RevertChange = New-Object system.Windows.Forms.Button
$RevertChange.text = "Revert Changes"
$RevertChange.width = 113
$RevertChange.height = 36
$RevertChange.location = New-Object System.Drawing.Point(254, 32)
$RevertChange.Font = 'Microsoft Sans Serif,10'

$LBL_2 = New-Object system.Windows.Forms.Label
$LBL_2.text = "Optional Privacy Changes/Fixes"
$LBL_2.AutoSize = $true
$LBL_2.width = 25
$LBL_2.height = 10
$LBL_2.location = New-Object System.Drawing.Point(9, 193)
$LBL_2.Font = 'Microsoft Sans Serif,12,style=Bold,Underline'

$DisableCortana = New-Object system.Windows.Forms.Button
$DisableCortana.text = "Disable Cortana"
$DisableCortana.width = 111
$DisableCortana.height = 36
$DisableCortana.location = New-Object System.Drawing.Point(9, 217)
$DisableCortana.Font = 'Microsoft Sans Serif,10'

$EnableCortana = New-Object system.Windows.Forms.Button
$EnableCortana.text = "Enable Cortana"
$EnableCortana.width = 112
$EnableCortana.height = 36
$EnableCortana.location = New-Object System.Drawing.Point(9, 260)
$EnableCortana.Font = 'Microsoft Sans Serif,10'

$StopEdgePDFTakeover = New-Object system.Windows.Forms.Button
$StopEdgePDFTakeover.text = "Stop Edge PDF Takeover"
$StopEdgePDFTakeover.width = 161
$StopEdgePDFTakeover.height = 38
$StopEdgePDFTakeover.location = New-Object System.Drawing.Point(130, 217)
$StopEdgePDFTakeover.Font = 'Microsoft Sans Serif,10'

$EnableEdgePDFTakeover = New-Object system.Windows.Forms.Button
$EnableEdgePDFTakeover.text = "Enable Edge PDF Takeover"
$EnableEdgePDFTakeover.width = 177
$EnableEdgePDFTakeover.height = 39
$EnableEdgePDFTakeover.location = New-Object System.Drawing.Point(130, 260)
$EnableEdgePDFTakeover.Font = 'Microsoft Sans Serif,10'

$DisableTelemetry = New-Object system.Windows.Forms.Button
$DisableTelemetry.text = "Disable Telemetry/Tasks"
$DisableTelemetry.width = 152
$DisableTelemetry.height = 35
$DisableTelemetry.location = New-Object System.Drawing.Point(9, 303)
$DisableTelemetry.Font = 'Microsoft Sans Serif,10'

$RemoveRegkeys = New-Object system.Windows.Forms.Button
$RemoveRegkeys.text = "Remove Bloatware Regkeys"
$RemoveRegkeys.width = 177
$RemoveRegkeys.height = 40
$RemoveRegkeys.location = New-Object System.Drawing.Point(169, 303)
$RemoveRegkeys.Font = 'Microsoft Sans Serif,10'

$RemoveOnedrive = New-Object system.Windows.Forms.Button
$RemoveOnedrive.text = "Uninstall OneDrive"
$RemoveOnedrive.width = 117
$RemoveOnedrive.height = 35
$RemoveOnedrive.location = New-Object System.Drawing.Point(9, 345)
$RemoveOnedrive.Font = 'Microsoft Sans Serif,10'

$FixWhitelist = New-Object system.Windows.Forms.Button
$FixWhitelist.text = "Fix Whitelisted Apps"
$FixWhitelist.width = 130
$FixWhitelist.height = 37
$FixWhitelist.location = New-Object System.Drawing.Point(254, 74)
$FixWhitelist.Font = 'Microsoft Sans Serif,10'

$RemoveBloatNoBlacklist = New-Object system.Windows.Forms.Button
$RemoveBloatNoBlacklist.text = "Remove Bloatware Without Blacklist"
$RemoveBloatNoBlacklist.width = 223
$RemoveBloatNoBlacklist.height = 39
$RemoveBloatNoBlacklist.location = New-Object System.Drawing.Point(9, 123)
$RemoveBloatNoBlacklist.Font = 'Microsoft Sans Serif,10'

$Form.controls.AddRange(@($Debloat, $RemoveAllBloatware, $RemoveBlacklist, $LBL_1, $RevertChange, $LBL_2, $DisableCortana, $EnableCortana, $StopEdgePDFTakeover, $EnableEdgePDFTakeover, $DisableTelemetry, $RemoveRegkeys, $RemoveOnedrive, $FixWhitelist, $RemoveBloatNoBlacklist))

$RemoveBlacklist.Add_Click( {
        $ErrorActionPreference = 'silentlycontinue'
        Function DebloatBlacklist {
            [CmdletBinding()]

            Param ()

            $Bloatware = @(

                #Unnecessary Windows 10 AppX Apps
                "Microsoft.BingNews"
                "Microsoft.GetHelp"
                "Microsoft.Getstarted"
                "Microsoft.Messaging"
                "Microsoft.Microsoft3DViewer"
                "Microsoft.MicrosoftOfficeHub"
                "Microsoft.NetworkSpeedTest"
                "Microsoft.News"
                "Microsoft.Office.Lens"
                "Microsoft.Office.OneNote"
                "Microsoft.Office.Sway"
                "Microsoft.OneConnect"
                "Microsoft.People"
                "Microsoft.Print3D"
                "Microsoft.RemoteDesktop"
                "Microsoft.SkypeApp"
                "Microsoft.StorePurchaseApp"
                "Microsoft.Office.Todo.List"
                "Microsoft.Whiteboard"
                "Microsoft.WindowsAlarms"
                "microsoft.windowscommunicationsapps"
                "Microsoft.WindowsFeedbackHub"
                "Microsoft.WindowsMaps"
                "Microsoft.WindowsSoundRecorder"
                "Microsoft.Xbox.TCUI"
                "Microsoft.XboxApp"
                "Microsoft.XboxGameOverlay"
                "Microsoft.XboxSpeechToTextOverlay"
                "Microsoft.ZuneMusic"
                "Microsoft.ZuneVideo"

                "*EclipseManager*"
                "*ActiproSoftwareLLC*"
                "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
                "*Duolingo-LearnLanguagesforFree*"
                "*PandoraMediaInc*"
                "*CandyCrush*"
                "*Wunderlist*"
                "*Flipboard*"
                "*Twitter*"
                "*Facebook*"
                "*Spotify*"
                "*Minecraft*"
                "*Royal Revolt*"
                "*Sway*"

                "*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
                "*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
                "*Microsoft.MSPaint*"
                "*Microsoft.MicrosoftStickyNotes*"
                "*Microsoft.Windows.Photos*"
            )
            foreach ($Bloat in $Bloatware) {
                Get-AppxPackage -Name $Bloat| Remove-AppxPackage -ErrorAction SilentlyContinue
                Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
                Write-Host "Trying to remove $Bloat."
                Write-Host "Bloatware removed! `n"
            }
        }
        Write-Host "Removing Bloatware with a specific blacklist."
        DebloatBlacklist
    })
$RemoveAllBloatware.Add_Click( {
        $ErrorActionPreference = 'silentlycontinue'
        #This Function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
        #Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

        #This is the switch parameter for running this script as a 'silent' script, for use in MDT images or any type of mass deployment without user interaction.

        Function Begin-SysPrep {
            $ErrorActionPreference = 'silentlycontinue'

            Write-Host -Message ('Starting Sysprep Fixes')

            # Disable Windows Store Automatic Updates
            Write-Host -Message "Adding Registry key to Disable Windows Store Automatic Updates"
            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
            If (!(Test-Path $registryPath)) {
                Mkdir $registryPath -ErrorAction SilentlyContinue
                New-ItemProperty $registryPath -Name AutoDownload -Value 2
            }
            Else {
                Set-ItemProperty $registryPath -Name AutoDownload -Value 2
            }
            #Stop WindowsStore Installer Service and set to Disabled
            Write-Host -Message ('Stopping InstallService')
            Stop-Service InstallService
            Write-Host -Message ('Setting InstallService Startup to Disabled')
            & Set-Service -Name InstallService -StartupType Disabled
        }

        Function CheckDMWService {

            Param([switch]$Debloat)

            If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
                Set-Service -Name dmwappushservice -StartupType Automatic
            }

            If (Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
                Start-Service -Name dmwappushservice
            }
        }


        Function DebloatAll {

            [CmdletBinding()]

            Param()

            #Removes AppxPackages
            #Credit to /u/GavinEke for a modified version of my whitelist code
            [regex]$WhitelistedApps = 'Microsoft.ScreenSketch|Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|`
            Microsoft.XboxGameCallableUI|Microsoft.XboxGamingOverlay|Microsoft.Xbox.TCUI|Microsoft.XboxGamingOverlay|Microsoft.XboxIdentityProvider|Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|`
            Microsoft.HEIFImageExtension|Microsoft.ScreenSketch|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|WindSynthBerry|MIDIBerry'
            Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps} | Remove-AppxPackage
            Get-AppxPackage | Where-Object {$_.Name -NotMatch $WhitelistedApps} | Remove-AppxPackage
            Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps} | Remove-AppxProvisionedPackage -Online
        }

        #Creates a PSDrive to be able to access the 'HKCR' tree
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        Function DebloatBlacklist {
            $ErrorActionPreference = 'silentlycontinue'

            $Bloatware = @(

                #Unnecessary Windows 10 AppX Apps
                "Microsoft.BingNews"
                "Microsoft.GetHelp"
                "Microsoft.Getstarted"
                "Microsoft.Messaging"
                "Microsoft.Microsoft3DViewer"
                "Microsoft.MicrosoftOfficeHub"
                "Microsoft.MicrosoftSolitaireCollection"
                "Microsoft.NetworkSpeedTest"
                "Microsoft.News"
                "Microsoft.Office.Lens"
                "Microsoft.Office.OneNote"
                "Microsoft.Office.Sway"
                "Microsoft.OneConnect"
                "Microsoft.People"
                "Microsoft.Print3D"
                "Microsoft.RemoteDesktop"
                "Microsoft.SkypeApp"
                "Microsoft.StorePurchaseApp"
                "Microsoft.Office.Todo.List"
                "Microsoft.Whiteboard"
                "Microsoft.WindowsAlarms"
                #"Microsoft.WindowsCamera"
                "microsoft.windowscommunicationsapps"
                "Microsoft.WindowsFeedbackHub"
                "Microsoft.WindowsMaps"
                "Microsoft.WindowsSoundRecorder"
                "Microsoft.Xbox.TCUI"
                "Microsoft.XboxApp"
                "Microsoft.XboxGameOverlay"
                "Microsoft.XboxIdentityProvider"
                "Microsoft.XboxSpeechToTextOverlay"
                "Microsoft.ZuneMusic"
                "Microsoft.ZuneVideo"

                #Sponsored Windows 10 AppX Apps
                #Add sponsored/featured apps to remove in the "*AppName*" format
                "*EclipseManager*"
                "*ActiproSoftwareLLC*"
                "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
                "*Duolingo-LearnLanguagesforFree*"
                "*PandoraMediaInc*"
                "*CandyCrush*"
                "*Wunderlist*"
                "*Flipboard*"
                "*Twitter*"
                "*Facebook*"
                "*Spotify*"
                "*Minecraft*"
                "*Royal Revolt*"
                "*Sway*"

                #Optional: Typically not removed but you can if you need to for some reason
                #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
                #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
                #"*Microsoft.BingWeather*"
                #"*Microsoft.MSPaint*"
                #"*Microsoft.MicrosoftStickyNotes*"
                #"*Microsoft.Windows.Photos*"
                #"*Microsoft.WindowsCalculator*"
                #"*Microsoft.WindowsStore*"
            )
            foreach ($Bloat in $Bloatware) {
                Get-AppxPackage -Name $Bloat| Remove-AppxPackage -ErrorAction SilentlyContinue
                Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
                Write-Host "Trying to remove $Bloat."
            }
        }

        Function Remove-Keys {
            $ErrorActionPreference = 'silentlycontinue'

            #These are the registry keys that it will delete.

            $Keys = @(

                #Remove Background Tasks
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

                #Windows File
                "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

                #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

                #Scheduled Tasks to delete
                "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"

                #Windows Protocol Keys
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

                #Windows Share Target
                "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            )

            #This writes the output of each key it is removing and also removes the keys listed above.
            ForEach ($Key in $Keys) {
                Write-Host "Removing $Key from registry"
                Remove-Item $Key -Recurse -ErrorAction SilentlyContinue
            }
        }

        Function Protect-Privacy {
            $ErrorActionPreference = 'silentlycontinue'

            #Creates a PSDrive to be able to access the 'HKCR' tree
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

            #Disables Windows Feedback Experience
            Write-Host "Disabling Windows Feedback Experience program"
            $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
            If (Test-Path $Advertising) {
                Set-ItemProperty $Advertising -Name Enabled -Value 0 -Verbose
            }

            #Stops Cortana from being used as part of your Windows Search Function
            Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
            $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
            If (Test-Path $Search) {
                Set-ItemProperty $Search -Name AllowCortana -Value 0 -Verbose
            }

            #Stops the Windows Feedback Experience from sending anonymous data
            Write-Host "Stopping the Windows Feedback Experience program"
            $Period1 = 'HKCU:\Software\Microsoft\Siuf'
            $Period2 = 'HKCU:\Software\Microsoft\Siuf\Rules'
            $Period3 = 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
            If (!(Test-Path $Period3)) {
                mkdir $Period1 -ErrorAction SilentlyContinue
                mkdir $Period2 -ErrorAction SilentlyContinue
                mkdir $Period3 -ErrorAction SilentlyContinue
                New-ItemProperty $Period3 -Name PeriodInNanoSeconds -Value 0 -Verbose -ErrorAction SilentlyContinue
            }

            Write-Host "Adding Registry key to prevent bloatware apps from returning"
            #Prevents bloatware applications from returning
            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
            If (!(Test-Path $registryPath)) {
                Mkdir $registryPath -ErrorAction SilentlyContinue
                New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose -ErrorAction SilentlyContinue
            }

            Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
            $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
            If (Test-Path $Holo) {
                Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 0 -Verbose
            }

            #Disables live tiles
            Write-Host "Disabling live tiles"
            $Live = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'
            If (!(Test-Path $Live)) {
                mkdir $Live -ErrorAction SilentlyContinue
                New-ItemProperty $Live -Name NoTileApplicationNotification -Value 1 -Verbose
            }

            #Turns off Data Collection via the AllowTelemtry key by changing it to 0
            Write-Host "Turning off Data Collection"
            $DataCollection = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
            If (Test-Path $DataCollection) {
                Set-ItemProperty $DataCollection -Name AllowTelemetry -Value 0 -Verbose
            }

            #Disables People icon on Taskbar
            Write-Host "Disabling People icon on Taskbar"
            $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
            If (Test-Path $People) {
                Set-ItemProperty $People -Name PeopleBand -Value 0 -Verbose
            }

            #Disables suggestions on start menu
            Write-Host "Disabling suggestions on the Start Menu"
            $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            If (Test-Path $Suggestions) {
                Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 0 -Verbose
            }


            Write-Output "Removing CloudStore from registry if it exists"
            $CloudStore = 'HKCUSoftware\Microsoft\Windows\CurrentVersion\CloudStore'
            If (Test-Path $CloudStore) {
                Stop-Process Explorer.exe -Force
                Remove-Item $CloudStore
                Start-Process Explorer.exe -Wait
            }

            #Loads the registry keys/values below into the NTUSER.DAT file which prevents the apps from redownloading. Credit to a60wattfish
            reg load HKU\Default_User C:\Users\Default\NTUSER.DAT
            Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SystemPaneSuggestionsEnabled -Value 0
            Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name PreInstalledAppsEnabled -Value 0
            Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name OemPreInstalledAppsEnabled -Value 0
            reg unload HKU\Default_User

            #Disables scheduled tasks that are considered unnecessary
            Write-Host "Disabling scheduled tasks"
            #Get-ScheduledTask -TaskName XblGameSaveTaskLogon | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName XblGameSaveTask | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
        }

        #This includes fixes by xsisbest
        Function FixWhitelistedApps {
            $ErrorActionPreference = 'silentlycontinue'

            If (!(Get-AppxPackage -AllUsers | Select Microsoft.Paint3D, Microsoft.MSPaint, Microsoft.WindowsCalculator, Microsoft.WindowsStore, Microsoft.MicrosoftStickyNotes, Microsoft.WindowsSoundRecorder, Microsoft.Windows.Photos)) {

                #Credit to abulgatz for the 4 lines of code
                Get-AppxPackage -allusers Microsoft.Paint3D | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.MSPaint | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.MicrosoftStickyNotes | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.WindowsSoundRecorder | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.Windows.Photos | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
            }
        }

        Function CheckDMWService {

            Param([switch]$Debloat)

            If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
                Set-Service -Name dmwappushservice -StartupType Automatic
            }

            If (Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
                Start-Service -Name dmwappushservice
            }
        }

        Function CheckInstallService {

            If (Get-Service -Name InstallService | Where-Object {$_.Status -eq "Stopped"}) {
                Start-Service -Name InstallService
                Set-Service -Name InstallService -StartupType Automatic
            }
        }

        Write-Host "Initiating Sysprep"
        Begin-SysPrep
        Write-Host "Removing bloatware apps."
        DebloatAll
        DebloatBlacklist
        Write-Host "Removing leftover bloatware registry keys."
        Remove-Keys
        Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
        FixWhitelistedApps
        Write-Host "Stopping telemetry, disabling unneccessary scheduled tasks, and preventing bloatware from returning."
        Protect-Privacy
        #Write-Host "Stopping Edge from taking over as the default PDF Viewer."
        #Stop-EdgePDF
        Write-Output "Setting the 'InstallService' Windows service back to 'Started' and the Startup Type 'Automatic'."
        CheckDMWService
        CheckInstallService
        Write-Host "Finished all tasks. `n"

    } )
$RemoveBloatNoBlacklist.Add_Click( {
        $ErrorActionPreference = 'silentlycontinue'
        #This Function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
        #Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

        #This is the switch parameter for running this script as a 'silent' script, for use in MDT images or any type of mass deployment without user interaction.

        param (
            [switch]$Debloat, [switch]$SysPrep
        )

        Function Begin-SysPrep {
            $ErrorActionPreference = 'silentlycontinue'

            param([switch]$SysPrep)
            Write-Host -Message ('Starting Sysprep Fixes')

            # Disable Windows Store Automatic Updates
            Write-Host -Message "Adding Registry key to Disable Windows Store Automatic Updates"
            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
            If (!(Test-Path $registryPath)) {
                Mkdir $registryPath -ErrorAction SilentlyContinue
                New-ItemProperty $registryPath -Name AutoDownload -Value 2
            }
            Else {
                Set-ItemProperty $registryPath -Name AutoDownload -Value 2
            }
            #Stop WindowsStore Installer Service and set to Disabled
            Write-Host -Message ('Stopping InstallService')
            Stop-Service InstallService
            Write-Host -Message ('Setting InstallService Startup to Disabled')
            & Set-Service -Name InstallService -StartupType Disabled
        }

        #Creates a PSDrive to be able to access the 'HKCR' tree
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        Function Start-Debloat {
            $ErrorActionPreference = 'silentlycontinue'

            param([switch]$Debloat)

            #Removes AppxPackages
            #Credit to Reddit user /u/GavinEke for a modified version of my whitelist code
            [regex]$WhitelistedApps = 'Microsoft.ScreenSketch|Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|`
            Microsoft.XboxGameCallableUI|Microsoft.XboxGamingOverlay|Microsoft.Xbox.TCUI|Microsoft.XboxGamingOverlay|Microsoft.XboxIdentityProvider|Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|`
            Microsoft.HEIFImageExtension|Microsoft.ScreenSketch|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|WindSynthBerry|MIDIBerry'
            Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps} | Remove-AppxPackage -ErrorAction SilentlyContinue
            # Run this again to avoid error on 1803 or having to reboot.
            Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps} | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }

        Function Remove-Keys {
            $ErrorActionPreference = 'silentlycontinue'

            Param([switch]$Debloat)

            #These are the registry keys that it will delete.

            $Keys = @(

                #Remove Background Tasks
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

                #Windows File
                "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

                #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

                #Scheduled Tasks to delete
                "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"

                #Windows Protocol Keys
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
                "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

                #Windows Share Target
                "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            )

            #This writes the output of each key it is removing and also removes the keys listed above.
            ForEach ($Key in $Keys) {
                Write-Host "Removing $Key from registry"
                Remove-Item $Key -Recurse -ErrorAction SilentlyContinue
            }
        }

        Function Protect-Privacy {
            $ErrorActionPreference = 'silentlycontinue'

            Param([switch]$Debloat)

            #Creates a PSDrive to be able to access the 'HKCR' tree
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

            #Disables Windows Feedback Experience
            Write-Host "Disabling Windows Feedback Experience program"
            $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
            If (Test-Path $Advertising) {
                Set-ItemProperty $Advertising -Name Enabled -Value 0 -Verbose
            }

            #Stops Cortana from being used as part of your Windows Search Function
            Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
            $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
            If (Test-Path $Search) {
                Set-ItemProperty $Search -Name AllowCortana -Value 0 -Verbose
            }

            #Stops the Windows Feedback Experience from sending anonymous data
            Write-Host "Stopping the Windows Feedback Experience program"
            $Period1 = 'HKCU:\Software\Microsoft\Siuf'
            $Period2 = 'HKCU:\Software\Microsoft\Siuf\Rules'
            $Period3 = 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
            If (!(Test-Path $Period3)) {
                mkdir $Period1 -ErrorAction SilentlyContinue
                mkdir $Period2 -ErrorAction SilentlyContinue
                mkdir $Period3 -ErrorAction SilentlyContinue
                New-ItemProperty $Period3 -Name PeriodInNanoSeconds -Value 0 -Verbose -ErrorAction SilentlyContinue
            }

            Write-Host "Adding Registry key to prevent bloatware apps from returning"
            #Prevents bloatware applications from returning
            $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
            If (!(Test-Path $registryPath)) {
                Mkdir $registryPath -ErrorAction SilentlyContinue
                New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose -ErrorAction SilentlyContinue
            }

            Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
            $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
            If (Test-Path $Holo) {
                Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 0 -Verbose
            }

            #Disables live tiles
            Write-Host "Disabling live tiles"
            $Live = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'
            If (!(Test-Path $Live)) {
                mkdir $Live -ErrorAction SilentlyContinue
                New-ItemProperty $Live -Name NoTileApplicationNotification -Value 1 -Verbose
            }

            #Turns off Data Collection via the AllowTelemtry key by changing it to 0
            Write-Host "Turning off Data Collection"
            $DataCollection = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
            If (Test-Path $DataCollection) {
                Set-ItemProperty $DataCollection -Name AllowTelemetry -Value 0 -Verbose
            }

            #Disables People icon on Taskbar
            Write-Host "Disabling People icon on Taskbar"
            $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
            If (Test-Path $People) {
                Set-ItemProperty $People -Name PeopleBand -Value 0 -Verbose
            }

            #Disables suggestions on start menu
            Write-Host "Disabling suggestions on the Start Menu"
            $Suggestions = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            If (Test-Path $Suggestions) {
                Set-ItemProperty $Suggestions -Name SystemPaneSuggestionsEnabled -Value 0 -Verbose
            }

            Write-Output "Removing CloudStore from registry if it exists"
            $CloudStore = 'HKCUSoftware\Microsoft\Windows\CurrentVersion\CloudStore'
            If (Test-Path $CloudStore) {
                Stop-Process Explorer.exe -Force
                Remove-Item $CloudStore
                Start-Process Explorer.exe -Wait
            }

            #Loads the registry keys/values below into the NTUSER.DAT file which prevents the apps from redownloading. Credit to a60wattfish
            reg load HKU\Default_User C:\Users\Default\NTUSER.DAT
            Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name SystemPaneSuggestionsEnabled -Value 0
            Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name PreInstalledAppsEnabled -Value 0
            Set-ItemProperty -Path Registry::HKU\Default_User\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager -Name OemPreInstalledAppsEnabled -Value 0
            reg unload HKU\Default_User

            #Disables scheduled tasks that are considered unnecessary
            Write-Host "Disabling scheduled tasks"
            #Get-ScheduledTask -TaskName XblGameSaveTaskLogon | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName XblGameSaveTask | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
            Get-ScheduledTask -TaskName DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
        }

        #This includes fixes by xsisbest
        Function FixWhitelistedApps {

            Param([switch]$Debloat)

            If (!(Get-AppxPackage -AllUsers | Select Microsoft.Paint3D, Microsoft.MSPaint, Microsoft.WindowsCalculator, Microsoft.WindowsStore, Microsoft.MicrosoftStickyNotes, Microsoft.WindowsSoundRecorder, Microsoft.Windows.Photos)) {

                #Credit to abulgatz for the 4 lines of code
                Get-AppxPackage -allusers Microsoft.Paint3D | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.MSPaint | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.MicrosoftStickyNotes | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.WindowsSoundRecorder | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                Get-AppxPackage -allusers Microsoft.Windows.Photos | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
            }
        }

        Begin-SysPrep
        Write-Host "Removing bloatware apps."
        Start-Debloat
        Write-Host "Removing leftover bloatware registry keys."
        Remove-Keys
        Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
        FixWhitelistedApps
        Write-Host "Stopping telemetry, disabling unneccessary scheduled tasks, and preventing bloatware from returning."
        Protect-Privacy
        #Write-Host "Stopping Edge from taking over as the default PDF Viewer."
        Write-Host "Checking to make sure that the service 'dmwappushservice' has been started."
        CheckDMWService
        Write-Output "Setting the 'InstallService' Windows service back to started and setting the Startup Type to 'Automatic'."
        CheckInstallService
        Write-Host "Finished all tasks. `n"

    })

$FixWhitelist.Add_Click( {
        $ErrorActionPreference = 'silentlycontinue'
        If (!(Get-AppxPackage -AllUsers | Select Microsoft.Paint3D, Microsoft.WindowsCalculator, Microsoft.WindowsStore, Microsoft.Windows.Photos, Microsoft.WindowsCamera)) {

            #Credit to abulgatz for these 4 lines of code
            Get-AppxPackage -allusers Microsoft.Paint3D | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
            Get-AppxPackage -allusers Microsoft.WindowsCalculator | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
            Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
            Get-AppxPackage -allusers Microsoft.Windows.Photos | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
        }

        Write-Host "Whitelisted apps were either fixed or re-added. `n"
    })

$RemoveOnedrive.Add_Click( {
        Write-Output "Checking for pre-existing files and folders located in the OneDrive folders..."
        Start-Sleep 1
        If (Get-Item -Path "$env:USERPROFILE\OneDrive\*") {
            Write-Output "Files found within the OneDrive folder! Checking to see if a folder named OneDriveBackupFiles exists."
            Start-Sleep 1

            If (Get-Item "$env:USERPROFILE\Desktop\OneDriveBackupFiles" -ErrorAction SilentlyContinue) {
                Write-Output "A folder named OneDriveBackupFiles already exists on your desktop. All files from your OneDrive location will be moved to that folder."
            }
            else {
                If (!(Get-Item "$env:USERPROFILE\Desktop\OneDriveBackupFiles" -ErrorAction SilentlyContinue)) {
                    Write-Output "A folder named OneDriveBackupFiles will be created and will be located on your desktop. All files from your OneDrive location will be located in that folder."
                    New-item -Path "$env:USERPROFILE\Desktop" -Name "OneDriveBackupFiles"-ItemType Directory -Force
                    Write-Output "Successfully created the folder 'OneDriveBackupFiles' on your desktop."
                }
            }
            Start-Sleep 1
            Move-Item -Path "$env:USERPROFILE\OneDrive\*" -Destination "$env:USERPROFILE\Desktop\OneDriveBackupFiles" -Force
            Write-Output "Successfully moved all files/folders from your OneDrive folder to the folder 'OneDriveBackupFiles' on your desktop."
            Start-Sleep 1
            Write-Output "Proceeding with the removal of OneDrive."
            Start-Sleep 1
        }
        Else {
            If (!(Get-Item -Path "$env:USERPROFILE\OneDrive\*")) {
                Write-Output "Either the OneDrive folder does not exist or there are no files to be found in the folder. Proceeding with removal of OneDrive."
                Start-Sleep 1
            }

            Write-Host "Enabling the Group Policy 'Prevent the usage of OneDrive for File Storage'."
            $OneDriveKey = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
            If (!(Test-Path $OneDriveKey)) {
                Mkdir $OneDriveKey
            }

            $DisableAllOneDrive = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
            If (Test-Path $DisableAllOneDrive) {
                New-ItemProperty $DisableAllOneDrive -Name OneDrive -Value DisableFileSyncNGSC -Verbose
            }
        }

        Write-Host "Uninstalling OneDrive. Please wait..."

        New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        $onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
        $ExplorerReg1 = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
        $ExplorerReg2 = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
        Stop-Process -Name "OneDrive*"
        Start-Sleep 2
        If (!(Test-Path $onedrive)) {
            $onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
        }
        Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
        Start-Sleep 2
        Write-Host "Stopping explorer"
        Start-Sleep 1
        .\taskkill.exe /F /IM explorer.exe
        Start-Sleep 3
        Write-Host "Removing leftover files"
        Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
        Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
        Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
        If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
            Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
        }
        Write-Host "Removing OneDrive from windows explorer"
        If (!(Test-Path $ExplorerReg1)) {
            New-Item $ExplorerReg1
        }
        Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0
        If (!(Test-Path $ExplorerReg2)) {
            New-Item $ExplorerReg2
        }
        Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0
        Write-Host "Restarting Explorer that was shut down before."
        Start-Process explorer.exe -NoNewWindow
        Write-Host "OneDrive has been successfully uninstalled! `n"

        Write-Host "Enabling the Group Policy 'Prevent the usage of OneDrive for File Storage'."
        $OneDriveKey = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
        If (!(Test-Path $OneDriveKey)) {
            Mkdir $OneDriveKey
        }

        $DisableAllOneDrive = 'HKLM:Software\Policies\Microsoft\Windows\OneDrive'
        If (Test-Path $DisableAllOneDrive) {
            New-ItemProperty $DisableAllOneDrive -Name OneDrive -Value DisableFileSyncNGSC -Verbose
        }
    })
#endregion events }

#endregion GUI }

[void]$Form.ShowDialog()
