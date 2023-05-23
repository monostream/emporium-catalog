#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber
set -o noglob

# external charts to be downloaded
charts=("ghost^19.3.6")

for chart in "${charts[@]}"
do
  # parts=$(echo "$chart" | tr '^' '\n')
  IFS="^" read -ra parts <<< "$chart"
  name="${parts[0]}"
  version="${parts[1]}"

  echo "downloading $name in version ^$version"

  helm pull bitnami/$name --destination charts/$name --version ^$version

  echo "extracting $name to charts/$name"

  find charts/$name -name "$name*" -type f -print0 | xargs -0 -I {} tar -xzf {} -C charts

  find charts/$name -name "$name*" -type f -print0 | xargs -0 -I {} rm {}
done