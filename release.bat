@echo off

rem Same YY.M.D format as the Tag workflow; no nested quotes, which cmd cannot parse inside for /f
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yy.M.d"') do set version=%%i

git fetch --all --prune || (echo Error: git fetch failed & exit /b 1)
git pull --tags --autostash -r origin master || (echo Error: git pull failed & exit /b 1)

rem Release exactly what is on origin/master - tagging unpushed local commits would publish them unreviewed
for /f %%i in ('git rev-parse HEAD') do set head=%%i
for /f %%i in ('git rev-parse origin/master') do set remote=%%i
if not "%head%"=="%remote%" (echo Error: HEAD is not origin/master, push or drop local commits first & exit /b 1)

git tag -a v%version% -m "Release v%version%" || (echo Error: git tag failed & exit /b 1)
git push origin refs/tags/v%version% || (echo Error: git push failed & exit /b 1)
