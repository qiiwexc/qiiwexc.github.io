@echo off
powershell -NoProfile -Command ^
    "$deps = Get-Content 'resources\dependencies.json' | ConvertFrom-Json;" ^
    "$pesterVersion = ($deps | Where-Object { $_.name -eq 'Pester' }).version;" ^
    "$analyzerVersion = ($deps | Where-Object { $_.name -eq 'PSScriptAnalyzer' }).version;" ^
    "Set-PSRepository PSGallery -InstallationPolicy Trusted;" ^
    "Install-Module -Name Pester -Force -Scope CurrentUser -RequiredVersion $pesterVersion;" ^
    "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -RequiredVersion $analyzerVersion"
