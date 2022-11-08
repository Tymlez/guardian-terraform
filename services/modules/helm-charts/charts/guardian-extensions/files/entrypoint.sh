#!/bin/bash
set -ex
ts=$(date +%s.%N)

if [ "$SERVICE_CHANNEL" = "worker" ];
then
  export SERVICE_CHANNEL="worker.$ts"
fi

if [ "$SERVICE_CHANNEL" = "ipfs-client" ];
then
  export SERVICE_CHANNEL="ipfs-client.$ts"
fi

case "$ENABLE_APM_NAME" in
    "newrelic")
        echo "Installing newrelic dependencies"

        npm install --save-dev --legacy-peer-deps newrelic @newrelic/native-metrics
        node -r newrelic ./dist/index.js
    ;;
    *)
      node ./dist/index.js
    ;;
esac