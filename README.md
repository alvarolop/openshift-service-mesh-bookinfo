# openshift-service-mesh-bookinfo
This repository is a proof-of-concept (POC) using Red Hat OpenShift Service Mesh. The purpose of the POC is to determine the feasibility of using OpenShift Service Mesh to connect, control, and secure the various services that comprise the bookinfo application


## Usage

### 1. Access the cluster

First of all, you need to be logged in into the Openshift cluster. Execute the following command and enter your username and password:

```bash
oc login <cluster_url>
```

### 2. Install the application

In this step you will install the example application. In order to do so, execute the following script:

```bash
chmod 755 create-application.sh
./create-application.sh
```

This script installs the `bookinfo` application that can be found at the Istio [documentation](https://istio.io/docs/examples/bookinfo).

### 3. Install Openshift Service Mesh

OSM is installed using operators. Execute the following script to install it in one step:

```bash
chmod 755 create-application.sh
./install-osm.sh
```