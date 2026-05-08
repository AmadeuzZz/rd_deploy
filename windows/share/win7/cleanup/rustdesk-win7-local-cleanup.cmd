@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==================================================
REM RustDesk Win7 local cleanup script
REM Version: win7-local-cleanup-1
REM ==================================================

set "LOCALDIR=C:\ProgramData\RustDeskDeploy"
set "CLEANLOG=%LOCALDIR%\cleanup-local.log"

set "RUSTDESKDIR=C:\Program Files\RustDesk"
set "SERVICE_CONFIG_DIR=C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk"
set "SYSTEM_CONFIG_DIR=C:\Windows\System32\config\systemprofile\AppData\Roaming\RustDesk"
set "EXTRACTEDDIR1=C:\Windows\system32\config\systemprofile\AppData\Local\rustdesk"
set "EXTRACTEDDIR2=C:\Windows\SysWOW64\config\systemprofile\AppData\Local\rustdesk"

if not exist "%LOCALDIR%" mkdir "%LOCALDIR%"

echo. >> "%CLEANLOG%"
echo ================================================== >> "%CLEANLOG%"
echo RustDesk local cleanup started: %DATE% %TIME% >> "%CLEANLOG%"

sc query Rustdesk > nul 2>&1
if "%ERRORLEVEL%"=="0" (
    net stop Rustdesk >> "%CLEANLOG%" 2>&1
    sc delete Rustdesk >> "%CLEANLOG%" 2>&1
    ping 127.0.0.1 -n 8 > nul
)

taskkill /F /IM rustdesk.exe >> "%CLEANLOG%" 2>&1
taskkill /F /IM RuntimeBroker_rustdesk.exe >> "%CLEANLOG%" 2>&1

rmdir /S /Q "%RUSTDESKDIR%" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%SERVICE_CONFIG_DIR%" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%SYSTEM_CONFIG_DIR%" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%EXTRACTEDDIR1%" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%EXTRACTEDDIR2%" >> "%CLEANLOG%" 2>&1

del /F /Q "%LOCALDIR%\deploy.log" >> "%CLEANLOG%" 2>&1
del /F /Q "%LOCALDIR%\rustdesk-win7.exe" >> "%CLEANLOG%" 2>&1
del /F /Q "%LOCALDIR%\installed-version-win7.txt" >> "%CLEANLOG%" 2>&1
rmdir /S /Q "%LOCALDIR%\deploy.lockdir" >> "%CLEANLOG%" 2>&1

echo RustDesk local cleanup finished: %DATE% %TIME% >> "%CLEANLOG%"
echo Cleanup log: %CLEANLOG%
exit /b 0
