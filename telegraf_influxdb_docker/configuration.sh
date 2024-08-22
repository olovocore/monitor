#!/bin/bash
export $(grep -v '^#' .env | xargs)

docker exec -it telegraf /bin/bash -c "groupadd docker && usermod -aG docker root && chown root:docker /var/run/docker.sock"


response=$(curl -s -X POST http://localhost:8086/api/v2/setup \
 -H "Content-Type: application/json" \
 -d '{
 "username": "'$INFLUX_USERNAME'",
 "password": "'$INFLUX_PASSWORD'",
 "org": "'$INFLUX_ORG'",
 "bucket": "'$INFLUX_BUCKET'"
}')

token=$(echo $response | jq -r .auth.token)

export INFLUX_TOKEN=$token
echo "INFLUX_TOKEN=$token"

envsubst < ./telegraf.conf.template > ./telegraf.conf
sudo mv ./telegraf.conf ./telegraf

docker compose restart telegraf

response=$(curl -i -s -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d "{\"user\": \"$GF_SECURITY_ADMIN_USER\", \"password\": \"$GF_SECURITY_ADMIN_PASSWORD\"}")  

grafana_session=$(echo "$response" | grep -oP 'grafana_session=\K[^;]+')
grafana_session_expiry=$(echo "$response" | grep -oP 'grafana_session_expiry=\K[^;]+')

echo "grafana_session: $grafana_session"
echo "grafana_session_expiry: $grafana_session_expiry"

response=$(curl -s -X POST http://localhost:3000/api/datasources \
  -H "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
  -H "content-type: application/json" \
  --data-raw '{"type":"influxdb","access":"proxy"}')

id_db=$(echo $response | jq -r .datasource.id)
uid_db=$(echo $response | jq -r .datasource.uid)
name_db=$(echo $response | jq -r .datasource.name)
type_db=$(echo $response | jq -r .datasource.type)

echo $id_db
echo $uid_db
echo $name_db
echo $type_db

response=$(curl -X PUT 'http://localhost:3000/api/datasources/uid/'$uid_db'' \
--header "Content-Type: application/json" \
--header "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
--data '{"id":'$id_db',
  "uid":"'$uid_db'",
  "orgId":1,
  "name":"'$name_db'",
  "type":"'$type_db'",
  "access":"proxy",
  "url":"'$INFLUX_URL'",
  "basicAuth":true,
  "basicAuthUser":"'$INFLUX_USERNAME'",
  "withCredentials":false,
  "isDefault":true,
  "jsonData":{"version":"Flux","httpMode":"POST","organization":"'$INFLUX_ORG'","defaultBucket":"'$INFLUX_BUCKET'"},
  "secureJsonFields":{},
  "version":1,
  "readOnly":false,
  "accessControl":{"alert.instances.external:read":true,"alert.instances.external:write":true,"alert.notifications.external:read":true,"alert.notifications.external:write":true,"alert.rules.external:read":true,"alert.rules.external:write":true,"datasources.id:read":true,"datasources:delete":true,"datasources:query":true,"datasources:read":true,"datasources:write":true},
  "apiVersion":"",
  "secureJsonData":{"basicAuthPassword":"'$INFLUX_PASSWORD'",
  "token":"'$INFLUX_TOKEN'"}
  }')


declare -A dashboard_files=(
  ["15650_rev1.json"]="DS_INFLUXDB"         # Telegraf Metrics dashboard
  ["18389_rev1.json"]="DS_DROPET-INFLUXDB"  # Docker
)

for dashboard_file in "${!dashboard_files[@]}"; do
    datasource=${dashboard_files[$dashboard_file]}
    temp_file=$(mktemp)

    dashboard_data=$(cat "$dashboard_file")
    echo '{"dashboard":'"$dashboard_data"',"overwrite":true,
    "inputs":[{"name":"'"$datasource"'","type":"datasource","pluginId":"influxdb","value":"'$uid_db'"}],"folderUid":""}' > "$temp_file"

    response=$(curl 'http://localhost:3000/api/dashboards/import' \
        -H "Cookie: grafana_session=$grafana_session; grafana_session_expiry=$grafana_session_expiry" \
        -H 'Content-Type: application/json' \
        --data-binary @"$temp_file")

    echo "Response for $dashboard_file: $response"
done
