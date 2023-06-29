#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber
set -o noglob

# add repos
helm repo add codechem https://charts.codechem.com
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add requarks https://charts.js.wiki

helm repo update

# external charts to be downloaded
charts=(
  "bitnami/ghost@19.3.6"
  "codechem/penpot@1.0.10"
  "requarks/wiki@2.2.20"
)

for chart in "${charts[@]}"
do
  IFS="@" read -ra nameAndVersion <<< "$chart"
  IFS="/" read -ra repoAndName <<< "${nameAndVersion[0]}"
  repo="${repoAndName[0]}"
  name="${repoAndName[1]}"
  version="${nameAndVersion[1]}"

  echo "downloading $name in version ^$version"

  helm pull $repo/$name --destination charts/$name --version $version

  echo "extracting $name to charts/$name"

  find charts/$name -name "$name*" -type f -print0 | xargs -0 -I {} tar -xzf {} -C charts

  find charts/$name -name "$name*" -type f -print0 | xargs -0 -I {} rm {}
done
