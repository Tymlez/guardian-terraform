#!/bin/bash
set -e

cd "$1"
version=$(git describe --tags --always --dirty)

echo -n "{\"result\" : \"$version\"}"
