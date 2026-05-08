# RustDesk Server Self-Hosted

## Путь проекта

Пример:

```bash
/opt/YOUR-RUSTDESK-SERVER-DIR
```

## Запуск

```bash
cd /opt/YOUR-RUSTDESK-SERVER-DIR
sudo docker compose up -d
```

## Проверка

```bash
sudo docker compose ps
sudo docker logs rustdesk-hbbs --tail=50
sudo docker logs rustdesk-hbbr --tail=50
sudo ss -tulpn | grep -E '21115|21116|21117|21118|21119'
```

Ожидаемые порты:

```text
21115/tcp   hbbs NAT test
21116/tcp   hbbs rendezvous
21116/udp   hbbs rendezvous
21117/tcp   hbbr relay
21118/tcp   hbbs websocket
21119/tcp   hbbr websocket
```

## Ключ сервера

После первого запуска в `./data` появятся:

```text
id_ed25519
id_ed25519.pub
```

В логах `hbbs` также будет строка:

```text
Key: <PUBLIC_KEY>
```

Этот ключ нужно подставить в клиентский:

```text
windows/share/common/RustDesk2.toml.example
```

## SQLite DB

База:

```text
/opt/YOUR-RUSTDESK-SERVER-DIR/data/db_v2.sqlite3
```

RustDesk использует WAL, поэтому при чтении копировать надо также:

```text
db_v2.sqlite3-wal
db_v2.sqlite3-shm
```

## Важно

Не использовать `latest` для production.  
Версия сервера в compose зафиксирована:

```text
rustdesk/rustdesk-server:1.1.15
```
