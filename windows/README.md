# Windows Deployment

## Шара

Целевой путь:

```text
YOUR-SHARE-LOCAL-PATH
```

Сетевой путь:

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$
```

## Создать структуру

```cmd
mkdir YOUR-SHARE-LOCAL-PATH\common
mkdir YOUR-SHARE-LOCAL-PATH\win7\install
mkdir YOUR-SHARE-LOCAL-PATH\win7\cleanup
mkdir YOUR-SHARE-LOCAL-PATH\win7\archive
mkdir YOUR-SHARE-LOCAL-PATH\win10-11\install
mkdir YOUR-SHARE-LOCAL-PATH\win10-11\cleanup
mkdir YOUR-SHARE-LOCAL-PATH\win10-11\archive
mkdir YOUR-SHARE-LOCAL-PATH\reports\win7\status
mkdir YOUR-SHARE-LOCAL-PATH\reports\win10-11\status
```

## Файлы

```text
common\RustDesk2.toml
common\genpass.vbs

win7\install\rustdesk.exe
win7\install\rustdesk-win7-deploy.cmd

win10-11\install\rustdesk.exe
win10-11\install\rustdesk-win10-11-deploy.cmd
```

Бинарники `rustdesk.exe` не включены в Git.  
Положи их вручную:

```text
win7:      RustDesk 1.2.3-1 x86_64 EXE
win10-11:  RustDesk 1.4.6 x86_64 EXE
```

## GPO startup script paths

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\win7\install\rustdesk-win7-deploy.cmd
\\YOUR-FILE-SERVER\YOUR-SHARE$\win10-11\install\rustdesk-win10-11-deploy.cmd
```
