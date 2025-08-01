# Web Development Build Pipeline - Help Example
PROJECT_NAME := web_project
VERSION := 1.0.0

# Color definitions
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

# Main targets with help comments
all: ## Build production version (minified, optimized)
	@echo "Building production..."

dev: ## Build development version (unminified, with source maps)
	@echo "Building development..."

watch: ## Watch files and rebuild automatically
	@echo "Starting watch mode..."

serve: ## Start development server on localhost:8080
	@echo "Starting dev server..."

lint: ## Run ESLint and stylelint on all files
	@echo "Running linters..."

test: ## Run JavaScript unit tests with Jest
	@echo "Running tests..."

optimize: ## Optimize images and compress assets
	@echo "Optimizing assets..."

deploy-staging: ## Deploy to staging environment
	@echo "Deploying to staging..."

deploy-prod: ## Deploy to production environment  
	@echo "Deploying to production..."

clean: ## Clean build artifacts and dist folder
	@echo "Cleaning..."

# Help target - tự động tạo menu từ comments
help: ## Display this help menu
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Available targets:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Build modes:$(NC)"
	@echo "  dev      - Development build (fast, unminified)"
	@echo "  prod     - Production build (optimized, minified)"
	@echo ""
	@echo "$(YELLOW)Usage examples:$(NC)"
	@echo "  make           # Production build"
	@echo "  make dev       # Development build"
	@echo "  make watch     # Watch and rebuild"
	@echo "  make serve     # Start dev server"

.PHONY: all dev watch serve lint test optimize deploy-staging deploy-prod clean help