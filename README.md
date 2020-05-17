# openshift-service-mesh-bookinfo
This repository is a proof-of-concept (POC) using Red Hat OpenShift Service Mesh. The purpose of the POC is to determine the feasibility of using OpenShift Service Mesh to connect, control, and secure the various services that comprise the bookinfo application


## Option 1: Basic Usage

Just follow these two steps to obtain a full installation.

### 1. Access the cluster

First of all, you need to be logged in into the Openshift cluster. Execute the following command and enter your username and password:

```bash
oc login <cluster_url>
```

### 2. Run the automated install

Execute the following script that contains the full automation of the installation:

```bash
chmod 755 0-automated-install.sh
./0-automated-install.sh
```


## Option 2: Step-by-step usage

If you prefer a custom installation, follow these steps.

### 1. Access the cluster

First of all, you need to be logged in into the Openshift cluster. Execute the following command and enter your username and password:

```bash
oc login <cluster_url>
```

### 2. Business Application

In this step you will install the example application. In order to do so, execute the following script:

```bash
chmod 755 3-business-application.sh
./3-business-application.sh
```

This script installs the `bookinfo` application that can be found at the Istio [documentation](https://istio.io/docs/examples/bookinfo).


### 3. OpenShift Service Mesh Operator and Control Plane

OSM is installed using operators. Execute the following script to install it in one step:

```bash
chmod 755 4-osm-operator-and-control-plane.sh
./4-osm-operator-and-control-plane.sh
```

### 4. ServiceMeshMemberRoll

Install a ServiceMeshMemberRoll resource and add a service mesh data plane auto-injection annotation:

```bash
chmod 755 5-service-mesh-member-roll.sh
./5-service-mesh-member-roll.sh
```

### 5. mTLS Security

The POC requires mTLS traffic between all services of the bookinfo application. Execute the following script to configure it in one step:

```bash
chmod 755 6-mtls-security.sh
./6-mtls-security.sh
```


## Testing your application

Perform load testing using the following command:

```bash
while :; do curl -k -s -w %{http_code} --output /dev/null https://$(oc get route productpage-gateway --template '{{ .spec.host }}' -n bookretail-istio-system)/productpage?u=normal; echo "";sleep 1; done
```