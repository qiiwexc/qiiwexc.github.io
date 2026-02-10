@echo off

powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://github.com/qiiwexc/qiiwexc.github.io/releases/latest/download/autounattend-Russian.xml' -OutFile 'autounattend.xml'"
