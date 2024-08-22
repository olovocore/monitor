#!/bin/bash


GRAFANA_DIR="./grafana"
INFLUXDB_DIR="./influxdb"
TELEGRAF_DIR="./telegraf"

if [ $# -ne 1 ]; then
  echo "Используйте: $0 {install|remove}"
  exit 1
fi

install_all() {
  echo "Начало установки компонентов..."
  
  bash "$INFLUXDB_DIR/install_influxdb.sh"
  
  bash "$TELEGRAF_DIR/install_telegraf.sh"
  
  docker-compose -f "$GRAFANA_DIR/docker-compose.yml" --env-file=./grafana/.env up -d
  
  echo "Все компоненты установлены."
}

remove_all() {
  echo "Начало удаления компонентов..."
  
  docker-compose -f "$GRAFANA_DIR/docker-compose.yml" --env-file=./grafana/.env down
  
  bash "$TELEGRAF_DIR/remove_telegraf.sh"
  
  bash "$INFLUXDB_DIR/remove_influxdb.sh"
  
  echo "Все компоненты удалены."
}

case "$1" in
  install)
    install_all
    ;;
  remove)
    remove_all
    ;;
  *)
    echo "Неверный аргумент: $1. Использовать 'install' или 'remove'."
    exit 1
    ;;
esac
