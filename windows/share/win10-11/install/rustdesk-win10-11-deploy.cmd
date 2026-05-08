@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==================================================
REM RustDesk Win10/11 deployment script
REM Version: win10-11-gpo-4
REM ==================================================

set "SHARE=\\YOUR-FILE-SERVER\YOUR-SHARE$"
set "INSTALLER=%SHARE%\win10-11\install\rustdesk.exe"
set "CONFIG=%SHARE%\common\RustDesk2.toml"
set "GENPASS=%SHARE%\common\genpass.vbs"
set "REPORTDIR=%SHARE%\reports\win10-11"
set "STATUSDIR=%REPORTDIR%\status"

set "LOCALDIR=C:\ProgramData\RustDeskDeploy"
set "LOCALINSTALLER=%LOCALDIR%\rustdesk-win10-11.exe"
set "LOGFILE=%LOCALDIR%\deploy-win10-11.log"
set "REPORTFILE=%REPORTDIR%\%COMPUTERNAME%.txt"
set "STATUSFILE=%STATUSDIR%\%COMPUTERNAME%-status.txt"
set "LOCKDIR=%LOCALDIR%\deploy-win10-11.lockdir"
set "VERSIONFILE=%LOCALDIR%\installed-version-win10-11.txt"

set "EXPECTED_VERSION=win10-11-exe-1.4.6"

set "RUSTDESKDIR=C:\Program Files\RustDesk"
set "RUSTDESKEXE=C:\Program Files\RustDesk\RustDesk.exe"
set "SERVICE_CONFIG_DIR=C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config"

set "RUNID=%COMPUTERNAME%-%DATE%-%TIME%-%RANDOM%"
set "RUNID=%RUNID::=%"
set "RUNID=%RUNID:.=%"
set "RUNID=%RUNID:,=%"
set "RUNID=%RUNID: =_%"

REM === Wait for network/domain services ===
ping 127.0.0.1 -n 15 > nul

if not exist "%LOCALDIR%" mkdir "%LOCALDIR%"

REM === Restrict local deployment folder ===
icacls "%LOCALDIR%" /inheritance:r > nul 2>&1
icacls "%LOCALDIR%" /grant "*S-1-5-18:(OI)(CI)(F)" > nul 2>&1
icacls "%LOCALDIR%" /grant "*S-1-5-32-544:(OI)(CI)(F)" > nul 2>&1

REM === Prevent parallel run with atomic directory lock ===
mkdir "%LOCKDIR%" > nul 2>&1

if not "%ERRORLEVEL%"=="0" (
    echo. >> "%LOGFILE%"
    echo ================================================== >> "%LOGFILE%"
    echo RustDesk deploy skipped: another instance is already running >> "%LOGFILE%"
    echo Timestamp: %DATE% %TIME% >> "%LOGFILE%"
    exit /b 0
)

echo. >> "%LOGFILE%"
echo ================================================== >> "%LOGFILE%"
echo RustDesk deploy started: %DATE% %TIME% >> "%LOGFILE%"
echo RUNID=%RUNID% >> "%LOGFILE%"
echo ScriptVersion=win10-11-gpo-4 >> "%LOGFILE%"
echo COMPUTERNAME=%COMPUTERNAME% >> "%LOGFILE%"
echo USERDOMAIN=%USERDOMAIN% >> "%LOGFILE%"
echo USERNAME=%USERNAME% >> "%LOGFILE%"

REM ==================================================
REM Fast path: service running, marker matches, and main report exists
REM ==================================================

echo Check existing RustDesk service and deployment version... >> "%LOGFILE%"

set "INSTALLED_MARKER="

if exist "%VERSIONFILE%" (
    set /p INSTALLED_MARKER=<"%VERSIONFILE%"
)

echo EXPECTED_VERSION=%EXPECTED_VERSION% >> "%LOGFILE%"
echo INSTALLED_MARKER=!INSTALLED_MARKER! >> "%LOGFILE%"

sc query Rustdesk | findstr /i "RUNNING" > nul 2>&1

if "%ERRORLEVEL%"=="0" (
    if "!INSTALLED_MARKER!"=="%EXPECTED_VERSION%" (
        if exist "%REPORTFILE%" (
            echo RustDesk service running, version marker matches, main report exists. Skipping installation. >> "%LOGFILE%"
            goto WRITE_ALREADY_INSTALLED_STATUS
        ) else (
            echo Main report missing. Reinstall will continue to generate a new password report. >> "%LOGFILE%"
        )
    ) else (
        echo RustDesk service running but marker is missing or mismatched. Reinstall will continue. >> "%LOGFILE%"
    )
) else (
    echo RustDesk service is not running or not installed. Full install will continue. >> "%LOGFILE%"
)

REM ==================================================
REM Check source files
REM ==================================================

echo Check source files... >> "%LOGFILE%"

if not exist "%INSTALLER%" (
    echo ERROR: installer not found: %INSTALLER% >> "%LOGFILE%"
    goto REPORT_ERROR
)

if not exist "%CONFIG%" (
    echo ERROR: config not found: %CONFIG% >> "%LOGFILE%"
    goto REPORT_ERROR
)

if not exist "%GENPASS%" (
    echo ERROR: genpass.vbs not found: %GENPASS% >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Generate password for this deployment run
REM ==================================================

echo Generating new 12-char password via VBScript >> "%LOGFILE%"

for /f "usebackq delims=" %%P in (`cscript //nologo "%GENPASS%"`) do set "RDPASS=%%P"

if "!RDPASS!"=="" (
    echo ERROR: password generation failed >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Copy installer locally
REM ==================================================

echo Copy installer... >> "%LOGFILE%"
copy /Y "%INSTALLER%" "%LOCALINSTALLER%" > nul 2>&1
echo ERRORLEVEL after copy installer: %ERRORLEVEL% >> "%LOGFILE%"

if not exist "%LOCALINSTALLER%" (
    echo ERROR: installer copy failed >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Silent install
REM ==================================================

echo Run silent install... >> "%LOGFILE%"
"%LOCALINSTALLER%" --silent-install > nul 2>&1
echo ERRORLEVEL after silent-install: %ERRORLEVEL% >> "%LOGFILE%"

echo Wait after silent install... >> "%LOGFILE%"
ping 127.0.0.1 -n 35 > nul

REM === Kill temporary/interactive RustDesk processes after installer ===
echo Kill temporary RustDesk processes after installer... >> "%LOGFILE%"
taskkill /F /IM rustdesk.exe > nul 2>&1
taskkill /F /IM RustDesk.exe > nul 2>&1
taskkill /F /IM RuntimeBroker_rustdesk.exe > nul 2>&1

ping 127.0.0.1 -n 5 > nul

REM ==================================================
REM Check installed executable
REM ==================================================

echo Check RustDesk executable... >> "%LOGFILE%"

if not exist "%RUSTDESKEXE%" (
    echo ERROR: RustDesk executable not found: %RUSTDESKEXE% >> "%LOGFILE%"
    dir "%RUSTDESKDIR%" >> "%LOGFILE%" 2>&1
    goto REPORT_ERROR
)

echo RustDesk executable found: %RUSTDESKEXE% >> "%LOGFILE%"

REM ==================================================
REM Prepare and copy server config
REM ==================================================

echo Prepare service config directory... >> "%LOGFILE%"

if not exist "%SERVICE_CONFIG_DIR%" mkdir "%SERVICE_CONFIG_DIR%"

echo Copy RustDesk2.toml... >> "%LOGFILE%"
copy /Y "%CONFIG%" "%SERVICE_CONFIG_DIR%\RustDesk2.toml" > nul 2>&1
echo ERRORLEVEL after copy config: %ERRORLEVEL% >> "%LOGFILE%"

if not exist "%SERVICE_CONFIG_DIR%\RustDesk2.toml" (
    echo ERROR: RustDesk2.toml copy failed >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Ensure service exists
REM ==================================================

echo Check RustDesk service exists... >> "%LOGFILE%"
sc query Rustdesk > nul 2>&1

if not "%ERRORLEVEL%"=="0" (
    echo RustDesk service missing, trying --install-service... >> "%LOGFILE%"
    "%RUSTDESKEXE%" --install-service > nul 2>&1
    echo ERRORLEVEL after install-service: %ERRORLEVEL% >> "%LOGFILE%"
    ping 127.0.0.1 -n 10 > nul
)

REM ==================================================
REM Restart service before setting password
REM ==================================================

echo Restart RustDesk service before password... >> "%LOGFILE%"
net stop Rustdesk > nul 2>&1
ping 127.0.0.1 -n 8 > nul
net start Rustdesk > nul 2>&1
echo ERRORLEVEL after pre-password net start: %ERRORLEVEL% >> "%LOGFILE%"

ping 127.0.0.1 -n 20 > nul

echo Verify RustDesk service running before password... >> "%LOGFILE%"
sc query Rustdesk | findstr /i "RUNNING" > nul 2>&1
echo ERRORLEVEL after pre-password RUNNING check: %ERRORLEVEL% >> "%LOGFILE%"

if not "%ERRORLEVEL%"=="0" (
    echo ERROR: RustDesk service is not running before password >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Set permanent password
REM ==================================================

echo Set RustDesk password... >> "%LOGFILE%"
"%RUSTDESKEXE%" --password "%RDPASS%" >> "%LOGFILE%" 2>&1
echo ERRORLEVEL after password: %ERRORLEVEL% >> "%LOGFILE%"

if not "%ERRORLEVEL%"=="0" (
    echo ERROR: failed to set RustDesk password >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Restart service after password
REM ==================================================

echo Restart RustDesk service after password... >> "%LOGFILE%"
net stop Rustdesk > nul 2>&1
ping 127.0.0.1 -n 8 > nul
net start Rustdesk > nul 2>&1
echo ERRORLEVEL after post-password net start: %ERRORLEVEL% >> "%LOGFILE%"

ping 127.0.0.1 -n 15 > nul

echo Verify RustDesk service running after password... >> "%LOGFILE%"
sc query Rustdesk | findstr /i "RUNNING" > nul 2>&1
echo ERRORLEVEL after final RUNNING check: %ERRORLEVEL% >> "%LOGFILE%"

if not "%ERRORLEVEL%"=="0" (
    echo ERROR: RustDesk service is not running after password restart >> "%LOGFILE%"
    goto REPORT_ERROR
)

REM ==================================================
REM Collect IPv4
REM ==================================================

set "IPADDRS="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    set "ONEIP=%%A"
    set "ONEIP=!ONEIP: =!"
    set "IPADDRS=!IPADDRS! !ONEIP!"
)

echo IPADDRS=!IPADDRS! >> "%LOGFILE%"

REM ==================================================
REM Write OK main report
REM ==================================================

echo Write OK main report... >> "%LOGFILE%"

echo Hostname: %COMPUTERNAME% > "%REPORTFILE%"
echo IP: !IPADDRS! >> "%REPORTFILE%"
echo Password: %RDPASS% >> "%REPORTFILE%"
echo RustDeskExe: %RUSTDESKEXE% >> "%REPORTFILE%"
echo RustDeskVersion: %EXPECTED_VERSION% >> "%REPORTFILE%"
echo ServiceName: Rustdesk >> "%REPORTFILE%"
echo Status: OK >> "%REPORTFILE%"
echo Timestamp: %DATE% %TIME% >> "%REPORTFILE%"
echo RunAsDomain: %USERDOMAIN% >> "%REPORTFILE%"
echo RunAsUser: %USERNAME% >> "%REPORTFILE%"

echo %EXPECTED_VERSION%>"%VERSIONFILE%"
echo Version marker written: %EXPECTED_VERSION% >> "%LOGFILE%"

echo RustDesk deploy finished OK: %DATE% %TIME% >> "%LOGFILE%"

rmdir "%LOCKDIR%" > nul 2>&1
exit /b 0

REM ==================================================
REM Already installed status report
REM ==================================================

:WRITE_ALREADY_INSTALLED_STATUS

set "IPADDRS="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    set "ONEIP=%%A"
    set "ONEIP=!ONEIP: =!"
    set "IPADDRS=!IPADDRS! !ONEIP!"
)

echo Write already-installed status report... >> "%LOGFILE%"

if not exist "%STATUSDIR%" mkdir "%STATUSDIR%"

echo Hostname: %COMPUTERNAME% > "%STATUSFILE%"
echo IP: !IPADDRS! >> "%STATUSFILE%"
echo RustDeskExe: %RUSTDESKEXE% >> "%STATUSFILE%"
echo RustDeskVersion: %EXPECTED_VERSION% >> "%STATUSFILE%"
echo ServiceName: Rustdesk >> "%STATUSFILE%"
echo Status: OK_ALREADY_INSTALLED >> "%STATUSFILE%"
echo MainReport: %REPORTFILE% >> "%STATUSFILE%"
echo Timestamp: %DATE% %TIME% >> "%STATUSFILE%"
echo RunAsDomain: %USERDOMAIN% >> "%STATUSFILE%"
echo RunAsUser: %USERNAME% >> "%STATUSFILE%"

echo RustDesk deploy skipped because service is already installed/running: %DATE% %TIME% >> "%LOGFILE%"
echo Main password report was not overwritten. >> "%LOGFILE%"

rmdir "%LOCKDIR%" > nul 2>&1
exit /b 0

REM ==================================================
REM Error report
REM ==================================================

:REPORT_ERROR

echo Write ERROR report... >> "%LOGFILE%"

echo Hostname: %COMPUTERNAME% > "%REPORTFILE%"
echo Status: ERROR >> "%REPORTFILE%"
echo Timestamp: %DATE% %TIME% >> "%REPORTFILE%"
echo LocalLog: %LOGFILE% >> "%REPORTFILE%"
echo RunAsDomain: %USERDOMAIN% >> "%REPORTFILE%"
echo RunAsUser: %USERNAME% >> "%REPORTFILE%"

echo RustDesk deploy finished ERROR: %DATE% %TIME% >> "%LOGFILE%"

rmdir "%LOCKDIR%" > nul 2>&1
exit /b 1
