# Python Build Tools Exercise - Unified Makefile
# Demonstrates various Python packaging and build systems

# Project configuration
PROJECT_NAME := python_build_demo
VERSION := 1.0.0

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Tools
PYTHON := python3
PIP := pip3

.DEFAULT_GOAL := help
.PHONY: help setup-all build-all test-all package-all clean-all

help: ## Display this help
	@echo "$(BLUE)Python Build Tools Exercise$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Setup all build environments
setup-all: setup-setuptools setup-poetry setup-hatch setup-pdm setup-flit setup-pipenv ## Setup all build tools
	@echo "$(GREEN)All build environments setup completed!$(NC)"

setup-setuptools: ## Setup setuptools project
	@echo "$(BLUE)Setting up setuptools project...$(NC)"
	@cd setuptools_project && $(PYTHON) -m venv venv
	@cd setuptools_project && . venv/bin/activate && pip install --upgrade pip setuptools wheel pip-tools

setup-poetry: ## Setup Poetry project
	@echo "$(BLUE)Setting up Poetry project...$(NC)"
	@if ! command -v poetry >/dev/null 2>&1; then \
		curl -sSL https://install.python-poetry.org | python3 -; \
	fi
	@cd poetry_project && poetry install

setup-hatch: ## Setup Hatch project
	@echo "$(BLUE)Setting up Hatch project...$(NC)"
	@pip install hatch
	@cd hatch_project && hatch env create

setup-pdm: ## Setup PDM project
	@echo "$(BLUE)Setting up PDM project...$(NC)"
	@pip install pdm
	@cd pdm_project && pdm install

setup-flit: ## Setup Flit project
	@echo "$(BLUE)Setting up Flit project...$(NC)"
	@pip install flit
	@cd flit_project && flit install --symlink

setup-pipenv: ## Setup Pipenv project
	@echo "$(BLUE)Setting up Pipenv project...$(NC)"
	@pip install pipenv
	@cd pipenv_project && pipenv install --dev

# Build all projects
build-all: build-setuptools build-poetry build-hatch build-pdm build-flit ## Build all projects
	@echo "$(GREEN)All projects built successfully!$(NC)"

build-setuptools: ## Build setuptools project
	@echo "$(BLUE)Building setuptools project...$(NC)"
	@cd setuptools_project && . venv/bin/activate && python setup.py sdist bdist_wheel

build-poetry: ## Build Poetry project
	@echo "$(BLUE)Building Poetry project...$(NC)"
	@cd poetry_project && poetry build

build-hatch: ## Build Hatch project
	@echo "$(BLUE)Building Hatch project...$(NC)"
	@cd hatch_project && hatch build

build-pdm: ## Build PDM project
	@echo "$(BLUE)Building PDM project...$(NC)"
	@cd pdm_project && pdm build

build-flit: ## Build Flit project
	@echo "$(BLUE)Building Flit project...$(NC)"
	@cd flit_project && flit build

# Test all projects
test-all: test-setuptools test-poetry test-hatch test-pdm ## Test all projects
	@echo "$(GREEN)All tests completed!$(NC)"

test-setuptools: ## Test setuptools project
	@echo "$(BLUE)Testing setuptools project...$(NC)"
	@cd setuptools_project && . venv/bin/activate && python -m pytest tests/

test-poetry: ## Test Poetry project
	@echo "$(BLUE)Testing Poetry project...$(NC)"
	@cd poetry_project && poetry run pytest

test-hatch: ## Test Hatch project
	@echo "$(BLUE)Testing Hatch project...$(NC)"
	@cd hatch_project && hatch run test

test-pdm: ## Test PDM project
	@echo "$(BLUE)Testing PDM project...$(NC)"
	@cd pdm_project && pdm run pytest

# Package for distribution
package-all: package-wheels package-docker package-executable ## Create all package formats
	@echo "$(GREEN)All packages created!$(NC)"

package-wheels: build-all ## Create wheel packages
	@echo "$(BLUE)Creating wheel packages...$(NC)"
	@mkdir -p wheel_builds/dist
	@find . -name "*.whl" -exec cp {} wheel_builds/dist/ \;

package-docker: ## Create Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	@cd docker_builds && docker build -t $(PROJECT_NAME):$(VERSION) .

package-executable: ## Create standalone executables
	@echo "$(BLUE)Creating executables with PyInstaller...$(NC)"
	@cd pyinstaller_builds && pyinstaller --onefile app.py

# Clean all builds
clean-all: clean-setuptools clean-poetry clean-hatch clean-pdm clean-builds ## Clean all build artifacts
	@echo "$(GREEN)All builds cleaned!$(NC)"

clean-setuptools: ## Clean setuptools build
	@cd setuptools_project && rm -rf build/ dist/ *.egg-info/ venv/

clean-poetry: ## Clean Poetry build
	@cd poetry_project && poetry env remove --all && rm -rf dist/

clean-hatch: ## Clean Hatch build
	@cd hatch_project && hatch env prune && rm -rf dist/

clean-pdm: ## Clean PDM build
	@cd pdm_project && rm -rf __pypackages__/ dist/

clean-builds: ## Clean package builds
	@rm -rf wheel_builds/dist/ pyinstaller_builds/dist/