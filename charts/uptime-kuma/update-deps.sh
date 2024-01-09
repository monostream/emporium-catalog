#!/usr/bin/env bash

CLI_EXISTS=$(which depschecker)

if [[ -z ${CLI_EXISTS} ]]; then
  echo "ERROR: depschecker not found"
  exit 1
fi

echo "Checking updates for uptime-kuma"
depschecker -f deps.json