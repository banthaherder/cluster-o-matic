.PHONY: infra

cluster-up: infra standup-cluster standup-systems standup-apps

infra:
	cd ./infra && \
	terraform init && \
	terraform apply --auto-approve && \
	$(terraform output -json | jq -r .update_kubeconfig_cmd.value) && \
	$(terraform output -json | jq -r .switch_cluster_context.value) 

standup-cluster:
	cd ./cluster-ops/cluster-config && \
	terraform init && \
	terraform apply --auto-approve

standup-systems:
	cd ./cluster-ops/system-services && \
	terraform init && \
	terraform apply --auto-approve && \
	kubectl apply -f cert-generator.yaml

standup-apps:
	cd ./cluster-ops/apps-services && \
	terraform init && \
	terraform apply --auto-approve

cluster-down: take-down-apps take-down-systems take-down-cluster take-down-infra

take-down-apps:
	cd ./cluster-ops/apps-services && \
	terraform init && \
	terraform destroy --auto-approve

take-down-systems:
	cd ./cluster-ops/system-services \
	&& terraform init && \
	terraform destroy --auto-approve && \
	kubectl delete -f cert-generator.yaml

take-down-cluster:
	cd ./cluster-ops/cluster-config && \
	terraform init && \
	terraform destroy --auto-approve

take-down-infra:
	cd ./infra && \
	terraform init && \
	terraform destroy -force --auto-approve

helm-repos:
	helm repo add jetstack https://charts.jetstack.io && \
	helm repo add stable https://kubernetes-charts.storage.googleapis.com && \
	helm repo add uswitch https://uswitch.github.io/kiam-helm-charts/charts && \
	helm repo update
