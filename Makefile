include tools/app.Makefile
include tools/crd.Makefile
include tools/gcloud.Makefile
include tools/var.Makefile


TAG ?= 5.1.0
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/robin-storage/deployer:$(TAG)
NAME ?= robin
IMAGE_ROBIN_OPERATOR ?= "gcr.io/robinio-public/robin-storage/robin-operator:5.1.0"
IMAGE_ROBIN ?= "gcr.io/robinio-public/robin-storage:5.1.0"
IMAGE_PROVISIONER ?= "gcr.io/robinio-public/robin-storage/csi-provisioner:v0.4.1_robin"
SERVICE_ACCOUNT ?= "marketplace-gke"
REPORTING_SECRET ?= ""
IMAGE_UBBAGENT ?= "gcr.io/robinio-public/robin-storage/ubbagent:1.0"
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "robinio", \
  "IMAGE_ROBIN_OPERATOR": "$(IMAGE_ROBIN_OPERATOR)", \
  "IMAGE_ROBIN": "$(IMAGE_ROBIN)", \
  "SERVICE_ACCOUNT": "$(SERVICE_ACCOUNT)", \
  "IMAGE_PROVISIONER": "$(IMAGE_PROVISIONER)", \
  "REPORTING_SECRET": "$(REPORTING_SECRET)", \
  "IMAGE_UBBAGENT": "$(IMAGE_UBBAGENT)" \
}
TESTER_IMAGE ?= $(REGISTRY)/robin-storage/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/robin-storage/deployer \
            .build/robin-storage/robin-storage \
            .build/robin-storage/tester


.build/robin-storage: | .build
	mkdir -p "$@"


.build/robin-storage/deployer: deployer/* \
                                  manifest/* \
                                  schema.yaml \
                                  .build/var/APP_DEPLOYER_IMAGE \
                                  .build/var/MARKETPLACE_TOOLS_TAG \
                                  .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/robin-storage
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/robin-storage" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
#	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/robin-storage/tester: apptest/**/* \
                                | .build/robin-storage
	$(call print_target, $@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
#	docker push "$(TESTER_IMAGE)"
	@touch "$@"


.build/robin-storage/robin-storage: .build/var/REGISTRY \
                                          .build/var/TAG \
                                          | .build/robin-storage
	$(call print_target, $@)
#	docker pull gcr.io/robin-storage/robin-storage:v1alpha1
#	docker tag gcr.io/robin-storage/robin-storage:v1alpha1 "$(REGISTRY)/robin-storage:$(TAG)"
#	docker push "$(REGISTRY)/robin-storage:$(TAG)"
	@touch "$@"
