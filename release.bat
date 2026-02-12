@echo off

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format \"y.M.d\""') do set version=%%i

git fetch --all --prune
git pull --tags --autostash -r origin master
git tag -a v%version% -M "Release v%version%"
git push origin --tags
