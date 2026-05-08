@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==================================================
REM RustDesk Win10/11 local cleanup script
REM Version: win10-11-local-cleanup-1
REM ==================================================

set "LOCALDIR=C:\ProgramData\RustDeskDeploy"
set "CLEANLOG=%LOCALDIR%\cleanup-win10-11-local.log"

set "RUSTDESKDIR=C:\Program Files\RustDesk"
set "SERVICE_CONFIG_DIR=C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk"

if not exist "%LOCALDIR%" mkdir "%LOCALDIR%"

echo. >> "%CLEANLOG%"
echo ================================================== >> "%CLEANLOG%"
echo RustDesk Win10/11 cleanup started: %DATE% %TIME% >> "%CLEANLOG%"

sc query Rustdesk > nul 2>&1
if "%ERRORLEVEL%"=="0" (
    net stop Rustdesk >> "%CLEANLOG%" 2>&1
    sc delete Rustdesk >> "%CLEANLOG%" 2>&1
    ping 127.0.0.1 -n 8 > nul
)

taskkill /F /IM RustDesk.exe >> "%CLEANLOG%" 2>&1
taskkill /F /IM rustdesk.exe >> "%CLEANLOG%" 2>&1
taskkill /F /IM RuntimeBroker_rustdesk.exe >> "%CLEANLOG%" 2>&1

rmdir /S /Q "%RUSTDESKDIR%" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%SERVICE_CONFIG_DIR%" >> "%CLEANLOG%" 2>&1

del /F /Q "%LOCALDIR%\deploy-win10-11.log" >> "%CLEANLOG%" 2>&1
del /F /Q "%LOCALDIR%\rustdesk-win10-11.exe" >> "%CLEANLOG%" 2>&1
del /F /Q "%LOCALDIR%\installed-version-win10-11.txt" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%LOCALDIR%\deploy-win10-11.lockdir" >> "%CLEANLOG%" 2>&1

echo RustDesk Win10/11 cleanup finished: %DATE% %TIME% >> "%CLEANLOG%"
echo Cleanup log: %CLEANLOG%
exit /b 0
