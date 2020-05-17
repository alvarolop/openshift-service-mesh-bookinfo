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

PROJECT_NAME_APP=bookinfo
PROJECT_NAME_OSM=bookretail-istio-system

# Create an OpenShift project for the bookinfo application
oc new-project $PROJECT_NAME_APP --display-name="Book Info"

# Deploy the bookinfo application in the new project
oc apply -f https://raw.githubusercontent.com/istio/istio/1.4.0/samples/bookinfo/platform/kube/bookinfo.yaml -n $PROJECT_NAME_APP

# Expose the productpage service as an OpenShift route
oc expose service productpage -n $PROJECT_NAME_APP

# Make sure that all the bookinfo deployments are ready.
counter=0
while (( $counter < $(oc get deployment -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP | wc -l) ))
do
    sleep 10
    counter=0
    for deployment in $(oc get deployment -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP); do 

        replicas="$(oc get deployment $deployment -o=go-template='{{.status.replicas}}' -n $PROJECT_NAME_APP)"
        readyReplicas="$(oc get deployment $deployment -o=go-template='{{.status.readyReplicas}}' -n $PROJECT_NAME_APP)"
        if [ "$replicas" -eq "$readyReplicas" ]; then
            echo "$deployment is ready"
            ((counter++))
        else
            echo "$deployment is not ready"
        fi
    done
done

echo -en "\nAccess the application using the following URL:"
echo -en "\n    http://$(oc get route productpage --template '{{ .spec.host }}' -n $PROJECT_NAME_APP)\n"