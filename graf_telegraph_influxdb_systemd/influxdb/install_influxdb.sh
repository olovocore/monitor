#!/bin/bash

wget https://dl.influxdata.com/influxdb/releases/influxdb2_2.7.10-1_amd64.deb

sudo dpkg -i influxdb2_2.7.10-1_amd64.deb

sudo systemctl enable influxdb
sudo systemctl start influxdb

rm influxdb2_2.7.10-1_amd64.deb

echo "influxdb 2.27.10 успешно установлен."