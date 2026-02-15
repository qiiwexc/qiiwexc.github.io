@echo off

for /f %%i in ('powershell -NoProfile -Command "$d = Get-Date; \"$($d.Year %% 100).$($d.Month).$($d.Day)\""') do set version=%%i

git fetch --all --prune || (echo Error: git fetch failed & exit /b 1)
git pull --tags --autostash -r origin master || (echo Error: git pull failed & exit /b 1)
git tag -a v%version% -m "Release v%version%" || (echo Error: git tag failed & exit /b 1)
git push origin --tags || (echo Error: git push failed & exit /b 1)
