# Security Notes

## Пароли

Пароль не хранится локально на клиенте в plaintext.

Основной отчёт с паролем создаётся только при установке/переустановке:

```text
reports\win7\PC-NAME.txt
reports\win10-11\PC-NAME.txt
```

Повторные старты пишут status-файл без пароля.

## Reports ACL

`reports` должен быть защищён.

Рекомендация:

```text
Domain Admins / IT admins: Full
Domain Computers: Modify/Create reports
Ordinary users: No access
```

## Локальная папка

```text
C:\ProgramData\RustDeskDeploy
```

Скрипт ограничивает ACL:

```text
SYSTEM: Full
Local Administrators: Full
```

## Git

Не коммитить реальные reports, logs, binaries и приватные ключи сервера.
