#!/bin/bash

sudo systemctl stop telegraf

sudo systemctl disable telegraf

sudo dpkg --purge telegraf

sudo rm -rf /etc/telegraf
sudo rm -rf /var/lib/telegraf
sudo rm -rf /var/log/telegraf

sudo systemctl daemon-reload

sudo apt-get autoremove -y
sudo apt-get autoclean

echo "Telegraf 1.31.3 успешно удален."
