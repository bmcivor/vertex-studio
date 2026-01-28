.PHONY: help check-docker build ping bootstrap bootstrap-verbose lab taiga mkdocs tailscale clean bump-patch bump-minor bump-major

help:
	@echo "Available targets:"
	@echo "  make build             - Build Ansible Docker container"
	@echo "  make ping              - Test connection to lab machine"
	@echo "  make bootstrap         - Run bootstrap playbook"
	@echo "  make bootstrap-verbose - Run bootstrap playbook with verbose output"
	@echo "  make lab               - Deploy complete platform (bootstrap + all apps)"
	@echo "  make taiga             - Deploy Taiga project management"
	@echo "  make mkdocs            - Deploy MkDocs documentation"
	@echo "  make tailscale         - Install Tailscale VPN"
	@echo "  make clean             - Remove Docker containers and images"
	@echo "  make bump-patch        - Bump patch version (0.1.0 -> 0.1.1)"
	@echo "  make bump-minor        - Bump minor version (0.1.0 -> 0.2.0)"
	@echo "  make bump-major        - Bump major version (0.1.0 -> 1.0.0)"

check-docker:
	@docker info > /dev/null 2>&1 || (echo "Docker is not running. Please start Docker and try again." && exit 1)

build: check-docker
	docker-compose build

ping: check-docker
	docker-compose run --rm ansible "ansible all -m ping"

bootstrap: check-docker
	docker-compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml"

bootstrap-verbose: check-docker
	docker-compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml -vv"

lab: check-docker
	docker-compose run --rm ansible "ansible-playbook playbooks/lab.yaml"

taiga: check-docker
	docker-compose run --rm ansible "ansible-playbook playbooks/taiga.yaml"

mkdocs: check-docker
	docker-compose run --rm ansible "ansible-playbook playbooks/mkdocs.yaml"

tailscale: check-docker
	docker-compose run --rm ansible "ansible-playbook playbooks/tailscale.yaml"

clean:
	@if docker-compose ps -q 2>/dev/null | grep -q .; then \
		docker-compose down; \
		docker-compose rm -f; \
	else \
		echo "No containers to clean" >&2; \
	fi

bump-patch:
	bump2version patch

bump-minor:
	bump2version minor

bump-major:
	bump2version major
