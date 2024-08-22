#!/bin/bash

wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz

tar xvf postgres_exporter-0.15.0.linux-amd64.tar.gz

sudo useradd -r -M -s /bin/false postgres_exporter

sudo mv ./postgres_exporter-0.15.0.linux-amd64/postgres_exporter /usr/local/bin

sudo chown postgres_exporter:postgres_exporter /usr/local/bin/postgres_exporter

echo "[Unit]
Description=Prometheus PostgreSQL Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=postgres_exporter
Group=postgres_exporter
Type=simple
ExecStart=/usr/local/bin/postgres_exporter \
        --web.listen-address=:9187 \
        --web.telemetry-path=/metrics \
        --log.level=info \
        --collector.database \
        --collector.database_wraparound \
        --collector.locks \
        --collector.long_running_transactions \
        --collector.postmaster \
        --collector.process_idle \
        --collector.replication \
        --collector.replication_slot \
        --collector.stat_activity_autovacuum \
        --collector.stat_bgwriter \
        --collector.stat_database \
        --collector.stat_statements \
        --collector.stat_user_tables \
        --collector.stat_wal_receiver \
        --collector.statio_user_indexes \
        --collector.statio_user_tables \
        --collector.wal \
        --collector.xlog_location \

Environment=DATA_SOURCE_NAME=postgresql://grafana:hellografana@localhost:8787/postgres?sslmode=disable

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/postgres_exporter.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable postgres_exporter
sudo systemctl start postgres_exporter

rm postgres_exporter-0.15.0.linux-amd64.tar.gz
rm -r postgres_exporter-0.15.0.linux-amd64

echo "Postgres Exporter установлен"
