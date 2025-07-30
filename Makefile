# Advanced Makefile for Bash Scripting Project
# This Makefile demonstrates comprehensive build automation concepts

# STEP 1: Define variables for configuration
# Project configuration variables
PROJECT_NAME := bash_scripting_project
VERSION := 1.0.0
BUILD_DIR := build
DIST_DIR := dist
SRC_DIR := scripts
TEST_DIR := tests
DOC_DIR := docs

# STEP 2: Compiler and tool configurations
# Shell and interpreter settings
SHELL := /bin/bash
PYTHON := python3
PIP := pip3
SHELLCHECK := shellcheck

# STEP 3: Color definitions for output formatting
# ANSI color codes for better output visibility
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# STEP 4: Environment detection
# Detect operating system for cross-platform compatibility
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    OS := linux
    SED := sed -i
endif
ifeq ($(UNAME_S),Darwin)
    OS := macos
    SED := sed -i ''
endif

# STEP 5: File discovery using wildcard functions
# Automatically find source files
SHELL_SCRIPTS := $(wildcard $(SRC_DIR)/*.sh)
PYTHON_SCRIPTS := $(wildcard $(SRC_DIR)/*.py)
TEST_SCRIPTS := $(wildcard $(TEST_DIR)/*.sh)

# STEP 6: Derived file lists for build targets
# Generate lists of compiled/processed files
CHECKED_SCRIPTS := $(SHELL_SCRIPTS:.sh=.checked)
FORMATTED_SCRIPTS := $(SHELL_SCRIPTS:.sh=.formatted)

# STEP 7: Default target (first target in Makefile)
# Default action when running 'make' without arguments
.DEFAULT_GOAL := help

# STEP 8: Phony targets declaration
# Declare targets that don't create files with the same name
.PHONY: help clean build test lint format install deploy docs \
        setup-dev check-deps validate package release \
        docker-build docker-run benchmark profile

# STEP 9: Help target with automatic documentation
# Generate help from target comments using pattern matching
help: ## Display this help message
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Available targets:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Environment: $(OS)$(NC)"
	@echo "$(YELLOW)Build directory: $(BUILD_DIR)$(NC)"

# STEP 10: Setup and dependency management
setup-dev: ## Setup development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@mkdir -p $(BUILD_DIR) $(DIST_DIR) $(DOC_DIR)
	@if command -v $(PYTHON) >/dev/null 2>&1; then \
		$(PYTHON) -m venv venv; \
		. venv/bin/activate && $(PIP) install --upgrade pip; \
		. venv/bin/activate && $(PIP) install -r requirements.txt 2>/dev/null || true; \
	fi
	@echo "$(GREEN)Development environment ready!$(NC)"

check-deps: ## Check for required dependencies
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@command -v bash >/dev/null 2>&1 || { echo "$(RED)bash is required$(NC)"; exit 1; }
	@command -v $(PYTHON) >/dev/null 2>&1 || { echo "$(RED)python3 is required$(NC)"; exit 1; }
	@command -v $(SHELLCHECK) >/dev/null 2>&1 || { echo "$(YELLOW)shellcheck not found (optional)$(NC)"; }
	@echo "$(GREEN)Dependencies check passed!$(NC)"

# STEP 11: Code quality and linting
lint: check-deps ## Run shellcheck on all shell scripts
	@echo "$(BLUE)Running shellcheck on shell scripts...$(NC)"
	@if command -v $(SHELLCHECK) >/dev/null 2>&1; then \
		for script in $(SHELL_SCRIPTS); do \
			echo "Checking $$script..."; \
			$(SHELLCHECK) -x $$script || exit 1; \
		done; \
		echo "$(GREEN)All scripts passed shellcheck!$(NC)"; \
	else \
		echo "$(YELLOW)Shellcheck not available, skipping lint check$(NC)"; \
	fi

# STEP 12: Code formatting
format: ## Format shell scripts (basic formatting)
	@echo "$(BLUE)Formatting shell scripts...$(NC)"
	@for script in $(SHELL_SCRIPTS); do \
		echo "Formatting $$script..."; \
		$(SED) 's/[[:space:]]*$$//' $$script; \
		chmod +x $$script; \
	done
	@echo "$(GREEN)Scripts formatted!$(NC)"

# STEP 13: Testing framework
test: ## Run all tests
	@echo "$(BLUE)Running tests...$(NC)"
	@if [ -d "$(TEST_DIR)" ]; then \
		test_count=0; \
		passed_count=0; \
		for test_script in $(TEST_SCRIPTS); do \
			echo "Running $$test_script..."; \
			if bash $$test_script; then \
				passed_count=$$((passed_count + 1)); \
			fi; \
			test_count=$$((test_count + 1)); \
		done; \
		echo "$(GREEN)Tests completed: $$passed_count/$$test_count passed$(NC)"; \
		if [ $$passed_count -ne $$test_count ]; then exit 1; fi; \
	else \
		echo "$(YELLOW)No test directory found$(NC)"; \
	fi

# STEP 14: Build process with dependency tracking
build: lint format ## Build the project
	@echo "$(BLUE)Building $(PROJECT_NAME) v$(VERSION)...$(NC)"
	@mkdir -p $(BUILD_DIR)
	@cp -r $(SRC_DIR)/* $(BUILD_DIR)/ 2>/dev/null || true
	@echo "$(VERSION)" > $(BUILD_DIR)/VERSION
	@echo "$(shell date)" > $(BUILD_DIR)/BUILD_DATE
	@echo "$(GREEN)Build completed successfully!$(NC)"

# STEP 15: Validation and verification
validate: build ## Validate built scripts
	@echo "$(BLUE)Validating built scripts...$(NC)"
	@for script in $(BUILD_DIR)/*.sh; do \
		if [ -f "$$script" ]; then \
			echo "Validating $$script..."; \
			bash -n $$script || exit 1; \
		fi; \
	done
	@echo "$(GREEN)All scripts validated!$(NC)"

# STEP 16: Installation process
install: validate ## Install scripts to system
	@echo "$(BLUE)Installing scripts...$(NC)"
	@install_dir="$${HOME}/bin"; \
	mkdir -p "$$install_dir"; \
	for script in $(BUILD_DIR)/*.sh; do \
		if [ -f "$$script" ]; then \
			cp "$$script" "$$install_dir/"; \
			chmod +x "$$install_dir/$$(basename $$script)"; \
			echo "Installed $$(basename $$script)"; \
		fi; \
	done
	@echo "$(GREEN)Installation completed!$(NC)"

# STEP 17: Documentation generation
docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@mkdir -p $(DOC_DIR)
	@echo "# $(PROJECT_NAME) Documentation" > $(DOC_DIR)/README.md
	@echo "" >> $(DOC_DIR)/README.md
	@echo "Generated on: $$(date)" >> $(DOC_DIR)/README.md
	@echo "" >> $(DOC_DIR)/README.md
	@echo "## Scripts" >> $(DOC_DIR)/README.md
	@for script in $(SHELL_SCRIPTS); do \
		echo "### $$(basename $$script)" >> $(DOC_DIR)/README.md; \
		head -10 $$script | grep "^#" | sed 's/^# *//' >> $(DOC_DIR)/README.md; \
		echo "" >> $(DOC_DIR)/README.md; \
	done
	@echo "$(GREEN)Documentation generated in $(DOC_DIR)/$(NC)"

# STEP 18: Packaging for distribution
package: build docs ## Create distribution package
	@echo "$(BLUE)Creating distribution package...$(NC)"
	@mkdir -p $(DIST_DIR)
	@tar -czf $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION).tar.gz \
		-C $(BUILD_DIR) . \
		--transform 's,^,$(PROJECT_NAME)-$(VERSION)/,'
	@zip -r $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION).zip $(BUILD_DIR)/* >/dev/null
	@echo "$(GREEN)Packages created:$(NC)"
	@ls -la $(DIST_DIR)/

# STEP 19: Performance benchmarking
benchmark: build ## Run performance benchmarks
	@echo "$(BLUE)Running benchmarks...$(NC)"
	@if [ -f "$(BUILD_DIR)/basic_script.sh" ]; then \
		echo "Benchmarking basic_script.sh..."; \
		time bash $(BUILD_DIR)/basic_script.sh 1000 >/dev/null; \
	fi
	@echo "$(GREEN)Benchmarks completed!$(NC)"

# STEP 20: Memory profiling
profile: build ## Profile memory usage
	@echo "$(BLUE)Profiling memory usage...$(NC)"
	@if command -v valgrind >/dev/null 2>&1; then \
		echo "Using valgrind for profiling..."; \
		valgrind --tool=massif bash $(BUILD_DIR)/basic_script.sh 100; \
	else \
		echo "$(YELLOW)Valgrind not available, using time command$(NC)"; \
		/usr/bin/time -v bash $(BUILD_DIR)/basic_script.sh 100 2>&1 | grep -E "(Maximum|Average)"; \
	fi

# STEP 21: Docker integration
docker-build: ## Build Docker image
	@echo "$(BLUE)Building Docker image...$(NC)"
	@if [ -f "Dockerfile" ]; then \
		docker build -t $(PROJECT_NAME):$(VERSION) .; \
		docker build -t $(PROJECT_NAME):latest .; \
		echo "$(GREEN)Docker image built successfully!$(NC)"; \
	else \
		echo "$(YELLOW)No Dockerfile found$(NC)"; \
	fi

docker-run: docker-build ## Run Docker container
	@echo "$(BLUE)Running Docker container...$(NC)"
	@docker run --rm -it $(PROJECT_NAME):latest

# STEP 22: Deployment automation
deploy: package ## Deploy to production
	@echo "$(BLUE)Deploying $(PROJECT_NAME) v$(VERSION)...$(NC)"
	@echo "$(YELLOW)This is a simulation - implement actual deployment logic$(NC)"
	@echo "1. Upload package to server"
	@echo "2. Extract and install"
	@echo "3. Update configuration"
	@echo "4. Restart services"
	@echo "5. Verify deployment"
	@echo "$(GREEN)Deployment simulation completed!$(NC)"

# STEP 23: Release management
release: clean test build package ## Create a new release
	@echo "$(BLUE)Creating release $(VERSION)...$(NC)"
	@git_status=$$(git status --porcelain 2>/dev/null || echo "no-git"); \
	if [ "$$git_status" != "no-git" ] && [ -n "$$git_status" ]; then \
		echo "$(RED)Working directory not clean. Commit changes first.$(NC)"; \
		exit 1; \
	fi
	@if command -v git >/dev/null 2>&1; then \
		git tag -a "v$(VERSION)" -m "Release version $(VERSION)"; \
		echo "$(GREEN)Git tag v$(VERSION) created$(NC)"; \
	fi
	@echo "$(GREEN)Release $(VERSION) ready!$(NC)"

# STEP 24: Cleanup targets
clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR) $(DIST_DIR)
	@rm -f $(SRC_DIR)/*.checked $(SRC_DIR)/*.formatted
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@echo "$(GREEN)Cleanup completed!$(NC)"

clean-all: clean ## Clean everything including dependencies
	@echo "$(BLUE)Deep cleaning...$(NC)"
	@rm -rf venv/ __pycache__/ .pytest_cache/
	@rm -rf $(DOC_DIR)
	@echo "$(GREEN)Deep cleanup completed!$(NC)"

# STEP 25: Development utilities
watch: ## Watch files and rebuild on changes (requires inotify-tools)
	@echo "$(BLUE)Watching for file changes...$(NC)"
	@if command -v inotifywait >/dev/null 2>&1; then \
		while inotifywait -e modify $(SRC_DIR)/*.sh; do \
			make build; \
		done; \
	else \
		echo "$(YELLOW)inotifywait not available. Install inotify-tools.$(NC)"; \
	fi

debug: ## Show Makefile variables for debugging
	@echo "$(BLUE)Makefile Debug Information:$(NC)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "VERSION: $(VERSION)"
	@echo "OS: $(OS)"
	@echo "SHELL_SCRIPTS: $(SHELL_SCRIPTS)"
	@echo "PYTHON_SCRIPTS: $(PYTHON_SCRIPTS)"
	@echo "BUILD_DIR: $(BUILD_DIR)"
	@echo "DIST_DIR: $(DIST_DIR)"

# STEP 26: Conditional targets based on file existence
# Only run if requirements.txt exists
ifneq (,$(wildcard requirements.txt))
install-deps: ## Install Python dependencies
	@echo "$(BLUE)Installing Python dependencies...$(NC)"
	@$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependencies installed!$(NC)"
endif

# STEP 27: Pattern rules for automatic file processing
# Rule to create .checked files from .sh files
%.checked: %.sh
	@echo "Checking $<..."
	@bash -n $< && touch $@

# Rule to create .formatted files from .sh files
%.formatted: %.sh
	@echo "Formatting $<..."
	@$(SED) 's/[[:space:]]*$$//' $<
	@chmod +x $<
	@touch $@

# STEP 28: Include external makefiles if they exist
# Include local customizations
-include Makefile.local

# STEP 29: Special targets
.SUFFIXES: .sh .py .checked .formatted

# STEP 30: Make configuration
# Disable built-in rules and variables for better performance
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables