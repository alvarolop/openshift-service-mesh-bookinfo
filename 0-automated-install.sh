#!/bin/bash
#
# ============================================================
# Red Hat Consulting EMEA, 2020
#
# Created-------: 20200514
# ============================================================
# Description--: This script deploys bookinfo example application in a OCP cluster.
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

./3-business-application.sh
./4-osm-operator-and-control-plane.sh
./5-service-mesh-member-roll.sh
./6-mtls-security.sh

