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

PROJECT_NAME_APP=bookinfo
PROJECT_NAME_OSM=bookretail-istio-system

# Create the operators
oc apply -f openshift/osm-operators-subscription.yaml

# Create an OpenShift project for the Service Mesh
oc adm new-project $PROJECT_NAME_OSM --display-name="OSM for bookinfo"

# Customize installation
oc apply -f openshift/osm-ServiceMeshControlPlane.yaml -n $PROJECT_NAME_OSM