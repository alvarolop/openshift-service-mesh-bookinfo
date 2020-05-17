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

# Create Service Mesh Member Roll for bookinfo namespace
oc apply -f openshift/osm-ServiceMeshMemberRoll.yaml -n $PROJECT_NAME_OSM

echo ""
sleep 120

# Add inject annotations to all the deployments
for deployment in $(oc get deployment -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP); do 
    oc patch deployment $deployment --type='json' -p "[{\"op\": \"add\", \"path\": \"/spec/template/metadata/annotations\", \"value\": {\"sidecar.istio.io/inject\": \"true\"}}]" -n $PROJECT_NAME_APP
done

# Patch Product Page application
oc patch deployment productpage-v1 -p '{"spec":{"template":{"metadata":{"labels":{"maistra.io/expose-route": "true"}}}}}' -n $PROJECT_NAME_APP

echo ""
sleep 10

# Restart all the pod applications manually
for deployment in $(oc get deployment -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP); do
    oc patch deployment $deployment -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n $PROJECT_NAME_APP
done

echo ""
sleep 15

# Make sure that all the bookinfo deployments now include the Envoy sidecar proxy.
counter=0
while (( $counter < $(oc get deployment -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP | wc -l) ))
do
    sleep 5
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

# Check number of containers in each pod
for pod in $(oc get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP); do
    oc get pod $pod -o=go-template='{{.metadata.name}} {{"\t:"}}{{range .spec.containers}} {{.name}}{{"\t"}}{{end}}{{"\n"}}' -n $PROJECT_NAME_APP
done

