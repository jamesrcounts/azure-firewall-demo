default: plan

init:
	terraform init --upgrade
	terraform -v
	terraform providers

fmt:
	cd .. && terraform fmt -recursive
	
validate:
	terraform validate

plan: init fmt validate
	terraform plan -out plan.tfplan
	
apply:
	terraform apply plan.tfplan
	rm plan.tfplan
	
clean:
	terraform destroy -auto-approve