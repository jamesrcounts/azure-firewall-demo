default: plan

CONFIG := terraform.auto.tfvars

ops_instance_id     := obliging-primate
env_subscription_id := bbb80ca8-cf8a-4d13-8fa4-6027d7e5b71d
env_instance_id     := climbing-weevil

$(CONFIG):
	# TODO: this could also be loaded from keyvault
	@echo 'env_instance_id="$(env_instance_id)"'          > $(CONFIG)
	@echo 'ops_instance_id="$(ops_instance_id)"'         >> $(CONFIG)
	@echo 'env_subscription_id="$(env_subscription_id)"' >> $(CONFIG)

fmt:
	cd .. && terraform fmt -recursive

init: ${HOME}/.terraformrc
	terraform init --upgrade 
	terraform -v
	terraform providers
	
clean:
	terraform destroy -auto-approve
	rm terraform.backend.tfvars
	
validate:
	terraform validate

plan: init $(CERTS) fmt validate
	terraform plan -out plan.tfplan
	
apply:
	terraform apply plan.tfplan
	rm plan.tfplan

login:
	az login --use-device-code
	az account set --subscription "Jim Counts (VS)"
	az account show --output table