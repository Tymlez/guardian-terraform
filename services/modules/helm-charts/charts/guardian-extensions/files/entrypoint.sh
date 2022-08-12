#!/bin/sh
set -ex
echo "this is trigger by custom sh file"
pwd
npm install --save-dev --legacy-peer-deps newrelic @newrelic/native-metrics
# npm install newrelic @newrelic/native-metrics
node -r newrelic ./dist/index.js