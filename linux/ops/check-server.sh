#!/usr/bin/env bash
set -euo pipefail

cd /opt/YOUR-RUSTDESK-SERVER-DIR

sudo docker compose ps
sudo docker logs rustdesk-hbbs --tail=50
sudo docker logs rustdesk-hbbr --tail=50
sudo ss -tulpn | grep -E '21115|21116|21117|21118|21119' || true
