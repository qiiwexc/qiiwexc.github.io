set host=192.168.1.13
set port=1688

cd /D c:\Windows\System32
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /f /v KeyManagementServiceName /d %host% /t REG_SZ /reg:32
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /f /v KeyManagementServicePort /d %port% /t REG_SZ /reg:32
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /f /v KeyManagementServiceName /d %host% /t REG_SZ /reg:64
reg.exe add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /f /v KeyManagementServicePort /d %port% /t REG_SZ /reg:64

timeout 15
