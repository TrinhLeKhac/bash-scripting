#!/bin/bash
# Exercise 12 Solution: Deployment Script

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_NAME=""
ENVIRONMENT=""
VERSION=""
DEPLOY_DIR="/opt/deployments"
ROLLBACK=false
DRY_RUN=false

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash deploy.sh [options]"
    echo "Options:"
    echo "  --app NAME          Application name"
    echo "  --env ENV           Environment (staging, production)"
    echo "  --version VERSION   Version to deploy"
    echo "  --rollback          Rollback to previous version"
    echo "  --dry-run           Show what would be done"
    echo "  --blue-green        Use blue-green deployment"
    echo "  --config FILE       Use configuration file"
}

# STEP 3: Log deployment activity
log_deploy() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "deploy_${APP_NAME}_${ENVIRONMENT}.log"
}

# STEP 4: Health check function
health_check() {
    local url=$1
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f -s "$url/health" >/dev/null; then
            echo -e "${GREEN}Health check passed${NC}"
            return 0
        fi
        echo "Health check attempt $attempt/$max_attempts..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}Health check failed${NC}"
    return 1
}

# STEP 5: Deploy application
deploy_app() {
    local app=$1
    local env=$2
    local version=$3
    
    log_deploy "Starting deployment: $app v$version to $env"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN] Would deploy $app v$version to $env${NC}"
        return 0
    fi
    
    # Create deployment directory
    local deploy_path="$DEPLOY_DIR/$app/$env/$version"
    mkdir -p "$deploy_path"
    
    # Download/copy application files
    echo -e "${BLUE}Downloading application files...${NC}"
    # Simulate download
    sleep 2
    
    # Update symlink to current version
    local current_link="$DEPLOY_DIR/$app/$env/current"
    ln -sfn "$deploy_path" "$current_link"
    
    # Restart application service
    echo -e "${BLUE}Restarting application service...${NC}"
    systemctl restart "$app" 2>/dev/null || echo "Service restart simulated"
    
    # Health check
    if health_check "http://localhost:8080"; then
        log_deploy "Deployment successful: $app v$version"
        echo -e "${GREEN}Deployment completed successfully${NC}"
        return 0
    else
        log_deploy "Deployment failed: $app v$version"
        echo -e "${RED}Deployment failed health check${NC}"
        return 1
    fi
}

# STEP 6: Rollback function
rollback_app() {
    local app=$1
    local env=$2
    
    log_deploy "Starting rollback: $app in $env"
    
    # Find previous version
    local versions_dir="$DEPLOY_DIR/$app/$env"
    local previous_version=$(ls -t "$versions_dir" | grep -v current | head -2 | tail -1)
    
    if [[ -z "$previous_version" ]]; then
        echo -e "${RED}No previous version found for rollback${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Rolling back to version: $previous_version${NC}"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN] Would rollback to $previous_version${NC}"
        return 0
    fi
    
    # Update symlink to previous version
    local current_link="$versions_dir/current"
    local previous_path="$versions_dir/$previous_version"
    ln -sfn "$previous_path" "$current_link"
    
    # Restart service
    systemctl restart "$app" 2>/dev/null || echo "Service restart simulated"
    
    # Health check
    if health_check "http://localhost:8080"; then
        log_deploy "Rollback successful to version: $previous_version"
        echo -e "${GREEN}Rollback completed successfully${NC}"
        return 0
    else
        log_deploy "Rollback failed"
        echo -e "${RED}Rollback failed${NC}"
        return 1
    fi
}

# STEP 7: Blue-green deployment
blue_green_deploy() {
    local app=$1
    local env=$2
    local version=$3
    
    log_deploy "Starting blue-green deployment: $app v$version"
    
    # Determine current and target environments
    local current_env=$(readlink "$DEPLOY_DIR/$app/$env/live" | grep -o "blue\|green")
    local target_env="blue"
    [[ "$current_env" == "blue" ]] && target_env="green"
    
    echo -e "${BLUE}Current environment: $current_env${NC}"
    echo -e "${BLUE}Target environment: $target_env${NC}"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN] Would deploy to $target_env environment${NC}"
        return 0
    fi
    
    # Deploy to target environment
    local target_path="$DEPLOY_DIR/$app/$env/$target_env"
    mkdir -p "$target_path"
    
    # Simulate deployment
    echo -e "${BLUE}Deploying to $target_env environment...${NC}"
    sleep 3
    
    # Health check on target
    if health_check "http://localhost:8081"; then
        # Switch traffic to target environment
        ln -sfn "$target_path" "$DEPLOY_DIR/$app/$env/live"
        log_deploy "Blue-green deployment successful"
        echo -e "${GREEN}Traffic switched to $target_env environment${NC}"
        return 0
    else
        log_deploy "Blue-green deployment failed"
        echo -e "${RED}Blue-green deployment failed${NC}"
        return 1
    fi
}

# STEP 8: Pre-deployment checks
pre_deploy_checks() {
    echo -e "${BLUE}Running pre-deployment checks...${NC}"
    
    # Check disk space
    local available_space=$(df "$DEPLOY_DIR" | tail -1 | awk '{print $4}')
    if [[ $available_space -lt 1000000 ]]; then
        echo -e "${RED}Insufficient disk space${NC}"
        return 1
    fi
    
    # Check if application is running
    if systemctl is-active --quiet "$APP_NAME" 2>/dev/null; then
        echo -e "${GREEN}Application service is running${NC}"
    else
        echo -e "${YELLOW}Application service is not running${NC}"
    fi
    
    echo -e "${GREEN}Pre-deployment checks passed${NC}"
    return 0
}

# STEP 9: Generate deployment report
generate_report() {
    local report_file="deployment_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
=== Deployment Report ===
Date: $(date)
Application: $APP_NAME
Environment: $ENVIRONMENT
Version: $VERSION
Action: $(if [[ "$ROLLBACK" == true ]]; then echo "Rollback"; else echo "Deploy"; fi)

Status: $(if [[ $? -eq 0 ]]; then echo "SUCCESS"; else echo "FAILED"; fi)

Deployment Details:
- Deploy Directory: $DEPLOY_DIR
- Log File: deploy_${APP_NAME}_${ENVIRONMENT}.log

EOF
    
    echo -e "${GREEN}Report generated: $report_file${NC}"
}

# STEP 10: Main function
main() {
    local blue_green=false
    local config_file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --app) APP_NAME=$2; shift 2 ;;
            --env) ENVIRONMENT=$2; shift 2 ;;
            --version) VERSION=$2; shift 2 ;;
            --rollback) ROLLBACK=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            --blue-green) blue_green=true; shift ;;
            --config) config_file=$2; shift 2 ;;
            --help) show_usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_usage; exit 1 ;;
        esac
    done
    
    # Load config file if provided
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        source "$config_file"
    fi
    
    # Validate required parameters
    if [[ -z "$APP_NAME" || -z "$ENVIRONMENT" ]]; then
        echo -e "${RED}Application name and environment are required${NC}"
        show_usage
        exit 1
    fi
    
    # Run pre-deployment checks
    if ! pre_deploy_checks; then
        echo -e "${RED}Pre-deployment checks failed${NC}"
        exit 1
    fi
    
    # Execute deployment action
    if [[ "$ROLLBACK" == true ]]; then
        rollback_app "$APP_NAME" "$ENVIRONMENT"
    elif [[ "$blue_green" == true ]]; then
        blue_green_deploy "$APP_NAME" "$ENVIRONMENT" "$VERSION"
    else
        if [[ -z "$VERSION" ]]; then
            echo -e "${RED}Version is required for deployment${NC}"
            exit 1
        fi
        deploy_app "$APP_NAME" "$ENVIRONMENT" "$VERSION"
    fi
    
    local exit_code=$?
    
    # Generate report
    generate_report
    
    exit $exit_code
}

main "$@"