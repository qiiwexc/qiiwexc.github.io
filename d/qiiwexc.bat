@echo off

set "batfile=%~f0"

powershell -NoProfile -Command ^
    "$ErrorActionPreference = 'Stop';" ^
    "$new = $env:batfile + '.new';" ^
    "$sums = $env:batfile + '.sha256';" ^
    "Invoke-WebRequest -UseBasicParsing -Uri 'https://bit.ly/qiiwexc_bat_update' -OutFile $new;" ^
    "Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/qiiwexc/qiiwexc.github.io/releases/latest/download/SHA256SUMS.txt' -OutFile $sums;" ^
    "$expected = [Regex]::Match((Get-Content $sums -Raw), '(?m)^([0-9a-fA-F]{64})\s+\*?qiiwexc\.bat\s*$').Groups[1].Value;" ^
    "Remove-Item $sums;" ^
    "if (-not $expected -or (Get-FileHash $new -Algorithm SHA256).Hash -ne $expected.ToUpper()) { Remove-Item $new; throw 'Checksum verification failed' };" ^
    "Move-Item -Force $new $env:batfile;" ^
    "Start-Process -FilePath $env:batfile -Verb RunAs" || pause & exit /b
