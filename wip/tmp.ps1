.'Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies' 'Attachments' 'SaveZoneInformation' DWORD:1

OInstall
/configure "d:\MyPath\Configuration.xml"    - Launch the program in hidden mode, and perform the installation.
/proplus x64 en-us excludeExcel excludeOneNote /apps visio
/apps x64 ru-ru en-us word excel visio
/proplus x86 en-us excludeOneNote /apps project /convert /activate

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main' -Name 'DisableFirstRunCustomize' -Value 2 -PropertyType DWORD -Force | Out-Null
