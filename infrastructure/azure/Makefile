default: plan

CONFIG := terraform.auto.tfvars

backend_instance_id := obliging-primate
env_subscription_id := bbb80ca8-cf8a-4d13-8fa4-6027d7e5b71d
env_instance_id     := climbing-weevil

${HOME}/.terraformrc:
	az keyvault secret download \
		--name terraformrc \
		--vault-name kv-$(backend_instance_id) \
		--file ${HOME}/.terraformrc

$(CONFIG):
	# TODO: this could also be loaded from keyvault
	@echo 'env_instance_id="$(env_instance_id)"'   > $(CONFIG)
	@echo 'env_subscription_id="$(env_subscription_id)"' >> $(CONFIG)

fmt:
	terraform fmt -recursive

.terraform: ${HOME}/.terraformrc
	terraform init --upgrade
	
clean:
	terraform destroy -auto-approve
	
validate:
	terraform validate

plan: .terraform $(CONFIG) fmt validate
	terraform plan -out plan.tfplan
	
apply:
	terraform apply plan.tfplan
	rm plan.tfplan

login:
	az login --use-device-code
	az account set --subscription "Jim Counts (paygo)"
	az account show --output table