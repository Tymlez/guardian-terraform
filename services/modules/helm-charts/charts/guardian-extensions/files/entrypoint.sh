#!/bin/bash
set -ex
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