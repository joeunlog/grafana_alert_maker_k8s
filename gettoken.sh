#!/bin/bash

# set grafana-alert-maker namespace
kubectl config set-context --current --namespace=monitor


#################################### get grafana token
export GRAFANA_ADMIN_USER=$(kubectl get secret grafana-alert-maker -o jsonpath='{.data}' | jq -r '."admin-user"' | base64 -d)
echo -ne "\e[1;44m>>> grafana admin : $GRAFANA_ADMIN_USER \n\e[0m"

export GRAFANA_ADMIN_PW=$(kubectl get secret grafana-alert-maker -o jsonpath='{.data}' | jq -r '."admin-password"' | base64 -d)
echo -ne "\e[1;44m>>> grafana admin password : $GRAFANA_ADMIN_PW \n\e[0m"

export GRAFANA_URL=$(kubectl get secret grafana-alert-maker -o jsonpath='{.data}' | jq -r '."grafana-url"' | base64 -d)
echo -ne "\e[1;44m>>> grafana URL : $GRAFANA_URL \n\e[0m"


export API_HASH=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
export GRAFANA_TOKEN=$(curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"apikeycurl-$API_HASH\", \"role\":\"Admin\"}" "http://$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PW@$GRAFANA_URL/api/auth/keys" | jq -r '.key')
echo -ne "\e[1;44m>>> grafana token : $GRAFANA_TOKEN \n\e[0m"


#################################### get datasource uid
export DATASOURCE=$(kubectl get cm grafana-alert-maker -o jsonpath='{.data.datasources\.json}' | jq -r '."datasource-name"')
echo -ne "\e[1;44m>>> datasource : $DATASOURCE \n\e[0m"

export DATASOURCE_UID=$(curl -X GET --insecure -H "Authorization: Bearer $GRAFANA_TOKEN" -H "Content-Type: application/json" "http://$GRAFANA_URL/api/datasources" | jq '.[] | select(.name=="'"${DATASOURCE}"'")' | jq '.uid')
echo -ne "\e[1;44m>>> datasource uid : $DATASOURCE_UID \n\e[0m"


#################################### create notification channel
kubectl get cm rafana-alert-maker -o jsonpath='{.data.notichannel\.json}' > notichannel.json

curl -X POST -H "Authorization: Bearer $GRAFANA_TOKEN" -H "Content-Type: application/json" -d @notichannel.json "http://$GRAFANA_URL/api/alert-notifications"