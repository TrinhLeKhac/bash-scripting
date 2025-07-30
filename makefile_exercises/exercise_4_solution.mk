# Exercise 4 Solution: Docker Multi-Stage Build System
# Advanced Makefile for Docker multi-stage builds and container orchestration

# STEP 1: Project configuration
PROJECT_NAME := docker_project
VERSION := 1.0.0
REGISTRY := localhost:5000
IMAGE_PREFIX := $(REGISTRY)/$(PROJECT_NAME)

# STEP 2: Directory structure
APP_DIR := app
DB_DIR := database
NGINX_DIR := nginx
MONITORING_DIR := monitoring
DOCKER_DIR := .

# STEP 3: Docker configuration
DOCKER := docker
DOCKER_COMPOSE := docker-compose
DOCKER_BUILDKIT := 1

# STEP 4: Image names and tags
APP_IMAGE := $(IMAGE_PREFIX)/app
DB_IMAGE := $(IMAGE_PREFIX)/database
NGINX_IMAGE := $(IMAGE_PREFIX)/nginx
MONITORING_IMAGE := $(IMAGE_PREFIX)/monitoring

# STEP 5: Build targets and environments
BUILD_TARGET ?= production
ENVIRONMENT ?= development
COMPOSE_FILE := docker-compose.yml

# STEP 6: Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# STEP 7: Default target
.DEFAULT_GOAL := help

# STEP 8: Phony targets
.PHONY: help build build-dev build-prod test security-scan deploy logs shell clean

# STEP 9: Build all images
build: build-app build-db build-nginx ## Build all images for current target
	@echo "$(GREEN)All images built for target: $(BUILD_TARGET)$(NC)"

# STEP 10: Build development images
build-dev: BUILD_TARGET=development
build-dev: build ## Build development images
	@echo "$(GREEN)Development images built!$(NC)"

# STEP 11: Build production images
build-prod: BUILD_TARGET=production
build-prod: build ## Build production images
	@echo "$(GREEN)Production images built!$(NC)"

# STEP 12: Build application image with multi-stage
build-app: ## Build application image
	@echo "$(BLUE)Building application image (target: $(BUILD_TARGET))...$(NC)"
	@DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) $(DOCKER) build \
		--target $(BUILD_TARGET) \
		--tag $(APP_IMAGE):$(BUILD_TARGET) \
		--tag $(APP_IMAGE):latest \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILD_DATE="$$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
		$(APP_DIR)
	@echo "$(GREEN)Application image built!$(NC)"

# STEP 13: Build database image
build-db: ## Build database image
	@echo "$(BLUE)Building database image...$(NC)"
	@$(DOCKER) build \
		--tag $(DB_IMAGE):$(VERSION) \
		--tag $(DB_IMAGE):latest \
		$(DB_DIR)
	@echo "$(GREEN)Database image built!$(NC)"

# STEP 14: Build nginx image
build-nginx: ## Build nginx image
	@echo "$(BLUE)Building nginx image...$(NC)"
	@$(DOCKER) build \
		--tag $(NGINX_IMAGE):$(VERSION) \
		--tag $(NGINX_IMAGE):latest \
		$(NGINX_DIR)
	@echo "$(GREEN)Nginx image built!$(NC)"

# STEP 15: Run all tests in containers
test: test-unit test-integration ## Run all tests
	@echo "$(GREEN)All tests completed!$(NC)"

# STEP 16: Run unit tests
test-unit: ## Run unit tests in containers
	@echo "$(BLUE)Running unit tests...$(NC)"
	@DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) $(DOCKER) build \
		--target tester \
		--tag $(APP_IMAGE):test \
		$(APP_DIR)
	@$(DOCKER) run --rm $(APP_IMAGE):test
	@echo "$(GREEN)Unit tests passed!$(NC)"

# STEP 17: Run integration tests
test-integration: build ## Run integration tests
	@echo "$(BLUE)Running integration tests...$(NC)"
	@$(DOCKER_COMPOSE) -f docker-compose.test.yml up --build --abort-on-container-exit
	@$(DOCKER_COMPOSE) -f docker-compose.test.yml down -v
	@echo "$(GREEN)Integration tests passed!$(NC)"

# STEP 18: Security scanning
security-scan: build-prod ## Scan images for vulnerabilities
	@echo "$(BLUE)Running security scans...$(NC)"
	@if command -v trivy >/dev/null 2>&1; then \
		echo "Scanning application image..."; \
		trivy image $(APP_IMAGE):production; \
		echo "Scanning database image..."; \
		trivy image $(DB_IMAGE):latest; \
		echo "Scanning nginx image..."; \
		trivy image $(NGINX_IMAGE):latest; \
	else \
		echo "$(YELLOW)Trivy not available, using docker scan...$(NC)"; \
		$(DOCKER) scan $(APP_IMAGE):production || true; \
	fi
	@echo "$(GREEN)Security scan completed!$(NC)"

# STEP 19: Deploy to development
deploy-dev: ENVIRONMENT=development
deploy-dev: COMPOSE_FILE=docker-compose.yml
deploy-dev: build-dev ## Deploy to development environment
	@echo "$(BLUE)Deploying to development...$(NC)"
	@BUILD_TARGET=development $(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Development deployment completed!$(NC)"
	@$(MAKE) show-endpoints

# STEP 20: Deploy to staging
deploy-staging: ENVIRONMENT=staging
deploy-staging: COMPOSE_FILE=docker-compose.staging.yml
deploy-staging: build-prod ## Deploy to staging environment
	@echo "$(BLUE)Deploying to staging...$(NC)"
	@BUILD_TARGET=production $(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Staging deployment completed!$(NC)"
	@$(MAKE) show-endpoints

# STEP 21: Deploy to production
deploy-prod: ENVIRONMENT=production
deploy-prod: COMPOSE_FILE=docker-compose.prod.yml
deploy-prod: build-prod security-scan ## Deploy to production environment
	@echo "$(BLUE)Deploying to production...$(NC)"
	@echo "$(YELLOW)This will deploy to production. Continue? [y/N]$(NC)"
	@read -r confirm && [ "$$confirm" = "y" ] || exit 1
	@BUILD_TARGET=production $(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Production deployment completed!$(NC)"
	@$(MAKE) show-endpoints

# STEP 22: Show service endpoints
show-endpoints: ## Show service endpoints
	@echo "$(BLUE)Service endpoints:$(NC)"
	@echo "$(YELLOW)Application: http://localhost:8080$(NC)"
	@echo "$(YELLOW)Database: localhost:5432$(NC)"
	@echo "$(YELLOW)Nginx: http://localhost:80$(NC)"
	@if [ -f "docker-compose.monitoring.yml" ]; then \
		echo "$(YELLOW)Prometheus: http://localhost:9090$(NC)"; \
		echo "$(YELLOW)Grafana: http://localhost:3000$(NC)"; \
	fi

# STEP 23: View service logs
logs: ## View service logs
	@echo "$(BLUE)Viewing service logs...$(NC)"
	@$(DOCKER_COMPOSE) logs -f

# STEP 24: View specific service logs
logs-app: ## View application logs
	@$(DOCKER_COMPOSE) logs -f app

logs-db: ## View database logs
	@$(DOCKER_COMPOSE) logs -f database

logs-nginx: ## View nginx logs
	@$(DOCKER_COMPOSE) logs -f nginx

# STEP 25: Open shell in containers
shell: ## Open shell in application container
	@echo "$(BLUE)Opening shell in application container...$(NC)"
	@$(DOCKER_COMPOSE) exec app /bin/sh

shell-db: ## Open shell in database container
	@$(DOCKER_COMPOSE) exec database /bin/bash

# STEP 26: Health checks
health-check: ## Check service health
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo "Application health:"
	@curl -f http://localhost:8080/health 2>/dev/null || echo "$(RED)Application not responding$(NC)"
	@echo "Database health:"
	@$(DOCKER_COMPOSE) exec -T database pg_isready -U postgres || echo "$(RED)Database not responding$(NC)"
	@echo "Nginx health:"
	@curl -f http://localhost:80 2>/dev/null >/dev/null && echo "$(GREEN)Nginx OK$(NC)" || echo "$(RED)Nginx not responding$(NC)"

# STEP 27: Performance benchmarking
benchmark: ## Run performance benchmarks
	@echo "$(BLUE)Running performance benchmarks...$(NC)"
	@if command -v ab >/dev/null 2>&1; then \
		echo "Benchmarking application..."; \
		ab -n 1000 -c 10 http://localhost:8080/health; \
		echo "Benchmarking nginx..."; \
		ab -n 1000 -c 10 http://localhost:80/; \
	else \
		echo "$(YELLOW)Apache Bench (ab) not available$(NC)"; \
	fi
	@echo "$(GREEN)Benchmarks completed!$(NC)"

# STEP 28: Load testing
load-test: ## Run load tests
	@echo "$(BLUE)Running load tests...$(NC)"
	@if command -v hey >/dev/null 2>&1; then \
		hey -n 10000 -c 100 -t 30 http://localhost:8080/health; \
	elif command -v wrk >/dev/null 2>&1; then \
		wrk -t12 -c400 -d30s http://localhost:8080/health; \
	else \
		echo "$(YELLOW)Load testing tools not available$(NC)"; \
	fi

# STEP 29: Monitoring deployment
deploy-monitoring: ## Deploy monitoring stack
	@echo "$(BLUE)Deploying monitoring stack...$(NC)"
	@$(DOCKER_COMPOSE) -f $(MONITORING_DIR)/docker-compose.monitoring.yml up -d
	@echo "$(GREEN)Monitoring stack deployed!$(NC)"
	@echo "$(YELLOW)Prometheus: http://localhost:9090$(NC)"
	@echo "$(YELLOW)Grafana: http://localhost:3000 (admin/admin)$(NC)"

# STEP 30: Registry operations
push: build-prod ## Push images to registry
	@echo "$(BLUE)Pushing images to registry...$(NC)"
	@$(DOCKER) push $(APP_IMAGE):production
	@$(DOCKER) push $(APP_IMAGE):latest
	@$(DOCKER) push $(DB_IMAGE):latest
	@$(DOCKER) push $(NGINX_IMAGE):latest
	@echo "$(GREEN)Images pushed to registry!$(NC)"

pull: ## Pull images from registry
	@echo "$(BLUE)Pulling images from registry...$(NC)"
	@$(DOCKER) pull $(APP_IMAGE):latest
	@$(DOCKER) pull $(DB_IMAGE):latest
	@$(DOCKER) pull $(NGINX_IMAGE):latest
	@echo "$(GREEN)Images pulled from registry!$(NC)"

# STEP 31: Backup and restore
backup: ## Backup database
	@echo "$(BLUE)Creating database backup...$(NC)"
	@mkdir -p backups
	@$(DOCKER_COMPOSE) exec -T database pg_dump -U postgres appdb > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Database backup created!$(NC)"

restore: ## Restore database from backup
	@echo "$(BLUE)Restoring database...$(NC)"
	@echo "$(YELLOW)Available backups:$(NC)"
	@ls -la backups/*.sql 2>/dev/null || echo "No backups found"
	@echo "Enter backup filename:"
	@read -r backup_file && \
	$(DOCKER_COMPOSE) exec -T database psql -U postgres -d appdb < "$$backup_file"
	@echo "$(GREEN)Database restored!$(NC)"

# STEP 32: Stop services
stop: ## Stop all services
	@echo "$(BLUE)Stopping services...$(NC)"
	@$(DOCKER_COMPOSE) down
	@$(DOCKER_COMPOSE) -f $(MONITORING_DIR)/docker-compose.monitoring.yml down 2>/dev/null || true
	@echo "$(GREEN)Services stopped!$(NC)"

# STEP 33: Clean containers and images
clean: stop ## Clean containers, images, and volumes
	@echo "$(BLUE)Cleaning Docker artifacts...$(NC)"
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	@$(DOCKER) system prune -f
	@$(DOCKER) volume prune -f
	@echo "$(GREEN)Cleanup completed!$(NC)"

# STEP 34: Clean everything
clean-all: clean ## Clean everything including images
	@echo "$(BLUE)Deep cleaning...$(NC)"
	@$(DOCKER) image prune -a -f
	@$(DOCKER) system prune -a -f --volumes
	@echo "$(GREEN)Deep cleanup completed!$(NC)"

# STEP 35: Development utilities
watch: ## Watch for changes and rebuild
	@echo "$(BLUE)Watching for changes...$(NC)"
	@if command -v inotifywait >/dev/null 2>&1; then \
		while inotifywait -r -e modify $(APP_DIR)/src; do \
			$(MAKE) build-dev; \
		done; \
	else \
		echo "$(YELLOW)inotifywait not available$(NC)"; \
	fi

# STEP 36: Image analysis
analyze: build-prod ## Analyze image layers and sizes
	@echo "$(BLUE)Analyzing images...$(NC)"
	@echo "Application image:"
	@$(DOCKER) history $(APP_IMAGE):production
	@echo "Database image:"
	@$(DOCKER) history $(DB_IMAGE):latest
	@echo "Nginx image:"
	@$(DOCKER) history $(NGINX_IMAGE):latest
	@echo "$(GREEN)Image analysis completed!$(NC)"

# STEP 37: Help target
help: ## Display this help
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Docker Multi-Stage Build System$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Build targets: development, production$(NC)"
	@echo "$(YELLOW)Environments: development, staging, production$(NC)"
	@echo "$(YELLOW)Usage: make [target] [BUILD_TARGET=target] [ENVIRONMENT=env]$(NC)"

# STEP 38: Debug information
debug: ## Show debug information
	@echo "$(BLUE)Debug Information:$(NC)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "VERSION: $(VERSION)"
	@echo "BUILD_TARGET: $(BUILD_TARGET)"
	@echo "ENVIRONMENT: $(ENVIRONMENT)"
	@echo "REGISTRY: $(REGISTRY)"
	@echo "APP_IMAGE: $(APP_IMAGE)"
	@echo "COMPOSE_FILE: $(COMPOSE_FILE)"
	@echo "Docker version:"
	@$(DOCKER) --version
	@echo "Docker Compose version:"
	@$(DOCKER_COMPOSE) --version

# STEP 39: Configuration
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules