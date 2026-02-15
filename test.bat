@echo off

powershell -NoProfile -ExecutionPolicy Bypass "Invoke-Pester -Configuration (. '.\PesterSettings.ps1')"
