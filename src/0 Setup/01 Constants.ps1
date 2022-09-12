Set-Variable -Option Constant BUTTON_WIDTH    170
Set-Variable -Option Constant BUTTON_HEIGHT   30

Set-Variable -Option Constant CHECKBOX_HEIGHT 20

Set-Variable -Option Constant INTERVAL_SHORT  5
Set-Variable -Option Constant INTERVAL_NORMAL 15
Set-Variable -Option Constant INTERVAL_LONG   30


Set-Variable -Option Constant INTERVAL_BUTTON_SHORT  ($BUTTON_HEIGHT + $INTERVAL_SHORT)
Set-Variable -Option Constant INTERVAL_BUTTON_NORMAL ($BUTTON_HEIGHT + $INTERVAL_NORMAL)

Set-Variable -Option Constant INTERVAL_CHECKBOX ($CHECKBOX_HEIGHT + $INTERVAL_SHORT)


Set-Variable -Option Constant GROUP_WIDTH ($INTERVAL_NORMAL + $BUTTON_WIDTH + $INTERVAL_NORMAL)

Set-Variable -Option Constant FORM_WIDTH  (($GROUP_WIDTH + $INTERVAL_NORMAL) * 3 + ($INTERVAL_NORMAL * 2))
Set-Variable -Option Constant FORM_HEIGHT ($INTERVAL_BUTTON_NORMAL * 13)

Set-Variable -Option Constant INITIAL_LOCATION_BUTTON "$INTERVAL_NORMAL, 20"

Set-Variable -Option Constant SHIFT_CHECKBOX "0, $($CHECKBOX_HEIGHT + $INTERVAL_SHORT)"


Set-Variable -Option Constant FONT_NAME   'Microsoft Sans Serif'
Set-Variable -Option Constant BUTTON_FONT "$FONT_NAME, 10"


Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Set-Variable -Option Constant PATH_TEMP_DIR "$env:TMP\qiiwexc"
Set-Variable -Option Constant PATH_PROGRAM_FILES_86 $(if ($OS_64_BIT) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles })
Set-Variable -Option Constant PATH_DEFENDER_EXE "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
Set-Variable -Option Constant PATH_CHROME_EXE "$PATH_PROGRAM_FILES_86\Google\Chrome\Application\chrome.exe"
Set-Variable -Option Constant PATH_MRT_EXE "$env:windir\System32\MRT.exe"

Set-Variable -Option Constant IS_ELEVATED $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
Set-Variable -Option Constant REQUIRES_ELEVATION $(if (!$IS_ELEVATED) { ' *' } else { '' })
