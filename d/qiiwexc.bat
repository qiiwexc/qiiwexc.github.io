@echo off

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://bit.ly/qiiwexc_bat_update' -OutFile '%~f0'; Start-Process -FilePath '%~f0' -Verb RunAs"
