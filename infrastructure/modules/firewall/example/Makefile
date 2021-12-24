default: plan

fmt:
	cd .. && terraform fmt -recursive

init:
	terraform init --upgrade 
	terraform -v
	terraform providers
	
clean:
	terraform destroy -auto-approve
	rm terraform.backend.tfvars
	
validate:
	terraform validate

plan: init fmt validate
	terraform plan -out plan.tfplan
	
apply:
	terraform apply plan.tfplan
	rm plan.tfplan

login:
	az login --use-device-code
	az account set --subscription "Jim Counts (VS)"
	az account show --output table