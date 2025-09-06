.'Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies' 'Attachments' 'SaveZoneInformation' DWORD:1

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main' -Name 'DisableFirstRunCustomize' -Value 2 -PropertyType DWORD -Force | Out-Null
