# Exercise 1 Solution: C Project Build System
# Advanced Makefile for C project with comprehensive features

# STEP 1: Project configuration variables
PROJECT_NAME := c_project
VERSION := 1.0.0
TARGET := $(PROJECT_NAME)

# STEP 2: Directory structure definition
SRC_DIR := src
INC_DIR := include
BUILD_DIR := build
BIN_DIR := bin
TEST_DIR := tests
DOC_DIR := docs

# STEP 3: Compiler and tool configuration
CC := gcc
CPPFLAGS := -I$(INC_DIR)
LDFLAGS := 
LIBS := 

# STEP 4: Build configuration flags
DEBUG_CFLAGS := -g -O0 -DDEBUG -Wall -Wextra -Wpedantic
RELEASE_CFLAGS := -O2 -DNDEBUG -Wall
PROFILE_CFLAGS := -pg -O2 -DPROFILE -Wall

# STEP 5: Default build type (can be overridden)
BUILD_TYPE ?= release
ifeq ($(BUILD_TYPE),debug)
    CFLAGS := $(DEBUG_CFLAGS)
    BUILD_SUFFIX := _debug
else ifeq ($(BUILD_TYPE),profile)
    CFLAGS := $(PROFILE_CFLAGS)
    BUILD_SUFFIX := _profile
else
    CFLAGS := $(RELEASE_CFLAGS)
    BUILD_SUFFIX :=
endif

# STEP 6: File discovery and object file generation
SOURCES := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
DEPENDS := $(OBJECTS:.o=.d)

# STEP 7: Test files configuration
TEST_SOURCES := $(wildcard $(TEST_DIR)/*.c)
TEST_OBJECTS := $(TEST_SOURCES:$(TEST_DIR)/%.c=$(BUILD_DIR)/test_%.o)
TEST_TARGETS := $(TEST_SOURCES:$(TEST_DIR)/%.c=$(BIN_DIR)/test_%)

# STEP 8: Installation directories
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
MANDIR := $(PREFIX)/share/man/man1

# STEP 9: Color definitions for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# STEP 10: Default target
.DEFAULT_GOAL := all

# STEP 11: Phony targets declaration
.PHONY: all debug release profile clean install uninstall test docs check dist help

# STEP 12: Main build targets
all: $(BIN_DIR)/$(TARGET)$(BUILD_SUFFIX) ## Build the project (default: release)

debug: ## Build debug version
	@$(MAKE) BUILD_TYPE=debug $(BIN_DIR)/$(TARGET)_debug

release: ## Build release version
	@$(MAKE) BUILD_TYPE=release $(BIN_DIR)/$(TARGET)

profile: ## Build profile version
	@$(MAKE) BUILD_TYPE=profile $(BIN_DIR)/$(TARGET)_profile

# STEP 13: Main executable linking rule
$(BIN_DIR)/$(TARGET)$(BUILD_SUFFIX): $(OBJECTS) | $(BIN_DIR)
	@echo "$(BLUE)Linking $(TARGET)$(BUILD_SUFFIX)...$(NC)"
	@$(CC) $(OBJECTS) -o $@ $(LDFLAGS) $(LIBS)
	@echo "$(GREEN)Build completed: $@$(NC)"

# STEP 14: Object file compilation with automatic dependency generation
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	@echo "$(YELLOW)Compiling $<...$(NC)"
	@$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

# STEP 15: Test compilation and execution
test: $(TEST_TARGETS) ## Build and run all tests
	@echo "$(BLUE)Running tests...$(NC)"
	@for test in $(TEST_TARGETS); do \
		echo "Running $$test..."; \
		$$test || exit 1; \
	done
	@echo "$(GREEN)All tests passed!$(NC)"

# STEP 16: Individual test target compilation
$(BIN_DIR)/test_%: $(BUILD_DIR)/test_%.o $(filter-out $(BUILD_DIR)/main.o,$(OBJECTS)) | $(BIN_DIR)
	@echo "$(YELLOW)Linking test $@...$(NC)"
	@$(CC) $^ -o $@ $(LDFLAGS) $(LIBS)

# STEP 17: Test object compilation
$(BUILD_DIR)/test_%.o: $(TEST_DIR)/%.c | $(BUILD_DIR)
	@echo "$(YELLOW)Compiling test $<...$(NC)"
	@$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# STEP 18: Directory creation rules
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(DOC_DIR):
	@mkdir -p $(DOC_DIR)

# STEP 19: Static analysis with various tools
check: ## Run static code analysis
	@echo "$(BLUE)Running static analysis...$(NC)"
	@if command -v cppcheck >/dev/null 2>&1; then \
		echo "Running cppcheck..."; \
		cppcheck --enable=all --inconclusive $(SRC_DIR)/; \
	fi
	@if command -v clang-tidy >/dev/null 2>&1; then \
		echo "Running clang-tidy..."; \
		clang-tidy $(SOURCES) -- $(CPPFLAGS); \
	fi
	@if command -v splint >/dev/null 2>&1; then \
		echo "Running splint..."; \
		splint $(CPPFLAGS) $(SOURCES); \
	fi
	@echo "$(GREEN)Static analysis completed!$(NC)"

# STEP 20: Documentation generation
docs: | $(DOC_DIR) ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@if command -v doxygen >/dev/null 2>&1; then \
		doxygen Doxyfile 2>/dev/null || echo "No Doxyfile found"; \
	else \
		echo "Generating simple documentation..."; \
		echo "# $(PROJECT_NAME) Documentation" > $(DOC_DIR)/README.md; \
		echo "Version: $(VERSION)" >> $(DOC_DIR)/README.md; \
		echo "Generated: $$(date)" >> $(DOC_DIR)/README.md; \
		for src in $(SOURCES); do \
			echo "## $$src" >> $(DOC_DIR)/README.md; \
			grep -E "^/\*\*|^ \*|^ \*/" $$src >> $(DOC_DIR)/README.md 2>/dev/null || true; \
		done; \
	fi
	@echo "$(GREEN)Documentation generated in $(DOC_DIR)/$(NC)"

# STEP 21: Installation targets
install: $(BIN_DIR)/$(TARGET) ## Install to system
	@echo "$(BLUE)Installing $(TARGET)...$(NC)"
	@install -d $(DESTDIR)$(BINDIR)
	@install -m 755 $(BIN_DIR)/$(TARGET) $(DESTDIR)$(BINDIR)/
	@echo "$(GREEN)Installed to $(DESTDIR)$(BINDIR)/$(TARGET)$(NC)"

uninstall: ## Remove from system
	@echo "$(BLUE)Uninstalling $(TARGET)...$(NC)"
	@rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	@echo "$(GREEN)Uninstalled $(TARGET)$(NC)"

# STEP 22: Distribution package creation
dist: clean ## Create distribution tarball
	@echo "$(BLUE)Creating distribution package...$(NC)"
	@mkdir -p dist
	@tar --exclude='./dist' --exclude='./.git' --exclude='./build' --exclude='./bin' \
		-czf dist/$(PROJECT_NAME)-$(VERSION).tar.gz .
	@echo "$(GREEN)Distribution package created: dist/$(PROJECT_NAME)-$(VERSION).tar.gz$(NC)"

# STEP 23: Cleanup targets
clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR) $(BIN_DIR) $(DOC_DIR)
	@rm -f *.gcov *.gcda *.gcno gmon.out
	@echo "$(GREEN)Cleanup completed!$(NC)"

# STEP 24: Development utilities
format: ## Format source code
	@echo "$(BLUE)Formatting source code...$(NC)"
	@if command -v clang-format >/dev/null 2>&1; then \
		clang-format -i $(SOURCES) $(wildcard $(INC_DIR)/*.h); \
		echo "$(GREEN)Code formatted!$(NC)"; \
	else \
		echo "$(YELLOW)clang-format not available$(NC)"; \
	fi

# STEP 25: Memory checking with valgrind
memcheck: debug ## Run memory check with valgrind
	@echo "$(BLUE)Running memory check...$(NC)"
	@if command -v valgrind >/dev/null 2>&1; then \
		valgrind --leak-check=full --show-leak-kinds=all \
			--track-origins=yes $(BIN_DIR)/$(TARGET)_debug; \
	else \
		echo "$(YELLOW)Valgrind not available$(NC)"; \
	fi

# STEP 26: Performance profiling
gprof: profile ## Generate profiling report
	@echo "$(BLUE)Generating profiling report...$(NC)"
	@$(BIN_DIR)/$(TARGET)_profile
	@if [ -f gmon.out ]; then \
		gprof $(BIN_DIR)/$(TARGET)_profile gmon.out > profile_report.txt; \
		echo "$(GREEN)Profile report generated: profile_report.txt$(NC)"; \
	else \
		echo "$(YELLOW)No profiling data generated$(NC)"; \
	fi

# STEP 27: Help target
help: ## Display this help
	@echo "$(BLUE)$(PROJECT_NAME) v$(VERSION) - Available targets:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Build types: debug, release, profile$(NC)"
	@echo "$(YELLOW)Usage: make [target] [BUILD_TYPE=type]$(NC)"

# STEP 28: Debug information
debug-make: ## Show Makefile variables
	@echo "$(BLUE)Makefile Debug Information:$(NC)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "VERSION: $(VERSION)"
	@echo "BUILD_TYPE: $(BUILD_TYPE)"
	@echo "CC: $(CC)"
	@echo "CFLAGS: $(CFLAGS)"
	@echo "SOURCES: $(SOURCES)"
	@echo "OBJECTS: $(OBJECTS)"
	@echo "TARGET: $(BIN_DIR)/$(TARGET)$(BUILD_SUFFIX)"

# STEP 29: Include dependency files
-include $(DEPENDS)

# STEP 30: Special configuration
.SUFFIXES:
.SUFFIXES: .c .o .h

# Disable built-in rules for better performance
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables