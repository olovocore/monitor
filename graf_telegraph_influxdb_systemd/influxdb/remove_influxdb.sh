#!/bin/bash

sudo systemctl stop influxdb

sudo systemctl disable influxdb

sudo apt-get purge -y influxdb2

sudo rm -rf /var/lib/influxdb
sudo rm -rf /etc/influxdb

sudo apt-get autoremove -y
sudo apt-get autoclean

echo "InfluxDB 2.7.10 успешно удален."
