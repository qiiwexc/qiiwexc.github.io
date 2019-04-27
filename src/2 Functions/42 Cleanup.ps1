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
        Add-Log $WRN 'Click the button again to continue'
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

    try { Start-Process 'vssadmin' 'delete shadows /all /quiet' -Verb RunAs -Wait }
    catch [Exception] {
        Add-Log $ERR "Failed to delete all restore points: $($_.Exception.Message)"
        return
    }

    Out-Success
}


function Start-FileCleanup {
    $LogMessage = 'Removing unnecessary files...'
    Add-Log $INF $LogMessage

    $ContainerJava86 = "${env:ProgramFiles(x86)}\Java"
    $ContainerJava = "$env:ProgramFiles\Java"
    $ContainerOpera = "$env:ProgramFiles\Opera"
    $ContainerChrome = "$PROGRAM_FILES_86\Google\Chrome\Application"
    $ContainerChromeBeta = "$PROGRAM_FILES_86\Google\Chrome Beta\Application"
    $ContainerChromeDev = "$PROGRAM_FILES_86\Google\Chrome Dev\Application"
    $ContainerGoogleUpdate = "$PROGRAM_FILES_86\Google\Update"

    $NonVersionedDirectories = @('Assets', 'Download', 'Install', 'SetupMetrics')
    $Containers = @($ContainerJava86, $ContainerJava, $ContainerOpera, $ContainerChrome, $ContainerChromeBeta, $ContainerChromeDev, $ContainerGoogleUpdate)

    $NewestJava86 = if (Test-Path $ContainerJava86) { Get-ChildItem $ContainerJava86 -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }
    $NewestJava = if (Test-Path $ContainerJava) { Get-ChildItem $ContainerJava -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }
    $NewestOpera = if (Test-Path $ContainerOpera) { Get-ChildItem $ContainerOpera -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }
    $NewestChrome = if (Test-Path $ContainerChrome) { Get-ChildItem $ContainerChrome -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }
    $NewestChromeBeta = if (Test-Path $ContainerChromeBeta) { Get-ChildItem $ContainerChromeBeta -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }
    $NewestChromeDev = if (Test-Path $ContainerChromeDev) { Get-ChildItem $ContainerChromeDev -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }
    $NewestGoogleUpdate = if (Test-Path $ContainerGoogleUpdate) { Get-ChildItem $ContainerGoogleUpdate -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1 }

    foreach ($Path in $Containers) {
        if (Test-Path $Path) {
            Add-Log $INF "Removing older versions from $Path"

            $Newest = (Get-ChildItem $Path -Directory -Exclude $NonVersionedDirectories | Sort-Object CreationTime | Select-Object -Last 1).Name
            Get-ChildItem $Path -Directory -Exclude $NonVersionedDirectories $Newest | ForEach-Object { Remove-Item $_ -Recurse -Force }

            Out-Success
        }
    }

    $ItemsToDeleteWithExclusions = @(
        "$PROGRAM_FILES_86\Microsoft\Skype for Desktop\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\locales;en-US.pak,lv.pak,ru.pak"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Resource*.dll;TeamViewer_Resource_en.dll,TeamViewer_Resource_ru.dll"
        "$PROGRAM_FILES_86\WinSCP\Translations;WinSCP.ru"
        "$env:ProgramFiles\7-Zip\Lang;en.ttt,lv.txt,ru.txt"
        "$env:ProgramFiles\FileZilla FTP Client\locales;lv_LV,ru"
        "$env:ProgramFiles\Google\Drive\Languages;lv,ru"
        "$env:ProgramFiles\Malwarebytes\Anti-Malware\Languages;lang_ru.qm"
        "$env:ProgramFiles\Microsoft VS Code\locales;en-US.pak,lv.pak,ru.pak"
        "$env:ProgramFiles\Oracle\VirtualBox\nls;qt_ru.qm,VirtualBox_ru.qm"
        "$env:ProgramFiles\paint.net\Resources;ru"
        "$env:ProgramFiles\qBittorrent\translations;qt_lv.qm,qt_ru.qm,qtbase_lv.qm,qtbase_ru.qm"
        "$env:ProgramFiles\VideoLAN\VLC\locale;lv,ru"
        "$NewestOpera\localization;en-US.pak,lv.pak,ru.pak"
        "$NewestChrome\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestChromeBeta\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestChromeDev\Locales;en-US.pak,lv.pak,ru.pak"
        "$NewestGoogleUpdate\goopdateres_*.dll;goopdateres_en-GB.dll,goopdateres_en-US.dll,goopdateres_lv.dll,goopdateres_ru.dll"
    )

    foreach ($Item in $ItemsToDeleteWithExclusions) {
        $Path, $Exclusions = $Item.Split(';')

        if (Test-Path $Path) {
            Add-Log $INF "Cleaning $Path"
            Get-ChildItem $Path -Exclude $Exclusions.Split(',') | ForEach-Object { Remove-Item $_ -Recurse -Force }
            Out-Success
        }
    }

    $ItemsToDelete = @(
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
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\About Java.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\Get Help.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Java\Visit Java.com.url"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\License (English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\User manual (CHM, English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle VM VirtualBox\User manual (PDF, English).lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY (64-bit)\PuTTY Manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY (64-bit)\PuTTY Web Site.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY\PuTTY Manual.lnk"
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PuTTY\PuTTY Web Site.lnk"
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
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\*.pdf"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\AcroCEF\*.txt"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Reader\Legal\ENU\*"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\ReadMe.htm"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Resource\ENUtxt.pdf"
        "$PROGRAM_FILES_86\Adobe\Acrobat Reader DC\Setup Files"
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
        "$PROGRAM_FILES_86\Mozilla Maintenance Service\logs"
        "$PROGRAM_FILES_86\Notepad++\change.log"
        "$PROGRAM_FILES_86\Notepad++\readme.txt"
        "$PROGRAM_FILES_86\Notepad++\updater\LICENSE"
        "$PROGRAM_FILES_86\Notepad++\updater\README.md"
        "$PROGRAM_FILES_86\Razer\Razer Services\Razer Central\Licenses"
        "$PROGRAM_FILES_86\Steam\dumps"
        "$PROGRAM_FILES_86\Steam\logs"
        "$PROGRAM_FILES_86\TeamViewer\*.log"
        "$PROGRAM_FILES_86\TeamViewer\*.txt"
        "$PROGRAM_FILES_86\TeamViewer\TeamViewer_Note.exe"
        "$PROGRAM_FILES_86\WinSCP\license.txt"
        "$PROGRAM_FILES_86\WinSCP\PuTTY\LICENCE"
        "$PROGRAM_FILES_86\WinSCP\PuTTY\putty.chm"
        "$env:ProgramFiles\7-Zip\7-zip.chm"
        "$env:ProgramFiles\7-Zip\7-zip.dll.tmp"
        "$env:ProgramFiles\7-Zip\descript.ion"
        "$env:ProgramFiles\7-Zip\History.txt"
        "$env:ProgramFiles\7-Zip\License.txt"
        "$env:ProgramFiles\7-Zip\readme.txt"
        "$env:ProgramFiles\Dolby\Dolby DAX3\API\amd64\Microsoft.VC90.CRT\README_ENU.txt"
        "$env:ProgramFiles\Dolby\Dolby DAX3\API\x86\Microsoft.VC90.CRT\README_ENU.txt"
        "$env:ProgramFiles\FileZilla FTP Client\AUTHORS"
        "$env:ProgramFiles\FileZilla FTP Client\GPL.html"
        "$env:ProgramFiles\FileZilla FTP Client\NEWS"
        "$env:ProgramFiles\Git\LICENSE.txt"
        "$env:ProgramFiles\Git\mingw64\doc"
        "$env:ProgramFiles\Git\ReleaseNotes.html"
        "$env:ProgramFiles\Git\tmp"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSE.rtf"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\LICENSES.chromium.html"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\licenses"
        "$env:ProgramFiles\Microsoft VS Code\resources\app\ThirdPartyNotices.txt"
        "$env:ProgramFiles\Mozilla Firefox\install.log"
        "$env:ProgramFiles\NVIDIA Corporation\Ansel\Tools\tools_licenses.txt"
        "$env:ProgramFiles\NVIDIA Corporation\Installer2"
        "$env:ProgramFiles\NVIDIA Corporation\license.txt"
        "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.1.pdf"
        "$env:ProgramFiles\Oracle\VirtualBox\doc"
        "$env:ProgramFiles\Oracle\VirtualBox\ExtensionPacks\Oracle_VM_VirtualBox_Extension_Pack\ExtPack-license.*"
        "$env:ProgramFiles\Oracle\VirtualBox\License_en_US.rtf"
        "$env:ProgramFiles\Oracle\VirtualBox\VirtualBox.chm"
        "$env:ProgramFiles\paint.net\License.txt"
        "$env:ProgramFiles\paint.net\Staging"
        "$env:ProgramFiles\PuTTY\LICENCE"
        "$env:ProgramFiles\PuTTY\putty.chm"
        "$env:ProgramFiles\PuTTY\README.txt"
        "$env:ProgramFiles\PuTTY\website.url"
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
        "$env:TMP\*"
        "$env:WinDir\Logs\*"
        "$env:WinDir\Temp\*"
        "$env:WinDir\SoftwareDistribution\Download\*"
    )

    foreach ($Item in $ItemsToDelete) {
        if (Test-Path $Item) {
            Add-Log $INF "Removing $Item"
            Remove-Item $Item -Recurse -Force
            Out-Success
        }
    }

    Add-Log $INF $LogMessage
    Out-Success
}
