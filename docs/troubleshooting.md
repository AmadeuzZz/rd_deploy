# Troubleshooting

## Startup Script не отработал

Проверить:

```cmd
gpresult /scope computer /r
rsop.msc
```

В RSOP:

```text
Computer Configuration
→ Windows Settings
→ Scripts (Startup/Shutdown)
→ Startup
```

Проверить путь к скрипту.

## Время/DNS

Group Policy и Kerberos чувствительны к времени.

```cmd
w32tm /query /status
w32tm /query /source
ipconfig /flushdns
klist purge
gpupdate /force
```

Если DNS-запись ПК была неверная, обновить DNS и сбросить кэш.

## Проверить доступ от SYSTEM

```cmd
PsExec.exe -i -s cmd.exe
whoami
```

Ожидаемо:

```text
nt authority\system
```

Проверка шары:

```cmd
dir "\\YOUR-FILE-SERVER\YOUR-SHARE$\win7\install"
type "\\YOUR-FILE-SERVER\YOUR-SHARE$\common\RustDesk2.toml"
echo test > "\\YOUR-FILE-SERVER\YOUR-SHARE$\reports\win7\%COMPUTERNAME%-access-test.txt"
```

## Запуск deploy вручную от SYSTEM

Win7:

```cmd
cmd.exe /c "\\YOUR-FILE-SERVER\YOUR-SHARE$\win7\install\rustdesk-win7-deploy.cmd"
```

Win10/11:

```cmd
cmd.exe /c "\\YOUR-FILE-SERVER\YOUR-SHARE$\win10-11\install\rustdesk-win10-11-deploy.cmd"
```

## Удалённое обновление политики одного ПК

```powershell
Invoke-GPUpdate -Computer "PC-NAME" -Force -RandomDelayInMinutes 0
Restart-Computer -ComputerName "PC-NAME" -Force
```

## Если PsExec не найден

Либо положить `PsExec.exe` в `C:\Temp`, либо использовать PowerShell/Invoke-GPUpdate.

## Ошибка доступа к шари

Проверить NTFS и Share permissions:

```cmd
net share YOUR-SHARE$
icacls "YOUR-SHARE-LOCAL-PATH\common"
icacls "YOUR-SHARE-LOCAL-PATH\win7\install"
icacls "YOUR-SHARE-LOCAL-PATH\reports\win7"
```

## `Процесс не может получить доступ к файлу`

На Win10/11 это часто возникает во время EXE-установки RustDesk, пока временный процесс держит файлы.  
Скрипт ждёт, убивает временные процессы и перезапускает службу.

## `--get-id` пустой

И на Win7, и на Win10/11 в тестах `--get-id` не был надёжным.  
ID можно смотреть на сервере через `rdids/rdid`, но таблица `peer` не является полноценным inventory.
