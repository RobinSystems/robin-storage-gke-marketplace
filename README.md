# Overview

ROBIN Storage for GKE is a purpose-built container-native storage solution that brings advanced data management capabilities to Kubernetes. It provides automated provisioning, point-in-time snapshots, backup and recovery, application cloning, QoS guarantee, and multi-cloud migration for stateful applications on Kubernetes. 

Learn more about the [Robin](https://robin.io/).

---
**NOTE**

Robin can only be installed on the cluster which have 
- Nodes have **ubuntu** image
- Nodes have **more than 4GB memory** 
- Cluster has **access to GCP disks and storage APIs**. If you are not sure, select "Allow full access to all Cloud APIs" while creating GKE cluster

---


# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install Robin storage app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/robin-storage).

---
**NOTE**

- Make sure not to use "Create cluster" option as it will not create cluster with Robin requirements

---

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local workstation in the
further instructions.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/RobinSystems/robin-storage)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=robin-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE" --image-type=UBUNTU --machine-type "n1-standard-4" --scopes "https://www.googleapis.com/auth/cloud-platform"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```
#### License Secret

You must obtain a license secret from GCP Marketplace to launch this application.
You can obtain the license from the listing page: https://console.cloud.google.com/marketplace/details/robinio-public/robin-storage.
The license secret is a Kubernetes Secret. Keep the name of this secret handy for the following section.


#### Clone this repo

```shell
git clone https://github.com/RobinSystems/robin-storage-gke-marketplace
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

#### Configure the app with environment variables

Choose an instance name and namespace for the app. 

```shell
export APP_INSTANCE_NAME=robin
export NAMESPACE=robinio
```
If the namespace is not present, create the namespace.
```shell
kubectl create namespace ${NAMESPACE}
```

Configure the container images:

```shell
TAG=5.1.0
export IMAGE_ROBIN_OPERATOR="gcr.io/robinio-public/robin-storage/robin-operator:${TAG}"
export IMAGE_ROBIN="gcr.io/robinio-public/robin-storage:${TAG}"
export IMAGE_PROVISIONER="gcr.io/robinio-public/robin-storage/csi-provisioner:v0.4.1_robin"
export REPORTING_SECRET=robin-1-reporting-secret
export IMAGE_UBBAGENT=gcr.io/robinio-public/robin-storage/ubbagent:1.0
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_ROBIN_OPERATOR"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Configure the service account

The operator needs a service account in the target namespace with cluster wide
permissions to manipulate Kubernetes resources.

Provision a service account and export its via an environment variable as follows:

```shell
kubectl create serviceaccount "${APP_INSTANCE_NAME}-sa" --namespace "${NAMESPACE}"
kubectl create clusterrolebinding "${APP_INSTANCE_NAME}-sa-rb" --clusterrole=cluster-admin --serviceaccount="${NAMESPACE}:${APP_INSTANCE_NAME}-sa"
export SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-sa"
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
awk 'FNR==1 {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_ROBIN_OPERATOR $IMAGE_ROBIN
  $SERVICE_ACCOUNT $IMAGE_PROVISIONER $REPORTING_SECRET $IMAGE_UBBAGENT' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

# Using Robin storage

```
# get status of the cluster
$ kubectl describe robinclusters/robin -n "${NAMESPACE}"

Use "Connect Command" from the output to connect to robin.

```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **Robin Storage**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=robin
export NAMESPACE=robinio
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster. Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace "${NAMESPACE}"
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete application,deployment\
  --namespace ${NAMESPACE}\
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
