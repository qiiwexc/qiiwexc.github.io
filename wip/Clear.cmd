@echo off
set RegKey=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\
set OfficeKey=*000000F01FEC
set Count=0

FOR /f "tokens=10 delims=\" %%i IN ('reg query %RegKey% /f %OfficeKey% /k') DO call :ProduList %%i

if %Count% == 0 (
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo. ----------------------------------------------------
echo.       Неиспользуемые обновления не найдены!
echo. ----------------------------------------------------
echo.
goto :eof
)

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo. ----------------------------------------------------
echo. Найдено %Count% неиспользуемых (устаревших) компонентов
echo. обновлений. Для их удаления, запустите функцию ещё раз.
echo. ----------------------------------------------------
echo.
goto :eof

:ProduList
set ProduRegKey=%RegKey%%1\
for /F "tokens=2*" %%i in ('reg query %ProduRegKey%InstallProperties /v DisplayName') do set ProduName=%%j
echo. %ProduName%
echo.
FOR /f "tokens=12 delims=\" %%i IN ('reg query %ProduRegKey%Patches /f * /k') DO call :UpdateList %%i
goto :eof

:UpdateList
set ProduUpdaRegKey=%ProduRegKey%Patches\%1
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v State') do set ProduUpdaState=%%j
if %ProduUpdaState% == 0x1 goto :eof
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v Uninstallable') do set ProduUpdaUninstallable=%%j
if not %ProduUpdaUninstallable% == 0x1 goto :eof
for /F "tokens=2*" %%i in ('reg query %ProduUpdaRegKey% /v DisplayName') do set ProduUpdaName=%%j
echo %ProduUpdaName%
set /A Count=%Count% + 1
goto :eof
