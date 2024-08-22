#!/bin/bash

export $(grep -v '^#' .env | xargs)

docker exec -it cadvisor /bin/sh -c "chown root:root /var/run/docker.sock"

docker compose -f docker-compose-prom.yml restart cadvisor 

response=$(curl -i -sS -X POST http://localhost:3000/login \
    -H "Content-Type: application/json" \
    -d "{\"user\": \"$GF_SECURITY_ADMIN_USER\", \"password\": \"$GF_SECURITY_ADMIN_PASSWORD\"}")

grafana_session=$(echo "$response" | grep -oP 'grafana_session=\K[^;]+')
grafana_session_expiry=$(echo "$response" | grep -oP 'grafana_session_expiry=\K[^;]+')

echo "grafana_session: $grafana_session"
echo "grafana_session_expiry: $grafana_session_expiry"

response=$(curl -sS -X POST http://localhost:3000/api/datasources \
    -H "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
    -H "content-type: application/json" \
    --data-raw '{"type":"prometheus","access":"proxy"}')

id_db=$(echo $response | jq -r .datasource.id)
uid_db=$(echo $response | jq -r .datasource.uid)
name_db=$(echo $response | jq -r .datasource.name)
type_db=$(echo $response | jq -r .datasource.type)

echo "Id_DB: $id_db"
echo "UID_DB: $uid_db"
echo "Name_db: $name_db"
echo "Type_db: $type_db"


response=$(curl -sS -X PUT 'http://localhost:3000/api/datasources/uid/'$uid_db'' \
    --header "Content-Type: application/json" \
    --header "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
    --data '{"id":'$id_db',
    "uid":"'$uid_db'",
    "orgId":1,
    "name":"'$name_db'",
    "type":"'$type_db'",
    "access":"proxy",
    "url":"'$PROMETHEUS_URL'",
    "basicAuth":true,
    "basicAuthUser":"",
    "withCredentials":false,
    "isDefault":true,
    "jsonData":{"httpMode":"POST"},
    "secureJsonFields":{},
    "version":1,
    "readOnly":false,
    "accessControl":{"alert.instances.external:read":true,"alert.instances.external:write":true,"alert.notifications.external:read":true,"alert.notifications.external:write":true,"alert.rules.external:read":true,"alert.rules.external:write":true,"datasources.id:read":true,"datasources:delete":true,"datasources:query":true,"datasources:read":true,"datasources:write":true},
    "apiVersion":""
}')

dashboard_files=(
  "1860_rev37.json" #Node exporter full
  "21361_rev1.json" #docker
  "3300_rev1.json" #Postgres Node
  "12273_rev4.json" #PostgreSQL Overview
)

for dashboard_file in "${dashboard_files[@]}"; do
    temp_file=$(mktemp)

    dashboard_data=$(cat "$dashboard_file")

    echo '{"dashboard":'"$dashboard_data"',"overwrite":true,
        "inputs":[{"name":"DS_PROMETHEUS","type":"datasource","pluginId":"prometheus","value":"'$uid_db'"}],"folderUid":""}' > $temp_file

    response=$(curl -sS -X POST 'http://localhost:3000/api/dashboards/import' \
        -H "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
        -H 'Content-Type: application/json' \
        --data-binary @$temp_file)

    echo "$dashboard_file: $response"
done

#systemD
dashboard_data=$(cat 1617_rev1.json)
response=$(curl -sS -X POST 'http://localhost:3000/api/dashboards/import' \
    -H "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
    -H 'content-type: application/json' \
    --data-raw '{"dashboard":'"$dashboard_data"',"overwrite":true,
    "inputs":[{"name":"DS_PROMETHEUS-MAIN","type":"datasource","pluginId":"prometheus","value":"'$uid_db'"}],"folderUid":""}')

    echo "$dashboard_file: $response"
