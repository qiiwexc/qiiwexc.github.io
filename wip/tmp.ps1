.'Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies' 'Attachments' 'SaveZoneInformation' DWORD:1

Function Start-DiskCheck {
    Set-Variable -Option Constant Parameters ('`$(`$Item.Name + ":")' + $(if ($FullScan) { ' /B' } elseif ($OS_VERSION -gt 7) { ' /scan /perf' }))
    Set-Variable -Option Constant Command "ForEach (`$Item in Get-PSDrive -PSProvider 'FileSystem') { Write-Host `"``n``nScanning drive `$(`$Item.Name + ':')``n``n`"; Start-Process 'chkdsk' '$Parameters'; Start-Sleep 5 }"

    try { Start-Process 'PowerShell' "-Command `"(Get-Host).UI.RawUI.WindowTitle = 'Disk check running...'; $Command`"" -Verb RunAs }
    catch [Exception] { Add-Log $ERR "Failed to check (C:) disk health: $($_.Exception.Message)"; Return }
}

# ForEach ($Item in Get-PSDrive -PSProvider 'FileSystem') { Write-Host "`n`nScanning drive $($Item.Name):`n`n"; Start-Process 'chkdsk' "$($Item.Name + ':') /scan /perf" -NoNewWindow -Wait }
# $Parameters = '$($Item.Name + ":")' + $(if ($False) { ' /B' } elseif ($True) { ' /scan /perf' })

OInstall
/configure "d:\MyPath\Configuration.xml"    - Launch the program in hidden mode, and perform the installation.
/proplus x64 en-us excludeExcel excludeOneNote /apps visio
/apps x64 ru-ru en-us word excel visio
/proplus x86 en-us excludeOneNote /apps project /convert /activate

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main' -Name 'DisableFirstRunCustomize' -Value 2 -PropertyType DWORD -Force | Out-Null
