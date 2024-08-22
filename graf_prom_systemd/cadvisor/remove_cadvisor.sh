#!/bin/bash

sudo systemctl stop cadvisor.service

sudo systemctl disable cadvisor.service

sudo rm /etc/systemd/system/cadvisor.service

sudo systemctl daemon-reload
sudo systemctl reset-failed

sudo rm /usr/local/bin/cadvisor

sudo userdel cadvisor
sudo groupdel cadvisor

echo "cAdvisor успешно удален из системы."
