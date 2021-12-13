default: apply

CONFIG := terraform.auto.tfvars

env_subscription_id := bbb80ca8-cf8a-4d13-8fa4-6027d7e5b71d
env_instance_id     := climbing-weevil

$(CONFIG):
	# TODO: this could also be loaded from keyvault
	@echo 'env_instance_id="$(env_instance_id)"'   > $(CONFIG)
	@echo 'env_subscription_id="$(env_subscription_id)"' >> $(CONFIG)

fmt:
	terraform fmt -recursive

init:
	terraform init --upgrade
	
clean:
	terraform destroy -auto-approve

connect:
	terraform init -get=false
	
validate:
	terraform validate

apply: $(CONFIG) fmt connect validate
	terraform apply

login:
	az login --use-device-code
	az account set --subscription "Jim Counts (paygo)"
	az account show --output table