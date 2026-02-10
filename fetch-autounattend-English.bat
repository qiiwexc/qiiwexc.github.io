@echo off

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/qiiwexc/qiiwexc.github.io/releases/latest/download/autounattend-English.xml' -OutFile 'autounattend.xml'"
