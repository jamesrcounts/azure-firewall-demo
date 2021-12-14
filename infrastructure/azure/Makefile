default: plan

CONFIG := terraform.auto.tfvars

ops_instance_id     := obliging-primate
env_subscription_id := bbb80ca8-cf8a-4d13-8fa4-6027d7e5b71d
env_instance_id     := climbing-weevil

${HOME}/.terraformrc:
	az keyvault secret download \
		--name terraformrc \
		--vault-name kv-$(ops_instance_id)     \
		--file ${HOME}/.terraformrc

$(CONFIG):
	# TODO: this could also be loaded from keyvault
	@echo 'env_instance_id="$(env_instance_id)"'          > $(CONFIG)
	@echo 'ops_instance_id="$(ops_instance_id)"'         >> $(CONFIG)
	@echo 'env_subscription_id="$(env_subscription_id)"' >> $(CONFIG)

terraform.backend.tfvars:
	az keyvault secret download \
		--name backend-config \
		--vault-name kv-$(ops_instance_id)     \
		--file terraform.backend.tfvars

fmt:
	terraform fmt -recursive

init: ${HOME}/.terraformrc terraform.backend.tfvars
	terraform init --upgrade -backend-config terraform.backend.tfvars
	terraform -v
	terraform providers
	
clean:
	terraform destroy -auto-approve
	
validate:
	terraform validate

plan: init $(CONFIG) fmt validate
	terraform plan -out plan.tfplan
	
apply:
	terraform apply plan.tfplan
	rm plan.tfplan

login:
	az login --use-device-code
	az account set --subscription "Jim Counts (VS)"
	az account show --output table