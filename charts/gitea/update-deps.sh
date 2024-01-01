#!/usr/bin/env bash

CLI_EXISTS=$(which depschecker)

if [[ -z ${CLI_EXISTS} ]]; then
  echo "ERROR: depschecker not found"
  exit 1
fi

HELM_EXISTS=$(which helm)

if [[ -z ${HELM_EXISTS} ]]; then
  echo "ERROR: helm not found"
  exit 1
fi

depschecker -f deps.json