#!/bin/bash

########################################################################
# Script : Prometheus operator teardown script.
# Desc	 : This script will uninstall all prometheus operator
#          components from your kubernetes cluster.
########################################################################

set -o errexit # make script exits when a command fails
set -o pipefail # make script exits when the rightmost command of a pipeline exits with non-zero status
# set -o xtrace # trace what gets executed for debugging purpose

RELEASE_NAME="prometheus-operator"
CHART_VERSION="$(cat CHART_VERSION)"

echo "Removing $RELEASE_NAME ..."

helm delete --purge $RELEASE_NAME

echo "$RELEASE_NAME successfully removed!"
