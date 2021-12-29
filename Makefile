#----------------------
# Makefile Commands
#----------------------

all: create-environment prepare-environment setup-vault deploy-application

create-environment: create-demo-ns set-default-k8s-context 

prepare-environment: add-hashiCorp-repo install-vault-server 

setup-vault: wait-complete-vault-deployment set-secret-vault config-k8s-auth write-vault-policy set-k8s-auth-role

deploy-application: create-k8s-service-account apply-k8s-deployment

#----------------------
# Environment Setup
#----------------------

create-demo-ns:
	@echo "Creating demo kubernetes namespace..."
	@kubectl create ns demo
	@echo "...Done 🏁"

set-default-k8s-context:
	@echo "Setting default namespace in kubernetes context..."
	@kubectl config set-context --current --namespace=demo
	@echo "...Done 🏁"

#----------------------
# HashiCorp Helm Steps
#----------------------

add-hashiCorp-repo:
	@echo "Adding hashiCorp helm repository..."
	@helm repo add hashicorp https://helm.releases.hashicorp.com
	@helm repo update
	@echo "...Done 🏁"

install-vault-server:
	@echo "Installing vault server..."
	@helm install vault hashicorp/vault --set "server.dev.enabled=true"
	@echo "...Done 🏁"

#----------------------
# Vault Config Steps
#----------------------

wait-complete-vault-deployment:
	@chmod +x ./manifests/vault/wait-vault-deployment.sh
	@./manifests/vault/wait-vault-deployment.sh

set-secret-vault:
	@echo "Setting a secret in Vault..."
	@kubectl exec vault-0 -- vault secrets enable -path=internal kv-v2
	@kubectl exec vault-0 -- vault kv put internal/app/config VAULT__SECRETVALUE="vault"
	@kubectl exec vault-0 -- vault kv get internal/app/config
	@echo "...Done 🏁"

config-k8s-auth:
	@echo "Configuring kubernetes authentication in Vault..."
	@kubectl exec vault-0 -- vault auth enable kubernetes
# kubectl exec vault-0 -- sh -c 'vault write auth/kubernetes/config kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:443" token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt issuer="https://kubernetes.default.svc.cluster.local"'
	@kubectl exec vault-0 -- sh -c 'vault write auth/kubernetes/config kubernetes_host="https://10.96.0.1:443" token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt issuer="https://kubernetes.default.svc.cluster.local"'
	@kubectl exec vault-0 -- vault read auth/kubernetes/config
	@echo "...Done 🏁"

write-vault-policy:
	@echo "Writing Vault Policies..."
	@kubectl cp ./manifests/vault/internal-app-policy.hcl vault-0:/vault/
	@kubectl exec vault-0 -- vault policy write internal-app /vault/internal-app-policy.hcl
	@kubectl exec vault-0 -- vault policy read internal-app
	@echo "...Done 🏁"

set-k8s-auth-role:
	@echo "Setting kubernetes auth role in Vault..."
	@kubectl exec vault-0 -- vault write auth/kubernetes/role/internal-app \
    	bound_service_account_names=internal-app \
    	bound_service_account_namespaces=demo \
    	policies=internal-app \
    	ttl=1h
	@kubectl exec vault-0 -- vault read auth/kubernetes/role/internal-app
	@echo "...Done 🏁"

#----------------------------
# Application Config Steps
#----------------------------

create-k8s-service-account:
	@echo "Creating kubernetes Service Account..."
	@kubectl create sa internal-app
	@echo "...Done 🏁"

apply-k8s-deployment:
	@echo "Applying kubernetes Deployment..."
	@kubectl apply -f ./manifests/application/deployment.yaml
	@echo "...Done 🏁"
