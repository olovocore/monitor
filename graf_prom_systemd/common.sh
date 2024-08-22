#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Используйте: $0 {install|remove}"
  exit 1
fi

install_all() {
    echo "Начало установки компонентов..."
    
    ./node/install_node_exporter.sh

    ./postgres/install_postgres_exporter.sh

    ./cadvisor/install_cadvisor.sh

    ./prometheus/install_prom.sh

    docker compose -f ./grafana/docker-compose.yml --env-file=./grafana/.env up -d

    echo "Все компоненты установлены."
}

remove_all() {
    echo "Начало удаления компонентов..."
    
    ./node/remove_node_exporter.sh

    ./postgres/remove_postgres_exporter.sh

    ./cadvisor/remove_cadvisor.sh

    ./prometheus/remove_prom.sh

    docker compose -f ./grafana/docker-compose.yml --env-file=./grafana/.env down

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
