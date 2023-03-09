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
        workdir=$(pwd)
        cd /tmp/newrelic
        npm init  -y
        npm install --legacy-peer-deps newrelic @newrelic/native-metrics
        echo $workdir
        cd $workdir
        cp -R /tmp/newrelic/node_modules $workdir/node_modules
        node -r newrelic ./dist/index.js
    ;;
    *)
        node ./dist/index.js
    ;;
esac