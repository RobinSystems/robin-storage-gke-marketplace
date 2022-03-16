if [[ $1 == "-i" ]]; then

    export CLUSTER=cluster-2
    export ZONE=us-central1-c
    export APP_INSTANCE_NAME=robin
    export NAMESPACE=robinio
    export HOST_TYPE=gcp

    gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"

    gcloud auth configure-docker

    kubectl create ns ${NAMESPACE}

    kubectl create -f secret.yaml -n ${NAMESPACE}

    kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"

    TAG=5.3.10
    export IMAGE_ROBIN_OPERATOR="gcr.io/robinio-public/robin-storage/robin-operator:${TAG}"
    export IMAGE_ROBIN="gcr.io/robinio-public/robin-storage:${TAG}"
    export REPORTING_SECRET="robin-1-reporting-secret"
    export IMAGE_UBBAGENT="gcr.io/robinio-public/robin-storage/ubbagent:5.3.10"
    export IMAGE_ROBIN_DEPLOYER="gcr.io/robinio-public/robin-storage/deployer:5.3.10"
    export IMAGE_CRJOB="gcr.io/robinio-public/robin-storage/crjob:5.3.10"
    export CLUSTER_REQUIREMENTS="yes"
    #export STORAGE_DISKS="count=1,type=pd-ssd,size=200"
    export STORAGE_DISKS=""
    export ROBINDS_DIR="/home/robinds"
    export ROBINLOG_DIR="/home/robinds"
    export ROBINCRASH_DIR="/home/robinds"
    export COREDNS_UPDATE="0"
    export DNS_SERVICE="kube-system/kube-dns"

    awk 'FNR==1 {print "---"}{print}' sa.yaml.template | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_ROBIN_OPERATOR $IMAGE_ROBIN
      $SERVICE_ACCOUNT $IMAGE_PROVISIONER_V04 $IMAGE_PROVISIONER_V10 $REPORTING_SECRET $IMAGE_UBBAGENT $IMAGE_ROBIN_DEPLOYER $CLUSTER_REQUIREMENTS $STORAGE_DISKS $HOST_TYPE $IMAGE_CRJOB $COREDNS_UPDATE $DNS_SERVICE'   > "sa_manifest.yaml"
    kubectl apply -f "sa_manifest.yaml" --namespace "${NAMESPACE}"

    export SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-deployer-sa"

    awk 'FNR==1 {print "---"}{print}' manifest/*   | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_ROBIN_OPERATOR $IMAGE_ROBIN
      $SERVICE_ACCOUNT $IMAGE_PROVISIONER_V04 $IMAGE_PROVISIONER_V10 $REPORTING_SECRET $IMAGE_UBBAGENT $IMAGE_ROBIN_DEPLOYER $CLUSTER_REQUIREMENTS $STORAGE_DISKS 
      $HOST_TYPE $ROBINDS_DIR $ROBINLOG_DIR $ROBINCRASH_DIR $IMAGE_CRJOB $COREDNS_UPDATE $DNS_SERVICE'   > "${APP_INSTANCE_NAME}_manifest.yaml"

    kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"

    echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
elif [[ $1 == '-u' ]]; then
    export APP_INSTANCE_NAME=robin
    export NAMESPACE=robinio
    export APP_INSTANCE_NAME=robin

    kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace "${NAMESPACE}"


    kubectl delete serviceaccount "${APP_INSTANCE_NAME}-deployer-sa" -n "${NAMESPACE}"

    kubectl delete clusterrolebinding "$APP_INSTANCE_NAME:$NAMESPACE:deployer-crb0"

    kubectl delete clusterrole $APP_INSTANCE_NAME:$NAMESPACE:deployer-cr0

    kubectl delete application,deployment\
          --namespace ${NAMESPACE}\
            --selector app.kubernetes.io/name=$APP_INSTANCE_NAME

    kubectl delete -f secret.yaml
    kubectl delete ns robinio
fi
