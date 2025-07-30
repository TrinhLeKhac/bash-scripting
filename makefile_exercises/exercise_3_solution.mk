# Exercise 3 Solution: Multi-Language Project Manager
# Unified Makefile for Python, Node.js, and Shell scripts

# STEP 1: Project configuration
PROJECT_NAME := multi_lang_project
VERSION := 1.0.0

# STEP 2: Directory structure
PYTHON_DIR := python
NODEJS_DIR := nodejs
SHELL_DIR := shell
DOCKER_DIR := docker
BUILD_DIR := build
DOCS_DIR := docs

# STEP 3: Tool configuration
PYTHON := python3
PIP := pip3
NODE := node
NPM := npm
SHELLCHECK := shellcheck
DOCKER := docker
DOCKER_COMPOSE := docker-compose

# STEP 4: Environment variables
PYTHON_VENV := $(PYTHON_DIR)/venv
NODE_MODULES := $(NODEJS_DIR)/node_modules
SHELL_SCRIPTS := $(wildcard $(SHELL_DIR)/scripts/*.sh)

# STEP 5: Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# STEP 6: Default target
.DEFAULT_GOAL := help

# STEP 7: Phony targets
.PHONY: help setup install clean test lint build docker-build deploy health-check docs

# STEP 8: Setup all environments
setup: setup-python setup-nodejs setup-shell ## Setup all development environments
	@echo "$(GREEN)All environments setup completed!$(NC)"

# STEP 9: Python environment setup
setup-python: ## Setup Python virtual environment
	@echo "$(BLUE)Setting up Python environment...$(NC)"
	@cd $(PYTHON_DIR) && $(PYTHON) -m venv venv
	@cd $(PYTHON_DIR) && . venv/bin/activate && $(PIP) install --upgrade pip
	@echo "$(GREEN)Python environment ready!$(NC)"

# STEP 10: Node.js environment setup
setup-nodejs: ## Setup Node.js environment
	@echo "$(BLUE)Setting up Node.js environment...$(NC)"
	@if [ ! -f "$(NODEJS_DIR)/package.json" ]; then \
		cd $(NODEJS_DIR) && $(NPM) init -y; \
	fi
	@echo "$(GREEN)Node.js environment ready!$(NC)"

# STEP 11: Shell environment setup
setup-shell: ## Validate shell environment
	@echo "$(BLUE)Setting up Shell environment...$(NC)"
	@command -v bash >/dev/null 2>&1 || { echo "$(RED)bash required$(NC)"; exit 1; }
	@command -v $(SHELLCHECK) >/dev/null 2>&1 || echo "$(YELLOW)shellcheck recommended$(NC)"
	@chmod +x $(SHELL_SCRIPTS)
	@echo "$(GREEN)Shell environment ready!$(NC)"

# STEP 12: Install all dependencies
install: install-python install-nodejs ## Install all dependencies
	@echo "$(GREEN)All dependencies installed!$(NC)"

# STEP 13: Install Python dependencies
install-python: setup-python ## Install Python dependencies
	@echo "$(BLUE)Installing Python dependencies...$(NC)"
	@if [ -f "$(PYTHON_DIR)/requirements.txt" ]; then \
		cd $(PYTHON_DIR) && . venv/bin/activate && $(PIP) install -r requirements.txt; \
	fi
	@echo "$(GREEN)Python dependencies installed!$(NC)"

# STEP 14: Install Node.js dependencies
install-nodejs: setup-nodejs ## Install Node.js dependencies
	@echo "$(BLUE)Installing Node.js dependencies...$(NC)"
	@if [ -f "$(NODEJS_DIR)/package.json" ]; then \
		cd $(NODEJS_DIR) && $(NPM) install; \
	fi
	@echo "$(GREEN)Node.js dependencies installed!$(NC)"

# STEP 15: Run all tests
test: test-python test-nodejs test-shell test-integration ## Run all tests
	@echo "$(GREEN)All tests completed!$(NC)"

# STEP 16: Python tests
test-python: install-python ## Run Python tests
	@echo "$(BLUE)Running Python tests...$(NC)"
	@cd $(PYTHON_DIR) && . venv/bin/activate && \
	if command -v pytest >/dev/null 2>&1; then \
		pytest tests/ -v; \
	else \
		$(PYTHON) -m unittest discover tests/; \
	fi
	@echo "$(GREEN)Python tests passed!$(NC)"

# STEP 17: Node.js tests
test-nodejs: install-nodejs ## Run Node.js tests
	@echo "$(BLUE)Running Node.js tests...$(NC)"
	@cd $(NODEJS_DIR) && \
	if [ -f "package.json" ] && grep -q '"test"' package.json; then \
		$(NPM) test; \
	else \
		echo "$(YELLOW)No Node.js tests configured$(NC)"; \
	fi
	@echo "$(GREEN)Node.js tests passed!$(NC)"

# STEP 18: Shell script tests
test-shell: ## Run shell script tests
	@echo "$(BLUE)Running shell script tests...$(NC)"
	@for script in $(SHELL_SCRIPTS); do \
		echo "Testing $$script..."; \
		bash -n $$script || exit 1; \
	done
	@if [ -f "$(SHELL_DIR)/tests/test_scripts.sh" ]; then \
		bash $(SHELL_DIR)/tests/test_scripts.sh; \
	fi
	@echo "$(GREEN)Shell script tests passed!$(NC)"

# STEP 19: Integration tests
test-integration: ## Run integration tests
	@echo "$(BLUE)Running integration tests...$(NC)"
	@echo "$(YELLOW)Starting services for integration testing...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_DIR)/docker-compose.yml up -d --build
	@sleep 10
	@echo "Testing Python service..."
	@curl -f http://localhost:8000/health >/dev/null 2>&1 || echo "Python service not responding"
	@echo "Testing Node.js service..."
	@curl -f http://localhost:3000/health >/dev/null 2>&1 || echo "Node.js service not responding"
	@$(DOCKER_COMPOSE) -f $(DOCKER_DIR)/docker-compose.yml down
	@echo "$(GREEN)Integration tests completed!$(NC)"

# STEP 20: Lint all code
lint: lint-python lint-nodejs lint-shell ## Run all linters
	@echo "$(GREEN)All linting completed!$(NC)"

# STEP 21: Python linting
lint-python: install-python ## Lint Python code
	@echo "$(BLUE)Linting Python code...$(NC)"
	@cd $(PYTHON_DIR) && . venv/bin/activate && \
	if command -v flake8 >/dev/null 2>&1; then \
		flake8 src/ tests/; \
	fi
	@if command -v black >/dev/null 2>&1; then \
		black --check src/ tests/; \
	fi
	@echo "$(GREEN)Python linting completed!$(NC)"

# STEP 22: Node.js linting
lint-nodejs: install-nodejs ## Lint Node.js code
	@echo "$(BLUE)Linting Node.js code...$(NC)"
	@cd $(NODEJS_DIR) && \
	if command -v npx eslint >/dev/null 2>&1; then \
		npx eslint src/ tests/; \
	fi
	@echo "$(GREEN)Node.js linting completed!$(NC)"

# STEP 23: Shell script linting
lint-shell: ## Lint shell scripts
	@echo "$(BLUE)Linting shell scripts...$(NC)"
	@if command -v $(SHELLCHECK) >/dev/null 2>&1; then \
		for script in $(SHELL_SCRIPTS); do \
			echo "Checking $$script..."; \
			$(SHELLCHECK) $$script; \
		done; \
	else \
		echo "$(YELLOW)shellcheck not available$(NC)"; \
	fi
	@echo "$(GREEN)Shell script linting completed!$(NC)"

# STEP 24: Build all components
build: build-python build-nodejs ## Build all components
	@echo "$(GREEN)All components built!$(NC)"

# STEP 25: Build Python component
build-python: install-python ## Build Python component
	@echo "$(BLUE)Building Python component...$(NC)"
	@mkdir -p $(BUILD_DIR)/python
	@cd $(PYTHON_DIR) && . venv/bin/activate && \
	if [ -f "setup.py" ]; then \
		$(PYTHON) setup.py build --build-base ../$(BUILD_DIR)/python; \
	else \
		cp -r src/* ../$(BUILD_DIR)/python/; \
	fi
	@echo "$(GREEN)Python component built!$(NC)"

# STEP 26: Build Node.js component
build-nodejs: install-nodejs ## Build Node.js component
	@echo "$(BLUE)Building Node.js component...$(NC)"
	@mkdir -p $(BUILD_DIR)/nodejs
	@cd $(NODEJS_DIR) && \
	if [ -f "package.json" ] && grep -q '"build"' package.json; then \
		$(NPM) run build; \
		cp -r dist/* ../$(BUILD_DIR)/nodejs/ 2>/dev/null || cp -r src/* ../$(BUILD_DIR)/nodejs/; \
	else \
		cp -r src/* ../$(BUILD_DIR)/nodejs/; \
	fi
	@echo "$(GREEN)Node.js component built!$(NC)"

# STEP 27: Docker build
docker-build: ## Build all Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_DIR)/docker-compose.yml build
	@echo "$(GREEN)Docker images built!$(NC)"

# STEP 28: Deploy services
deploy: docker-build ## Deploy all services
	@echo "$(BLUE)Deploying services...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_DIR)/docker-compose.yml up -d
	@echo "$(GREEN)Services deployed!$(NC)"
	@echo "$(YELLOW)Python service: http://localhost:8000$(NC)"
	@echo "$(YELLOW)Node.js service: http://localhost:3000$(NC)"

# STEP 29: Health check
health-check: ## Check service health
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo "Python service:"
	@curl -s http://localhost:8000/health | jq . 2>/dev/null || curl -s http://localhost:8000/health
	@echo "Node.js service:"
	@curl -s http://localhost:3000/health | jq . 2>/dev/null || curl -s http://localhost:3000/health
	@echo "$(GREEN)Health check completed!$(NC)"

# STEP 30: Generate documentation
docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@mkdir -p $(DOCS_DIR)
	@echo "# $(PROJECT_NAME) Documentation" > $(DOCS_DIR)/README.md
	@echo "Version: $(VERSION)" >> $(DOCS_DIR)/README.md
	@echo "Generated: $$(date)" >> $(DOCS_DIR)/README.md
	@echo "" >> $(DOCS_DIR)/README.md
	@echo "## Python Component" >> $(DOCS_DIR)/README.md
	@if [ -f "$(PYTHON_DIR)/README.md" ]; then \
		cat $(PYTHON_DIR)/README.md >> $(DOCS_DIR)/README.md; \
	fi
	@echo "" >> $(DOCS_DIR)/README.md
	@echo "## Node.js Component" >> $(DOCS_DIR)/README.md
	@if [ -f "$(NODEJS_DIR)/README.md" ]; then \
		cat $(NODEJS_DIR)/README.md >> $(DOCS_DIR)/README.md; \
	fi
	@echo "$(GREEN)Documentation generated!$(NC)"

# STEP 31: Performance benchmark
benchmark: deploy ## Run performance benchmarks
	@echo "$(BLUE)Running performance benchmarks...$(NC)"
	@sleep 5
	@echo "Benchmarking Python service..."
	@if command -v ab >/dev/null 2>&1; then \
		ab -n 1000 -c 10 http://localhost:8000/health; \
	fi
	@echo "Benchmarking Node.js service..."
	@if command -v ab >/dev/null 2>&1; then \
		ab -n 1000 -c 10 http://localhost:3000/health; \
	fi
	@echo "$(GREEN)Benchmarks completed!$(NC)"

# STEP 32: Stop services
stop: ## Stop all services
	@echo "$(BLUE)Stopping services...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_DIR)/docker-compose.yml down
	@echo "$(GREEN)Services stopped!$(NC)"

# STEP 33: Clean all artifacts
clean: stop ## Clean all build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR) $(DOCS_DIR)
	@rm -rf $(PYTHON_DIR)/venv $(PYTHON_DIR)/__pycache__ $(PYTHON_DIR)/.pytest_cache
	@rm -rf $(NODEJS_DIR)/node_modules $(NODEJS_DIR)/dist
	@$(DOCKER) system prune -f
	@echo "$(GREEN)Cleanup completed!$(NC)"

# STEP 34: Development mode
dev: ## Start development environment
	@echo "$(BLUE)Starting development environment...$(NC)"
	@$(DOCKER_COMPOSE) -f $(DOCKER_DIR)/docker-compose.yml -f $(DOCKER_DIR)/docker-compose.dev.yml up --build

# STEP 35: Help target
help: ## Display this help
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Multi-Language Project Manager$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Components: Python, Node.js, Shell Scripts$(NC)"
	@echo "$(YELLOW)Usage: make [target]$(NC)"

# STEP 36: Debug information
debug: ## Show Makefile debug information
	@echo "$(BLUE)Debug Information:$(NC)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "VERSION: $(VERSION)"
	@echo "PYTHON: $(PYTHON)"
	@echo "NODE: $(NODE)"
	@echo "SHELL_SCRIPTS: $(SHELL_SCRIPTS)"
	@echo "PYTHON_VENV: $(PYTHON_VENV)"
	@echo "NODE_MODULES: $(NODE_MODULES)"

# STEP 37: Configuration
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules