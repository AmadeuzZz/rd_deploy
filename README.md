# RustDesk Self-Hosted Domain Deployment

Проект для развёртывания RustDesk Self-Hosted в домене Active Directory через GPO Startup Scripts.

Содержит:

- Docker Compose для RustDesk Server (`hbbs`/`hbbr`)
- структуру Windows-шары `YOUR-SHARE$`
- deploy-скрипт для Windows 7 Legacy
- deploy-скрипт для Windows 10/11
- cleanup-скрипты для тестов
- GPO/WMI/ACL инструкции
- fish-функции для просмотра RustDesk ID в SQLite-базе сервера
- команды диагностики и rollout-checklist

---

## Template placeholders

Перед использованием замени placeholders под свою инфраструктуру:

```text
YOUR-DOMAIN                  NetBIOS-имя домена, например EXAMPLE
YOUR-DOMAIN.LOCAL            FQDN домена, например example.local
YOUR-FILE-SERVER             DNS-имя файлового сервера
YOUR-SHARE$                  скрытая SMB-шара для deployment payload/reports
YOUR-SHARE-LOCAL-PATH        локальный путь на файловом сервере, например D:\Shares\RustDeskDeploy
SERVER_IP                    IP или DNS RustDesk self-host server
HBBS_PORT                    hbbs rendezvous port, стандартно 21116
HBBR_PORT                    hbbr relay port, стандартно 21117
CLIENT_IP                    IP тестового клиента для SQL-поиска
PC-NAME / YOUR-PC-NAME       имя тестового ПК
PUT_RUSTDESK_SERVER_PUBLIC_KEY_HERE  публичный ключ hbbs из логов сервера
```


---

## 1. Общая архитектура

```text
RustDesk clients
   ↓
GPO Startup Script
   ↓
\\YOUR-FILE-SERVER\YOUR-SHARE$
   ├── common
   ├── win7
   ├── win10-11
   └── reports
   ↓
RustDesk Server Self-Hosted
   ├── hbbs :21115, 21116/tcp+udp, 21118
   └── hbbr :21117, 21119
```

### Сервер RustDesk

- `hbbs` — rendezvous/server ID
- `hbbr` — relay server
- Docker image зафиксирован на стабильной версии, не `latest`
- Данные сервера хранятся в `./data`
- В `data/id_ed25519.pub` лежит публичный ключ сервера, который нужен клиентам в `RustDesk2.toml`

### Клиенты

Разделены на две ветки:

```text
Windows 7    → legacy EXE + отдельная GPO + WMI filter 6.1
Windows 10/11 → newer EXE + отдельная GPO + WMI filter 10.*
```

---

## 2. Целевая структура Windows-шары

На файловом сервере:

```text
YOUR-SHARE-LOCAL-PATH
├── common
│   ├── RustDesk2.toml
│   └── genpass.vbs
│
├── win7
│   ├── install
│   │   ├── rustdesk.exe
│   │   └── rustdesk-win7-deploy.cmd
│   ├── cleanup
│   │   └── rustdesk-win7-local-cleanup.cmd
│   └── archive
│
├── win10-11
│   ├── install
│   │   ├── rustdesk.exe
│   │   └── rustdesk-win10-11-deploy.cmd
│   ├── cleanup
│   │   └── rustdesk-win10-11-local-cleanup.cmd
│   └── archive
│
└── reports
    ├── win7
    │   └── status
    └── win10-11
        └── status
```

Сетевой путь:

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$
```

Рекомендуется позже заменить IP на DNS-имя, например:

```text
\\YOUR-FILE-SERVER.YOUR-DOMAIN.LOCAL\YOUR-SHARE$
```

если DNS стабилен.

---

## 3. Что делают deploy-скрипты

Оба скрипта:

- запускаются через GPO Startup Script от имени `DOMAIN\COMPUTER$`
- используют atomic lock-directory, чтобы отсечь двойной запуск
- защищают локальную папку `C:\ProgramData\RustDeskDeploy`
- не хранят plaintext-пароль локально
- генерируют пароль через `genpass.vbs`
- пишут пароль только в основной отчёт на защищённой шаре
- пишут `OK_ALREADY_INSTALLED` в отдельный status-файл, не перезаписывая основной отчёт с паролем
- используют version marker, чтобы не скипать старые/чужие установки RustDesk

### Основной отчёт

Создаётся только при установке/переустановке:

```text
reports\win7\PC-NAME.txt
reports\win10-11\PC-NAME.txt
```

Содержит пароль:

```text
Hostname: PC-NAME
IP: CLIENT_IP
Password: <generated-password>
RustDeskVersion: ...
Status: OK
```

### Status-отчёт

Обновляется при повторных стартах, если RustDesk уже установлен:

```text
reports\win7\status\PC-NAME-status.txt
reports\win10-11\status\PC-NAME-status.txt
```

Пароль там не пишется:

```text
Status: OK_ALREADY_INSTALLED
MainReport: \\YOUR-FILE-SERVER\YOUR-SHARE$\reports\...\PC-NAME.txt
```

---

## 4. Version marker

Скрипты не скипают любую установленную копию RustDesk.  
Они скипают только если:

1. служба `Rustdesk` запущена;
2. локальный marker-файл совпадает с ожидаемой версией;
3. основной отчёт с паролем существует.

Marker-файлы:

```text
Win7:
C:\ProgramData\RustDeskDeploy\installed-version-win7.txt

Win10/11:
C:\ProgramData\RustDeskDeploy\installed-version-win10-11.txt
```

Ожидаемые значения:

```text
win7-legacy-1.2.3-1
win10-11-exe-1.4.6
```

Если marker отсутствует или не совпадает — скрипт делает переустановку.

---

## 5. GPO-модель

Создать две GPO:

```text
Deploy RustDesk - Windows 7 Legacy
Deploy RustDesk - Windows 10-11
```

### Win7 WMI filter

```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.1%" AND ProductType = "1"
```

### Win10/11 WMI filter

```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.%" AND ProductType = "1"
```

### Startup Script paths

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\win7\install\rustdesk-win7-deploy.cmd
\\YOUR-FILE-SERVER\YOUR-SHARE$\win10-11\install\rustdesk-win10-11-deploy.cmd
```

### Security Filtering

Для простого массового rollout можно использовать:

```text
Domain Computers
```

Разделение ОС делает WMI-фильтр.

Для контролируемого rollout партиями можно использовать группы:

```text
GG_RustDesk_Win7_Deploy
GG_RustDesk_Win10_11_Deploy
```

---

## 6. Почему Win7-скрипт сложнее

На Windows 7 RustDesk `1.2.3-1` при запуске через GPO/SYSTEM ведёт себя нестабильно:

- `--get-id` не отдаёт ID
- `--install-service` может создавать битый путь службы
- `--silent-install` распаковывает payload в `systemprofile\AppData\Local\rustdesk`

Поэтому Win7-скрипт:

1. запускает `--silent-install`;
2. копирует всю распакованную папку RustDesk в `C:\Program Files\RustDesk`;
3. вручную создаёт службу через `sc create`;
4. кладёт `RustDesk2.toml` в `LocalService` и `LocalSystem/systemprofile`;
5. задаёт пароль и перезапускает службу.

---

## 7. Где смотреть результаты

### Win7

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\reports\win7
\\YOUR-FILE-SERVER\YOUR-SHARE$\reports\win7\status
```

### Win10/11

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\reports\win10-11
\\YOUR-FILE-SERVER\YOUR-SHARE$\reports\win10-11\status
```

### Локальные логи

```text
Win7:
C:\ProgramData\RustDeskDeploy\deploy.log

Win10/11:
C:\ProgramData\RustDeskDeploy\deploy-win10-11.log
```

---

## 8. Проверка ID на RustDesk Server

Функции для fish находятся в:

```text
linux/fish-functions/
```

Установить:

```fish
mkdir -p ~/.config/fish/functions
cp linux/fish-functions/*.fish ~/.config/fish/functions/
```

Использование:

```fish
rdids
rdid CLIENT_IP
```

> Важно: таблица `peer` в RustDesk Server не является полноценным inventory.  
> Если вручную удалить запись из базы, клиент не всегда появляется заново без полной перерегистрации/очистки state.

---
