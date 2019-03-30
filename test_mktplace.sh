kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
export NAMESPACE=robinio
export IMAGE_ROBIN_OPERATOR=gcr.io/robinio-public/robin-storage/robin-operator:5.1.0
export IMAGE_ROBIN=gcr.io/robinio-public/robin-storage:5.1.0
export SERVICE_ACCOUNT=marketplace-gke
export IMAGE_PROVISIONER=gcr.io/robinio-public/robin-storage/csi-provisioner:v0.4.1_robin
export REPORTING_SECRET=reporting-sec
export IMAGE_UBBAGENT=gcr.io/robinio-public/robin-storage/ubbagent:1.0
make app/install
