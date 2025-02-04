#!/usr/bin/env make
# vim: tabstop=8 noexpandtab
#SHELL += -xue

.PHONY: all tf-init tf-plan tf-build help

# Default target
all: help

help:
	@echo "Available commands:"
	@echo "  make tf-init  - Initialize the Terraform environment if not already done"
	@echo "  make tf-plan  - Generate and save a Terraform execution plan"
	@echo "  make tf-build - Apply the Terraform plan to build the infrastructure"

tf-init:
	if [ ! -d '.terraform' ]; then \
		printf '\n%s\n' 'Initializing the build...'; \
		terraform init -get=true; \
	else \
		printf '\n%s\n\n' '  Dude, already initialized!'; \
	fi

tf-plan:
	terraform plan  \
		-out=kubes.plan 

tf-build:
	terraform apply kubes.plan

tf-destroy:
	terraform apply  -auto-approve -destroy