@echo off

set "psfile=%temp%\qiiwexc.ps1"

> "%psfile%" (
  for /f "delims=" %%A in ('findstr "^::" "%~f0"') do (
    set "line=%%A"
    setlocal enabledelayedexpansion
    echo(!line:~2!
    endlocal
  )
)

if "%~1"=="ShowConsole" (
  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%"
) else (
  powershell -ExecutionPolicy Bypass "%psfile%" -HideConsole -CallerPath "%cd%"
)

::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Info #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::<#
::
::-=-=-=-=-=-= README =-=-=-=-=-=-
::
::To execute, right-click the file, then select "Run with PowerShell".
::
::Double click will simply open the file in Notepad.
::
::
::-=-=-=-= TROUBLESHOOTING =-=-=-=-
::
::If a window briefly opens and closes, press Win+R on the keyboard, paste the following and click OK:
::
::    PowerShell -Command "Start-Process 'PowerShell' -Verb RunAs '-Command Set-ExecutionPolicy RemoteSigned -Force'"
::
::Now you can try starting the utility again
::
::#>
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Params #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::param(
::    [String][Parameter(Position = 0)]$CallerPath,
::    [Switch]$HideConsole
::)
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Constants #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant Version ([Version]'25.9.21')
::
::Set-Variable -Option Constant BUTTON_WIDTH    170
::Set-Variable -Option Constant BUTTON_HEIGHT   30
::
::Set-Variable -Option Constant CHECKBOX_HEIGHT ($BUTTON_HEIGHT - 10)
::
::
::Set-Variable -Option Constant INTERVAL_BUTTON ($BUTTON_HEIGHT + 15)
::
::Set-Variable -Option Constant INTERVAL_CHECKBOX ($CHECKBOX_HEIGHT + 5)
::
::
::Set-Variable -Option Constant GROUP_WIDTH (15 + $BUTTON_WIDTH + 15)
::
::Set-Variable -Option Constant FORM_WIDTH  (($GROUP_WIDTH + 15) * 3 + 30)
::Set-Variable -Option Constant FORM_HEIGHT 560
::
::Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "15, 20"
::
::Set-Variable -Option Constant SHIFT_CHECKBOX "0, $INTERVAL_CHECKBOX"
::
::
::Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
::Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"
::
::
::Set-Variable -Option Constant INF 'INF'
::Set-Variable -Option Constant WRN 'WRN'
::Set-Variable -Option Constant ERR 'ERR'
::
::
::Set-Variable -Option Constant PATH_CURRENT_DIR $CallerPath
::Set-Variable -Option Constant PATH_TEMP_DIR "$([System.IO.Path]::GetTempPath())qiiwexc"
::Set-Variable -Option Constant PATH_PROFILE_ROAMING "$env:USERPROFILE\AppData\Roaming"
::Set-Variable -Option Constant PATH_PROFILE_LOCAL "$env:USERPROFILE\AppData\Local"
::
::Set-Variable -Option Constant SYSTEM_LANGUAGE (Get-SystemLanguage)
::
::Set-Variable -Option Constant IS_ELEVATED (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
::Set-Variable -Option Constant REQUIRES_ELEVATION $(if (!$IS_ELEVATED) { ' *' } else { '' })
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Initialization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Write-Host 'Initializing...'
::
::Set-Variable -Option Constant OLD_WINDOW_TITLE ($HOST.UI.RawUI.WindowTitle)
::$HOST.UI.RawUI.WindowTitle = "qiiwexc v$VERSION$(if ($IS_ELEVATED) {': Administrator'})"
::
::if ($HideConsole) {
::    Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
::                                                                [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
::    [Void][Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)
::}
::
::try {
::    Add-Type -AssemblyName System.Windows.Forms
::} catch {
::    Throw 'System not supported'
::}
::
::[System.Windows.Forms.Application]::EnableVisualStyles()
::
::
::Set-Variable -Option Constant PS_VERSION $PSVersionTable.PSVersion.Major
::
::Set-Variable -Option Constant SHELL (New-Object -com Shell.Application)
::
::Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, Version)
::Set-Variable -Option Constant IsWindows11 ($OperatingSystem.Caption -Match "Windows 11")
::Set-Variable -Option Constant OS_NAME $OperatingSystem.Caption
::Set-Variable -Option Constant OS_BUILD $OperatingSystem.Version
::Set-Variable -Option Constant OS_64_BIT $(if ($env:PROCESSOR_ARCHITECTURE -Like '*64') { $True })
::Set-Variable -Option Constant OS_VERSION $(if ($IsWindows11) { 11 } else { Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } } })
::
::Set-Variable -Option Constant WordRegPath (Get-ItemProperty 'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer' -ErrorAction SilentlyContinue)
::Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
::Set-Variable -Option Constant PathOfficeC2RClientExe "$env:CommonProgramFiles\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
::Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PathOfficeC2RClientExe) { 'C2R' } else { 'MSI' } })
::
::New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Office Installer #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_OFFICE_INSTALLER '[Configurations]
::NOSOUND = 1
::PosR = 1
::ArchR = 1
::DlndArch = 1
::CBBranch = 1
::Word = 1
::Excel = 1
::Access = 0
::Publisher = 0
::Teams = 0
::Groove = 0
::Lync = 0
::OneNote = 0
::OneDrive = 0
::Outlook = 0
::PowerPoint = 1
::Project = 0
::ProjectPro = 0
::ProjectMondo = 0
::Visio = 0
::VisioPro = 0
::VisioMondo = 0
::ProofingTools = 0
::OnOff = 1
::langs = en-GB|lv-LV|
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# 7zip #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_7ZIP 'Windows Registry Editor Version 5.00
::
::[HKEY_CURRENT_USER\Software\7-Zip]
::"LargePages"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\7-Zip\FM]
::"AlternativeSelection"=dword:00000001
::"Columns\RootFolder"=hex:01,00,00,00,00,00,00,00,01,00,00,00,04,00,00,00,01,00,00,00,A0,00,00,00
::"FlatViewArc0"=dword:00000000
::"FlatViewArc1"=dword:00000000
::"FolderHistory"=hex:00,00
::"FolderShortcuts"=""
::"FullRow"=dword:00000001
::"ListMode"=dword:00000303
::"PanelPath0"=""
::"PanelPath1"=""
::"Panels"=hex:02,00,00,00,00,00,00,00,BE,03,00,00
::"Position"=hex:B6,00,00,00,B6,00,00,00,56,06,00,00,49,03,00,00,01,00,00,00
::"ShowDots"=dword:00000001
::"ShowGrid"=dword:00000001
::"ShowRealFileIcons"=dword:00000001
::"ShowSystemMenu"=dword:00000001
::"SingleClick"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\7-Zip\Options]
::"ContextMenu"=dword:00001367
::"MenuIcons"=dword:00000001
::"WriteZoneIdExtract"=dword:00000001
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Chrome Local State #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_CHROME_LOCAL_STATE '{
::  "background_mode": {
::    "enabled": false
::  },
::  "browser": {
::    "first_run_finished": true
::  },
::  "dns_over_https": {
::    "mode": "secure",
::    "templates": "https://chrome.cloudflare-dns.com/dns-query"
::  },
::  "hardware_acceleration_mode_previous": true,
::  "os_update_handler_enabled": true,
::  "performance_tuning": {
::    "battery_saver_mode": {
::      "state": 0
::    }
::  }
::}
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Chrome Preferences #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_CHROME_PREFERENCES '{
::  "browser": {
::    "enable_spellchecking": true,
::    "window_placement": {
::      "maximized": true,
::      "work_area_left": 0,
::      "work_area_top": 0
::    }
::  },
::  "default_search_provider_data": {
::    "mirrored_template_url_data": {
::      "preconnect_to_search_url": true,
::      "prefetch_likely_navigations": true
::    }
::  },
::  "enable_do_not_track": true,
::  "https_first_balanced_mode_enabled": false,
::  "https_only_mode_auto_enabled": false,
::  "https_only_mode_enabled": true,
::  "intl": {
::    "accept_languages": "lv,ru,en-GB",
::    "selected_languages": "lv,ru,en-GB"
::  },
::  "net": {
::    "network_prediction_options": 3
::  },
::  "privacy_sandbox": {
::    "m1": {
::      "ad_measurement_enabled": false,
::      "consent_decision_made": true,
::      "eea_notice_acknowledged": true,
::      "fledge_enabled": false,
::      "topics_enabled": true
::    }
::  },
::  "safebrowsing": {
::    "enabled": true,
::    "enhanced": true
::  },
::  "spellcheck": {
::    "dictionaries": ["lv", "ru", "en-GB"],
::    "use_spelling_service": true
::  }
::}
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Edge Local State #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_EDGE_LOCAL_STATE '{
::  "background_mode": {
::    "enabled": false
::  },
::  "edge": {
::    "perf_center": {
::      "efficiency_mode_toggle": false,
::      "efficiency_mode_v2_is_active": false,
::      "perf_game_mode": false,
::      "perf_game_mode_default_changed": true,
::      "performance_mode": 3,
::      "performance_mode_is_on": false
::    }
::  },
::  "smartscreen": {
::    "enabled": true,
::    "pua_protection_enabled": true
::  },
::  "startup_boost": {
::    "enabled": false
::  }
::}
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Edge Preferences #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_EDGE_PREFERENCES '{
::  "browser": {
::    "editor_proofing_languages": {
::      "en-GB": {
::        "Grammar": true,
::        "Spelling": true
::      },
::      "lv": {
::        "Grammar": true,
::        "Spelling": true
::      },
::      "ru": {
::        "Grammar": true,
::        "Spelling": true
::      }
::    },
::    "enable_editor_proofing": true,
::    "enable_text_prediction_v2": true,
::    "show_hubapps_personalization": false,
::    "show_prompt_before_closing_tabs": true,
::    "window_placement": {
::      "maximized": true,
::      "work_area_left": 0,
::      "work_area_top": 0
::    }
::  },
::  "edge": {
::    "sleeping_tabs": {
::      "enabled": false,
::      "fade_tabs": false,
::      "threshold": 43200
::    },
::    "super_duper_secure_mode": {
::      "enabled": true,
::      "state": 1,
::      "strict_inprivate": true
::    }
::  },
::  "enhanced_tracking_prevention": {
::    "user_pref": 3
::  },
::  "https_only_mode_auto_enabled": false,
::  "https_only_mode_enabled": true,
::  "instrumentation": {
::    "ntp": {
::      "layout_mode": "updateLayout;3;1758293358211",
::      "news_feed_display": "updateFeeds;off;1758293358217"
::    }
::  },
::  "intl": {
::    "accept_languages": "lv,ru,en-GB",
::    "selected_languages": "lv,ru,en-GB"
::  },
::  "local_browser_data_share": {
::    "pin_recommendations_eligible": false
::  },
::  "ntp": {
::    "hide_default_top_sites": true,
::    "layout_mode": 3,
::    "news_feed_display": "off",
::    "next_site_suggestions_available": false,
::    "quick_links_options": 0,
::    "record_user_choices": [
::      {
::        "setting": "layout_mode",
::        "source": "ntp",
::        "value": 3
::      },
::      {
::        "setting": "ntp.news_feed_display",
::        "source": "ntp",
::        "value": "off"
::      },
::      {
::        "setting": "tscollapsed",
::        "source": "updatePrefTSCollapsed",
::        "value": 0
::      },
::      {
::        "setting": "quick_links_options",
::        "source": "ntp",
::        "value": "off"
::      }
::    ]
::  },
::  "spellcheck": {
::    "dictionaries": ["lv", "ru", "en-GB"]
::  },
::  "video_enhancement": {
::    "enabled": true
::  }
::}
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# qBittorrent Base #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_BASE '[Appearance]
::Style=Fusion
::
::[Application]
::FileLogger\Age=1
::FileLogger\AgeType=0
::FileLogger\Backup=true
::FileLogger\DeleteOld=true
::FileLogger\Enabled=true
::FileLogger\MaxSizeBytes=1024
::GUI\Notifications\TorrentAdded=false
::
::[BitTorrent]
::MergeTrackersEnabled=true
::Session\AddExtensionToIncompleteFiles=true
::Session\GlobalMaxRatio=0
::Session\GlobalMaxSeedingMinutes=0
::Session\IDNSupportEnabled=true
::Session\IgnoreSlowTorrentsForQueueing=true
::Session\IncludeOverheadInLimits=true
::Session\MaxActiveDownloads=2
::Session\MaxActiveUploads=1
::Session\PerformanceWarning=true
::Session\PieceExtentAffinity=true
::Session\QueueingSystemEnabled=true
::Session\ReannounceWhenAddressChanged=true
::Session\RefreshInterval=500
::Session\SaveResumeDataInterval=1
::Session\SaveStatisticsInterval=5
::Session\ShareLimitAction=Remove
::Session\SlowTorrentsDownloadRate=1024
::Session\StartPaused=false
::Session\SuggestMode=true
::Session\TorrentStopCondition=FilesChecked
::TrackerEnabled=true
::
::[Core]
::AutoDeleteAddedTorrentFile=Never
::
::[LegalNotice]
::Accepted=true
::
::[MainWindow]
::geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\xff\xff\xff\xf8\0\0\a\x7f\0\0\x3\x8a\0\0\x1\xf7\0\0\0\xbb\0\0\x5\x88\0\0\x2\xed\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\x17\0\0\a\x7f\0\0\x3\x8a)
::
::[Meta]
::MigrationVersion=8
::
::[OptionsDialog]
::HorizontalSplitterSizes=197, 1032
::LastViewedPage=0
::Size=@Size(1255 829)
::
::[RSS]
::AutoDownloader\DownloadRepacks=true
::Session\MaxArticlesPerFeed=9999999
::Session\RefreshInterval=1
::
::[SpeedWidget]
::graph_enable_2=true
::graph_enable_3=true
::graph_enable_4=true
::graph_enable_5=true
::graph_enable_6=true
::graph_enable_7=true
::graph_enable_8=true
::graph_enable_9=true
::period=0
::
::[TorrentProperties]
::CurrentTab=0
::SplitterSizes="71,719"
::Visible=true
::
::[Preferences]
::Advanced\RecheckOnCompletion=true
::Connection\ResolvePeerHostNames=true
::General\CloseToTray=false
::General\CloseToTrayNotified=true
::General\PreventFromSuspendWhenDownloading=true
::General\SpeedInTitleBar=true
::General\StatusbarExternalIPDisplayed=true
::General\SystrayEnabled=false
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# qBittorrent English #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_ENGLISH 'General\Locale=en_GB
::
::[GUI]
::DownloadTrackerFavicon=true
::Log\Enabled=false
::MainWindow\FiltersSidebarWidth=155
::Qt6\TorrentProperties\FilesListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x6\xd1\0\0\0\x6\x1\x1\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\x6\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0\x7f\0\0\0\x1\0\0\0\0\0\0\0U\0\0\0\x1\0\0\0\0\0\0\x5)\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0W\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TorrentProperties\PeerListState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\xf\0@\0\0\0\x1\0\0\0\xe\0\0\0\x64\0\0\x4Y\0\0\0\xf\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\xf\0\0\0r\0\0\0\x1\0\0\0\0\0\0\0V\0\0\0\x1\0\0\0\0\0\0\0\x32\0\0\0\x1\0\0\0\0\0\0\0Y\0\0\0\x1\0\0\0\0\0\0\0\x35\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0g\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0\x61\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0`\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0T\0\0\0\x1\0\0\0\0\0\0\0\x32\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
::Qt6\TorrentProperties\TrackerListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x3\xce\0\0\0\v\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\v\0\0\0\xa2\0\0\0\x1\0\0\0\0\0\0\0\x30\0\0\0\x1\0\0\0\0\0\0\0[\0\0\0\x1\0\0\0\0\0\0\0=\0\0\0\x1\0\0\0\0\0\0\0\x39\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0G\0\0\0\x1\0\0\0\0\0\0\0\x84\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0q\0\0\0\x1\0\0\0\0\0\0\0j\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TransferList\HeaderState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0%\0\xf8\x8f\x66\x1f\0\0\0\x13\0\0\0!\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0\v\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0\x11\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\x13\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\r\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0\xe\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0#\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\x5<\0\0\0%\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0%\0\0\0!\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0\x31\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0J\0\0\0\x1\0\0\0\0\0\0\0=\0\0\0\x1\0\0\0\0\0\0\0;\0\0\0\x1\0\0\0\0\0\0\0\x39\0\0\0\x1\0\0\0\0\0\0\0\x61\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0.\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0`\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0~\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0U\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0V\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::StartUpWindowState=Normal
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# qBittorrent Russian #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_QBITTORRENT_RUSSIAN 'General\Locale=ru
::
::[GUI]
::DownloadTrackerFavicon=true
::Log\Enabled=false
::MainWindow\FiltersSidebarWidth=153
::Qt6\TorrentProperties\FilesListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x6\xd1\0\0\0\x6\x1\x1\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\x6\0\0\0\x33\0\0\0\x1\0\0\0\0\0\0\0r\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0\x8f\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\x4\xfe\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0P\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TorrentProperties\PeerListState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\xf\0@\0\0\0\x1\0\0\0\xe\0\0\0\x64\0\0\x4:\0\0\0\xf\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\xf\0\0\0n\0\0\0\x1\0\0\0\0\0\0\0K\0\0\0\x1\0\0\0\0\0\0\0\x36\0\0\0\x1\0\0\0\0\0\0\0\x62\0\0\0\x1\0\0\0\0\0\0\0>\0\0\0\x1\0\0\0\0\0\0\0\x44\0\0\0\x1\0\0\0\0\0\0\0^\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0L\0\0\0\x1\0\0\0\0\0\0\0\x42\0\0\0\x1\0\0\0\0\0\0\0X\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0M\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
::Qt6\TorrentProperties\TrackerListState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x4\x19\0\0\0\v\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0\v\0\0\0\xb9\0\0\0\x1\0\0\0\0\0\0\0K\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0<\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0q\0\0\0\x1\0\0\0\0\0\0\0^\0\0\0\x1\0\0\0\0\0\0\0]\0\0\0\x1\0\0\0\0\0\0\0~\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\xff\xff\xff\xff\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::Qt6\TransferList\HeaderState="@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0%\0\xf8\x8f\x66\x1f\0\0\0\x13\0\0\0\x11\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\v\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\x13\0\0\0\x64\0\0\0!\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\r\0\0\0\x64\0\0\0\xe\0\0\0\x64\0\0\0#\0\0\0\x64\0\0\x5\xfb\0\0\0%\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0%\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x33\0\0\0\x1\0\0\0\0\0\0\0\x44\0\0\0\x1\0\0\0\0\0\0\0\x65\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0W\0\0\0\x1\0\0\0\0\0\0\0:\0\0\0\x1\0\0\0\0\0\0\0<\0\0\0\x1\0\0\0\0\0\0\0L\0\0\0\x1\0\0\0\0\0\0\0\x42\0\0\0\x1\0\0\0\0\0\0\0_\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0X\0\0\0\x1\0\0\0\0\0\0\0\x43\0\0\0\x1\0\0\0\0\0\0\0\x8a\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0O\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0x\0\0\0\x1\0\0\0\0\0\0\0u\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0P\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)"
::StartUpWindowState=Normal
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# TeamVIewer #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_TEAMVIEWER 'Windows Registry Editor Version 5.00
::
::[HKEY_CURRENT_USER\Software\TeamViewer]
::"AutoHideServerControl"=dword:00000001
::"ColorScheme"=dword:00000001
::"CustomInvitationSubject"=" "
::"CustomInvitationText"=" "
::"Pres_Compression"=dword:00000064
::"Pres_DisableGuiAnimations"=dword:00000000
::"Pres_QualityMode"=dword:00000003
::"Remote_Colors"=dword:00000020
::"Remote_DisableGuiAnimations"=dword:00000000
::"Remote_QualityMode"=dword:00000003
::"Remote_RemoteCursor"=dword:00000001
::"Remote_RemoveWallpaper"=dword:00000000
::"RemotePrintingPreferPDFFormat"=dword:00000001
::"SsoKmsEnabled"=dword:00000002
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# VLC #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_VLC '[qt]
::qt-system-tray=0
::qt-updates-days=1
::qt-privacy-ask=0
::
::[core]
::video-title-show=0
::metadata-network-access=1
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Windows Personalization #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_WINDOWS_PERSONALIZATION 'Windows Registry Editor Version 5.00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
::"GlobalUserDisabled"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent]
::"DisableSpotlightCollectionOnDesktop"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
::"ContentDeliveryAllowed"=dword:00000001
::"RotatingLockScreenEnabled"=dword:00000001
::"RotatingLockScreenOverlayEnabled"=dword:00000001
::"RotatingLockScreenOverlayVisible"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen]
::"CreativeId"=""
::"RotatingLockScreenEnabled"=dword:00000001
::"RotatingLockScreenOverlayEnabled"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"NavPaneExpandToCurrentFolder"=dword:00000001
::"NavPaneShowAllFolders"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers]
::"BackgroundType"=dword:00000006
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Windows #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_WINDOWS 'Windows Registry Editor Version 5.00
::
::[HKEY_CLASSES_ROOT\jpegfile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\pngfile\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open]
::"MuiVerb"="@photoviewer.dll,-3043"
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap]
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,36,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-70"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print]
::"NeverDefault"=""
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget]
::"Clsid"="{60fd46de-f830-4894-a628-6fa81bc0190d}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF]
::"EditFlags"=dword:00010000
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-72"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg]
::"EditFlags"=dword:00010000
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-72"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif]
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-83"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png]
::"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\
::  00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,\
::  77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,\
::  00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,\
::  65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,\
::  00
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\DefaultIcon]
::@="%SystemRoot%\\System32\\imageres.dll,-71"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp]
::"EditFlags"=dword:00010000
::"ImageOptionFlags"=dword:00000001
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\DefaultIcon]
::@="%SystemRoot%\\System32\\wmphoto.dll,-400"
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open]
::"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,\
::  69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,\
::  00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,\
::  72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,\
::  00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget]
::"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
::
::[HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\command]
::@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
::  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
::  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
::  00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
::  25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
::  00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
::  6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
::  00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
::  5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
::  00,31,00,00,00
::
::[HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\DropTarget]
::"{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"=""
::
::[HKEY_CURRENT_USER\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell]
::"ShowCmd"=dword:00000003
::"WFlags"=dword:00000002
::
::[HKEY_CURRENT_USER\Software\Microsoft\Edge\SmartScreenPuaEnabled]
::@=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Feeds]
::"DefaultInterval"=dword:0000000F
::"SyncStatus"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
::"DoNotTrack"=dword:00000001
::"Use FormSuggest"="yes"
::
::[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Privacy]
::"CleanDownloadHistory"=dword:00000001
::"CleanForms"=dword:00000001
::"CleanPassword"=dword:00000001
::"ClearBrowsingHistoryOnExit"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Preferences]
::"AcceptedPrivacyStatement"=dword:00000001
::"FirstRun"=dword:00000000
::"MetadataRetrieval"=dword:00000003
::"SilentAcquisition"=dword:00000001
::"UsageTracking"=dword:00000000
::"Volume"=dword:00000064
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
::"MaximizeApps"=dword:00000001
::"ShowRecommendations"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
::"NavPaneShowAllCloudStates"=dword:00000001
::"Start_IrisRecommendations"=dword:00000000
::"Start_Layout"=dword:00000001
::"TaskbarGlomLevel"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\CIDSizeMRU]
::"0"=hex:4E,00,4F,00,54,00,45,00,50,00,41,00,44,00,2E,00,45,00,58,00,45,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,F8,FF,FF, \
::  FF,F8,FF,FF,FF,88,07,00,00,93,03,00,00,00,00,00,00,00,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,2B,00,00,00,C0,03,00,00,0B,02,00,00,00,00,00,00,00, \
::  00,00,00,00,00,00,00,00,00,00,00,01,00,00,00,FF,FF,FF,FF
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel]
::"AllItemsIconView"=dword:00000000
::"StartupPage"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView]
::"AllItemsIconView"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
::"MSEdge"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer]
::"PreviewPaneSizer"=hex:8D,00,00,00,01,00,00,00,00,00,00,00,3D,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Modules\PerExplorerSettings\3\Sizer]
::"PreviewPaneSizer"=hex:8D,00,00,00,01,00,00,00,00,00,00,00,3D,03,00,00
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences]
::"ArchivedFiles"=dword:00000001
::"SystemFolders"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
::"VisualFXSetting"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings]
::"SecureProtocols"=dword:00002820
::"SyncMode5"=dword:00000003
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache\Content]
::"CacheLimit"=dword:00002000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache]
::"ContentLimit"=dword:00000008
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache]
::"Persistent"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Url History]
::"DaysToKeep"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start]
::"VisiblePlaces"=hex:2F,B3,67,E3,DE,89,55,43,BF,CE,61,F3,7B,18,A9,37,86,08,73, \
::  52,AA,51,43,42,9F,7B,27,76,58,46,59,D4
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy]
::"256"=dword:0000003C
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
::"VideoQualityOnBattery"=dword:00000001
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows Security Health\State]
::"AccountProtection_MicrosoftAccount_Disconnected"=dword:00000000
::
::[HKEY_CURRENT_USER\Software\Microsoft\Windows Security Health\State]
::"Hardware_DataEncryption_AddMsa"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Dfrg\TaskSettings]
::"fAllVolumes"=dword:00000001
::"fDeadlineEnabled"=dword:00000001
::"fExclude"=dword:00000000
::"fTaskEnabled"=dword:00000001
::"TaskFrequency"=dword:00000002
::"Volumes"=" "
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection]
::"SummaryNotificationDisabled"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\NoExecuteState]
::"LastNoExecuteRadioButtonState"=dword:000036BD
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities]
::"ApplicationDescription"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3069"
::"ApplicationName"="@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3009"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations]
::".bmp"="PhotoViewer.FileAssoc.Bitmap"
::".cr2"="PhotoViewer.FileAssoc.Tiff"
::".dib"="PhotoViewer.FileAssoc.Bitmap"
::".gif"="PhotoViewer.FileAssoc.Gif"
::".jfif"="PhotoViewer.FileAssoc.JFIF"
::".jpe"="PhotoViewer.FileAssoc.Jpeg"
::".jpeg"="PhotoViewer.FileAssoc.Jpeg"
::".jpg"="PhotoViewer.FileAssoc.Jpeg"
::".jxr"="PhotoViewer.FileAssoc.Wdp"
::".png"="PhotoViewer.FileAssoc.Png"
::".tif"="PhotoViewer.FileAssoc.Tiff"
::".tiff"="PhotoViewer.FileAssoc.Tiff"
::".wdp"="PhotoViewer.FileAssoc.Wdp"
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup]
::"CostedNetworkPolicy"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run]
::"SecurityHealth"=hex:05,00,00,00,88,26,66,6D,84,2A,DC,01
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
::"PromptOnSecureDesktop"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Search\Preferences]
::"AllowIndexingEncryptedStoresOrItems"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
::"AllowMUUpdateService"=dword:00000001
::"IsContinuousInnovationOptedIn"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
::"AllowUsingDiacritics"=dword:00000001
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows Search]
::"EnableFindMyFiles"=dword:00000001
::"SystemIndexNormalization"=dword:00000003
::
::[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\System]
::"PromptOnSecureDesktop"=dword:00000000
::
::[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
::"AutoUpdateEnabled"=dword:00000001
::"UpdateOnlyOnWifi"=dword:00000000
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# ShutUp10 #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_SHUTUP10 "
::P001	+	# Disable sharing of handwriting data (Category: Privacy)
::P002	+	# Disable sharing of handwriting error reports (Category: Privacy)
::P003	+	# Disable Inventory Collector (Category: Privacy)
::P004	+	# Disable camera in logon screen (Category: Privacy)
::P005	+	# Disable and reset Advertising ID and info for the machine (Category: Privacy)
::P006	+	# Disable and reset Advertising ID and info (Category: Privacy)
::P008	+	# Disable transmission of typing information (Category: Privacy)
::P026	+	# Disable advertisements via Bluetooth (Category: Privacy)
::P027	+	# Disable the Windows Customer Experience Improvement Program (Category: Privacy)
::P028	+	# Disable backup of text messages into the cloud (Category: Privacy)
::P064	+	# Disable suggestions in the timeline (Category: Privacy)
::P065	+	# Disable suggestions in Start (Category: Privacy)
::P066	+	# Disable tips, tricks, and suggestions when using Windows (Category: Privacy)
::P067	+	# Disable showing suggested content in the Settings app (Category: Privacy)
::P070	+	# Disable the possibility of suggesting to finish the setup of the device (Category: Privacy)
::P069	+	# Disable Windows Error Reporting (Category: Privacy)
::P009	-	# Disable biometrical features (Category: Privacy)
::P010	-	# Disable app notifications (Category: Privacy)
::P015	-	# Disable access to local language for browsers (Category: Privacy)
::P068	-	# Disable text suggestions when typing on the software keyboard (Category: Privacy)
::P016	-	# Disable sending URLs from apps to Windows Store (Category: Privacy)
::A001	+	# Disable recordings of user activity (Category: Activity History and Clipboard)
::A002	+	# Disable storing users' activity history (Category: Activity History and Clipboard)
::A003	+	# Disable the submission of user activities to Microsoft (Category: Activity History and Clipboard)
::A004	+	# Disable storage of clipboard history for whole machine (Category: Activity History and Clipboard)
::A006	+	# Disable storage of clipboard history (Category: Activity History and Clipboard)
::A005	+	# Disable the transfer of the clipboard to other devices via the cloud (Category: Activity History and Clipboard)
::P007	+	# Disable app access to user account information (Category: App Privacy)
::P036	+	# Disable app access to user account information (Category: App Privacy)
::P025	+	# Disable Windows tracking of app starts (Category: App Privacy)
::P033	+	# Disable app access to diagnostics information (Category: App Privacy)
::P023	+	# Disable app access to diagnostics information (Category: App Privacy)
::P056	-	# Disable app access to device location (Category: App Privacy)
::P057	-	# Disable app access to device location (Category: App Privacy)
::P012	-	# Disable app access to camera (Category: App Privacy)
::P034	-	# Disable app access to camera (Category: App Privacy)
::P013	-	# Disable app access to microphone (Category: App Privacy)
::P035	-	# Disable app access to microphone (Category: App Privacy)
::P062	-	# Disable app access to use voice activation (Category: App Privacy)
::P063	-	# Disable app access to use voice activation when device is locked (Category: App Privacy)
::P081	-	# Disable the standard app for the headset button (Category: App Privacy)
::P047	-	# Disable app access to notifications (Category: App Privacy)
::P019	-	# Disable app access to notifications (Category: App Privacy)
::P048	-	# Disable app access to motion (Category: App Privacy)
::P049	-	# Disable app access to movements (Category: App Privacy)
::P020	-	# Disable app access to contacts (Category: App Privacy)
::P037	-	# Disable app access to contacts (Category: App Privacy)
::P011	-	# Disable app access to calendar (Category: App Privacy)
::P038	-	# Disable app access to calendar (Category: App Privacy)
::P050	-	# Disable app access to phone calls (Category: App Privacy)
::P051	-	# Disable app access to phone calls (Category: App Privacy)
::P018	-	# Disable app access to call history (Category: App Privacy)
::P039	-	# Disable app access to call history (Category: App Privacy)
::P021	-	# Disable app access to email (Category: App Privacy)
::P040	-	# Disable app access to email (Category: App Privacy)
::P022	-	# Disable app access to tasks (Category: App Privacy)
::P041	-	# Disable app access to tasks (Category: App Privacy)
::P014	-	# Disable app access to messages (Category: App Privacy)
::P042	-	# Disable app access to messages (Category: App Privacy)
::P052	-	# Disable app access to radios (Category: App Privacy)
::P053	-	# Disable app access to radios (Category: App Privacy)
::P054	-	# Disable app access to unpaired devices (Category: App Privacy)
::P055	-	# Disable app access to unpaired devices (Category: App Privacy)
::P029	-	# Disable app access to documents (Category: App Privacy)
::P043	-	# Disable app access to documents (Category: App Privacy)
::P030	-	# Disable app access to images (Category: App Privacy)
::P044	-	# Disable app access to images (Category: App Privacy)
::P031	-	# Disable app access to videos (Category: App Privacy)
::P045	-	# Disable app access to videos (Category: App Privacy)
::P032	-	# Disable app access to the file system (Category: App Privacy)
::P046	-	# Disable app access to the file system (Category: App Privacy)
::P058	-	# Disable app access to wireless equipment (Category: App Privacy)
::P059	-	# Disable app access to wireless technology (Category: App Privacy)
::P060	-	# Disable app access to eye tracking (Category: App Privacy)
::P061	-	# Disable app access to eye tracking (Category: App Privacy)
::P071	-	# Disable the ability for apps to take screenshots (Category: App Privacy)
::P072	-	# Disable the ability for apps to take screenshots (Category: App Privacy)
::P073	-	# Disable the ability for desktop apps to take screenshots (Category: App Privacy)
::P074	-	# Disable the ability for apps to take screenshots without borders (Category: App Privacy)
::P075	-	# Disable the ability for apps to take screenshots without borders (Category: App Privacy)
::P076	-	# Disable the ability for desktop apps to take screenshots without margins (Category: App Privacy)
::P077	-	# Disable app access to music libraries (Category: App Privacy)
::P078	-	# Disable app access to music libraries (Category: App Privacy)
::P079	-	# Disable app access to downloads folder (Category: App Privacy)
::P080	-	# Disable app access to downloads folder (Category: App Privacy)
::P024	-	# Prohibit apps from running in the background (Category: App Privacy)
::S001	-	# Disable password reveal button (Category: Security)
::S002	+	# Disable user steps recorder (Category: Security)
::S003	+	# Disable telemetry (Category: Security)
::S008	-	# Disable Internet access of Windows Media Digital Rights Management (DRM) (Category: Security)
::E101	+	# Disable tracking in the web (Category: Microsoft Edge (new version based on Chromium))
::E201	+	# Disable tracking in the web (Category: Microsoft Edge (new version based on Chromium))
::E115	+	# Disable check for saved payment methods by sites (Category: Microsoft Edge (new version based on Chromium))
::E215	-	# Disable check for saved payment methods by sites (Category: Microsoft Edge (new version based on Chromium))
::E118	+	# Disable personalizing advertising, search, news and other services (Category: Microsoft Edge (new version based on Chromium))
::E218	+	# Disable personalizing advertising, search, news and other services (Category: Microsoft Edge (new version based on Chromium))
::E107	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (new version based on Chromium))
::E207	-	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (new version based on Chromium))
::E111	+	# Disable user feedback in toolbar (Category: Microsoft Edge (new version based on Chromium))
::E211	+	# Disable user feedback in toolbar (Category: Microsoft Edge (new version based on Chromium))
::E112	+	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (new version based on Chromium))
::E212	-	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (new version based on Chromium))
::E109	-	# Disable form suggestions (Category: Microsoft Edge (new version based on Chromium))
::E209	-	# Disable form suggestions (Category: Microsoft Edge (new version based on Chromium))
::E121	-	# Disable suggestions from local providers (Category: Microsoft Edge (new version based on Chromium))
::E221	-	# Disable suggestions from local providers (Category: Microsoft Edge (new version based on Chromium))
::E103	-	# Disable search and website suggestions (Category: Microsoft Edge (new version based on Chromium))
::E203	-	# Disable search and website suggestions (Category: Microsoft Edge (new version based on Chromium))
::E123	+	# Disable shopping assistant in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E223	+	# Disable shopping assistant in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E124	-	# Disable Edge bar (Category: Microsoft Edge (new version based on Chromium))
::E224	+	# Disable Edge bar (Category: Microsoft Edge (new version based on Chromium))
::E128	-	# Disable Sidebar in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E228	-	# Disable Sidebar in Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E129	-	# Disable the Microsoft Account Sign-In Button (Category: Microsoft Edge (new version based on Chromium))
::E229	-	# Disable the Microsoft Account Sign-In Button (Category: Microsoft Edge (new version based on Chromium))
::E130	-	# Disable Enhanced Spell Checking (Category: Microsoft Edge (new version based on Chromium))
::E230	-	# Disable Enhanced Spell Checking (Category: Microsoft Edge (new version based on Chromium))
::E119	-	# Disable use of web service to resolve navigation errors (Category: Microsoft Edge (new version based on Chromium))
::E219	-	# Disable use of web service to resolve navigation errors (Category: Microsoft Edge (new version based on Chromium))
::E120	-	# Disable suggestion of similar sites when website cannot be found (Category: Microsoft Edge (new version based on Chromium))
::E220	-	# Disable suggestion of similar sites when website cannot be found (Category: Microsoft Edge (new version based on Chromium))
::E122	-	# Disable preload of pages for faster browsing and searching (Category: Microsoft Edge (new version based on Chromium))
::E222	-	# Disable preload of pages for faster browsing and searching (Category: Microsoft Edge (new version based on Chromium))
::E125	-	# Disable saving passwords for websites (Category: Microsoft Edge (new version based on Chromium))
::E225	-	# Disable saving passwords for websites (Category: Microsoft Edge (new version based on Chromium))
::E126	-	# Disable site safety services for more information about a visited website (Category: Microsoft Edge (new version based on Chromium))
::E226	-	# Disable site safety services for more information about a visited website (Category: Microsoft Edge (new version based on Chromium))
::E131	-	# Disable automatic redirection from Internet Explorer to Microsoft Edge (Category: Microsoft Edge (new version based on Chromium))
::E106	-	# Disable SmartScreen Filter (Category: Microsoft Edge (new version based on Chromium))
::E206	-	# Disable SmartScreen Filter (Category: Microsoft Edge (new version based on Chromium))
::E127	-	# Disable typosquatting checker for site addresses (Category: Microsoft Edge (new version based on Chromium))
::E227	-	# Disable typosquatting checker for site addresses (Category: Microsoft Edge (new version based on Chromium))
::E001	+	# Disable tracking in the web (Category: Microsoft Edge (legacy version))
::E002	-	# Disable page prediction (Category: Microsoft Edge (legacy version))
::E003	-	# Disable search and website suggestions (Category: Microsoft Edge (legacy version))
::E008	+	# Disable Cortana in Microsoft Edge (Category: Microsoft Edge (legacy version))
::E007	+	# Disable automatic completion of web addresses in address bar (Category: Microsoft Edge (legacy version))
::E010	-	# Disable showing search history (Category: Microsoft Edge (legacy version))
::E011	+	# Disable user feedback in toolbar (Category: Microsoft Edge (legacy version))
::E012	-	# Disable storing and autocompleting of credit card data on websites (Category: Microsoft Edge (legacy version))
::E009	-	# Disable form suggestions (Category: Microsoft Edge (legacy version))
::E004	-	# Disable sites saving protected media licenses on my device (Category: Microsoft Edge (legacy version))
::E005	-	# Do not optimize web search results on the task bar for screen reader (Category: Microsoft Edge (legacy version))
::E013	+	# Disable Microsoft Edge launch in the background (Category: Microsoft Edge (legacy version))
::E014	-	# Disable loading the start and new tab pages in the background (Category: Microsoft Edge (legacy version))
::E006	-	# Disable SmartScreen Filter (Category: Microsoft Edge (legacy version))
::F002	+	# Disable telemetry for Microsoft Office (Category: Microsoft Office)
::F014	+	# Disable diagnostic data submission (Category: Microsoft Office)
::F015	+	# Disable participation in the Customer Experience Improvement Program (Category: Microsoft Office)
::F016	+	# Disable the display of LinkedIn information (Category: Microsoft Office)
::F001	+	# Disable inline text prediction in mails (Category: Microsoft Office)
::F003	+	# Disable logging for Microsoft Office Telemetry Agent (Category: Microsoft Office)
::F004	+	# Disable upload of data for Microsoft Office Telemetry Agent (Category: Microsoft Office)
::F005	+	# Obfuscate file names when uploading telemetry data (Category: Microsoft Office)
::F007	+	# Disable Microsoft Office surveys (Category: Microsoft Office)
::F008	+	# Disable feedback to Microsoft (Category: Microsoft Office)
::F009	+	# Disable Microsoft's feedback tracking (Category: Microsoft Office)
::F017	+	# Disable Microsoft's feedback tracking (Category: Microsoft Office)
::F006	-	# Disable automatic receipt of updates (Category: Microsoft Office)
::F010	-	# Disable connected experiences in Office (Category: Microsoft Office)
::F011	-	# Disable connected experiences with content analytics (Category: Microsoft Office)
::F012	-	# Disable online content downloading for connected experiences (Category: Microsoft Office)
::F013	-	# Disable optional connected experiences in Office (Category: Microsoft Office)
::Y001	-	# Disable synchronization of all settings (Category: Synchronization of Windows Settings)
::Y002	-	# Disable synchronization of design settings (Category: Synchronization of Windows Settings)
::Y003	-	# Disable synchronization of browser settings (Category: Synchronization of Windows Settings)
::Y004	-	# Disable synchronization of credentials (passwords) (Category: Synchronization of Windows Settings)
::Y005	-	# Disable synchronization of language settings (Category: Synchronization of Windows Settings)
::Y006	-	# Disable synchronization of accessibility settings (Category: Synchronization of Windows Settings)
::Y007	-	# Disable synchronization of advanced Windows settings (Category: Synchronization of Windows Settings)
::C012	+	# Disable and reset Cortana (Category: Cortana (Personal Assistant))
::C002	+	# Disable Input Personalization (Category: Cortana (Personal Assistant))
::C013	+	# Disable online speech recognition (Category: Cortana (Personal Assistant))
::C007	+	# Cortana and search are disallowed to use location (Category: Cortana (Personal Assistant))
::C008	+	# Disable web search from Windows Desktop Search (Category: Cortana (Personal Assistant))
::C009	+	# Disable display web results in Search (Category: Cortana (Personal Assistant))
::C010	+	# Disable download and updates of speech recognition and speech synthesis models (Category: Cortana (Personal Assistant))
::C011	+	# Disable cloud search (Category: Cortana (Personal Assistant))
::C014	+	# Disable Cortana above lock screen (Category: Cortana (Personal Assistant))
::C015	+	# Disable the search highlights in the taskbar (Category: Cortana (Personal Assistant))
::C101	+	# Disable the Windows Copilot (Category: Windows AI)
::C201	+	# Disable the Windows Copilot (Category: Windows AI)
::C204	+	# Disable the provision of recall functionality to all users (Category: Windows AI)
::C205	-	# Disable the Image Creator in Microsoft Paint (Category: Windows AI)
::C102	+	# Disable the Copilot button from the taskbar (Category: Windows AI)
::C103	+	# Disable Windows Copilot+ Recall (Category: Windows AI)
::C203	+	# Disable Windows Copilot+ Recall (Category: Windows AI)
::C206	-	# Disable Cocreator in Microsoft Paint (Category: Windows AI)
::C207	-	# Disable AI-powered image fill in Microsoft Paint (Category: Windows AI)
::L001	-	# Disable functionality to locate the system (Category: Location Services)
::L003	+	# Disable scripting functionality to locate the system (Category: Location Services)
::L004	-	# Disable sensors for locating the system and its orientation (Category: Location Services)
::L005	-	# Disable Windows Geolocation Service (Category: Location Services)
::U001	+	# Disable application telemetry (Category: User Behavior)
::U004	+	# Disable diagnostic data from customizing user experiences for whole machine (Category: User Behavior)
::U005	+	# Disable the use of diagnostic data for a tailor-made user experience (Category: User Behavior)
::U006	+	# Disable diagnostic log collection (Category: User Behavior)
::U007	+	# Disable downloading of OneSettings configuration settings (Category: User Behavior)
::W001	+	# Disable Windows Update via peer-to-peer (Category: Windows Update)
::W011	+	# Disable updates to the speech recognition and speech synthesis modules. (Category: Windows Update)
::W004	-	# Activate deferring of upgrades (Category: Windows Update)
::W005	-	# Disable automatic downloading manufacturers' apps and icons for devices (Category: Windows Update)
::W010	-	# Disable automatic driver updates through Windows Update (Category: Windows Update)
::W009	-	# Disable automatic app updates through Windows Update (Category: Windows Update)
::P017	-	# Disable Windows dynamic configuration and update rollouts (Category: Windows Update)
::W006	-	# Disable automatic Windows Updates (Category: Windows Update)
::W008	-	# Disable Windows Updates for other products (e.g. Microsoft Office) (Category: Windows Update)
::M006	+	# Disable occasionally showing app suggestions in Start menu (Category: Windows Explorer)
::M011	-	# Do not show recently opened items in Jump Lists on `"Start`" or the taskbar (Category: Windows Explorer)
::M010	+	# Disable ads in Windows Explorer/OneDrive (Category: Windows Explorer)
::O003	+	# Disable OneDrive access to network before login (Category: Windows Explorer)
::O001	+	# Disable Microsoft OneDrive (Category: Windows Explorer)
::S012	+	# Disable Microsoft SpyNet membership (Category: Microsoft Defender and Microsoft SpyNet)
::S013	+	# Disable submitting data samples to Microsoft (Category: Microsoft Defender and Microsoft SpyNet)
::S014	+	# Disable reporting of malware infection information (Category: Microsoft Defender and Microsoft SpyNet)
::K001	+	# Disable Windows Spotlight (Category: Lock Screen)
::K002	+	# Disable fun facts, tips, tricks, and more on your lock screen (Category: Lock Screen)
::K005	+	# Disable notifications on lock screen (Category: Lock Screen)
::D001	+	# Disable access to mobile devices (Category: Mobile Devices)
::D002	+	# Disable Phone Link app (Category: Mobile Devices)
::D003	+	# Disable showing suggestions for using mobile devices with Windows (Category: Mobile Devices)
::D104	+	# Disable connecting the PC to mobile devices (Category: Mobile Devices)
::M025	+	# Disable search with AI in search box (Category: Search)
::M003	+	# Disable extension of Windows search with Bing (Category: Search)
::M015	+	# Disable People icon in the taskbar (Category: Taskbar)
::M016	+	# Disable search box in task bar (Category: Taskbar)
::M017	+	# Disable `"Meet now`" in the task bar (Category: Taskbar)
::M018	+	# Disable `"Meet now`" in the task bar (Category: Taskbar)
::M019	+	# Disable news and interests in the task bar (Category: Taskbar)
::M021	+	# Disable widgets in Windows Explorer (Category: Taskbar)
::M022	+	# Disable feedback reminders (Category: Miscellaneous)
::M001	+	# Disable feedback reminders (Category: Miscellaneous)
::M004	+	# Disable automatic installation of recommended Windows Store Apps (Category: Miscellaneous)
::M005	+	# Disable tips, tricks, and suggestions while using Windows (Category: Miscellaneous)
::M024	+	# Disable Windows Media Player Diagnostics (Category: Miscellaneous)
::M026	+	# Disable remote assistance connections to this computer (Category: Miscellaneous)
::M027	+	# Disable remote connections to this computer (Category: Miscellaneous)
::M028	+	# Disable the desktop icon for information on `"Windows Spotlight`" (Category: Miscellaneous)
::M012	-	# Disable Key Management Service Online Activation (Category: Miscellaneous)
::M013	-	# Disable automatic download and update of map data (Category: Miscellaneous)
::M014	-	# Disable unsolicited network traffic on the offline maps settings page (Category: Miscellaneous)
::N001	-	# Disable Network Connectivity Status Indicator (Category: Miscellaneous)
::"
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# WinUtil #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant CONFIG_WINUTIL '{
::    "WPFTweaks":  [
::                      "WPFTweaksAH",
::                      "WPFTweaksBraveDebloat",
::                      "WPFTweaksConsumerFeatures",
::                      "WPFTweaksDeleteTempFiles",
::                      "WPFTweaksDisableLMS1",
::                      "WPFTweaksDiskCleanup",
::                      "WPFTweaksDVR",
::                      "WPFTweaksEdgeDebloat",
::                      "WPFTweaksHome",
::                      "WPFTweaksLoc",
::                      "WPFTweaksPowershell7Tele",
::                      "WPFTweaksRecallOff",
::                      "WPFTweaksRemoveCopilot",
::                      "WPFTweaksRemoveGallery",
::                      "WPFTweaksRestorePoint",
::                      "WPFTweaksRightClickMenu",
::                      "WPFTweaksTele",
::                      "WPFTweaksWifi"
::                  ],
::    "Install":  [
::
::                ],
::    "WPFInstall":  [
::
::                   ],
::    "WPFFeature":  [
::                       "WPFFeatureDisableSearchSuggestions",
::                       "WPFFeatureRegBackup"
::                   ]
::}
::'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# TabPage #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function New-TabPage {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text
::    )
::
::    Set-Variable -Option Constant TabPage (New-Object System.Windows.Forms.TabPage)
::
::    $TabPage.UseVisualStyleBackColor = $True
::    $TabPage.Text = $Text
::
::    $TAB_CONTROL.Controls.Add($TabPage)
::
::    Set-Variable -Scope Script PREVIOUS_GROUP $Null
::    Set-Variable -Scope Script CURRENT_TAB $TabPage
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# GroupBox #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function New-GroupBox {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [Int][Parameter(Position = 1)]$IndexOverride
::    )
::
::    Set-Variable -Option Constant GroupBox (New-Object System.Windows.Forms.GroupBox)
::
::    Set-Variable -Scope Script PREVIOUS_GROUP $CURRENT_GROUP
::    Set-Variable -Scope Script PAD_CHECKBOXES $True
::
::    [Int]$GroupIndex = 0
::
::    if ($IndexOverride) {
::        $GroupIndex = $IndexOverride
::    } else {
::        $CURRENT_TAB.Controls | ForEach-Object { $GroupIndex += $_.Length }
::    }
::
::    if ($GroupIndex -lt 3) {
::        Set-Variable -Option Constant Location $(if ($GroupIndex -eq 0) { "15, 15" } else { $PREVIOUS_GROUP.Location + "$($GROUP_WIDTH + 15), 0" })
::    } else {
::        Set-Variable -Option Constant PreviousGroup $CURRENT_TAB.Controls[$GroupIndex - 3]
::        Set-Variable -Option Constant Location ($PreviousGroup.Location + "0, $($PreviousGroup.Height + 15)")
::    }
::
::    $GroupBox.Width = $GROUP_WIDTH
::    $GroupBox.Text = $Text
::    $GroupBox.Location = $Location
::
::    $CURRENT_TAB.Controls.Add($GroupBox)
::
::    Set-Variable -Scope Script PREVIOUS_BUTTON $Null
::    Set-Variable -Scope Script PREVIOUS_RADIO $Null
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
::
::    Set-Variable -Scope Script CURRENT_GROUP $GroupBox
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Button #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function New-ButtonBrowser {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [ScriptBlock][Parameter(Position = 1, Mandatory = $True)]$Function
::    )
::
::    New-Button $Text $Function | Out-Null
::
::    New-Label 'Opens in the browser'
::}
::
::Function New-Button {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [ScriptBlock][Parameter(Position = 1)]$Function,
::        [Switch]$Disabled,
::        [Switch]$UAC
::    )
::
::    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)
::
::    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [System.Drawing.Point]$Shift = "0, 0"
::
::    if ($PREVIOUS_LABEL_OR_CHECKBOX -or $PREVIOUS_RADIO) {
::        $PreviousLabelOrCheckboxY = if ($PREVIOUS_LABEL_OR_CHECKBOX) { $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y } else { 0 }
::        $PreviousRadioY = if ($PREVIOUS_RADIO) { $PREVIOUS_RADIO.Location.Y } else { 0 }
::
::        $PreviousMiscElement = if ($PreviousLabelOrCheckboxY -gt $PreviousRadioY) { $PreviousLabelOrCheckboxY } else { $PreviousRadioY }
::
::        $InitialLocation.Y = $PreviousMiscElement
::        $Shift = "0, 30"
::    } elseif ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "0, $INTERVAL_BUTTON"
::    }
::
::
::    [System.Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $Button.Font = $BUTTON_FONT
::    $Button.Height = $BUTTON_HEIGHT
::    $Button.Width = $BUTTON_WIDTH
::    $Button.Enabled = !$Disabled
::    $Button.Location = $Location
::
::    $Button.Text = if ($UAC) { "$Text$REQUIRES_ELEVATION" } else { $Text }
::
::    if ($Function) {
::        $Button.Add_Click($Function)
::    }
::
::    $CURRENT_GROUP.Height = $Location.Y + $INTERVAL_BUTTON
::    $CURRENT_GROUP.Controls.Add($Button)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
::    Set-Variable -Scope Script PREVIOUS_RADIO $Null
::    Set-Variable -Scope Script PREVIOUS_BUTTON $Button
::
::    Return $Button
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# CheckBox #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function New-CheckBoxRunAfterDownload {
::    Param(
::        [Switch]$Disabled,
::        [Switch]$Checked
::    )
::
::    Return New-CheckBox 'Start after download' -Disabled:$Disabled -Checked:$Checked
::}
::
::Function New-CheckBox {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [String][Parameter(Position = 1)]$Name,
::        [Switch]$Disabled,
::        [Switch]$Checked
::    )
::
::    Set-Variable -Option Constant CheckBox (New-Object System.Windows.Forms.CheckBox)
::
::    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [System.Drawing.Point]$Shift = "0, 0"
::
::    if ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "$INTERVAL_CHECKBOX, 30"
::    }
::
::    if ($PREVIOUS_LABEL_OR_CHECKBOX) {
::        $InitialLocation.Y = $PREVIOUS_LABEL_OR_CHECKBOX.Location.Y
::
::        if ($PAD_CHECKBOXES) {
::            $Shift = "$INTERVAL_CHECKBOX, $CHECKBOX_HEIGHT"
::        } else {
::            $Shift = "0, $INTERVAL_CHECKBOX"
::        }
::    }
::
::    [System.Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $CheckBox.Text = $Text
::    $CheckBox.Name = $Name
::    $CheckBox.Checked = $Checked
::    $CheckBox.Enabled = !$Disabled
::    $CheckBox.Size = "145, $CHECKBOX_HEIGHT"
::    $CheckBox.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($CheckBox)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $CheckBox
::
::    Return $CheckBox
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Label #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function New-Label {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text
::    )
::
::    Set-Variable -Option Constant Label (New-Object System.Windows.Forms.Label)
::
::    [System.Drawing.Point]$Location = ($PREVIOUS_BUTTON.Location + "30, $BUTTON_HEIGHT")
::
::    $Label.Size = "145, $CHECKBOX_HEIGHT"
::    $Label.Text = $Text
::    $Label.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($Label)
::
::    Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Label
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# RadioButton #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function New-RadioButton {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Text,
::        [Switch]$Checked,
::        [Switch]$Disabled
::    )
::
::    Set-Variable -Option Constant RadioButton (New-Object System.Windows.Forms.RadioButton)
::
::    [System.Drawing.Point]$InitialLocation = $INITIAL_LOCATION_BUTTON
::    [System.Drawing.Point]$Shift = "0, 0"
::
::    if ($PREVIOUS_RADIO) {
::        $InitialLocation.X = $PREVIOUS_BUTTON.Location.X
::        $InitialLocation.Y = $PREVIOUS_RADIO.Location.Y
::        $Shift = "90, 0"
::    } elseif ($PREVIOUS_LABEL_OR_CHECKBOX) {
::        $InitialLocation = $PREVIOUS_LABEL_OR_CHECKBOX.Location
::        $Shift = "-15, 20"
::    } elseif ($PREVIOUS_BUTTON) {
::        $InitialLocation = $PREVIOUS_BUTTON.Location
::        $Shift = "10, $BUTTON_HEIGHT"
::    }
::
::    [System.Drawing.Point]$Location = $InitialLocation + $Shift
::
::    $RadioButton.Text = $Text
::    $RadioButton.Checked = $Checked
::    $RadioButton.Enabled = !$Disabled
::    $RadioButton.Size = "80, $CHECKBOX_HEIGHT"
::    $RadioButton.Location = $Location
::
::    $CURRENT_GROUP.Height = $Location.Y + $BUTTON_HEIGHT
::    $CURRENT_GROUP.Controls.Add($RadioButton)
::
::    Set-Variable -Scope Script PREVIOUS_RADIO $RadioButton
::
::    Return $RadioButton
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
::$FORM.Text = $HOST.UI.RawUI.WindowTitle
::$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
::$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
::$FORM.FormBorderStyle = 'Fixed3D'
::$FORM.StartPosition = 'CenterScreen'
::$FORM.MaximizeBox = $False
::$FORM.Top = $True
::$FORM.Add_Shown( {
::    Initialize-Startup
::} )
::$FORM.Add_FormClosing( {
::    Reset-State
::} )
::
::
::Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
::$LOG.Height = 200
::$LOG.Width = $FORM_WIDTH - 10
::$LOG.Location = "5, $($FORM_HEIGHT - $LOG.Height - 5)"
::$LOG.Font = "$FONT_NAME, 9"
::$LOG.ReadOnly = $True
::$FORM.Controls.Add($LOG)
::
::
::Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
::$TAB_CONTROL.Size = "$($LOG.Width + 1), $($FORM_HEIGHT - $LOG.Height - 1)"
::$TAB_CONTROL.Location = "5, 5"
::$FORM.Controls.Add($TAB_CONTROL)
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Home #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant TAB_HOME (New-TabPage 'Home')
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Run as Administrator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Run as Administrator'
::
::
::$BUTTON_TEXT = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Restart as administrator'})"
::$BUTTON_FUNCTION = { Start-Elevated }
::New-Button -UAC $BUTTON_TEXT $BUTTON_FUNCTION -Disabled:$IS_ELEVATED | Out-Null
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Bootable USB Tools #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Bootable USB Tools'
::
::
::$BUTTON_DownloadVentoy = New-Button -UAC 'Ventoy'
::$BUTTON_DownloadVentoy.Add_Click( {
::    Set-Variable -Option Constant FileName $((Split-Path -Leaf 'https://github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-windows.zip') -Replace '-windows', '')
::    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked 'https://github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-windows.zip' -FileName:$FileName
::} )
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartVentoy.Add_CheckStateChanged( {
::    $BUTTON_DownloadVentoy.Text = "Ventoy$(if ($CHECKBOX_StartVentoy.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked 'https://github.com/pbatard/rufus/releases/download/v4.9/rufus-4.9p.exe' -Params:'-g' }
::$BUTTON_DownloadRufus = New-Button -UAC 'Rufus' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartRufus.Add_CheckStateChanged( {
::    $BUTTON_DownloadRufus.Text = "Rufus$(if ($CHECKBOX_StartRufus.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Activators #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Activators (Windows 7+, Office)'
::
::$BUTTON_FUNCTION = { Start-Activator }
::New-Button -UAC 'MAS Activator' $BUTTON_FUNCTION -Disabled:$($OS_VERSION -lt 7)  | Out-Null
::
::
::
::$BUTTON_FUNCTION = { Start-DownloadExtractExecute -AVWarning -Execute:$CHECKBOX_StartActivationProgram.Checked 'https://qiiwexc.github.io/d/ActivationProgram.zip' }
::$BUTTON_DownloadActivationProgram = New-Button -UAC 'Activation Program' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartActivationProgram = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartActivationProgram.Add_CheckStateChanged( {
::    $BUTTON_DownloadActivationProgram.Text = "Activation Program$(if ($CHECKBOX_StartActivationProgram.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Installs #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant TAB_INSTALLS (New-TabPage 'Installs')
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Ninite'
::
::$PAD_CHECKBOXES = $False
::
::
::$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
::$CHECKBOX_Ninite_Chrome.Add_CheckStateChanged( {
::    Set-NiniteButtonState
::} )
::
::$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
::$CHECKBOX_Ninite_7zip.Add_CheckStateChanged( {
::    Set-NiniteButtonState
::} )
::
::$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
::$CHECKBOX_Ninite_VLC.Add_CheckStateChanged( {
::    Set-NiniteButtonState
::} )
::
::$CHECKBOX_Ninite_TeamViewer = New-CheckBox 'TeamViewer' -Name 'teamviewer15' -Checked
::$CHECKBOX_Ninite_TeamViewer.Add_CheckStateChanged( {
::    Set-NiniteButtonState
::} )
::
::$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
::$CHECKBOX_Ninite_qBittorrent.Add_CheckStateChanged( {
::    Set-NiniteButtonState
::} )
::
::$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
::$CHECKBOX_Ninite_Malwarebytes.Add_CheckStateChanged( {
::    Set-NiniteButtonState
::} )
::
::$BUTTON_DownloadNinite = New-Button -UAC 'Download selected'
::$BUTTON_DownloadNinite.Add_Click( {
::    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartNinite.Checked "https://ninite.com/$(Set-NiniteQuery)/ninite.exe" (Set-NiniteFileName)
::} )
::
::$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked
::$CHECKBOX_StartNinite.Add_CheckStateChanged( {
::    $BUTTON_DownloadNinite.Text = "Download selected$(if ($CHECKBOX_StartNinite.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::$BUTTON_FUNCTION = { Open-InBrowser "https://ninite.com/?select=$(Set-NiniteQuery)" }
::New-ButtonBrowser 'View other' $BUTTON_FUNCTION
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Essentials #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Essentials'
::
::
::$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartSDI.Checked 'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.15.6.817.zip' }
::$BUTTON_DownloadSDI = New-Button -UAC 'Snappy Driver Installer' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartSDI.Add_CheckStateChanged( {
::    $BUTTON_DownloadSDI.Text = "Snappy Driver Installer$(if ($CHECKBOX_StartSDI.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::$BUTTON_FUNCTION = { Start-OfficeInstaller -Execute:$CHECKBOX_StartOfficeInstaller.Checked }
::$BUTTON_DownloadOfficeInstaller = New-Button -UAC 'Office Installer+' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartOfficeInstaller.Add_CheckStateChanged( {
::    $BUTTON_DownloadOfficeInstaller.Text = "Office Installer+$(if ($CHECKBOX_StartOfficeInstaller.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::
::$BUTTON_DownloadUnchecky = New-Button -UAC 'Unchecky'
::$BUTTON_DownloadUnchecky.Add_Click( {
::    Set-Variable -Option Constant Params $(if ($CHECKBOX_SilentlyInstallUnchecky.Checked) { '-install -no_desktop_icon' })
::    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartUnchecky.Checked 'https://unchecky.com/files/unchecky_setup.exe' -Params:$Params -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked
::} )
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
::    $BUTTON_DownloadUnchecky.Text = "Unchecky$(if ($CHECKBOX_StartUnchecky.Checked) { $REQUIRES_ELEVATION })"
::    $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
::} )
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Windows Images #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Windows Images'
::
::
::$BUTTON_FUNCTION = { Open-InBrowser 'https://w16.monkrus.ws/2025/01/windows-11-v24h2-rus-eng-20in1-hwid-act.html' }
::New-ButtonBrowser 'Windows 11' $BUTTON_FUNCTION
::
::$BUTTON_FUNCTION = { Open-InBrowser 'https://w16.monkrus.ws/2022/11/windows-10-v22h2-rus-eng-x86-x64-32in1.html' }
::New-ButtonBrowser 'Windows 10' $BUTTON_FUNCTION
::
::$BUTTON_FUNCTION = { Open-InBrowser 'https://w16.monkrus.ws/2024/02/windows-7-sp1-rus-eng-x86-x64-18in1.html' }
::New-ButtonBrowser 'Windows 7' $BUTTON_FUNCTION
::
::$BUTTON_FUNCTION = { Open-InBrowser 'https://rutracker.org/forum/viewtopic.php?t=4366725' }
::New-ButtonBrowser 'Windows PE (Live CD)' $BUTTON_FUNCTION
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant TAB_CONFIGURATION (New-TabPage 'Configuration')
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Apps Configuration #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Apps Configuration'
::
::$PAD_CHECKBOXES = $False
::
::
::$CHECKBOX_Config_Windows = New-CheckBox 'Windows' -Checked
::
::$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Checked
::
::$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Checked
::
::$CHECKBOX_Config_TeamViewer = New-CheckBox 'TeamViewer' -Checked
::
::$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Checked
::
::$CHECKBOX_Config_Edge = New-CheckBox 'Microsoft Edge' -Checked
::
::$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Checked
::
::
::$BUTTON_FUNCTION = { Set-AppsConfiguration }
::New-Button -UAC 'Apply configuration' $BUTTON_FUNCTION | Out-Null
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Alternative DNS #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Alternative DNS'
::
::
::$BUTTON_FUNCTION = { Set-CloudFlareDNS }
::New-Button -UAC 'Setup CloudFlare DNS' $BUTTON_FUNCTION | Out-Null
::
::$CHECKBOX_CloudFlareAntiMalware = New-CheckBox 'Malware protection' -Checked
::$CHECKBOX_CloudFlareAntiMalware.Add_CheckStateChanged( {
::    $CHECKBOX_CloudFlareFamilyFriendly.Enabled = $CHECKBOX_CloudFlareAntiMalware.Checked
::} )
::
::$CHECKBOX_CloudFlareFamilyFriendly = New-CheckBox 'Adult content filtering'
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Deboat Windows #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Debloat Windows and Privacy'
::
::
::$BUTTON_FUNCTION = { Start-WindowsDebloat }
::New-Button -UAC 'Windows 10/11 debloat' $BUTTON_FUNCTION | Out-Null
::
::
::$BUTTON_FUNCTION = { Start-ShutUp10 -Execute:$CHECKBOX_StartShutUp10.Checked -Silent:($CHECKBOX_StartShutUp10.Checked -and $CHECKBOX_SilentlyRunShutUp10.Checked) }
::$BUTTON_StartShutUp10 = New-Button -UAC 'ShutUp10++ privacy' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartShutUp10 = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartShutUp10.Add_CheckStateChanged( {
::    $CHECKBOX_SilentlyRunShutUp10.Enabled = $CHECKBOX_StartShutUp10.Checked
::    $BUTTON_StartShutUp10.Text = "ShutUp10++ privacy$(if ($CHECKBOX_StartShutUp10.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_SilentlyRunShutUp10 = New-CheckBox 'Silently apply tweaks' -Disabled:$CHECKBOX_DISABLED
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Windows Configurator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Windows Configurator' 4
::
::
::$BUTTON_FUNCTION = { Start-WinUtil -Apply:$CHECKBOX_SilentlyRunWinUtil.Checked }
::New-Button -UAC 'WinUtil' $BUTTON_FUNCTION | Out-Null
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_SilentlyRunWinUtil = New-CheckBox 'Auto apply tweaks' -Disabled:$CHECKBOX_DISABLED
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Set-Variable -Option Constant TAB_DIAGNOSTICS (New-TabPage 'Diagnostics and Recovery')
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Hardware Info #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Hardware Info'
::
::
::$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartCpuZ.Checked 'https://download.cpuid.com/cpu-z/cpu-z_2.16-en.zip' }
::$BUTTON_DownloadCpuZ = New-Button -UAC 'CPU-Z' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartCpuZ.Add_CheckStateChanged( {
::    $BUTTON_DownloadCpuZ.Text = "CPU-Z$(if ($CHECKBOX_StartCpuZ.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# HDD Diagnostics #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'HDD Diagnostics'
::
::
::$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVictoria.Checked 'https://hdd.by/Victoria/Victoria537.zip' }
::$BUTTON_DownloadVictoria = New-Button -UAC 'Victoria' $BUTTON_FUNCTION
::
::$CHECKBOX_DISABLED = $PS_VERSION -le 2
::$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
::$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
::$CHECKBOX_StartVictoria.Add_CheckStateChanged( {
::    $BUTTON_DownloadVictoria.Text = "Victoria$(if ($CHECKBOX_StartVictoria.Checked) { $REQUIRES_ELEVATION })"
::} )
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# TronScript #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::New-GroupBox 'Windows Disinfection'
::
::
::$BUTTON_FUNCTION = { Open-InBrowser 'https://github.com/bmrf/tron/blob/master/README.md#use' }
::New-ButtonBrowser 'Download TronScript' $BUTTON_FUNCTION
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Startup #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Initialize-Startup {
::    $FORM.Activate()
::    Write-LogMessage "[$((Get-Date).ToString())] Initializing..."
::
::    if ($IS_ELEVATED) {
::        Set-Variable -Option Constant IE_Registry_Key 'Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Internet Explorer\Main'
::
::        if (!(Test-Path $IE_Registry_Key)) {
::            New-Item $IE_Registry_Key -Force | Out-Null
::        }
::
::        Set-ItemProperty -Path $IE_Registry_Key -Name "DisableFirstRunCustomize" -Value 1
::    }
::
::    if ($PS_VERSION -lt 2) {
::        Add-Log $WRN "PowerShell $PS_VERSION detected, while PowerShell 2 and newer are supported. Some features might not work correctly."
::    } elseif ($PS_VERSION -eq 2) {
::        Add-Log $WRN "PowerShell $PS_VERSION detected, some features are not supported and are disabled."
::    }
::
::    if ($OS_VERSION -lt 8) {
::        Add-Log $WRN "Windows $OS_VERSION detected, some features are not supported."
::    }
::
::    if ($PS_VERSION -gt 2) {
::        try {
::            [Net.ServicePointManager]::SecurityProtocol = 'Tls12'
::        } catch [Exception] {
::            Add-Log $WRN "Failed to configure security protocol, downloading from GitHub might not work: $($_.Exception.Message)"
::        }
::
::        try {
::            Add-Type -AssemblyName System.IO.Compression.FileSystem
::            Set-Variable -Option Constant -Scope Script ZIP_SUPPORTED $True
::        } catch [Exception] {
::            Add-Log $WRN "Failed to load 'System.IO.Compression.FileSystem' module: $($_.Exception.Message)"
::        }
::    }
::
::    Add-Log $INF 'Current system information:'
::
::    Set-Variable -Option Constant ComputerSystem (Get-WmiObject Win32_ComputerSystem)
::    Set-Variable -Option Constant Computer ($ComputerSystem | Select-Object PCSystemType)
::
::    if ($Computer) {
::        Add-Log $INF "    Computer type:  $(Switch ($Computer.PCSystemType) { 1 {'Desktop'} 2 {'Laptop'} Default {'Other'} })"
::    }
::
::    Set-Variable -Option Constant OfficeYear $(Switch ($OFFICE_VERSION) { 16 { '2016 / 2019 / 2021 / 2024' } 15 { '2013' } 14 { '2010' } 12 { '2007' } 11 { '2003' } })
::    Set-Variable -Option Constant OfficeName $(if ($OfficeYear) { "Microsoft Office $OfficeYear" } else { 'Unknown version or not installed' })
::    Set-Variable -Option Constant WindowsRelease ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').ReleaseId)
::
::    Add-Log $INF "    Operation system:  $OS_NAME"
::    Add-Log $INF "    OS architecture:  $(if ($OS_64_BIT) { '64-bit' } else { '32-bit' })"
::    Add-Log $INF "    OS language:  $SYSTEM_LANGUAGE"
::    Add-Log $INF "    $(if ($OS_VERSION -ge 10) {'OS release / '})Build number:  $(if ($OS_VERSION -ge 10) {"v$WindowsRelease / "})$OS_BUILD"
::    Add-Log $INF "    Office version:  $OfficeName $(if ($OFFICE_INSTALL_TYPE) {`"($OFFICE_INSTALL_TYPE installation type)`"})"
::
::    Get-CurrentVersion
::
::    if ($OFFICE_INSTALL_TYPE -eq 'MSI' -and $OFFICE_VERSION -ge 15) {
::        Add-Log $WRN 'MSI installation of Microsoft Office is detected.'
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Logger #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Add-Log {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Message
::    )
::
::    $LOG.SelectionStart = $LOG.TextLength
::
::    Switch ($Level) {
::        $WRN {
::            $LOG.SelectionColor = 'blue'
::        }
::        $ERR {
::            $LOG.SelectionColor = 'red'
::        }
::        Default {
::            $LOG.SelectionColor = 'black'
::        }
::    }
::
::    Write-LogMessage "`n[$((Get-Date).ToString())] $Message"
::}
::
::
::Function Write-LogMessage {
::    Param([String][Parameter(Position = 0, Mandatory = $True)]$Text)
::
::    Write-Host -NoNewline $Text
::    $LOG.AppendText($Text)
::    $LOG.SelectionColor = 'black'
::    $LOG.ScrollToCaret()
::}
::
::
::Function Out-Status {
::    Param([String][Parameter(Position = 0, Mandatory = $True)]$Status)
::
::    Write-LogMessage ' '
::
::    Set-Variable -Option Constant LogDefaultFont $LOG.Font
::    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)
::
::    Write-LogMessage $Status
::
::    $LOG.SelectionFont = $LogDefaultFont
::    $LOG.SelectionColor = 'black'
::}
::
::
::Function Out-Success {
::    Out-Status 'Done'
::}
::
::Function Out-Failure {
::    Out-Status 'Failed'
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Self-Update #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Get-CurrentVersion {
::    if ($PS_VERSION -le 2) {
::        Add-Log $WRN "Automatic self-update requires PowerShell 3 or higher (currently running on PowerShell $PS_VERSION)"
::        Return
::    }
::
::    Add-Log $INF 'Checking for updates...'
::
::    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
::    if ($IsNotConnected) {
::        Add-Log $ERR "Failed to check for updates: $IsNotConnected"
::        Return
::    }
::
::    $ProgressPreference = 'SilentlyContinue'
::    try {
::        Set-Variable -Option Constant LatestVersion ([Version](Invoke-WebRequest 'https://bit.ly/qiiwexc_version').ToString())
::        $ProgressPreference = 'Continue'
::    } catch [Exception] {
::        $ProgressPreference = 'Continue'
::        Add-Log $ERR "Failed to check for updates: $($_.Exception.Message)"
::        Return
::    }
::
::    if ($LatestVersion -gt $VERSION) {
::        Add-Log $WRN "Newer version available: v$LatestVersion"
::        Get-Update
::    } else {
::        Out-Status 'No updates available'
::    }
::}
::
::
::Function Get-Update {
::    Set-Variable -Option Constant TargetFileBat "$PATH_CURRENT_DIR\qiiwexc.bat"
::
::    Add-Log $WRN 'Downloading new version...'
::
::    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
::
::    if ($IsNotConnected) {
::        Add-Log $ERR "Failed to download update: $IsNotConnected"
::        Return
::    }
::
::    try {
::        Invoke-WebRequest 'https://bit.ly/qiiwexc_bat' -OutFile $TargetFileBat
::    } catch [Exception] {
::        Add-Log $ERR "Failed to download update: $($_.Exception.Message)"
::        Return
::    }
::
::    Out-Success
::    Add-Log $WRN 'Restarting...'
::
::    try {
::        Start-Script $TargetFileBat
::    } catch [Exception] {
::        Add-Log $ERR "Failed to start new version: $($_.Exception.Message)"
::        Return
::    }
::
::    Exit-Script
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Common #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Get-NetworkAdapter {
::    Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
::}
::
::Function Get-ConnectionStatus {
::    if (!(Get-NetworkAdapter)) {
::        Return 'Computer is not connected to the Internet'
::    }
::}
::
::Function Reset-State {
::    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR
::    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
::    Write-Host ''
::}
::
::Function Exit-Script {
::    Reset-State
::    $FORM.Close()
::}
::
::
::Function Open-InBrowser {
::    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)
::
::    Add-Log $INF "Opening URL in the default browser: $URL"
::
::    try {
::        [System.Diagnostics.Process]::Start($URL)
::    } catch [Exception] {
::        Add-Log $ERR "Could not open the URL: $($_.Exception.Message)"
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Script #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-Script {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Command,
::        [String]$WorkingDirectory,
::        [Switch]$BypassExecutionPolicy,
::        [Switch]$Elevated,
::        [Switch]$HideConsole,
::        [Switch]$HideWindow,
::        [Switch]$Wait
::    )
::
::    Set-Variable -Option Constant ExecutionPolicy $(if ($BypassExecutionPolicy) { '-ExecutionPolicy Bypass' } else { '' })
::    Set-Variable -Option Constant ConsoleState $(if ($HideConsole) { '-HideConsole' } else { '' })
::    Set-Variable -Option Constant CallerPath $(if ($WorkingDirectory) { "-CallerPath:$WorkingDirectory" } else { '' })
::    Set-Variable -Option Constant Verb $(if ($Elevated) { 'RunAs' } else { 'Open' })
::    Set-Variable -Option Constant WindowStyle $(if ($HideWindow) { 'Hidden' } else { 'Normal' })
::
::    Set-Variable -Option Constant FullCommand "$ExecutionPolicy $Command $ConsoleState $CallerPath"
::
::    Start-Process 'PowerShell' $FullCommand -Wait:$Wait -Verb:$Verb -WindowStyle:$WindowStyle
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download File #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-Download {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
::        [String][Parameter(Position = 1)]$SaveAs,
::        [Switch]$Temp
::    )
::
::    Set-Variable -Option Constant FileName $(if ($SaveAs) { $SaveAs } else { Split-Path -Leaf $URL })
::    Set-Variable -Option Constant TempPath "$PATH_TEMP_DIR\$FileName"
::    Set-Variable -Option Constant SavePath $(if ($Temp) { $TempPath } else { "$PATH_CURRENT_DIR\$FileName" })
::
::    New-Item -Force -ItemType Directory $PATH_TEMP_DIR | Out-Null
::
::    Add-Log $INF "Downloading from $URL"
::
::    Set-Variable -Option Constant IsNotConnected (Get-ConnectionStatus)
::    if ($IsNotConnected) {
::        Add-Log $ERR "Download failed: $IsNotConnected"
::
::        if (Test-Path $SavePath) {
::            Add-Log $WRN "Previous download found, returning it"
::            Return $SavePath
::        } else {
::            Return
::        }
::    }
::
::    try {
::        Remove-Item -Force -ErrorAction SilentlyContinue $SavePath
::        (New-Object System.Net.WebClient).DownloadFile($URL, $TempPath)
::
::        if (!$Temp) {
::            Move-Item -Force -ErrorAction SilentlyContinue $TempPath $SavePath
::        }
::
::        if (Test-Path $SavePath) {
::            Out-Success
::        } else {
::            Throw 'Possibly computer is offline or disk is full'
::        }
::    } catch [Exception] {
::        Add-Log $ERR "Download failed: $($_.Exception.Message)"
::        Return
::    }
::
::    Return $SavePath
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Extract ZIP #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-Extraction {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$ZipPath,
::        [Switch]$Execute
::    )
::
::    Set-Variable -Option Constant ZipName (Split-Path -Leaf $ZipPath)
::    Set-Variable -Option Constant ExtractionPath $ZipPath.TrimEnd('.zip')
::    Set-Variable -Option Constant ExtractionDir (Split-Path -Leaf $ExtractionPath)
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
::
::    [String]$Executable = Switch -Wildcard ($ZipName) {
::        'ActivationProgram.zip' { "ActivationProgram$(if ($OS_64_BIT) {''} else {'_x86'}).exe" }
::        'Office_Installer+.zip' { "Office Installer+$(if ($OS_64_BIT) {''} else {' x86'}).exe" }
::        'cpu-z_*' { "$ExtractionDir\cpuz_x$(if ($OS_64_BIT) {'64'} else {'32'}).exe" }
::        'SDIO_*' { "$ExtractionDir\SDIO_auto.bat" }
::        'ventoy*' { "$ExtractionDir\$ExtractionDir\Ventoy2Disk.exe" }
::        'Victoria*' { "$ExtractionDir\$ExtractionDir\Victoria.exe" }
::        Default { $ZipName.TrimEnd('.zip') + '.exe' }
::    }
::
::    Set-Variable -Option Constant IsDirectory ($ExtractionDir -and $Executable -Like "$ExtractionDir\*")
::    Set-Variable -Option Constant TemporaryExe "$ExtractionPath\$Executable"
::    Set-Variable -Option Constant TargetExe "$TargetPath\$Executable"
::
::    Remove-Item -Force -ErrorAction SilentlyContinue $TemporaryExe
::    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
::    New-Item -Force -ItemType Directory $ExtractionPath | Out-Null
::
::    Add-Log $INF "Extracting '$ZipPath'..."
::
::    try {
::        if ($ZIP_SUPPORTED) {
::            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $ExtractionPath)
::        } else {
::            ForEach ($Item In $SHELL.NameSpace($ZipPath).Items()) {
::                $SHELL.NameSpace($ExtractionPath).CopyHere($Item)
::            }
::        }
::    } catch [Exception] {
::        Add-Log $ERR "Failed to extract '$ZipPath': $($_.Exception.Message)"
::        Return
::    }
::
::    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath
::
::    if (!$IsDirectory) {
::        Move-Item -Force -ErrorAction SilentlyContinue $TemporaryExe $TargetExe
::        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $ExtractionPath
::    }
::
::    if (!$Execute -and $IsDirectory) {
::        Remove-Item -Force -ErrorAction SilentlyContinue -Recurse "$TargetPath\$ExtractionDir"
::        Move-Item -Force -ErrorAction SilentlyContinue $ExtractionPath $TargetPath
::    }
::
::    Out-Success
::    Add-Log $INF "Files extracted to '$TargetPath'"
::
::    Return $TargetExe
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Run Executable #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-Executable {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$Executable,
::        [String][Parameter(Position = 1)]$Switches,
::        [Switch]$Silent
::    )
::
::    if ($Switches -and $Silent) {
::        Add-Log $INF "Running '$Executable' silently..."
::
::        try {
::            Start-Process -Wait $Executable $Switches
::        } catch [Exception] {
::            Add-Log $ERR "Failed to run '$Executable': $($_.Exception.Message)"
::            Return
::        }
::
::        Out-Success
::
::        Add-Log $INF "Removing '$Executable'..."
::        Remove-Item -Force $Executable
::        Out-Success
::    } else {
::        Add-Log $INF "Running '$Executable'..."
::
::        try {
::            if ($Switches) {
::                Start-Process $Executable $Switches -WorkingDirectory (Split-Path $Executable)
::            } else {
::                Start-Process $Executable -WorkingDirectory (Split-Path $Executable)
::            }
::        } catch [Exception] {
::            Add-Log $ERR "Failed to execute '$Executable': $($_.Exception.Message)"
::            Return
::        }
::
::        Out-Success
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Download Extract Execute #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-DownloadExtractExecute {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$URL,
::        [String][Parameter(Position = 1)]$FileName,
::        [String][Parameter(Position = 2)]$Params,
::        [Switch]$AVWarning,
::        [Switch]$Execute,
::        [Switch]$Silent
::    )
::
::    if ($AVWarning -and !$AVWarningShown) {
::        Add-Log $WRN 'This file may trigger anti-virus false positive!'
::        Add-Log $WRN 'It is recommended to disable anti-virus software for download and subsequent use of this file!'
::        Add-Log $WRN 'Click the button again to continue'
::        Set-Variable -Option Constant -Scope Script AVWarningShown $True
::        Return
::    }
::
::    if ($PS_VERSION -le 2 -and ($URL -Match '*github.com/*' -or $URL -Match '*github.io/*')) {
::        Open-InBrowser $URL
::    } else {
::        Set-Variable -Option Constant UrlEnding $URL.Substring($URL.Length - 4)
::        Set-Variable -Option Constant IsZip ($UrlEnding -eq '.zip')
::        Set-Variable -Option Constant DownloadedFile (Start-Download $URL $FileName -Temp:$($Execute -or $IsZip))
::
::        if ($DownloadedFile) {
::            Set-Variable -Option Constant Executable $(if ($IsZip) { Start-Extraction $DownloadedFile -Execute:$Execute } else { $DownloadedFile })
::
::            if ($Execute) {
::                Start-Executable $Executable $Params -Silent:$Silent
::            }
::        }
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Merge JSON #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Merge-JsonObjects {
::    Param(
::        [Parameter(Position = 0, Mandatory = $True)]$Source,
::        [Parameter(Position = 1, Mandatory = $True)]$Extend
::    )
::
::    if ($Source -is [PSCustomObject] -and $Extend -is [PSCustomObject]) {
::        $Merged = [Ordered] @{}
::
::        ForEach ($Property In $Source.PSObject.Properties) {
::            if ($Null -eq $Extend.$($Property.Name)) {
::                $Merged[$Property.Name] = $Property.Value
::            } else {
::                $Merged[$Property.Name] = Merge-JsonObjects $Property.Value $Extend.$($Property.Name)
::            }
::        }
::
::        ForEach ($Property In $Extend.PSObject.Properties) {
::            if ($Null -eq $Source.$($Property.Name)) {
::                $Merged[$Property.Name] = $Property.Value
::            }
::        }
::
::        [PSCustomObject] $Merged
::    } elseif ($Source -is [Collections.IList] -and $Extend -is [Collections.IList]) {
::        $MaxCount = [Math]::Max($Source.Count, $Extend.Count)
::
::        [Array]$Merged = for ($i = 0; $i -lt $MaxCount; ++$i) {
::            if ($i -ge $Source.Count) {
::                $Extend[$i]
::            } elseif ($i -ge $Extend.Count) {
::                $Source[$i]
::            } else {
::                Merge-JsonObjects $Source[$i] $Extend[$i]
::            }
::        }
::
::        , $Merged
::    } else {
::        $Extend
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Configuration Helpers #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Write-ConfigurationFile {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Path,
::        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
::        [String][Parameter(Position = 3)]$ProcessName = $AppName
::    )
::
::    Add-Log $INF "Writing $AppName configuration to '$Path'..."
::
::    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue
::
::    New-Item -ItemType Directory $(Split-Path -Parent $Path)
::    Set-Content $Path $Content
::
::    Out-Success
::}
::
::
::Function Update-JsonFile {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Path,
::        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
::        [String][Parameter(Position = 3)]$ProcessName = $AppName
::    )
::
::    Add-Log $INF "Writing $AppName configuration to '$Path'..."
::
::    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue
::
::    New-Item -ItemType Directory $(Split-Path -Parent $Path)
::
::    $CurrentConfig = Get-Content $Path -Raw | ConvertFrom-Json
::    $PatchConfig = $Content | ConvertFrom-Json
::
::    $UpdatedConfig = Merge-JsonObjects $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress
::
::    Set-Content $Path $UpdatedConfig
::
::    Out-Success
::}
::
::
::Function Import-RegistryConfiguration {
::    Param(
::        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
::        [String][Parameter(Position = 1, Mandatory = $True)]$Content
::    )
::
::    Add-Log $INF "Importing $AppName configuration into registry..."
::
::    Set-Variable -Option Constant RegFilePath "$PATH_TEMP_DIR\$AppName.reg"
::    Set-Content $RegFilePath $Content
::
::    try {
::        Start-Process -Verb RunAs -Wait 'regedit' "/s $RegFilePath"
::    } catch [Exception] {
::        Add-Log $ERR "Failed to import file: $($_.Exception.Message)"
::        Return
::    }
::
::    Out-Success
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Start Elevated #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-Elevated {
::    if (!$IS_ELEVATED) {
::        Add-Log $INF 'Requesting administrator privileges...'
::
::        try {
::            Start-Script -Elevated -BypassExecutionPolicy -WorkingDirectory:$PATH_CURRENT_DIR -HideConsole:$HideConsole $MyInvocation.ScriptName
::        } catch [Exception] {
::            Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"
::            Return
::        }
::
::        Exit-Script
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Activator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-Activator {
::    Add-Log $INF "Starting MAS activator..."
::
::    if ($OS_VERSION -eq 7) {
::        Start-Script -HideWindow "iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))"
::    } else {
::        Start-Script -HideWindow "irm https://get.activated.win | iex"
::    }
::
::    Out-Success
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Ninite #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Set-NiniteButtonState {
::    $CHECKBOX_StartNinite.Enabled = $BUTTON_DownloadNinite.Enabled = $CHECKBOX_Ninite_7zip.Checked -or $CHECKBOX_Ninite_VLC.Checked -or `
::        $CHECKBOX_Ninite_TeamViewer.Checked -or $CHECKBOX_Ninite_Chrome.Checked -or $CHECKBOX_Ninite_qBittorrent.Checked -or $CHECKBOX_Ninite_Malwarebytes.Checked
::}
::
::
::Function Set-NiniteQuery {
::    [String[]]$Array = @()
::    if ($CHECKBOX_Ninite_7zip.Checked) {
::        $Array += $CHECKBOX_Ninite_7zip.Name
::    }
::    if ($CHECKBOX_Ninite_VLC.Checked) {
::        $Array += $CHECKBOX_Ninite_VLC.Name
::    }
::    if ($CHECKBOX_Ninite_TeamViewer.Checked) {
::        $Array += $CHECKBOX_Ninite_TeamViewer.Name
::    }
::    if ($CHECKBOX_Ninite_Chrome.Checked) {
::        $Array += $CHECKBOX_Ninite_Chrome.Name
::    }
::    if ($CHECKBOX_Ninite_qBittorrent.Checked) {
::        $Array += $CHECKBOX_Ninite_qBittorrent.Name
::    }
::    if ($CHECKBOX_Ninite_Malwarebytes.Checked) {
::        $Array += $CHECKBOX_Ninite_Malwarebytes.Name
::    }
::    Return $Array -Join '-'
::}
::
::
::Function Set-NiniteFileName {
::    [String[]]$Array = @()
::    if ($CHECKBOX_Ninite_7zip.Checked) {
::        $Array += $CHECKBOX_Ninite_7zip.Text
::    }
::    if ($CHECKBOX_Ninite_VLC.Checked) {
::        $Array += $CHECKBOX_Ninite_VLC.Text
::    }
::    if ($CHECKBOX_Ninite_TeamViewer.Checked) {
::        $Array += $CHECKBOX_Ninite_TeamViewer.Text
::    }
::    if ($CHECKBOX_Ninite_Chrome.Checked) {
::        $Array += $CHECKBOX_Ninite_Chrome.Text
::    }
::    if ($CHECKBOX_Ninite_qBittorrent.Checked) {
::        $Array += $CHECKBOX_Ninite_qBittorrent.Text
::    }
::    if ($CHECKBOX_Ninite_Malwarebytes.Checked) {
::        $Array += $CHECKBOX_Ninite_Malwarebytes.Text
::    }
::    Return "Ninite $($Array -Join ' ') Installer.exe"
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Install Office #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-OfficeInstaller {
::    Param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute
::    )
::
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
::    Set-Variable -Option Constant Config $(if ($SYSTEM_LANGUAGE -Match 'ru') { $CONFIG_OFFICE_INSTALLER -Replace 'en-GB', 'ru-RU' } else { $CONFIG_OFFICE_INSTALLER })
::
::    Set-Content "$TargetPath\Office Installer+.ini" $Config
::
::    Start-DownloadExtractExecute -AVWarning -Execute:$Execute 'https://qiiwexc.github.io/d/Office_Installer+.zip'
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Apps Configuration #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Set-AppsConfiguration {
::    if ($CHECKBOX_Config_VLC.Checked) {
::        $AppName = $CHECKBOX_Config_VLC.Text
::        $Path = "$PATH_PROFILE_ROAMING\vlc\vlcrc"
::        $Content = $CONFIG_VLC
::        Write-ConfigurationFile $AppName $Path $Content
::    }
::
::    if ($CHECKBOX_Config_qBittorrent.Checked) {
::        $AppName = $CHECKBOX_Config_qBittorrent.Text
::        $Path = "$PATH_PROFILE_ROAMING\$AppName\$AppName.ini"
::        $Content = $CONFIG_QBITTORRENT_BASE + $(if ($SYSTEM_LANGUAGE -Match 'ru') { $CONFIG_QBITTORRENT_RUSSIAN } else { $CONFIG_QBITTORRENT_ENGLISH })
::        Write-ConfigurationFile $AppName $Path $Content
::    }
::
::    if ($CHECKBOX_Config_7zip.Checked) {
::        Import-RegistryConfiguration $CHECKBOX_Config_7zip.Text $CONFIG_7ZIP
::    }
::
::    if ($CHECKBOX_Config_TeamViewer.Checked) {
::        Import-RegistryConfiguration $CHECKBOX_Config_TeamViewer.Text $CONFIG_TEAMVIEWER
::    }
::
::    if ($CHECKBOX_Config_Edge.Checked) {
::        $AppName = $CHECKBOX_Config_Edge.Text
::
::        $Path = "$PATH_PROFILE_LOCAL\Microsoft\Edge\User Data\Local State"
::        Update-JsonFile $AppName $Path $CONFIG_EDGE_LOCAL_STATE "msedge"
::
::        $Path = "$PATH_PROFILE_LOCAL\Microsoft\Edge\User Data\Default\Preferences"
::        Update-JsonFile $AppName $Path $CONFIG_EDGE_PREFERENCES "msedge"
::    }
::
::    if ($CHECKBOX_Config_Chrome.Checked) {
::        $AppName = $CHECKBOX_Config_Chrome.Text
::
::        $Path = "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Local State"
::        Update-JsonFile $AppName $Path $CONFIG_CHROME_LOCAL_STATE "chrome"
::
::        $Path = "$PATH_PROFILE_LOCAL\Google\Chrome\User Data\Default\Preferences"
::        Update-JsonFile $AppName $Path $CONFIG_CHROME_PREFERENCES "chrome"
::    }
::
::    if ($CHECKBOX_Config_Windows.Checked) {
::        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3
::        Unregister-ScheduledTask -TaskName "CreateExplorerShellUnelevatedTask" -Confirm:$False -ErrorAction SilentlyContinue
::
::        Import-RegistryConfiguration $CHECKBOX_Config_Windows.Text $CONFIG_WINDOWS
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Power Configuration #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Set-PowerConfiguration {
::    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX
::    powercfg /SetAcValueIndex SCHEME_BALANCED 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0
::    powercfg /SetAcValueIndex SCHEME_BALANCED 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
::    powercfg /SetAcValueIndex SCHEME_BALANCED 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
::    powercfg /SetAcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0
::    powercfg /SetAcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1
::    powercfg /SetAcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 1
::    powercfg /SetAcValueIndex SCHEME_BALANCED de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0
::    powercfg /SetAcValueIndex SCHEME_BALANCED SUB_PCIEXPRESS ASPM 0
::    powercfg /SetAcValueIndex SCHEME_BALANCED SUB_SLEEP HYBRIDSLEEP 1
::    powercfg /SetAcValueIndex SCHEME_BALANCED SUB_SLEEP RTCWAKE 1
::    powercfg /SetDcValueIndex SCHEME_BALANCED 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0
::    powercfg /SetDcValueIndex SCHEME_BALANCED 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
::    powercfg /SetDcValueIndex SCHEME_BALANCED 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
::    powercfg /SetDcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0
::    powercfg /SetDcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1
::    powercfg /SetDcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 1
::    powercfg /SetDcValueIndex SCHEME_BALANCED de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0
::    powercfg /SetDcValueIndex SCHEME_BALANCED SUB_PCIEXPRESS ASPM 0
::    powercfg /SetDcValueIndex SCHEME_BALANCED SUB_SLEEP HYBRIDSLEEP 1
::    powercfg /SetDcValueIndex SCHEME_BALANCED SUB_SLEEP RTCWAKE 1
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# DNS #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Set-CloudFlareDNS {
::    [String]$PreferredDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.1.1.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.1.1.2' } else { '1.1.1.1' } };
::    [String]$AlternateDnsServer = if ($CHECKBOX_CloudFlareFamilyFriendly.Checked) { '1.0.0.3' } else { if ($CHECKBOX_CloudFlareAntiMalware.Checked) { '1.0.0.2' } else { '1.0.0.1' } };
::
::    Add-Log $WRN 'Internet connection may get interrupted briefly'
::    Add-Log $INF "Changing DNS server to CloudFlare DNS ($PreferredDnsServer / $AlternateDnsServer)..."
::
::    if (!(Get-NetworkAdapter)) {
::        Add-Log $ERR 'Could not determine network adapter used to connect to the Internet'
::        Add-Log $ERR 'This could mean that computer is not connected'
::        Return
::    }
::
::    try {
::        Start-Script -Elevated -HideWindow "(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True').SetDNSServerSearchOrder(`$('$PreferredDnsServer', '$AlternateDnsServer'))"
::    } catch [Exception] {
::        Add-Log $ERR "Failed to change DNS server: $($_.Exception.Message)"
::        Return
::    }
::
::    Out-Success
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Debloat Windows #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-WindowsDebloat {
::    Add-Log $INF "Starting Windows 10/11 debloat utility..."
::
::    Start-Script -Elevated -HideWindow "irm https://debloat.raphi.re/ | iex"
::
::    Out-Success
::}
::
::
::Function Start-ShutUp10 {
::    Param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
::        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
::    )
::
::    Add-Log $INF "Starting ShutUp10++ utility..."
::
::    Set-Variable -Option Constant TargetPath $(if ($Execute) { $PATH_TEMP_DIR } else { $PATH_CURRENT_DIR })
::    Set-Variable -Option Constant ConfigFile "$TargetPath\ooshutup10.cfg"
::
::    Set-Content $ConfigFile $CONFIG_SHUTUP10
::
::    if ($Silent) {
::        Start-DownloadExtractExecute -Execute:$Execute 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe' -Params $ConfigFile
::    } else {
::        Start-DownloadExtractExecute -Execute:$Execute 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
::    }
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Windows Configurator #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::Function Start-WinUtil {
::    Param(
::        [Switch][Parameter(Position = 0, Mandatory = $True)]$Apply
::    )
::
::    Add-Log $INF "Starting WinUtil utility..."
::
::    Set-Variable -Option Constant ConfigFile "$PATH_TEMP_DIR\winutil.json"
::
::    Set-Content $ConfigFile $CONFIG_WINUTIL
::
::    Set-Variable -Option Constant ConfigParam "-Config $ConfigFile"
::    Set-Variable -Option Constant RunParam $(if ($Apply) { '-Run' } else { '' })
::
::    Start-Script "& ([ScriptBlock]::Create((irm 'https://christitus.com/win'))) $ConfigParam $RunParam"
::
::    Out-Success
::}
::
::
::#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-# Draw Form #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
::
::[Void]$FORM.ShowDialog()
::
::# SIG # Begin signature block
::# MIIbuQYJKoZIhvcNAQcCoIIbqjCCG6YCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
::# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
::# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfpQLj25yQLZ1nZTAwPtlDR5a
::# HEOgghYyMIIC9DCCAdygAwIBAgIQXsI0IvjnYrROmtXpEM8jXjANBgkqhkiG9w0B
::# AQUFADASMRAwDgYDVQQDDAdxaWl3ZXhjMB4XDTI1MDgwOTIyNDMxOVoXDTI2MDgw
::# OTIzMDMxOVowEjEQMA4GA1UEAwwHcWlpd2V4YzCCASIwDQYJKoZIhvcNAQEBBQAD
::# ggEPADCCAQoCggEBAMhnu8NP9C+9WtGc5kHCOjJo3ZMzdw/qQIMhafhu736EWnJ5
::# j2Ua2afyvPhxUf1d1XUdYLfkbCb7qX9bqCoA8CKzelGgrVFhvXdQVQxI31t6gPPB
::# PYc7w85z2rvo7E4R47VvBHx4n5tN0CLCLBitOx9SANscprrJU67Xpz25lKdT8557
::# 2mMI/JMblE0nJY7tivun3Suz4Rg9TeX/4Dp3zVfUBeK+Vt+HtXk+uYBUTvKF3oYL
::# xKImA680lbd/JPQ7+ukG+LPSvRVENKnI5PVT9CxivuTnQ8eLl6UDosdKVj1Fu/xB
::# t+m4xHi83SyE843jVEzanodfQT822bT+rpAPv90CAwEAAaNGMEQwDgYDVR0PAQH/
::# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQQUvLuFhpdcPOA
::# LOynGgBzOzueBzANBgkqhkiG9w0BAQUFAAOCAQEAxmeQFnsFSp/ZwWdhErD3HGXi
::# JaBiozCNeAqxVMqjGCVK4auPU0lppVRE7J6JmvxzAWCjmajQafxUgZUdjoQ9vmBZ
::# NkbhUtzls1x+eV02MMwx82Hukq5llL5atcOp7QtZ4B6aDYmYsl+N8iWJ3Ol6gTDf
::# 1+YWop3k4BUqHQ7AtEir1lrwatdwB5l+jksNAFolYrrr1nY8fbCsQjqDqMlA6YqS
::# 21MqEoNqc7tt1OYGW/Z9QdG+P0mhjdlU6hMiNRAxz455/LPcxPgkwdxpsmzuXjnj
::# KtASPCCVG6IYFlmKKlwF+BPE/aV212/ZGrb7J3WMYgm86cJtX6YO0y79sAk1sTCC
::# BY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTEL
::# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
::# LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290
::# IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMC
::# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
::# LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkq
::# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE9
::# 8orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9S
::# H8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g
::# 1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RY
::# jgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17cjo+A2raRmECQecN4x7axxLVqGDgD
::# EI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNA
::# vwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDg
::# ohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQA
::# zH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOk
::# GLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHF
::# ynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gd
::# LfXZqbId5RsCAwEAAaOCATowggE2MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYE
::# FOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
::# IZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUH
::# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDov
::# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
::# dDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
::# aUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkq
::# hkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7
::# IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/5
::# 9PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0
::# POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISf
::# b8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhU
::# LSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6peKOK5lDCCBrQwggScoAMCAQICEA3H
::# rFcF/yGZLkBDIgw6SYYwDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTAT
::# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEh
::# MB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTI1MDUwNzAwMDAw
::# MFoXDTM4MDExNDIzNTk1OVowaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
::# ZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFt
::# cGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMTCCAiIwDQYJKoZIhvcNAQEBBQAD
::# ggIPADCCAgoCggIBALR4MdMKmEFyvjxGwBysddujRmh0tFEXnU2tjQ2UtZmWgyxU
::# 7UNqEY81FzJsQqr5G7A6c+Gh/qm8Xi4aPCOo2N8S9SLrC6Kbltqn7SWCWgzbNfiR
::# +2fkHUiljNOqnIVD/gG3SYDEAd4dg2dDGpeZGKe+42DFUF0mR/vtLa4+gKPsYfwE
::# u7EEbkC9+0F2w4QJLVSTEG8yAR2CQWIM1iI5PHg62IVwxKSpO0XaF9DPfNBKS7Za
::# zch8NF5vp7eaZ2CVNxpqumzTCNSOxm+SAWSuIr21Qomb+zzQWKhxKTVVgtmUPAW3
::# 5xUUFREmDrMxSNlr/NsJyUXzdtFUUt4aS4CEeIY8y9IaaGBpPNXKFifinT7zL2gd
::# FpBP9qh8SdLnEut/GcalNeJQ55IuwnKCgs+nrpuQNfVmUB5KlCX3ZA4x5HHKS+rq
::# BvKWxdCyQEEGcbLe1b8Aw4wJkhU1JrPsFfxW1gaou30yZ46t4Y9F20HHfIY4/6vH
::# espYMQmUiote8ladjS/nJ0+k6MvqzfpzPDOy5y6gqztiT96Fv/9bH7mQyogxG9QE
::# PHrPV6/7umw052AkyiLA6tQbZl1KhBtTasySkuJDpsZGKdlsjg4u70EwgWbVRSX1
::# Wd4+zoFpp4Ra+MlKM2baoD6x0VR4RjSpWM8o5a6D8bpfm4CLKczsG7ZrIGNTAgMB
::# AAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTvb1NK6eQG
::# fHrK4pBW9i/USezLTjAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAO
::# BgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEE
::# azBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYB
::# BQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0
::# ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2lj
::# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYG
::# Z4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAF877FoAc/gc9
::# EXZxML2+C8i1NKZ/zdCHxYgaMH9Pw5tcBnPw6O6FTGNpoV2V4wzSUGvI9NAzaoQk
::# 97frPBtIj+ZLzdp+yXdhOP4hCFATuNT+ReOPK0mCefSG+tXqGpYZ3essBS3q8nL2
::# UwM+NMvEuBd/2vmdYxDCvwzJv2sRUoKEfJ+nN57mQfQXwcAEGCvRR2qKtntujB71
::# WPYAgwPyWLKu6RnaID/B0ba2H3LUiwDRAXx1Neq9ydOal95CHfmTnM4I+ZI2rVQf
::# jXQA1WSjjf4J2a7jLzWGNqNX+DF0SQzHU0pTi4dBwp9nEC8EAqoxW6q17r0z0noD
::# js6+BFo+z7bKSBwZXTRNivYuve3L2oiKNqetRHdqfMTCW/NmKLJ9M+MtucVGyOxi
::# Df06VXxyKkOirv6o02OoXN4bFzK0vlNMsvhlqgF2puE6FndlENSmE+9JGYxOGLS/
::# D284NHNboDGcmWXfwXRy4kbu4QFhOm0xJuF2EZAOk5eCkhSxZON3rGlHqhpB/8Ml
::# uDezooIs8CVnrpHMiD2wL40mm53+/j7tFaxYKIqL0Q4ssd8xHZnIn/7GELH3IdvG
::# 2XlM9q7WP/UwgOkw/HQtyRN62JK4S1C8uw3PdBunvAZapsiI5YKdvlarEvf8EA+8
::# hcpSM9LHJmyrxaFtoza2zNaQ9k+5t1wwggbtMIIE1aADAgECAhAKgO8YS43xBYLR
::# xHanlXRoMA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5E
::# aWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1l
::# U3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEwHhcNMjUwNjA0MDAwMDAw
::# WhcNMzYwOTAzMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
::# cnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFNIQTI1NiBSU0E0MDk2IFRpbWVz
::# dGFtcCBSZXNwb25kZXIgMjAyNSAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
::# CgKCAgEA0EasLRLGntDqrmBWsytXum9R/4ZwCgHfyjfMGUIwYzKomd8U1nH7C8Dr
::# 0cVMF3BsfAFI54um8+dnxk36+jx0Tb+k+87H9WPxNyFPJIDZHhAqlUPt281mHrBb
::# ZHqRK71Em3/hCGC5KyyneqiZ7syvFXJ9A72wzHpkBaMUNg7MOLxI6E9RaUueHTQK
::# WXymOtRwJXcrcTTPPT2V1D/+cFllESviH8YjoPFvZSjKs3SKO1QNUdFd2adw44wD
::# cKgH+JRJE5Qg0NP3yiSyi5MxgU6cehGHr7zou1znOM8odbkqoK+lJ25LCHBSai25
::# CFyD23DZgPfDrJJJK77epTwMP6eKA0kWa3osAe8fcpK40uhktzUd/Yk0xUvhDU6l
::# vJukx7jphx40DQt82yepyekl4i0r8OEps/FNO4ahfvAk12hE5FVs9HVVWcO5J4dV
::# mVzix4A77p3awLbr89A90/nWGjXMGn7FQhmSlIUDy9Z2hSgctaepZTd0ILIUbWuh
::# KuAeNIeWrzHKYueMJtItnj2Q+aTyLLKLM0MheP/9w6CtjuuVHJOVoIJ/DtpJRE7C
::# e7vMRHoRon4CWIvuiNN1Lk9Y+xZ66lazs2kKFSTnnkrT3pXWETTJkhd76CIDBbTR
::# ofOsNyEhzZtCGmnQigpFHti58CSmvEyJcAlDVcKacJ+A9/z7eacCAwEAAaOCAZUw
::# ggGRMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFOQ7/PIx7f391/ORcWMZUEPPYYzo
::# MB8GA1UdIwQYMBaAFO9vU0rp5AZ8esrikFb2L9RJ7MtOMA4GA1UdDwEB/wQEAwIH
::# gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCBlQYIKwYBBQUHAQEEgYgwgYUwJAYI
::# KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBdBggrBgEFBQcwAoZR
::# aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGlt
::# ZVN0YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3J0MF8GA1UdHwRYMFYwVKBS
::# oFCGTmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRp
::# bWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNybDAgBgNVHSAEGTAXMAgG
::# BmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBAGUqrfEcJwS5
::# rmBB7NEIRJ5jQHIh+OT2Ik/bNYulCrVvhREafBYF0RkP2AGr181o2YWPoSHz9iZE
::# N/FPsLSTwVQWo2H62yGBvg7ouCODwrx6ULj6hYKqdT8wv2UV+Kbz/3ImZlJ7YXwB
::# D9R0oU62PtgxOao872bOySCILdBghQ/ZLcdC8cbUUO75ZSpbh1oipOhcUT8lD8QA
::# GB9lctZTTOJM3pHfKBAEcxQFoHlt2s9sXoxFizTeHihsQyfFg5fxUFEp7W42fNBV
::# N4ueLaceRf9Cq9ec1v5iQMWTFQa0xNqItH3CPFTG7aEQJmmrJTV3Qhtfparz+BW6
::# 0OiMEgV5GWoBy4RVPRwqxv7Mk0Sy4QHs7v9y69NBqycz0BZwhB9WOfOu/CIJnzkQ
::# TwtSSpGGhLdjnQ4eBpjtP+XB3pQCtv4E5UCSDag6+iX8MmB10nfldPF9SVD7weCC
::# 3yXZi/uuhqdwkgVxuiMFzGVFwYbQsiGnoa9F5AaAyBjFBtXVLcKtapnMG3VH3EmA
::# p/jsJ3FVF3+d1SVDTmjFjLbNFZUWMXuZyvgLfgyPehwJVxwC+UpX2MSey2ueIu9T
::# HFVkT+um1vshETaWyQo8gmBto/m3acaP9QsuLj3FNwFlTxq25+T4QwX9xa6ILs84
::# ZPvmpovq90K8eWyG2N01c4IhSOxqt81nMYIE8TCCBO0CAQEwJjASMRAwDgYDVQQD
::# DAdxaWl3ZXhjAhBewjQi+OditE6a1ekQzyNeMAkGBSsOAwIaBQCgeDAYBgorBgEE
::# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
::# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ0UBgP
::# f+xiTNuw1W+IUXaW9bvYDzANBgkqhkiG9w0BAQEFAASCAQBhoTwxQGIUSnFRlSTd
::# 9L6wDpI7mlHpV+qNdaCmTxyzmPCmC8wkVBnbUdIV66cbNAZlyofNOEmQDU39voWi
::# XxVgkjDfvtrXBccJwnNx2Cp7bgsnIiSzgtdzF6BbOvuRP5882hRuotmYGzg7LRYM
::# PaTVoftHEIpJZqNf/BgCXMi55OS2jar1l/O7tzLDEkIHPzkY7gbcXhmn6CLa509+
::# c4r/L/kZom3jhxrxdhW1oo+yL+bXQ6vYs9pCeVaMPQWuppf68k210o+f1HvtsO4B
::# uyRTdPMzhuDA8Q6ONt3+KeD1wUbWk9iX/hEhaqrbj/CFowkY8QRcFF6e9J1RbRkL
::# lC5aoYIDJjCCAyIGCSqGSIb3DQEJBjGCAxMwggMPAgEBMH0waTELMAkGA1UEBhMC
::# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBU
::# cnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMQIQ
::# CoDvGEuN8QWC0cR2p5V0aDANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzEL
::# BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI1MDkyMTIwNDEzMFowLwYJKoZI
::# hvcNAQkEMSIEIKNFKEFOK7TpJAAeW8SV8bzb+NxeAXLE07mdGuKCNY+oMA0GCSqG
::# SIb3DQEBAQUABIICAGPXKzmn6ueRoIW+lSIw2uGtpyCmEjr6TM7TccBLI2J2yVDI
::# Fy5082VTDfPaKLC6Sq4FucP3AZxtF2EAlPkBytht7/xjNiETkG7sxgpHhKkep0zQ
::# hAlo2yh1MOiy8okbUJqqXGoocGJRMZOmKE9yFz7PIYsMU05b289NGZLUGyGsl94W
::# +/z4Crfxp+wwjZz+PKiu2qYdkZ8c7D+otxm2G5pTx7FzjzbH58kyZjEnSkeTMzZV
::# 8sQnzsmyO2QVlCYmYQHtV29nfqJZLvhlyIYowznuWLDZxoR6XzP/TFVprOfM8XQ4
::# 5Ac7Y/XMvLkXnq/sUQFeaTKsOcE5cSTtSxWVAa5BSGoPeBT0eXAov8tvqCXXocP3
::# CEgbii/EFyi4DVSNeuN+2a97u4NrPYW8DrGA9moWrGCmJvO+5KtlvYxLBRs5lW1m
::# M5fiitCY50gPKHl2XjYxMAVJMf3vRpGLJDrqalAjB47Shhig0xic/OyMkh64UPuC
::# WfztYTLD09W1UKI/o0QcYqfoRLXIiDZSbbME5oWTzdS2xyIf/LixNzddK9GG0Cm9
::# 3P/pWyGuadowSrDZLLrXsP0rikdN8FoYj47H4i/CetWvw2lCRe1HayYwYc32Jh+1
::# vij7iNiGa8EfokdmcOQdQE6Mxd2QH1zyDOTgfZOX98WGPPfhf8ooAt/t+PSm
::# SIG # End signature block
