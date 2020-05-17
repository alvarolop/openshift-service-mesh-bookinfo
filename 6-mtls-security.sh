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
BASE_URL=$(oc get route console -o go-template='{{.spec.host}}' -n openshift-console | cut -d. -f2-)

# Create a policy object for the bookinfo namespace deployments.
for deployment in $(oc get deployment -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP); do 
    oc process -f openshift/template-policy.yaml -p DEPLOYMENT=$deployment -o yaml | oc apply -f - -n $PROJECT_NAME_APP
done

# Create appropriate TLS certificates
echo "[ req ]
req_extensions     = req_ext
distinguished_name = req_distinguished_name
prompt             = no

[req_distinguished_name]
commonName=${BASE_URL}

[req_ext]
subjectAltName   = @alt_names

[alt_names]
DNS.1  = .${BASE_URL}
DNS.2  = *.${BASE_URL}
" > cert.cfg

openssl req -x509 -config cert.cfg -extensions req_ext -nodes -days 730 -newkey rsa:2048 -sha256 -keyout tls.key -out tls.crt
oc create secret tls istio-ingressgateway-certs --cert tls.crt --key tls.key -n $PROJECT_NAME_OSM
oc patch deployment istio-ingressgateway -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%FT%T%z`'"}}}}}' -n $PROJECT_NAME_OSM


# Create Destination rules for services
for service in $(oc get service -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n $PROJECT_NAME_APP); do 
    oc process -f openshift/template-destination-rule.yaml -p SERVICE_NAME=$service -o yaml | oc apply -f - -n $PROJECT_NAME_APP
done

# Create VirtualService for Product Page
oc process -f openshift/template-product-page.yaml -p BASE_URL=${BASE_URL} -o yaml | oc apply -f - -n $PROJECT_NAME_OSM
oc delete route productpage -n $PROJECT_NAME_APP

echo -en "\nAccess the application using the following URL:"
echo -en "\n    https://$(oc get route productpage-gateway --template '{{ .spec.host }}' -n $PROJECT_NAME_OSM)\n"