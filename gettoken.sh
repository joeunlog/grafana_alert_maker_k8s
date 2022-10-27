#!/bin/bash

echo -ne "\e[1;44m\n#################### set namespace ####################\n\e[0m"
# set grafana-alert-maker namespace
kubectl config set-context --current --namespace=monitor


#################################### get grafana token
echo -ne "\e[1;44m\n#################### get grafana token ####################\n\e[0m"

export GRAFANA_ADMIN_USER=$(kubectl get secret grafana-alert-maker -o jsonpath='{.data}' | jq -r '."admin-user"' | base64 -d)
echo ">>> grafana admin : $GRAFANA_ADMIN_USER \n"

export GRAFANA_ADMIN_PW=$(kubectl get secret grafana-alert-maker -o jsonpath='{.data}' | jq -r '."admin-password"' | base64 -d)
echo ">>> grafana admin password : $GRAFANA_ADMIN_PW \n"

export GRAFANA_URL=$(kubectl get secret grafana-alert-maker -o jsonpath='{.data}' | jq -r '."grafana-url"' | base64 -d)
echo ">>> grafana URL : $GRAFANA_URL \n"


export API_HASH=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
echo ">>> new api user : apikeycurl-$API_HASH \n"
export GRAFANA_TOKEN=$(curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"apikeycurl-$API_HASH\", \"role\":\"Admin\"}" "http://$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PW@$GRAFANA_URL/api/auth/keys" | jq -r '.key')
echo ">>> grafana token : $GRAFANA_TOKEN \n"


#################################### get datasource uid
echo -ne "\e[1;44m\n#################### get datasource uid ####################\n\e[0m"

export DATASOURCE=$(kubectl get cm grafana-alert-maker -o jsonpath='{.data.datasources\.json}' | jq -r '."datasource-name"')
echo ">>> datasource : $DATASOURCE \n"

export DATASOURCE_UID=$(curl -X GET --insecure -H "Authorization: Bearer $GRAFANA_TOKEN" -H "Content-Type: application/json" "http://$GRAFANA_URL/api/datasources" | jq '.[] | select(.name=="'"${DATASOURCE}"'")' | jq '.uid')
echo ">>> datasource uid : $DATASOURCE_UID \n"


#################################### create notification channel
echo -ne "\e[1;44m\n#################### create notification channel ####################\n\e[0m"
kubectl get secret grafana-alert-maker -o jsonpath='{.data.notichannel}' | base64 -d > notichannel.json
echo ">>> notichannel.json \n"
cat notichannel.json

curl -X POST -H "Authorization: Bearer $GRAFANA_TOKEN" -H "Content-Type: application/json" -d @notichannel.json "http://$GRAFANA_URL/api/alert-notifications"