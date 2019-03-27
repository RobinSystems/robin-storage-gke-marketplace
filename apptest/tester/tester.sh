set -eo pipefail

export APP_INSTANCE_NAME="robin-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)"
export NAMESPACE=kube-system
export IMAGE_ROBIN_OPERATOR=gcr.io/robinio-public/robin-storage/robin-operator:5.1.0
export IMAGE_ROBIN=gcr.io/robinio-public/robin-storage:5.1.0
export SERVICE_ACCOUNT=marketplace-gke
export IMAGE_PROVISIONER=gcr.io/robinio-public/robin-storage/csi-provisioner:v0.4.1_robin
export REPORTING_SECRET=reporting-sec
export IMAGE_UBBAGENT=gcr.io/robinio-public/robin-storage/ubbagent:1.0
cat ROBIN.yaml.template | envsubst > ROBIN.yaml

cat ROBIN.yaml

kubectl apply -f ROBIN.yaml
sleep 60
kubectl get -f ROBIN.yaml -o yaml
kubectl delete -f ROBIN.yaml 
