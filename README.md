# Overview

ROBIN Storage for GKE is a purpose-built container-native storage solution that brings advanced data management capabilities to Kubernetes. It provides automated provisioning, point-in-time snapshots, backup and recovery, application cloning, QoS guarantee, and multi-cloud migration for stateful applications on Kubernetes. 

Learn more about the [Robin](https://robin.io/).

---
**NOTE**

Robin can only be installed on the cluster which have 
- Nodes have **ubuntu** image
- Nodes have minimum **4 vCPUs and 4GB memory** 
- Cluster has **access to GCP disks and storage APIs**. If you are not sure, select "Allow full access to all Cloud APIs" while creating GKE cluster

---


# Installation

## Quick install with Google Cloud Marketplace


Make sure **not to use "Create cluster" option** as it will not create cluster with Robin requirements. You can use following commands to create GKE cluster if you do not have existing cluster which meets Robin prerequisites.

```shell
export CLUSTER=robin-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE" --image-type=UBUNTU --machine-type "n1-standard-4" --scopes "https://www.googleapis.com/auth/cloud-platform"
```
Also, here is the [video to create GKE cluster](https://youtu.be/5AyOxQvtCLI) with recommended configuration and access.

Get up and running with a few clicks! Install Robin storage app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Please select the cluster created 
which satisfies Robin requirements. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/robinio-public/robin-storage). 




# Getting started with Robin Storage

Once the installation is complete, you can get details about robin cluster by running

```
# get status of the cluster
$ kubectl describe robinclusters/robin -n "${NAMESPACE}"

Use **Connect Command** from the output to connect to robin. For example,
$ kubectl exec -it robin-rnnnd -n robinio bash
```
After logging into Robin container you can login as “admin” user. Default password is ‘Robin123’
```
$ robin login admin
```
You can verify the installation by running

```
$ robin host list
```

Setup helm if you don't have it. Robin has helper utilities to initialize helm
```
$ robin k8s deploy-tiller-objects
$ robin k8s helm-setup
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com
```

Deploy a sample app to verify. Let's deploy postgresql
```
$ helm install --name sales stable/postgresql --tls --set persistence.storageClass=robin-0-3 --tiller-namespace default
```
Use the output of command to connect to postgresql database.

Please follow [product videos](https://robin.io/product/robin-storage-action/#postgres) for other data management capabilities 


You can refer [user guide](https://s3-us-west-2.amazonaws.com/robinio-docs/5.1.0/install.html#verify-installation) for further details.

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **Robin Storage**.

1. On the Application Details page, click **Delete**.
