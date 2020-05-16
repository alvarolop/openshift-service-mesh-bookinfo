#!/bin/bash
#
# ============================================================
# Red Hat Consulting EMEA, 2020
#
# Created-------: 20200514
# ============================================================
# Description--: This script installs Openshift Service Mesh in your OCP cluster.
#
# ============================================================
#
# ============================================================
# Pre Steps---:
# chmod 774 *.sh
# ============================================================
#
#
#
# EOH

PROJECT_NAME=bookinfo

# Create a new OpenShift project for the bookinfo application
oc new-project $PROJECT_NAME --display-name="Book Info"

# Deploy the bookinfo application in the new project
oc apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml -n $PROJECT_NAME

# Expose the productpage service as an OpenShift route
oc expose service productpage -n $PROJECT_NAME

echo -en "\nAccess the application using the following URL:"
echo -en "\n    http://$(oc get route productpage --template '{{ .spec.host }}' -n $PROJECT_NAME)\n"