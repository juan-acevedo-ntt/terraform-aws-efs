SHELL := bash

all: test-all

PHONY += test-all
test-all: validate test-unit test-integration

PHONY += azlogin
azlogin:
	@az login --service-principal -u $(ARM_CLIENT_ID) -p $(ARM_CLIENT_SECRET) --tenant $(ARM_TENANT_ID)

PHONY += validate
validate:
	terraform init && terraform validate

# NOTE: This target requires wata727/tflint Docker image
PHONY += lint
lint:
	tflint

PHONY += format-check
format-check:
	terraform fmt -recursive -check
	@test -z "$(shell gofmt -l test)" || { echo "Wrong format. Please execute: make format"; exit 1; }

# Run unit and integration tests using Terratest
#
# NOTE: These targets require the terraform-test Docker image
PHONY += test-unit
test-unit: clean format
	cd test && go test -run TestUT_*

PHONY += test-integration
test-integration: clean format
	cd test && go test -timeout 1800s -run TestExamplesComplete

PHONY += format
format:
	terraform fmt -recursive
	go fmt ./test/...

PHONY += clean
clean:
	rm -rf vendor .terraform terraform.tfplan terraform.tfstate*

PHONY += clean-all
clean-all: destroy-examples clean
	cd test/fixture && rm -rf vendor .terraform terraform.tfplan terraform.tfstate*

.PHONY: $(PHONY)
