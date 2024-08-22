#!/bin/bash

sudo systemctl stop postgres_exporter.service

sudo systemctl disable postgres_exporter.service

sudo rm /etc/systemd/system/postgres_exporter.service

sudo systemctl daemon-reload
sudo systemctl reset-failed

sudo rm /usr/local/bin/postgres_exporter

sudo userdel postgres_exporter
sudo groupdel postgres_exporter

echo "Postgres Exporter успешно удален из системы."
