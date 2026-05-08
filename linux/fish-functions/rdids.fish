function rdids
    set RD_DIR /opt/YOUR-RUSTDESK-SERVER-DIR
    set TMP_DB /tmp/rustdesk-db-check.sqlite3

    cd $RD_DIR; or return 1

    sudo rm -f /tmp/rustdesk-db-check.sqlite3*

    sudo cp ./data/db_v2.sqlite3 $TMP_DB

    if test -f ./data/db_v2.sqlite3-wal
        sudo cp ./data/db_v2.sqlite3-wal "$TMP_DB-wal"
    end

    if test -f ./data/db_v2.sqlite3-shm
        sudo cp ./data/db_v2.sqlite3-shm "$TMP_DB-shm"
    end

    sudo chown $USER:$USER /tmp/rustdesk-db-check.sqlite3*

    sqlite3 -header -column $TMP_DB "
SELECT
  id,
  created_at,
  replace(json_extract(info, '\$.ip'), '::ffff:', '') AS ip
FROM peer
ORDER BY created_at DESC;
"
end
