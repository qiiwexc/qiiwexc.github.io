Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'

Set-Variable -Option Constant REQUIRES_ELEVATION $(if (-not $IS_ELEVATED) { ' *' })


Set-Variable -Option Constant WIDTH_BUTTON    170
Set-Variable -Option Constant HEIGHT_BUTTON   30

Set-Variable -Option Constant WIDTH_CHECKBOX   145
Set-Variable -Option Constant HEIGHT_CHECKBOX  20

Set-Variable -Option Constant INTERVAL_SHORT     5
Set-Variable -Option Constant INTERVAL_NORMAL    15
Set-Variable -Option Constant INTERVAL_LONG      30
Set-Variable -Option Constant INTERVAL_GROUP_TOP 20


Set-Variable -Option Constant INTERVAL_BUTTON_SHORT    ($HEIGHT_BUTTON + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_BUTTON_NORMAL   ($HEIGHT_BUTTON + $INTERVAL_NORMAL)
Set-Variable -Option Constant INTERVAL_BUTTON_LONG     ($HEIGHT_BUTTON + $INTERVAL_LONG)

Set-Variable -Option Constant INTERVAL_CHECKBOX_SHORT  ($HEIGHT_CHECKBOX + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_CHECKBOX_NORMAL ($HEIGHT_CHECKBOX + $INTERVAL_NORMAL)


Set-Variable -Option Constant WIDTH_GROUP ($INTERVAL_NORMAL + $WIDTH_BUTTON + $INTERVAL_NORMAL)

Set-Variable -Option Constant WIDTH_FORM  (($WIDTH_GROUP + $INTERVAL_NORMAL) * 3 + ($INTERVAL_NORMAL * 2))
Set-Variable -Option Constant HEIGHT_FORM ($INTERVAL_BUTTON_NORMAL * 13)

Set-Variable -Option Constant CHECKBOX_SIZE "$WIDTH_CHECKBOX, $HEIGHT_CHECKBOX"

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "$INTERVAL_NORMAL, $INTERVAL_GROUP_TOP"
Set-Variable -Option Constant INITIAL_LOCATION_GROUP  "$INTERVAL_NORMAL, $INTERVAL_NORMAL"


Set-Variable -Option Constant SHIFT_BUTTON_SHORT      "0, $INTERVAL_BUTTON_SHORT"
Set-Variable -Option Constant SHIFT_BUTTON_NORMAL     "0, $INTERVAL_BUTTON_NORMAL"
Set-Variable -Option Constant SHIFT_BUTTON_LONG       "0, $INTERVAL_BUTTON_LONG"

Set-Variable -Option Constant SHIFT_CHECKBOX          "0, $INTERVAL_CHECKBOX_SHORT"
Set-Variable -Option Constant SHIFT_CHECKBOX_EXECUTE  "$($INTERVAL_LONG - $INTERVAL_SHORT), $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"

Set-Variable -Option Constant SHIFT_GROUP_HORIZONTAL  "$($WIDTH_GROUP + $INTERVAL_NORMAL), 0"

Set-Variable -Option Constant SHIFT_LABEL_BROWSER     "$INTERVAL_LONG, $($INTERVAL_BUTTON_SHORT - $INTERVAL_SHORT)"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"


Set-Variable -Option Constant PATH_DEFENDER_EXE "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
Set-Variable -Option Constant PATH_CHROME_EXE "$PROGRAM_FILES_86\Google\Chrome\Application\chrome.exe"

Set-Variable -Option Constant PATH_TEMP_DIR "$env:TMP\qiiwexc"


Set-Variable -Option Constant OperatingSystem (Get-WmiObject Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version)

Set-Variable -Option Constant OS_NAME $OperatingSystem.Caption
Set-Variable -Option Constant OS_BUILD $OperatingSystem.Version
Set-Variable -Option Constant OS_64_BIT $(if ($OperatingSystem.OSArchitecture -Like '64-*') { $True })
Set-Variable -Option Constant OS_VERSION $(Switch -Wildcard ($OS_BUILD) { '10.0.*' { 10 } '6.3.*' { 8.1 } '6.2.*' { 8 } '6.1.*' { 7 } Default { 'Vista or less / Unknown' } })


Set-Variable -Option Constant PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })

Set-Variable -Option Constant LogicalDisk (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'")
Set-Variable -Option Constant SYSTEM_PARTITION ($LogicalDisk | Select-Object @{L = 'FreeSpace'; E = { '{0:N2}' -f ($_.FreeSpace / 1GB) } }, @{L = 'Size'; E = { '{0:N2}' -f ($_.Size / 1GB) } })


Set-Variable -Option Constant WordRegPath (Get-ItemProperty "$(New-PSDrive HKCR Registry HKEY_CLASSES_ROOT):\Word.Application\CurVer" -ErrorAction SilentlyContinue)
Set-Variable -Option Constant OFFICE_VERSION $(if ($WordRegPath) { ($WordRegPath.'(default)') -Replace '\D+', '' })
Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
Set-Variable -Option Constant OFFICE_INSTALL_TYPE $(if ($OFFICE_VERSION) { if (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE) { 'C2R' } else { 'MSI' } })
