# Exercise 5 Solution: Cross-Platform Package Manager
# Advanced Makefile for cross-platform builds and package distribution

# STEP 1: Project configuration
PROJECT_NAME := cross_platform_app
VERSION := 1.0.0
DESCRIPTION := Cross-platform application with multi-architecture support

# STEP 2: Directory structure
SRC_DIR := src
PACKAGING_DIR := packaging
SCRIPTS_DIR := scripts
DIST_DIR := dist
RELEASES_DIR := releases
BUILD_DIR := build

# STEP 3: Build matrix configuration
PLATFORMS := linux-x64 linux-arm64 linux-arm32 macos-x64 macos-arm64 windows-x64 windows-x86 freebsd-x64
LINUX_ARCHS := x64 arm64 arm32
MACOS_ARCHS := x64 arm64
WINDOWS_ARCHS := x64 x86

# STEP 4: Compiler configuration
CC_LINUX_X64 := x86_64-linux-gnu-gcc
CC_LINUX_ARM64 := aarch64-linux-gnu-gcc
CC_LINUX_ARM32 := arm-linux-gnueabihf-gcc
CC_MACOS := clang
CC_WINDOWS_X64 := x86_64-w64-mingw32-gcc
CC_WINDOWS_X86 := i686-w64-mingw32-gcc
CC_FREEBSD := clang

# STEP 5: Package formats
LINUX_FORMATS := deb rpm appimage
MACOS_FORMATS := dmg pkg
WINDOWS_FORMATS := msi nsis
UNIVERSAL_FORMATS := tar.gz zip docker

# STEP 6: Distribution channels
GITHUB_REPO := github.com/example/cross-platform-app
DOCKER_REGISTRY := docker.io/example
CDN_BUCKET := s3://releases.example.com

# STEP 7: Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# STEP 8: Default target
.DEFAULT_GOAL := help

# STEP 9: Phony targets
.PHONY: help all-platforms clean packages sign-packages test-packages release upload-cdn

# STEP 10: Build for all platforms
all-platforms: $(PLATFORMS) ## Build for all supported platforms
	@echo "$(GREEN)All platforms built successfully!$(NC)"

# STEP 11: Linux x86_64 build
linux-x64: ## Build for Linux x86_64
	@echo "$(BLUE)Building for Linux x86_64...$(NC)"
	@mkdir -p $(BUILD_DIR)/linux-x64
	@$(CC_LINUX_X64) -static -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/linux.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/linux-x64/$(PROJECT_NAME)
	@echo "$(GREEN)Linux x86_64 build completed!$(NC)"

# STEP 12: Linux ARM64 build
linux-arm64: ## Build for Linux ARM64
	@echo "$(BLUE)Building for Linux ARM64...$(NC)"
	@mkdir -p $(BUILD_DIR)/linux-arm64
	@$(CC_LINUX_ARM64) -static -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/linux.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/linux-arm64/$(PROJECT_NAME)
	@echo "$(GREEN)Linux ARM64 build completed!$(NC)"

# STEP 13: Linux ARM32 build
linux-arm32: ## Build for Linux ARM32
	@echo "$(BLUE)Building for Linux ARM32...$(NC)"
	@mkdir -p $(BUILD_DIR)/linux-arm32
	@$(CC_LINUX_ARM32) -static -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/linux.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/linux-arm32/$(PROJECT_NAME)
	@echo "$(GREEN)Linux ARM32 build completed!$(NC)"

# STEP 14: macOS universal binary
macos-universal: macos-x64 macos-arm64 ## Build macOS universal binary
	@echo "$(BLUE)Creating macOS universal binary...$(NC)"
	@mkdir -p $(BUILD_DIR)/macos-universal
	@lipo -create \
		$(BUILD_DIR)/macos-x64/$(PROJECT_NAME) \
		$(BUILD_DIR)/macos-arm64/$(PROJECT_NAME) \
		-output $(BUILD_DIR)/macos-universal/$(PROJECT_NAME)
	@echo "$(GREEN)macOS universal binary created!$(NC)"

# STEP 15: macOS x86_64 build
macos-x64: ## Build for macOS x86_64
	@echo "$(BLUE)Building for macOS x86_64...$(NC)"
	@mkdir -p $(BUILD_DIR)/macos-x64
	@$(CC_MACOS) -target x86_64-apple-macos10.15 -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/macos.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/macos-x64/$(PROJECT_NAME)
	@echo "$(GREEN)macOS x86_64 build completed!$(NC)"

# STEP 16: macOS ARM64 build
macos-arm64: ## Build for macOS ARM64
	@echo "$(BLUE)Building for macOS ARM64...$(NC)"
	@mkdir -p $(BUILD_DIR)/macos-arm64
	@$(CC_MACOS) -target arm64-apple-macos11.0 -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/macos.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/macos-arm64/$(PROJECT_NAME)
	@echo "$(GREEN)macOS ARM64 build completed!$(NC)"

# STEP 17: Windows x64 build
windows-x64: ## Build for Windows x64
	@echo "$(BLUE)Building for Windows x64...$(NC)"
	@mkdir -p $(BUILD_DIR)/windows-x64
	@$(CC_WINDOWS_X64) -static -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/windows.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/windows-x64/$(PROJECT_NAME).exe
	@echo "$(GREEN)Windows x64 build completed!$(NC)"

# STEP 18: Windows x86 build
windows-x86: ## Build for Windows x86
	@echo "$(BLUE)Building for Windows x86...$(NC)"
	@mkdir -p $(BUILD_DIR)/windows-x86
	@$(CC_WINDOWS_X86) -static -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/windows.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/windows-x86/$(PROJECT_NAME).exe
	@echo "$(GREEN)Windows x86 build completed!$(NC)"

# STEP 19: FreeBSD build
freebsd-x64: ## Build for FreeBSD x64
	@echo "$(BLUE)Building for FreeBSD x64...$(NC)"
	@mkdir -p $(BUILD_DIR)/freebsd-x64
	@$(CC_FREEBSD) -static -O2 -DVERSION=\"$(VERSION)\" \
		$(SRC_DIR)/*.c $(SRC_DIR)/platform/linux.c \
		-I$(SRC_DIR)/include -o $(BUILD_DIR)/freebsd-x64/$(PROJECT_NAME)
	@echo "$(GREEN)FreeBSD x64 build completed!$(NC)"

# STEP 20: Create all packages
packages: all-platforms ## Create all package formats
	@echo "$(BLUE)Creating packages for all platforms...$(NC)"
	@$(MAKE) linux-packages
	@$(MAKE) macos-packages
	@$(MAKE) windows-packages
	@$(MAKE) universal-packages
	@echo "$(GREEN)All packages created!$(NC)"

# STEP 21: Linux packages
linux-packages: linux-x64 linux-arm64 linux-arm32 ## Create Linux packages
	@echo "$(BLUE)Creating Linux packages...$(NC)"
	@mkdir -p $(DIST_DIR)/linux
	
	# DEB packages
	@for arch in x64 arm64 arm32; do \
		echo "Creating DEB package for $$arch..."; \
		mkdir -p $(DIST_DIR)/linux/deb-$$arch/DEBIAN; \
		mkdir -p $(DIST_DIR)/linux/deb-$$arch/usr/bin; \
		cp $(BUILD_DIR)/linux-$$arch/$(PROJECT_NAME) $(DIST_DIR)/linux/deb-$$arch/usr/bin/; \
		sed "s/ARCH/$$arch/g; s/VERSION/$(VERSION)/g" $(PACKAGING_DIR)/linux/debian/control > $(DIST_DIR)/linux/deb-$$arch/DEBIAN/control; \
		dpkg-deb --build $(DIST_DIR)/linux/deb-$$arch $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-$$arch.deb; \
	done
	
	# RPM packages
	@for arch in x64 arm64 arm32; do \
		echo "Creating RPM package for $$arch..."; \
		rpmbuild -bb --define "_topdir $(PWD)/$(DIST_DIR)/rpm" \
			--define "_arch $$arch" --define "_version $(VERSION)" \
			$(PACKAGING_DIR)/linux/rpm/spec.template; \
	done
	
	# AppImage
	@echo "Creating AppImage..."
	@mkdir -p $(DIST_DIR)/appimage
	@cp $(BUILD_DIR)/linux-x64/$(PROJECT_NAME) $(DIST_DIR)/appimage/
	@cp $(PACKAGING_DIR)/linux/appimage/AppRun $(DIST_DIR)/appimage/
	@chmod +x $(DIST_DIR)/appimage/AppRun
	@appimagetool $(DIST_DIR)/appimage $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-x86_64.AppImage
	
	@echo "$(GREEN)Linux packages created!$(NC)"

# STEP 22: macOS packages
macos-packages: macos-universal ## Create macOS packages
	@echo "$(BLUE)Creating macOS packages...$(NC)"
	@mkdir -p $(DIST_DIR)/macos
	
	# DMG package
	@echo "Creating DMG package..."
	@mkdir -p $(DIST_DIR)/macos/dmg/$(PROJECT_NAME).app/Contents/MacOS
	@mkdir -p $(DIST_DIR)/macos/dmg/$(PROJECT_NAME).app/Contents/Resources
	@cp $(BUILD_DIR)/macos-universal/$(PROJECT_NAME) $(DIST_DIR)/macos/dmg/$(PROJECT_NAME).app/Contents/MacOS/
	@cp $(PACKAGING_DIR)/macos/Info.plist $(DIST_DIR)/macos/dmg/$(PROJECT_NAME).app/Contents/
	@hdiutil create -volname "$(PROJECT_NAME)" -srcfolder $(DIST_DIR)/macos/dmg \
		-ov -format UDZO $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION).dmg
	
	# PKG package
	@echo "Creating PKG package..."
	@pkgbuild --root $(DIST_DIR)/macos/dmg --identifier com.example.$(PROJECT_NAME) \
		--version $(VERSION) $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION).pkg
	
	@echo "$(GREEN)macOS packages created!$(NC)"

# STEP 23: Windows packages
windows-packages: windows-x64 windows-x86 ## Create Windows packages
	@echo "$(BLUE)Creating Windows packages...$(NC)"
	@mkdir -p $(DIST_DIR)/windows
	
	# MSI packages
	@for arch in x64 x86; do \
		echo "Creating MSI package for $$arch..."; \
		candle -arch $$arch -dVersion=$(VERSION) -dArch=$$arch \
			$(PACKAGING_DIR)/windows/installer.wxs -out $(DIST_DIR)/windows/installer-$$arch.wixobj; \
		light $(DIST_DIR)/windows/installer-$$arch.wixobj \
			-out $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-$$arch.msi; \
	done
	
	# NSIS installer
	@echo "Creating NSIS installer..."
	@makensis -DVERSION=$(VERSION) $(PACKAGING_DIR)/windows/installer.nsi
	
	@echo "$(GREEN)Windows packages created!$(NC)"

# STEP 24: Universal packages
universal-packages: all-platforms ## Create universal packages
	@echo "$(BLUE)Creating universal packages...$(NC)"
	@mkdir -p $(DIST_DIR)/universal
	
	# Tar.gz archives
	@for platform in $(PLATFORMS); do \
		echo "Creating tar.gz for $$platform..."; \
		tar -czf $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-$$platform.tar.gz \
			-C $(BUILD_DIR)/$$platform .; \
	done
	
	# ZIP archives
	@for platform in $(PLATFORMS); do \
		echo "Creating zip for $$platform..."; \
		cd $(BUILD_DIR)/$$platform && zip -r ../../$(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-$$platform.zip .; \
	done
	
	@echo "$(GREEN)Universal packages created!$(NC)"

# STEP 25: Docker images
docker-images: linux-x64 ## Build Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	@mkdir -p $(DIST_DIR)/docker
	
	# Multi-stage Dockerfile for different base images
	@for base in alpine ubuntu scratch; do \
		echo "Building Docker image with $$base base..."; \
		docker build -f $(PACKAGING_DIR)/docker/Dockerfile.$$base \
			--build-arg BINARY_PATH=$(BUILD_DIR)/linux-x64/$(PROJECT_NAME) \
			-t $(DOCKER_REGISTRY)/$(PROJECT_NAME):$(VERSION)-$$base \
			-t $(DOCKER_REGISTRY)/$(PROJECT_NAME):latest-$$base .; \
	done
	
	@echo "$(GREEN)Docker images built!$(NC)"

# STEP 26: Sign packages
sign-packages: packages ## Sign all packages
	@echo "$(BLUE)Signing packages...$(NC)"
	
	# Sign with GPG
	@if command -v gpg >/dev/null 2>&1; then \
		for file in $(DIST_DIR)/*.{deb,rpm,dmg,pkg,msi,tar.gz,zip}; do \
			if [ -f "$$file" ]; then \
				echo "Signing $$file..."; \
				gpg --detach-sign --armor "$$file"; \
			fi; \
		done; \
	else \
		echo "$(YELLOW)GPG not available for signing$(NC)"; \
	fi
	
	# Generate checksums
	@echo "Generating checksums..."
	@cd $(DIST_DIR) && sha256sum *.{deb,rpm,dmg,pkg,msi,tar.gz,zip} > SHA256SUMS 2>/dev/null || true
	
	@echo "$(GREEN)Packages signed and checksums generated!$(NC)"

# STEP 27: Test packages
test-packages: packages ## Test package installation
	@echo "$(BLUE)Testing package installation...$(NC)"
	
	# Test DEB package
	@if command -v dpkg >/dev/null 2>&1; then \
		echo "Testing DEB package..."; \
		dpkg -I $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-x64.deb; \
	fi
	
	# Test tar.gz extraction
	@echo "Testing tar.gz extraction..."
	@mkdir -p $(DIST_DIR)/test
	@tar -xzf $(DIST_DIR)/$(PROJECT_NAME)-$(VERSION)-linux-x64.tar.gz -C $(DIST_DIR)/test
	@$(DIST_DIR)/test/$(PROJECT_NAME) --version || true
	@rm -rf $(DIST_DIR)/test
	
	@echo "$(GREEN)Package testing completed!$(NC)"

# STEP 28: Create GitHub release
release: sign-packages ## Create GitHub release
	@echo "$(BLUE)Creating GitHub release...$(NC)"
	@mkdir -p $(RELEASES_DIR)
	
	# Generate release notes
	@echo "# Release $(VERSION)" > $(RELEASES_DIR)/release-notes.md
	@echo "" >> $(RELEASES_DIR)/release-notes.md
	@echo "## Changes" >> $(RELEASES_DIR)/release-notes.md
	@git log --oneline --since="1 month ago" >> $(RELEASES_DIR)/release-notes.md || echo "- Initial release" >> $(RELEASES_DIR)/release-notes.md
	@echo "" >> $(RELEASES_DIR)/release-notes.md
	@echo "## Downloads" >> $(RELEASES_DIR)/release-notes.md
	@echo "Choose the appropriate package for your platform:" >> $(RELEASES_DIR)/release-notes.md
	@echo "" >> $(RELEASES_DIR)/release-notes.md
	@for file in $(DIST_DIR)/*.{deb,rpm,dmg,pkg,msi,tar.gz,zip}; do \
		if [ -f "$$file" ]; then \
			echo "- $$(basename $$file)" >> $(RELEASES_DIR)/release-notes.md; \
		fi; \
	done
	
	# Create git tag
	@if command -v git >/dev/null 2>&1; then \
		git tag -a "v$(VERSION)" -m "Release version $(VERSION)" || true; \
	fi
	
	@echo "$(GREEN)Release v$(VERSION) prepared!$(NC)"
	@echo "$(YELLOW)Upload assets to GitHub manually or use GitHub CLI$(NC)"

# STEP 29: Upload to CDN
upload-cdn: sign-packages ## Upload packages to CDN
	@echo "$(BLUE)Uploading packages to CDN...$(NC)"
	
	# Upload to S3 (simulation)
	@echo "$(YELLOW)Simulating CDN upload...$(NC)"
	@for file in $(DIST_DIR)/*.{deb,rpm,dmg,pkg,msi,tar.gz,zip,asc}; do \
		if [ -f "$$file" ]; then \
			echo "Would upload: $$file to $(CDN_BUCKET)/$(VERSION)/"; \
		fi; \
	done
	
	# Update latest symlinks
	@echo "$(YELLOW)Would update latest symlinks$(NC)"
	
	@echo "$(GREEN)CDN upload simulation completed!$(NC)"

# STEP 30: Performance benchmarks
benchmark: all-platforms ## Run performance benchmarks
	@echo "$(BLUE)Running performance benchmarks...$(NC)"
	@mkdir -p $(DIST_DIR)/benchmarks
	
	@for platform in linux-x64 macos-x64 windows-x64; do \
		if [ -f "$(BUILD_DIR)/$$platform/$(PROJECT_NAME)" ] || [ -f "$(BUILD_DIR)/$$platform/$(PROJECT_NAME).exe" ]; then \
			echo "Benchmarking $$platform..."; \
			time $(BUILD_DIR)/$$platform/$(PROJECT_NAME)* > $(DIST_DIR)/benchmarks/$$platform.txt 2>&1 || true; \
		fi; \
	done
	
	@echo "$(GREEN)Benchmarks completed!$(NC)"

# STEP 31: Clean build artifacts
clean: ## Clean all build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR) $(DIST_DIR) $(RELEASES_DIR)
	@docker rmi $(DOCKER_REGISTRY)/$(PROJECT_NAME):* 2>/dev/null || true
	@echo "$(GREEN)Cleanup completed!$(NC)"

# STEP 32: Validate build environment
validate-env: ## Validate cross-compilation environment
	@echo "$(BLUE)Validating build environment...$(NC)"
	@echo "Checking cross-compilers..."
	@command -v $(CC_LINUX_X64) >/dev/null 2>&1 || echo "$(YELLOW)$(CC_LINUX_X64) not found$(NC)"
	@command -v $(CC_LINUX_ARM64) >/dev/null 2>&1 || echo "$(YELLOW)$(CC_LINUX_ARM64) not found$(NC)"
	@command -v $(CC_WINDOWS_X64) >/dev/null 2>&1 || echo "$(YELLOW)$(CC_WINDOWS_X64) not found$(NC)"
	@echo "Checking packaging tools..."
	@command -v dpkg-deb >/dev/null 2>&1 || echo "$(YELLOW)dpkg-deb not found$(NC)"
	@command -v rpmbuild >/dev/null 2>&1 || echo "$(YELLOW)rpmbuild not found$(NC)"
	@command -v docker >/dev/null 2>&1 || echo "$(YELLOW)docker not found$(NC)"
	@echo "$(GREEN)Environment validation completed!$(NC)"

# STEP 33: Help target
help: ## Display this help
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Cross-Platform Package Manager$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Supported platforms: $(PLATFORMS)$(NC)"
	@echo "$(YELLOW)Package formats: DEB, RPM, AppImage, DMG, PKG, MSI, TAR.GZ, ZIP$(NC)"
	@echo "$(YELLOW)Usage: make [target]$(NC)"

# STEP 34: Debug information
debug: ## Show debug information
	@echo "$(BLUE)Debug Information:$(NC)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "VERSION: $(VERSION)"
	@echo "PLATFORMS: $(PLATFORMS)"
	@echo "BUILD_DIR: $(BUILD_DIR)"
	@echo "DIST_DIR: $(DIST_DIR)"
	@echo "Available cross-compilers:"
	@for cc in $(CC_LINUX_X64) $(CC_LINUX_ARM64) $(CC_WINDOWS_X64); do \
		if command -v $$cc >/dev/null 2>&1; then \
			echo "  $$cc: $(GREEN)available$(NC)"; \
		else \
			echo "  $$cc: $(RED)not found$(NC)"; \
		fi; \
	done

# STEP 35: Configuration
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules