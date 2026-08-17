.PHONY: help check-docker check-bump2version build ping bootstrap bootstrap-verbose lab taiga mkdocs tailscale nvidia nvidia-container stable-diffusion ollama grafana prometheus loki registry jenkins minecraft-bedrock minecraft-bedrock-destroy clean reboot shutdown bump-patch bump-minor bump-major install uninstall

PREFIX ?= $(HOME)/.local
bindir := $(PREFIX)/bin
ROOT := $(abspath $(CURDIR))

# Do not echo recipe lines before running (docker-compose, bump2version, etc.).
.SILENT:

help:
	@echo "Available targets:"
	@echo "  make build                     - Build Ansible Docker container"
	@echo "  make ping                      - Test connection to lab machine"
	@echo "  make bootstrap                 - Run bootstrap playbook"
	@echo "  make bootstrap-verbose         - Run bootstrap playbook with verbose output"
	@echo "  make lab                       - Deploy complete platform (bootstrap + all apps)"
	@echo "  make taiga                     - Deploy Taiga project management"
	@echo "  make mkdocs                    - Deploy MkDocs documentation"
	@echo "  make tailscale                 - Install Tailscale VPN"
	@echo "  make nvidia                    - Install NVIDIA drivers and CUDA"
	@echo "  make nvidia-container          - Install NVIDIA container toolkit for Docker GPU"
	@echo "  make stable-diffusion          - Deploy Stable Diffusion WebUI with SDXL"
	@echo "  make ollama                    - Install Ollama and pull LLaVA model"
	@echo "  make grafana                   - Deploy Grafana monitoring dashboard"
	@echo "  make prometheus                - Deploy Prometheus and cAdvisor for metrics"
	@echo "  make loki                      - Deploy Loki and Promtail for log collection"
	@echo "  make registry                  - Deploy Docker Registry and UI"
	@echo "  make jenkins                   - Deploy Jenkins CI server"
	@echo "  make minecraft-bedrock         - Deploy Minecraft Bedrock server"
	@echo "  make minecraft-bedrock-destroy - Destroy Minecraft Bedrock server"
	@echo "  make clean                     - Remove Docker containers and images"
	@echo "  make reboot                    - Reboot the lab machine"
	@echo "  make shutdown                  - Shutdown the lab machine"
	@echo "  make bump-patch                - Bump patch version (0.1.0 -> 0.1.1)"
	@echo "  make bump-minor                - Bump minor version (0.1.0 -> 0.2.0)"
	@echo "  make bump-major                - Bump major version (0.1.0 -> 1.0.0)"
	@echo "  make install                   - Install vertex-studio CLI (PREFIX=$(HOME)/.local, override PREFIX/DESTDIR)"
	@echo "  make uninstall                 - Remove installed vertex-studio (same PREFIX/DESTDIR as install)"

check-docker:
	@docker info > /dev/null 2>&1 || (echo "Docker is not running. Please start Docker and try again." && exit 1)

check-bump2version:
	@command -v bump2version > /dev/null 2>&1 || (echo "bump2version is not installed. Run: pipx install bump2version" && exit 1)

build: check-docker
	docker compose build

ping: check-docker
	docker compose run --rm ansible "ansible all -m ping"

bootstrap: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml"

bootstrap-verbose: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/bootstrap.yaml -vv"

lab: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/lab.yaml"

taiga: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/taiga.yaml"

mkdocs: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/mkdocs.yaml"

tailscale: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/tailscale.yaml"

nvidia: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/nvidia.yaml"

nvidia-container: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/nvidia-container.yaml"

stable-diffusion: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/stable-diffusion.yaml"

ollama: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/ollama.yaml"

grafana: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/grafana.yaml"

prometheus: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/prometheus.yaml"

loki: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/loki.yaml"

registry: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/registry.yaml"

jenkins: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/jenkins.yaml"

minecraft-bedrock: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/minecraft-bedrock.yaml -e minecraft_bedrock_destroy=false"

minecraft-bedrock-destroy: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/minecraft-bedrock.yaml -e minecraft_bedrock_destroy=true"

clean: check-docker
	docker compose down --rmi local --remove-orphans

reboot: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/power.yaml -e power_state=reboot"

shutdown: check-docker
	docker compose run --rm ansible "ansible-playbook playbooks/power.yaml -e power_state=shutdown"

bump-patch: check-bump2version
	bump2version patch

bump-minor: check-bump2version
	bump2version minor

bump-major: check-bump2version
	bump2version major

install:
	@install -d "$(DESTDIR)$(bindir)"
	@tmp="$$(mktemp)"; \
		trap 'rm -f "$$tmp"' EXIT; \
		sed 's|@ROOT@|$(ROOT)|g' bin/vertex-studio.in > "$$tmp" && \
		install -m 755 "$$tmp" "$(DESTDIR)$(bindir)/vertex-studio"
	@echo "Installed $(DESTDIR)$(bindir)/vertex-studio (ROOT=$(ROOT))"
	@if [ -z "$(DESTDIR)" ]; then \
		case ":$$PATH:" in *:"$(bindir)":*) ;; *) \
			echo ""; \
			echo "Note: $(bindir) is not on PATH. Example:" >&2; \
			echo "  export PATH=\"$(bindir):$$PATH\"" >&2; \
		;; esac; \
	fi

uninstall:
	@rm -f "$(DESTDIR)$(bindir)/vertex-studio"
	@echo "Removed $(DESTDIR)$(bindir)/vertex-studio (if it existed)"
