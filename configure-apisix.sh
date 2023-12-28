#!/bin/bash

curl "http://127.0.0.1:9180/apisix/admin/consumers" -X PUT -d @apisix-consumer.json -H 'X-API-KEY: __APISIX_ADMIN_KEY_VAR__'
curl "http://127.0.0.1:9180/apisix/admin/routes" -X POST -d @apisix-route.json -H 'X-API-KEY: __APISIX_ADMIN_KEY_VAR__'
curl "http://127.0.0.1:9180/apisix/admin/ssls" -H 'X-API-KEY: __APISIX_ADMIN_KEY_VAR__' -d'{
     "cert" : "'"$(cat server.crt)"'",
     "key": "'"$(cat server.key)"'",
     "snis": ["*.com","*.org","*.net"]
}'