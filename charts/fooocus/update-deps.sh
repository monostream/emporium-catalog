#!/usr/bin/env bash

CLI_EXISTS=$(which deps-checker)

if [[ -z ${CLI_EXISTS} ]]; then
  echo "ERROR: deps-checker not found"
  exit 1
fi

echo "Checking updates for fooocus"
deps-checker -f deps.json -u
