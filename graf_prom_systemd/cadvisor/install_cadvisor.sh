#!/bin/bash

wget https://github.com/google/cadvisor/releases/download/v0.50.0/cadvisor-v0.50.0-linux-amd64

sudo mv cadvisor-v0.50.0-linux-amd64 /usr/local/bin/cadvisor

sudo useradd -r -M -s /bin/false cadvisor
sudo usermod -aG docker cadvisor

# Установка прав на исполняемый файл
sudo chown cadvisor:cadvisor /usr/local/bin/cadvisor
sudo chmod +x /usr/local/bin/cadvisor

echo "[Unit]
Description=cAdvisor
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/cadvisor

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/cadvisor.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable cadvisor.service
sudo systemctl start cadvisor.service

echo "cAdvisor установлен"
