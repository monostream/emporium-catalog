#!/usr/bin/env bash

set -Eeuo pipefail


docker build . --tag devcloud-codespace --platform linux/amd64
docker run -it --rm --privileged -p 8080:8080 -e PASSWORD=debug -v $(pwd)/home:/home/codespace devcloud-codespace /bin/bash