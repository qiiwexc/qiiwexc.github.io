function Remove-Trash {
    Add-Log $INF 'Emptying Recycle Bin...'

    try {
        if ($PS_VERSION -ge 5) { Clear-RecycleBin -Force }
        else {
            [String]$Command = '(New-Object -ComObject Shell.Application).Namespace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force }'
            Start-Process 'powershell' "-Command `"$Command`"" -Verb RunAs -WindowStyle Hidden
        }
    }
    catch [Exception] {
        Add-Log $ERR "Failed to empty Recycle Bin: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


function Start-DiskCleanup {
    Add-Log $INF 'Starting disk cleanup utility...'

    try { Start-Process 'cleanmgr' '/lowdisk' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to start disk cleanup utility: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


function Start-CCleaner {
    if (-not $CCleanerWarningShown) {
        Add-Log $WRN 'This task runs silent cleanup with CCleaner using current CCleaner settings'
        Add-Log $WRN 'Click the button again to continue'
        [Bool]$Script:CCleanerWarningShown = $True
        Return
    }

    Add-Log $INF 'Starting CCleaner background task...'

    try { Start-Process $CCleanerExe '/auto' }
    catch [Exception] {
        Add-Log $ERR "Failed to start CCleaner: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


function Start-WindowsCleanup {
    Add-Log $INF 'Starting Windows update cleanup...'

    try { Start-Process 'DISM' '/Online /Cleanup-Image /StartComponentCleanup' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to cleanup Windows updates: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


function Remove-RestorePoints {
    Add-Log $INF 'Deleting all restore points...'

    try { Start-Process 'vssadmin' 'delete shadows /all /quiet' -Verb RunAs }
    catch [Exception] {
        Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"
        Return
    }

    Out-Success
}


function Start-FileCleanup {
    [String]$LogMessage = 'Removing unnecessary files...'
    Add-Log $INF $LogMessage

    [String]$ContainerJava86 = "${env:ProgramFiles(x86)}\Java"
    [String]$ContainerJava = "$env:ProgramFiles\Java"
    [String]$ContainerOpera = "$env:ProgramFiles\Opera"
    [String]$ContainerChrome = "$PROGRAM_FILES_86\Google\Chrome\Application"
    [String]$ContainerChromeBeta = "$PROGRAM_FILES_86\Google\Chrome Beta\Application"
    [String]$ContainerChromeDev = "$PROGRAM_FILES_86\Google\Chrome Dev\Application"
    [String]$ContainerGoogleUpdate = "$PROGRAM_FILES_86\Google\Update"

    [String[]]$NonVersionedDirectories = @('Assets', 'Download', 'Install', 'SetupMetrics')
    [String[]]$Containers = @($ContainerJava86, $ContainerJava, $ContainerOpera, $ContainerChrome, $ContainerChromeBeta, $ContainerChromeDev, $ContainerGoogleUpdate)

    [String]$NewestJava86 = if (Test-Path $ContainerJava86) { Get-ChildItem $ContainerJava86 -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }
    [String]$NewestJava = if (Test-Path $ContainerJava) { Get-ChildItem $ContainerJava -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }
    [String]$NewestOpera = if (Test-Path $ContainerOpera) { Get-ChildItem $ContainerOpera -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }
    [String]$NewestChrome = if (Test-Path $ContainerChrome) { Get-ChildItem $ContainerChrome -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }
    [String]$NewestChromeBeta = if (Test-Path $ContainerChromeBeta) { Get-ChildItem $ContainerChromeBeta -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }
    [String]$NewestChromeDev = if (Test-Path $ContainerChromeDev) { Get-ChildItem $ContainerChromeDev -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }
    [String]$NewestGoogleUpdate = if (Test-Path $ContainerGoogleUpdate) { Get-ChildItem $ContainerGoogleUpdate -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1 }

    foreach ($Path In $Containers) {
        if (Test-Path $Path) {
            Add-Log $INF "Removing older versions from $Path"

            [String]$Newest = (Get-ChildItem $Path -Exclude $NonVersionedDirectories | Where-Object { $_.PSIsContainer } | Sort-Object CreationTime | Select-Object -Last 1).Name
            Get-ChildItem $Path -Exclude $NonVersionedDirectories $Newest | Where-Object { $_.PSIsContainer } | ForEach-Object { Remove-Item $_ -Recurse -Force }

            Out-Success
        }
    }

    [String[]]$ItemsToDeleteWithExclusions = @(
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Resource*.dll;TeamViewer_Resource_en.dll,TeamViewer_Resource_ru.dll"
        "$PROGRAM_FILES_86\WinSCP\Translations;WinSCP.ru"
        "$env:ProgramFiles\7-Zip\Lang;en.ttt,lv.txt,ru.txt"
        "$env:ProgramFiles\CCleaner\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\Defraggler\Lang;lang-1049.dll,lang-1062.dll"
        "$env:ProgramFiles\FileZilla FTP Client\locales;lv_LV,ru"
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
    )

    foreach ($Item In $ItemsToDeleteWithExclusions) {
        [String]$Path, [String]$Exclusions = $Item.Split(';')

        if (Test-Path $Path) {
            Add-Log $INF "Cleaning $Path"
            Get-ChildItem $Path -Exclude $Exclusions.Split(',') | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
            Out-Success
        }
    }

    [String[]]$ItemsToDelete = @(
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
        "$NewestChrome\Installer"
        "$NewestChromeBeta\default_apps"
        "$NewestChromeBeta\Installer"
        "$NewestChromeDev\default_apps"
        "$NewestChromeDev\Installer"
        "$NewestGoogleUpdate\Recovery"
        "$env:SystemDrive\Intel"
        "$env:SystemDrive\Intel\Logs\*"
        "$env:SystemDrive\temp"
        "$env:Public\Foxit Software"
        "$env:UserProfile\.VirtualBox\*.log*"
        "$env:UserProfile\AppData\LocalLow\AuthClient-4-VIP\logs"
        "$env:UserProfile\AppData\LocalLow\PKI Client"
        "$env:UserProfile\AppData\LocalLow\Sun"
        "$env:UserProfile\MicrosoftEdgeBackups"
        "$env:AppData\Code\logs"
        "$env:AppData\Google"
        "$env:AppData\hpqLog"
        "$env:AppData\Microsoft\Skype for Desktop\logs"
        "$env:AppData\Opera Software\Opera Stable\Crash Reports"
        "$env:AppData\Opera Software\Opera Stable\*.log"
        "$env:AppData\Skype"
        "$env:AppData\Sun"
        "$env:AppData\Synapse3"
        "$env:AppData\TeamViewer\*.log"
        "$env:AppData\Visual Studio Code"
        "$env:AppData\vlc\crashdump"
        "$env:LocalAppData\CrashDumps"
        "$env:LocalAppData\DBG"
        "$env:LocalAppData\Deployment"
        "$env:LocalAppData\Diagnostics"
        "$env:LocalAppData\Google\CrashReports"
        "$env:LocalAppData\Google\Software Reporter Tool"
        "$env:LocalAppData\PeerDistRepub"
        "$env:LocalAppData\Razer\Synapse3\Log"
        "$env:LocalAppData\VirtualStore"
        "$env:ProgramData\Adobe"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip\7-Zip Help.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Docs.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Sheets.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Backup and Sync from Google\Google Slides.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\CCleaner\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Defraggler\*.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\About Java.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\*.url"
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
        "$env:ProgramData\Mozilla"
        "$env:ProgramData\NVIDIA Corporation\NvFBCPlugin"
        "$env:ProgramData\NVIDIA Corporation\umdlogs"
        "$env:ProgramData\NVIDIA\*.log_backup1"
        "$env:ProgramData\Oracle"
        "$env:ProgramData\Razer\GameManager\Logs"
        "$env:ProgramData\Razer\Installer\Logs"
        "$env:ProgramData\Razer\Razer Central\Logs"
        "$env:ProgramData\Razer\Razer Central\WebAppCache\Service Worker\Database\*.log"
        "$env:ProgramData\Razer\Synapse3\CrashDumps"
        "$env:ProgramData\Razer\Synapse3\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Charlotte\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Devices\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Bin\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Lib\DetectManager\Log"
        "$env:ProgramData\Razer\Synapse3\Service\Log"
        "$env:ProgramData\Roaming"
        "$env:ProgramData\USOShared"
        "$env:ProgramData\VirtualBox"
        "$env:ProgramData\WindowsHolographicDevices"
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
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Setup Files"
        "$PROGRAM_FILES_86\CCleaner\Setup"
        "$PROGRAM_FILES_86\Dolby\Dolby DAX3\API\amd64\Microsoft.VC90.CRT\README_ENU.txt"
        "$PROGRAM_FILES_86\Dolby\Dolby DAX3\API\x86\Microsoft.VC90.CRT\README_ENU.txt"
        "$PROGRAM_FILES_86\FileZilla FTP Client\AUTHORS"
        "$PROGRAM_FILES_86\FileZilla FTP Client\GPL.html"
        "$PROGRAM_FILES_86\FileZilla FTP Client\NEWS"
        "$PROGRAM_FILES_86\Foxit Software\Foxit Reader\notice.txt"
        "$PROGRAM_FILES_86\Git\LICENSE.txt"
        "$PROGRAM_FILES_86\Git\mingw64\doc"
        "$PROGRAM_FILES_86\Git\ReleaseNotes.html"
        "$PROGRAM_FILES_86\Git\tmp"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome Beta\Temp"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome Dev\Temp"
        "$PROGRAM_FILES_86\Google\Chrome\Application\SetupMetrics"
        "$PROGRAM_FILES_86\Google\Chrome\Temp"
        "$PROGRAM_FILES_86\Google\CrashReports"
        "$PROGRAM_FILES_86\Google\Update\Download"
        "$PROGRAM_FILES_86\Google\Update\Install"
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\*.html"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\licenses"
        "$PROGRAM_FILES_86\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$PROGRAM_FILES_86\Mozilla Firefox\install.log"
        "$PROGRAM_FILES_86\Mozilla Maintenance Service\logs"
        "$PROGRAM_FILES_86\Notepad++\change.log"
        "$PROGRAM_FILES_86\Notepad++\readme.txt"
        "$PROGRAM_FILES_86\Notepad++\updater\LICENSE"
        "$PROGRAM_FILES_86\Notepad++\updater\README.md"
        "$PROGRAM_FILES_86\NVIDIA Corporation\Ansel\Tools\tools_licenses.txt"
        "$PROGRAM_FILES_86\NVIDIA Corporation\license.txt"
        "$PROGRAM_FILES_86\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\doc"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\License_en_US.rtf"
        "$PROGRAM_FILES_86\Oracle\VirtualBox\VirtualBox.chm"
        "$PROGRAM_FILES_86\paint.net\License.txt"
        "$PROGRAM_FILES_86\paint.net\Staging"
        "$PROGRAM_FILES_86\PuTTY\LICENCE"
        "$PROGRAM_FILES_86\PuTTY\putty.chm"
        "$PROGRAM_FILES_86\PuTTY\README.txt"
        "$PROGRAM_FILES_86\PuTTY\website.url"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\Licenses"
        "$PROGRAM_FILES_86\Steam\dumps"
        "$PROGRAM_FILES_86\Steam\logs"
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
        "$env:ProgramFiles\Adobe\Acrobat Reader DC\Setup Files"
        "$env:ProgramFiles\CCleaner\Setup"
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
        "$env:ProgramFiles\Google\Chrome Beta\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome Beta\Temp"
        "$env:ProgramFiles\Google\Chrome Dev\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome Dev\Temp"
        "$env:ProgramFiles\Google\Chrome\Application\SetupMetrics"
        "$env:ProgramFiles\Google\Chrome\Temp"
        "$env:ProgramFiles\Google\CrashReports"
        "$env:ProgramFiles\Google\Update\Download"
        "$env:ProgramFiles\Google\Update\Install"
        "$env:ProgramFiles\Microsoft\Skype for Desktop\*.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$env:ProgramFiles\Mozilla Firefox\install.log"
        "$env:ProgramFiles\Mozilla Maintenance Service\logs"
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
        "$env:ProgramFiles\Steam\dumps"
        "$env:ProgramFiles\Steam\logs"
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
        "$env:TMP\*"
        "$env:WinDir\Logs\*"
        "$env:WinDir\Temp\*"
        "$env:WinDir\SoftwareDistribution\Download\*"
    )

    foreach ($Item In $ItemsToDelete) {
        if (Test-Path $Item) {
            Add-Log $INF "Removing $Item"
            Remove-Item $Item -Recurse -Force -ErrorAction SilentlyContinue
            Out-Success
        }
    }

    if (-not $IS_ELEVATED) {
        Add-Log $WRN 'Removal of certain files requires administrator privileges. To remove them, restart the utility'
        Add-Log $WRN '  as administrator (see Home -> This utility -> Run as administrator) and run this task again.'
    }

    Add-Log $INF $LogMessage
    Out-Success
}
