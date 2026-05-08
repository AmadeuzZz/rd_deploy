#!/usr/bin/env bash
set -euo pipefail

cd /opt/YOUR-RUSTDESK-SERVER-DIR

TS="$(date +%F-%H%M%S)"
mkdir -p ./backups

sudo cp ./data/db_v2.sqlite3 "./backups/db_v2.sqlite3-$TS"
sudo cp ./data/db_v2.sqlite3-wal "./backups/db_v2.sqlite3-wal-$TS" 2>/dev/null || true
sudo cp ./data/db_v2.sqlite3-shm "./backups/db_v2.sqlite3-shm-$TS" 2>/dev/null || true

echo "Backup created in /opt/YOUR-RUSTDESK-SERVER-DIR/backups with timestamp $TS"
