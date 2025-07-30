# Exercise 2 Solution: Web Development Build Pipeline
# Comprehensive Makefile for web project with asset optimization

# STEP 1: Project configuration
PROJECT_NAME := web_project
VERSION := 1.0.0
NODE_ENV ?= production

# STEP 2: Directory structure
SRC_DIR := src
DIST_DIR := dist
CSS_DIR := $(SRC_DIR)/css
JS_DIR := $(SRC_DIR)/js
IMG_DIR := $(SRC_DIR)/images
HTML_DIR := $(SRC_DIR)/html

# STEP 3: Tool configuration
NPM := npm
NODE := node
UGLIFYJS := npx uglify-js
CLEANCSS := npx clean-css-cli
HTMLMIN := npx html-minifier
IMAGEMIN := npx imagemin-cli

# STEP 4: File discovery
CSS_FILES := $(wildcard $(CSS_DIR)/*.css)
JS_FILES := $(wildcard $(JS_DIR)/*.js)
HTML_FILES := $(wildcard $(HTML_DIR)/*.html)
IMG_FILES := $(wildcard $(IMG_DIR)/*.{png,jpg,jpeg,gif,svg})

# STEP 5: Output files
CSS_BUNDLE := $(DIST_DIR)/css/bundle.css
JS_BUNDLE := $(DIST_DIR)/js/bundle.js
CSS_MIN := $(DIST_DIR)/css/bundle.min.css
JS_MIN := $(DIST_DIR)/js/bundle.min.js

# STEP 6: Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# STEP 7: Default target
.DEFAULT_GOAL := build

# STEP 8: Phony targets
.PHONY: all dev prod build watch serve lint test clean install deploy-staging deploy-prod

# STEP 9: Environment-specific builds
dev: NODE_ENV=development
dev: build-dev

prod: NODE_ENV=production
prod: build-prod

# STEP 10: Development build (unminified)
build-dev: install | $(DIST_DIR)
	@echo "$(BLUE)Building for development...$(NC)"
	@mkdir -p $(DIST_DIR)/css $(DIST_DIR)/js $(DIST_DIR)/images
	@cat $(CSS_FILES) > $(CSS_BUNDLE)
	@cat $(JS_FILES) > $(JS_BUNDLE)
	@cp $(HTML_FILES) $(DIST_DIR)/ 2>/dev/null || true
	@cp $(IMG_FILES) $(DIST_DIR)/images/ 2>/dev/null || true
	@echo "$(GREEN)Development build completed!$(NC)"

# STEP 11: Production build (minified and optimized)
build-prod: install lint | $(DIST_DIR)
	@echo "$(BLUE)Building for production...$(NC)"
	@mkdir -p $(DIST_DIR)/css $(DIST_DIR)/js $(DIST_DIR)/images
	
	# CSS processing
	@echo "$(YELLOW)Processing CSS...$(NC)"
	@cat $(CSS_FILES) | $(CLEANCSS) -o $(CSS_MIN)
	
	# JavaScript processing
	@echo "$(YELLOW)Processing JavaScript...$(NC)"
	@cat $(JS_FILES) | $(UGLIFYJS) --compress --mangle -o $(JS_MIN)
	
	# HTML processing
	@echo "$(YELLOW)Processing HTML...$(NC)"
	@for html in $(HTML_FILES); do \
		$(HTMLMIN) --collapse-whitespace --remove-comments \
			--minify-css --minify-js $$html -o $(DIST_DIR)/$$(basename $$html); \
	done
	
	# Image optimization
	@echo "$(YELLOW)Optimizing images...$(NC)"
	@if [ -n "$(IMG_FILES)" ]; then \
		$(IMAGEMIN) $(IMG_DIR)/* --out-dir=$(DIST_DIR)/images; \
	fi
	
	@echo "$(GREEN)Production build completed!$(NC)"

# STEP 12: Default build target
build: build-prod

# STEP 13: Install dependencies
install: package.json
	@echo "$(BLUE)Installing dependencies...$(NC)"
	@$(NPM) install
	@echo "$(GREEN)Dependencies installed!$(NC)"

# STEP 14: Linting
lint: install
	@echo "$(BLUE)Running linters...$(NC)"
	@if command -v npx eslint >/dev/null 2>&1; then \
		npx eslint $(JS_FILES) || true; \
	fi
	@if command -v npx stylelint >/dev/null 2>&1; then \
		npx stylelint $(CSS_FILES) || true; \
	fi
	@echo "$(GREEN)Linting completed!$(NC)"

# STEP 15: Testing
test: install
	@echo "$(BLUE)Running tests...$(NC)"
	@if [ -f "package.json" ] && grep -q '"test"' package.json; then \
		$(NPM) test; \
	else \
		echo "$(YELLOW)No tests configured$(NC)"; \
	fi

# STEP 16: Watch mode for development
watch: install
	@echo "$(BLUE)Starting watch mode...$(NC)"
	@while true; do \
		inotifywait -e modify $(CSS_FILES) $(JS_FILES) $(HTML_FILES) 2>/dev/null && \
		$(MAKE) build-dev; \
	done

# STEP 17: Development server
serve: build-dev
	@echo "$(BLUE)Starting development server...$(NC)"
	@if command -v python3 >/dev/null 2>&1; then \
		cd $(DIST_DIR) && python3 -m http.server 8080; \
	elif command -v python >/dev/null 2>&1; then \
		cd $(DIST_DIR) && python -m SimpleHTTPServer 8080; \
	else \
		echo "$(RED)Python not found. Cannot start server.$(NC)"; \
	fi

# STEP 18: Asset versioning for cache busting
version-assets: build-prod
	@echo "$(BLUE)Adding version hashes to assets...$(NC)"
	@cd $(DIST_DIR) && \
	for file in css/*.css js/*.js; do \
		if [ -f "$$file" ]; then \
			hash=$$(md5sum "$$file" | cut -d' ' -f1 | head -c8); \
			dir=$$(dirname "$$file"); \
			name=$$(basename "$$file" | cut -d. -f1); \
			ext=$$(basename "$$file" | cut -d. -f2-); \
			mv "$$file" "$$dir/$$name.$$hash.$$ext"; \
		fi; \
	done
	@echo "$(GREEN)Assets versioned!$(NC)"

# STEP 19: Gzip compression
compress: build-prod
	@echo "$(BLUE)Creating gzipped versions...$(NC)"
	@find $(DIST_DIR) -type f \( -name "*.css" -o -name "*.js" -o -name "*.html" \) \
		-exec gzip -k {} \;
	@echo "$(GREEN)Compression completed!$(NC)"

# STEP 20: Bundle analysis
analyze: build-prod
	@echo "$(BLUE)Analyzing bundle sizes...$(NC)"
	@echo "CSS Bundle Size: $$(wc -c < $(CSS_MIN)) bytes"
	@echo "JS Bundle Size: $$(wc -c < $(JS_MIN)) bytes"
	@echo "Total Assets:"
	@du -sh $(DIST_DIR)/*
	@echo "$(GREEN)Analysis completed!$(NC)"

# STEP 21: Deployment to staging
deploy-staging: build-prod
	@echo "$(BLUE)Deploying to staging...$(NC)"
	@echo "$(YELLOW)This is a simulation - implement actual deployment$(NC)"
	@echo "1. Upload files to staging server"
	@echo "2. Update configuration"
	@echo "3. Clear CDN cache"
	@echo "4. Run smoke tests"
	@echo "$(GREEN)Staging deployment completed!$(NC)"

# STEP 22: Deployment to production
deploy-prod: build-prod compress
	@echo "$(BLUE)Deploying to production...$(NC)"
	@echo "$(YELLOW)This is a simulation - implement actual deployment$(NC)"
	@echo "1. Create backup of current version"
	@echo "2. Upload files to production server"
	@echo "3. Update configuration"
	@echo "4. Clear CDN cache"
	@echo "5. Run health checks"
	@echo "6. Update DNS if needed"
	@echo "$(GREEN)Production deployment completed!$(NC)"

# STEP 23: Performance audit
audit: build-prod
	@echo "$(BLUE)Running performance audit...$(NC)"
	@if command -v npx lighthouse >/dev/null 2>&1; then \
		npx lighthouse file://$(PWD)/$(DIST_DIR)/index.html \
			--output=html --output-path=lighthouse-report.html; \
	else \
		echo "$(YELLOW)Lighthouse not available$(NC)"; \
	fi

# STEP 24: Security check
security: install
	@echo "$(BLUE)Running security audit...$(NC)"
	@$(NPM) audit || true
	@echo "$(GREEN)Security audit completed!$(NC)"

# STEP 25: Clean build artifacts
clean:
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf $(DIST_DIR)
	@rm -f lighthouse-report.html
	@echo "$(GREEN)Cleanup completed!$(NC)"

# STEP 26: Clean everything including dependencies
clean-all: clean
	@echo "$(BLUE)Deep cleaning...$(NC)"
	@rm -rf node_modules
	@rm -f package-lock.json
	@echo "$(GREEN)Deep cleanup completed!$(NC)"

# STEP 27: Directory creation
$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

# STEP 28: Help target
help:
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Available targets:$(NC)"
	@echo ""
	@echo "$(GREEN)build$(NC)          Build production version"
	@echo "$(GREEN)dev$(NC)            Build development version"
	@echo "$(GREEN)watch$(NC)          Watch files and rebuild"
	@echo "$(GREEN)serve$(NC)          Start development server"
	@echo "$(GREEN)lint$(NC)           Run code linters"
	@echo "$(GREEN)test$(NC)           Run tests"
	@echo "$(GREEN)deploy-staging$(NC) Deploy to staging"
	@echo "$(GREEN)deploy-prod$(NC)    Deploy to production"
	@echo "$(GREEN)clean$(NC)          Clean build artifacts"

# STEP 29: File dependencies
$(CSS_BUNDLE): $(CSS_FILES)
$(JS_BUNDLE): $(JS_FILES)
$(CSS_MIN): $(CSS_FILES)
$(JS_MIN): $(JS_FILES)

# STEP 30: Make configuration
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules