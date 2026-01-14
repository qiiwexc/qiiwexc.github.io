@echo off

powershell -ExecutionPolicy Bypass "Invoke-Pester -Configuration (. '.\PesterSettings.ps1' -Coverage)"
