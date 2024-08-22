#!/bin/bash

sudo systemctl stop prometheus.service

sudo systemctl disable prometheus.service

sudo rm /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl reset-failed

sudo rm /usr/local/bin/prometheus
sudo rm /usr/local/bin/promtool

sudo userdel prometheus
sudo groupdel prometheus

sudo rm -rf /etc/prometheus
sudo rm -rf /var/lib/prometheus

echo "Prometheus успешно удален из системы."
