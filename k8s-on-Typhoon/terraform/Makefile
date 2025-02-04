#!/usr/bin/env make
# vim: tabstop=8 noexpandtab
# SHELL += -xue

.PHONY: all tf-init tf-plan tf-build tf-destroy help

# Variables
env ?= local  # Default environment, can be overridden from the command line

# If an environment is provided as the second argument, override the default
ENV_ARG = $(word 2, $(MAKECMDGOALS))
ifneq ($(ENV_ARG),)
    env := $(ENV_ARG)
endif

# Prevent `make` from treating the second argument as a target
$(ENV_ARG):
	@:


# Default target
all: help

help:
	@echo "Available commands:"
	@echo "  make tf-init [env]    - Initialize the Terraform environment for a specific environment (e.g., dev, prod, sandbox)"
	@echo "  make tf-plan [env]    - Generate and save a Terraform execution plan for a specific environment"
	@echo "  make tf-build         - Apply the Terraform plan to build the infrastructure"
	@echo "  make tf-destroy       - Destroy the Terraform-managed infrastructure"
	@echo "  env=<environment>     - (Optional) Override the environment to use a different backend config"
	@echo "  TFVARS_FILE=<file>    - (Optional) Override the default .tfvars file used in plan/build/destroy"
	@echo
	@echo "Examples:"
	@echo "  make tf-init sandbox"
	@echo "  make tf-plan sandbox"
	@echo "  make tf-plan ENV=prod"

# Initialize terraform if not already done
tf-init:
	@if [ ! -d '.terraform' ]; then \
		printf '\n%s\n' 'Initializing the Terraform environment for $(env)...'; \
		if [ ! -f ./backends/$(env).backend ]; then \
			printf '\n%s\n' 'Backend config ./backends/$(env).backend not found!'; \
			exit 1; \
		fi; \
		terraform init -get=true -backend-config=./backends/$(env).backend; \
	else \
		printf '\n%s\n' 'Terraform is already initialized. Updating providers...'; \
		terraform init -upgrade -get=true -backend-config=./backends/$(env).backend; \
	fi

# Create a Terraform plan with an optional tfvars file
tf-plan:
	@printf '\n%s\n' "Generating Terraform plan for environment $(env) using $(env)..."
	terraform plan -var-file=$(env).tfvars -out=$(env).plan

# Apply the Terraform plan to build the infrastructure
tf-build:
	@printf '\n%s\n' "Applying the Terraform plan..."
	terraform apply $(env).plan

# Destroy the infrastructure with the option to pass a tfvars file
tf-destroy:
	@printf '\n%s\n' "Destroying infrastructure using $(env)..."
	terraform apply -var-file=$(env).tfvars -auto-approve -destroy

