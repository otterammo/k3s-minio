KUBECONFIG ?= ../k3s-infra/kubeconfig
KUBE := KUBECONFIG=$(KUBECONFIG) kubectl

.PHONY: deploy create-secret create-bucket status destroy

deploy: create-secret apply wait-for-ready create-bucket ## Full deploy: secret + manifests + bucket
	@echo "MinIO fully deployed"

create-secret: ## Create MinIO root credentials secret
	@bash scripts/create-secret.sh

apply: ## Apply MinIO manifests
	@$(KUBE) apply -f manifests/

wait-for-ready: ## Wait for MinIO pod to be ready
	@$(KUBE) wait --namespace minio --for=condition=ready pod --selector=app=minio --timeout=180s

create-bucket: ## Create backup bucket
	@bash scripts/create-bucket.sh

status: ## Show MinIO status
	@$(KUBE) get pods,svc -n minio

destroy: ## Remove MinIO
	@$(KUBE) delete namespace minio --timeout=120s 2>/dev/null || echo "Already removed"
