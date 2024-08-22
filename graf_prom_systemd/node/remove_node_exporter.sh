#!/bin/bash

sudo systemctl stop node_exporter.service

sudo systemctl disable node_exporter.service

sudo rm /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl reset-failed

sudo rm /usr/local/bin/node_exporter

sudo userdel node_exporter
sudo groupdel node_exporter

echo "Node Exporter успешно удален из системы."
