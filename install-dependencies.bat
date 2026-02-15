@echo off

set PSSCRIPTANALYZER_VERSION=1.24.0
set PESTER_VERSION=5.7.1

powershell -NoProfile -Command "Set-PSRepository PSGallery -InstallationPolicy Trusted; Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -MinimumVersion %PSSCRIPTANALYZER_VERSION%; Install-Module -Name Pester -Force -Scope CurrentUser -MinimumVersion %PESTER_VERSION%"
