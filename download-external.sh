#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber
set -o noglob

# add repos
helm repo add codechem https://charts.codechem.com
helm repo add bitnami oci://bitnamicharts.docker.pkg.emporium.rocks
helm repo add requarks https://charts.js.wiki
helm repo add gitlab https://charts.gitlab.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

helm repo update

# external charts to be downloaded
charts=(
  "bitnami/ghost@19.3.6"
  "codechem/penpot@1.0.10"
  "requarks/wiki@2.2.20"
  "gitlab/gitlab@7.2.1"
  "prometheus-community/kube-prometheus-stack@48.2.0"
  "grafana/loki@5.10.0"
  "grafana/tempo@1.3.1"
  "grafana/promtail@6.11.9"
  "kubernetes-dashboard/kubernetes-dashboard@6.0.8"
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
