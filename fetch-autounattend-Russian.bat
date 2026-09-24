@echo off

powershell -NoProfile -Command ^
    "$ErrorActionPreference = 'Stop';" ^
    "$release = 'https://github.com/qiiwexc/qiiwexc.github.io/releases/latest/download/';" ^
    "$name = 'autounattend-Russian.xml';" ^
    "$new = $name + '.new';" ^
    "$sums = $name + '.sha256';" ^
    "Invoke-WebRequest -UseBasicParsing -Uri ($release + $name) -OutFile $new;" ^
    "Invoke-WebRequest -UseBasicParsing -Uri ($release + 'SHA256SUMS.txt') -OutFile $sums;" ^
    "$expected = [Regex]::Match((Get-Content $sums -Raw), '(?m)^([0-9a-fA-F]{64})\s+\*?' + [Regex]::Escape($name) + '\s*$').Groups[1].Value;" ^
    "Remove-Item $sums;" ^
    "if (-not $expected -or (Get-FileHash $new -Algorithm SHA256).Hash -ne $expected.ToUpper()) { Remove-Item $new; throw 'Checksum verification failed' };" ^
    "Move-Item -Force $new 'autounattend.xml'" || pause
