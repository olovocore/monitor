#!/bin/bash

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz

sudo mv ./node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin

sudo useradd -r -M -s /bin/false node_exporter

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo "[Unit]
Description=Node Exporter
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.systemd

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/node_exporter.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter.service

rm node_exporter-1.8.2.linux-amd64.tar.gz
rm -r node_exporter-1.8.2.linux-amd64

echo "Node Exporter установлен"
