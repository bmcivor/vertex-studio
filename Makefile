.PHONY: help build ping bootstrap bootstrap-verbose clean

help:
	@echo "Available targets:"
	@echo "  make build             - Build Ansible Docker container"
	@echo "  make ping              - Test connection to lab machine"
	@echo "  make bootstrap         - Run bootstrap playbook"
	@echo "  make bootstrap-verbose - Run bootstrap playbook with verbose output"
	@echo "  make clean             - Remove Docker containers and images"

build:
	docker-compose build

ping:
	docker-compose run --rm ansible "ansible all -m ping"

bootstrap:
	docker-compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml"

bootstrap-verbose:
	docker-compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml -vv"

clean:
	@if docker-compose ps -q 2>/dev/null | grep -q .; then \
		docker-compose down; \
		docker-compose rm -f; \
	else \
		echo "No containers to clean" >&2; \
	fi
