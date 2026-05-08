@echo off

REM Run on file server as administrator.

net share YOUR-SHARE$ /delete

net share YOUR-SHARE$="YOUR-SHARE-LOCAL-PATH" /grant:"YOUR-DOMAIN\Администраторы домена",FULL /grant:"YOUR-DOMAIN\Компьютеры домена",CHANGE /remark:"Автоустановка RustDesk на ПК домена."

icacls "YOUR-SHARE-LOCAL-PATH" /inheritance:r

icacls "YOUR-SHARE-LOCAL-PATH" /grant "YOUR-DOMAIN\Администраторы домена:(OI)(CI)(F)"
icacls "YOUR-SHARE-LOCAL-PATH" /grant "BUILTIN\Администраторы:(OI)(CI)(F)"
icacls "YOUR-SHARE-LOCAL-PATH" /grant "NT AUTHORITY\СИСТЕМА:(OI)(CI)(F)"

icacls "YOUR-SHARE-LOCAL-PATH\common" /grant "YOUR-DOMAIN\Компьютеры домена:(OI)(CI)(RX)" /T
icacls "YOUR-SHARE-LOCAL-PATH\win7" /grant "YOUR-DOMAIN\Компьютеры домена:(OI)(CI)(RX)" /T
icacls "YOUR-SHARE-LOCAL-PATH\win10-11" /grant "YOUR-DOMAIN\Компьютеры домена:(OI)(CI)(RX)" /T

icacls "YOUR-SHARE-LOCAL-PATH\reports" /grant "YOUR-DOMAIN\Компьютеры домена:(OI)(CI)(M)" /T

net share YOUR-SHARE$
icacls "YOUR-SHARE-LOCAL-PATH"
icacls "YOUR-SHARE-LOCAL-PATH\reports"
