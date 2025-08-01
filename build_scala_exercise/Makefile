# Scala Build Tools Exercise - Unified Makefile
# Demonstrates various Scala build systems and Spark applications

# Project configuration
PROJECT_NAME := scala_build_demo
VERSION := 1.0.0
SCALA_VERSION := 2.12.17
SPARK_VERSION := 3.4.0

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Tools
SBT := sbt
MAVEN := mvn
GRADLE := gradle
MILL := mill
SPARK_SUBMIT := spark-submit

.DEFAULT_GOAL := help
.PHONY: help setup-all build-all test-all package-all clean-all

help: ## Display this help
	@echo "$(BLUE)Scala Build Tools Exercise$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Setup all build environments
setup-all: setup-sbt setup-maven setup-gradle setup-mill ## Setup all build tools
	@echo "$(GREEN)All build environments setup completed!$(NC)"

setup-sbt: ## Setup SBT projects
	@echo "$(BLUE)Setting up SBT projects...$(NC)"
	@cd sbt_project && $(SBT) update
	@cd spark_sbt && $(SBT) update

setup-maven: ## Setup Maven projects
	@echo "$(BLUE)Setting up Maven projects...$(NC)"
	@cd maven_project && $(MAVEN) dependency:resolve
	@cd spark_maven && $(MAVEN) dependency:resolve

setup-gradle: ## Setup Gradle projects
	@echo "$(BLUE)Setting up Gradle projects...$(NC)"
	@cd gradle_project && $(GRADLE) build --dry-run
	@cd spark_gradle && $(GRADLE) build --dry-run

setup-mill: ## Setup Mill projects
	@echo "$(BLUE)Setting up Mill projects...$(NC)"
	@cd mill_project && $(MILL) resolve _

# Build all projects
build-all: build-sbt build-maven build-gradle build-mill ## Build all projects
	@echo "$(GREEN)All projects built successfully!$(NC)"

build-sbt: ## Build SBT projects
	@echo "$(BLUE)Building SBT projects...$(NC)"
	@cd sbt_project && $(SBT) compile
	@cd spark_sbt && $(SBT) compile

build-maven: ## Build Maven projects
	@echo "$(BLUE)Building Maven projects...$(NC)"
	@cd maven_project && $(MAVEN) compile
	@cd spark_maven && $(MAVEN) compile

build-gradle: ## Build Gradle projects
	@echo "$(BLUE)Building Gradle projects...$(NC)"
	@cd gradle_project && $(GRADLE) compileScala
	@cd spark_gradle && $(GRADLE) compileScala

build-mill: ## Build Mill projects
	@echo "$(BLUE)Building Mill projects...$(NC)"
	@cd mill_project && $(MILL) _.compile

# Build Spark applications
build-spark: build-spark-sbt build-spark-maven build-spark-gradle ## Build all Spark applications
	@echo "$(GREEN)All Spark applications built!$(NC)"

build-spark-sbt: ## Build Spark SBT application
	@echo "$(BLUE)Building Spark SBT application...$(NC)"
	@cd spark_sbt && $(SBT) assembly

build-spark-maven: ## Build Spark Maven application
	@echo "$(BLUE)Building Spark Maven application...$(NC)"
	@cd spark_maven && $(MAVEN) package

build-spark-gradle: ## Build Spark Gradle application
	@echo "$(BLUE)Building Spark Gradle application...$(NC)"
	@cd spark_gradle && $(GRADLE) shadowJar

# Test all projects
test-all: test-sbt test-maven test-gradle test-mill ## Test all projects
	@echo "$(GREEN)All tests completed!$(NC)"

test-sbt: ## Test SBT projects
	@echo "$(BLUE)Testing SBT projects...$(NC)"
	@cd sbt_project && $(SBT) test
	@cd spark_sbt && $(SBT) test

test-maven: ## Test Maven projects
	@echo "$(BLUE)Testing Maven projects...$(NC)"
	@cd maven_project && $(MAVEN) test
	@cd spark_maven && $(MAVEN) test

test-gradle: ## Test Gradle projects
	@echo "$(BLUE)Testing Gradle projects...$(NC)"
	@cd gradle_project && $(GRADLE) test
	@cd spark_gradle && $(GRADLE) test

test-mill: ## Test Mill projects
	@echo "$(BLUE)Testing Mill projects...$(NC)"
	@cd mill_project && $(MILL) _.test

# Package JAR files
package-jars: package-fat-jars package-assembly-jars ## Create all JAR packages
	@echo "$(GREEN)All JARs packaged!$(NC)"

package-fat-jars: ## Create fat JARs
	@echo "$(BLUE)Creating fat JARs...$(NC)"
	@mkdir -p fat_jar_builds
	@cd spark_sbt && $(SBT) assembly && cp target/scala-*/spark-sbt-assembly-*.jar ../fat_jar_builds/
	@cd spark_maven && $(MAVEN) package && cp target/spark-maven-*-jar-with-dependencies.jar ../fat_jar_builds/
	@cd spark_gradle && $(GRADLE) shadowJar && cp build/libs/spark-gradle-*-all.jar ../fat_jar_builds/

package-assembly-jars: ## Create assembly JARs
	@echo "$(BLUE)Creating assembly JARs...$(NC)"
	@mkdir -p assembly_builds
	@find . -name "*assembly*.jar" -exec cp {} assembly_builds/ \;

# Run Spark applications
run-spark: run-spark-wordcount run-spark-analytics ## Run Spark applications
	@echo "$(GREEN)Spark applications executed!$(NC)"

run-spark-wordcount: ## Run Spark WordCount example
	@echo "$(BLUE)Running Spark WordCount...$(NC)"
	@if [ -f fat_jar_builds/spark-sbt-assembly-*.jar ]; then \
		$(SPARK_SUBMIT) --class com.example.WordCount fat_jar_builds/spark-sbt-assembly-*.jar; \
	fi

run-spark-analytics: ## Run Spark Analytics example
	@echo "$(BLUE)Running Spark Analytics...$(NC)"
	@if [ -f fat_jar_builds/spark-maven-*-jar-with-dependencies.jar ]; then \
		$(SPARK_SUBMIT) --class com.example.DataAnalytics fat_jar_builds/spark-maven-*-jar-with-dependencies.jar; \
	fi

# Docker builds
docker-build: ## Build Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	@cd docker_builds && docker build -t $(PROJECT_NAME)-spark:$(VERSION) .

# Performance benchmarks
benchmark: ## Run build performance benchmarks
	@echo "$(BLUE)Running build benchmarks...$(NC)"
	@echo "SBT build time:" && time (cd sbt_project && $(SBT) clean compile)
	@echo "Maven build time:" && time (cd maven_project && $(MAVEN) clean compile)
	@echo "Gradle build time:" && time (cd gradle_project && $(GRADLE) clean compileScala)
	@echo "Mill build time:" && time (cd mill_project && $(MILL) clean && $(MILL) _.compile)

# Clean all builds
clean-all: clean-sbt clean-maven clean-gradle clean-mill clean-jars ## Clean all build artifacts
	@echo "$(GREEN)All builds cleaned!$(NC)"

clean-sbt: ## Clean SBT builds
	@cd sbt_project && $(SBT) clean
	@cd spark_sbt && $(SBT) clean

clean-maven: ## Clean Maven builds
	@cd maven_project && $(MAVEN) clean
	@cd spark_maven && $(MAVEN) clean

clean-gradle: ## Clean Gradle builds
	@cd gradle_project && $(GRADLE) clean
	@cd spark_gradle && $(GRADLE) clean

clean-mill: ## Clean Mill builds
	@cd mill_project && $(MILL) clean

clean-jars: ## Clean JAR builds
	@rm -rf fat_jar_builds/* assembly_builds/*