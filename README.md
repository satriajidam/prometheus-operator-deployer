# Prometheus Operator Deployer

Deploy prometheus operator with custom prometheus rules & grafana dashboards.

## Contents

- **install.sh** ~ prometheus-operator install script. It's idempotent, which mean you can use it to both install and update your prometheus-operator deployment.

- **uninstall.sh** ~ prometheus-operator's uninstall script.

- **CHART_VERSION** ~ Contains prometheus-operator helm chart version to install. If you want to update your prometheus-operator deployment, make sure to update the prometheus-operator version here first before running the installation script.

- **values.yaml** ~ Helm chart values for prometheus-operator configuration. Modify this file to configure your prometheus-operator deployment.

- **templates/** ~ Contains custom prometheus rules, grafana dashboards, & prometheus-operator helm templates. Modify the contents of this folder to customize your prometheus-operator default setup.

- **namespace.yaml** ~ YAML config for creating monitoring Namespace for prometheus-operator.

- **priorityclass.yaml** ~ YAML config for creating PriorityClass required by prometheus-operator's node-exporter.

## Requirements

Local computer/laptop:

- kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl)

- Helm client (https://github.com/helm/helm/blob/master/docs/install.md)

Kubernetes cluster:

- Persistent volumes support (https://kubernetes.io/docs/concepts/storage/persistent-volumes)

- Helm server (https://github.com/helm/helm/blob/master/docs/install.md)

Database:

- MySQL for Grafana (http://docs.grafana.org/installation/configuration/#database)

## How to

### Setup Kubernetes for prometheus-operator

1. Run `kubectl apply -f namespace.yaml` to create monitoring namespace

2. Run `kunectl apply -f priorityclass.yaml` to create custom priority class

### Install / Update prometheus-operator

1. Edit **CHART_VERSION** to your preferred prometheus-operator version

2. Edit **values.yaml** to configure your prometheus-operator deployment

3. Run **./install.sh <target_namespace>** to deploy prometheus-operator

### Uninstall prometheus-operator

1. Run **./uninstall.sh** to remove all prometheus-operator's components

## References

- https://github.com/coreos/prometheus-operator

- https://prometheus.io

- https://grafana.com
