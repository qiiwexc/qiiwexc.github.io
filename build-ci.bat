@echo off

powershell -ExecutionPolicy Bypass ".\tools\build.ps1 -Full -CI"
