#!/bin/bash
wget https://github.com/prometheus/prometheus/releases/download/v2.54.0/prometheus-2.54.0.linux-amd64.tar.gz

tar xvf prometheus-2.54.0.linux-amd64.tar.gz

sudo mv ./prometheus-2.54.0.linux-amd64/prometheus /usr/local/bin
sudo mv ./prometheus-2.54.0.linux-amd64/promtool /usr/local/bin

sudo useradd -r -M -s /bin/false prometheus

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo mv ./prometheus-2.54.0.linux-amd64/consoles /etc/prometheus
sudo mv ./prometheus-2.54.0.linux-amd64/console_libraries /etc/prometheus

sudo mv ./prometheus-2.54.0.linux-amd64/prometheus.yml /etc/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus

echo "[Unit]
Description=Background service of Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
	--config.file /etc/prometheus/prometheus.yml \
	--storage.tsdb.path /var/lib/prometheus/ \
	--web.console.templates=/etc/prometheus/consoles \
	--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable prometheus.service
sudo systemctl start prometheus.service

rm prometheus-2.54.0.linux-amd64.tar.gz
rm -r prometheus-2.54.0.linux-amd64

echo "Prometheus установлен"
