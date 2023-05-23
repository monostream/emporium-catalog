# Helm Charts packaged for App-Store by monostream

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```sh
helm repo add monostream https://monostream.github.io/charts
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
monostream` to see the charts.

To install the <chart-name> chart:

```sh
helm install my-<chart-name> monostream/<chart-name>
```
  
To uninstall the chart:

```sh
helm delete my-<chart-name>
```
  
