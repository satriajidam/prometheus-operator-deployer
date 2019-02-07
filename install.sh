#!/bin/bash

########################################################################
# Script : Prometheus operator deployment script.
# Desc	 : This script will install prometheus operator in your
#          kubernetes cluster or update it if it's already installed.
########################################################################

set -o errexit # make script exits when a command fails
set -o pipefail # make script exits when the rightmost command of a pipeline exits with non-zero status
# set -o xtrace # trace what gets executed for debugging purpose

### Get script arguments.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <KUBERNETES_NAMESPACE>"
  exit 1
fi

NAMESPACE="$1"

### Helper functions.

function get_script_dir() {
  local src dir

  src="${BASH_SOURCE[0]}"

  # While $src is a symlink, resolve it.
  while [ -h "$src" ]; do
    dir="$( cd -P "$( dirname "$src" )" && pwd )"
    src="$( readlink "$src" )"
    # If $src was a relative symlink (so no "/" as prefix,
    # need to resolve it relative to the symlink base directory.
    [ "$src" != /* ] && src="$dir/$src"
  done
  
  dir="$( cd -P "$( dirname "$src" )" && pwd )"
  echo "$dir"
}

### Download prometheus operator chart.

RELEASE_NAME="prometheus-operator"
CHART_VERSION="$(cat CHART_VERSION)"
OPERATOR="$RELEASE_NAME-$CHART_VERSION"

# Update repo.
helm repo update

# Download chart.
if [ ! -d "$OPERATOR" ]; then
  helm fetch stable/$RELEASE_NAME --version $CHART_VERSION
  tar -xvzf $OPERATOR.tgz
  mv $RELEASE_NAME $OPERATOR
  rm $OPERATOR.tgz
fi

### Prepare custom templates.

INSTALLED="$(helm list | (grep $RELEASE_NAME || true) | awk '{print $1}')"
CHART_DIR="$(get_script_dir)/$OPERATOR"
VALUES_PATH="$(get_script_dir)/values.yaml"
TEMPLATES_PATH="$(get_script_dir)/templates"

# Add custom alertmanager rules.
cp -rf \
  $TEMPLATES_PATH/alertmanager/rules/* \
  $CHART_DIR/templates/alertmanager/rules

# Add custom grafana service.yaml.
cp -rf \
  $TEMPLATES_PATH/grafana/service.yaml \
  $CHART_DIR/charts/grafana/templates/service.yaml

# Replace default grafana dashboards.
rm -rf $CHART_DIR/templates/grafana/dashboards
cp -rf $TEMPLATES_PATH/grafana/dashboards $CHART_DIR/templates/grafana

### Install prometheus operator.

echo "Deploying $OPERATOR ..."

if [ "$INSTALLED" = "$RELEASE_NAME" ]; then
  echo "Upgrading $OPERATOR ..."

  helm upgrade \
    --namespace $NAMESPACE \
    --values $VALUES_PATH \
    $RELEASE_NAME $CHART_DIR
else
  echo "Installing $OPERATOR ..."

  helm install \
    $CHART_DIR \
    --name $RELEASE_NAME \
    --namespace $NAMESPACE \
    --values $VALUES_PATH
fi

echo "$OPERATOR successfully deployed!"
