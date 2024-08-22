#!/bin/bash

wget https://dl.influxdata.com/telegraf/releases/telegraf_1.31.3-1_amd64.deb

sudo dpkg -i telegraf_1.31.3-1_amd64.deb

sudo systemctl daemon-reload

sudo systemctl start telegraf

sudo systemctl enable telegraf

rm telegraf_1.31.3-1_amd64.deb

echo "Telegraf 1.31.3 успешно установлен."
