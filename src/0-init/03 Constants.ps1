Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Set-Variable -Option Constant PATH_CURRENT_DIR $CallerPath
Set-Variable -Option Constant PATH_TEMP_DIR "$([System.IO.Path]::GetTempPath())qiiwexc"
Set-Variable -Option Constant PATH_PROFILE_ROAMING "$env:USERPROFILE\AppData\Roaming"
Set-Variable -Option Constant PATH_PROFILE_LOCAL "$env:USERPROFILE\AppData\Local"

Set-Variable -Option Constant SYSTEM_LANGUAGE (Get-SystemLanguage)
