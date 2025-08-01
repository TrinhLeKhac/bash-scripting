#!/bin/bash
# Exercise 13 Solution: Configuration Manager

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_DIR="./configs"
TEMPLATE_DIR="./templates"
BACKUP_DIR="./config_backups"
ENVIRONMENT=""
APP_NAME=""

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash config_manager.sh [options]"
    echo "Options:"
    echo "  --env ENV           Environment (dev, staging, prod)"
    echo "  --app APP           Application name"
    echo "  --generate          Generate config from template"
    echo "  --template FILE     Template file to use"
    echo "  --validate FILE     Validate configuration file"
    echo "  --backup            Backup current configurations"
    echo "  --restore FILE      Restore from backup"
    echo "  --sync --from ENV --to ENV  Sync configs between environments"
}

# STEP 3: Load environment variables
load_env_vars() {
    local env=$1
    local env_file="$CONFIG_DIR/$env/.env"
    
    if [[ -f "$env_file" ]]; then
        echo -e "${BLUE}Loading environment variables from: $env_file${NC}"
        set -a  # Export all variables
        source "$env_file"
        set +a  # Stop exporting
        return 0
    else
        echo -e "${YELLOW}No environment file found: $env_file${NC}"
        return 1
    fi
}

# STEP 4: Process template with variable substitution
process_template() {
    local template_file=$1
    local output_file=$2
    
    if [[ ! -f "$template_file" ]]; then
        echo -e "${RED}Template file not found: $template_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Processing template: $template_file${NC}"
    
    # Use envsubst to substitute environment variables
    if command -v envsubst >/dev/null; then
        envsubst < "$template_file" > "$output_file"
    else
        # Manual substitution for common patterns
        sed -e "s/\${APP_NAME}/$APP_NAME/g" \
            -e "s/\${ENVIRONMENT}/$ENVIRONMENT/g" \
            -e "s/\${DB_HOST}/${DB_HOST:-localhost}/g" \
            -e "s/\${DB_PORT}/${DB_PORT:-5432}/g" \
            -e "s/\${DB_NAME}/${DB_NAME:-myapp}/g" \
            "$template_file" > "$output_file"
    fi
    
    echo -e "${GREEN}Configuration generated: $output_file${NC}"
    return 0
}

# STEP 5: Generate configuration from template
generate_config() {
    local template_file="$TEMPLATE_DIR/${APP_NAME}.conf.template"
    local output_dir="$CONFIG_DIR/$ENVIRONMENT"
    local output_file="$output_dir/${APP_NAME}.conf"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Load environment variables
    load_env_vars "$ENVIRONMENT"
    
    # Process template
    if process_template "$template_file" "$output_file"; then
        echo -e "${GREEN}Configuration generated successfully${NC}"
        return 0
    else
        echo -e "${RED}Failed to generate configuration${NC}"
        return 1
    fi
}

# STEP 6: Validate configuration file
validate_config() {
    local config_file=$1
    local errors=0
    
    echo -e "${BLUE}Validating configuration: $config_file${NC}"
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "${RED}Configuration file not found${NC}"
        return 1
    fi
    
    # Check for required parameters
    local required_params=("APP_NAME" "DB_HOST" "DB_PORT")
    
    for param in "${required_params[@]}"; do
        if ! grep -q "^$param=" "$config_file"; then
            echo -e "${RED}Missing required parameter: $param${NC}"
            errors=$((errors + 1))
        fi
    done
    
    # Check for syntax errors (basic)
    if ! bash -n "$config_file" 2>/dev/null; then
        echo -e "${RED}Syntax errors found in configuration${NC}"
        errors=$((errors + 1))
    fi
    
    # Check for placeholder variables not substituted
    if grep -q '\${' "$config_file"; then
        echo -e "${YELLOW}Warning: Unsubstituted variables found${NC}"
        grep '\${' "$config_file"
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}Configuration validation passed${NC}"
        return 0
    else
        echo -e "${RED}Configuration validation failed with $errors errors${NC}"
        return 1
    fi
}

# STEP 7: Backup configurations
backup_configs() {
    local env=$1
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/config_${env}_${timestamp}.tar.gz"
    
    mkdir -p "$BACKUP_DIR"
    
    echo -e "${BLUE}Creating backup for environment: $env${NC}"
    
    if tar -czf "$backup_file" -C "$CONFIG_DIR" "$env" 2>/dev/null; then
        echo -e "${GREEN}Backup created: $backup_file${NC}"
        return 0
    else
        echo -e "${RED}Backup failed${NC}"
        return 1
    fi
}

# STEP 8: Restore from backup
restore_backup() {
    local backup_file=$1
    
    if [[ ! -f "$backup_file" ]]; then
        echo -e "${RED}Backup file not found: $backup_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Restoring from backup: $backup_file${NC}"
    
    # Extract backup
    if tar -xzf "$backup_file" -C "$CONFIG_DIR"; then
        echo -e "${GREEN}Restore completed successfully${NC}"
        return 0
    else
        echo -e "${RED}Restore failed${NC}"
        return 1
    fi
}

# STEP 9: Sync configurations between environments
sync_configs() {
    local from_env=$1
    local to_env=$2
    
    local from_dir="$CONFIG_DIR/$from_env"
    local to_dir="$CONFIG_DIR/$to_env"
    
    if [[ ! -d "$from_dir" ]]; then
        echo -e "${RED}Source environment not found: $from_env${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Syncing configurations: $from_env → $to_env${NC}"
    
    # Create backup of target environment first
    if [[ -d "$to_dir" ]]; then
        backup_configs "$to_env"
    fi
    
    # Copy configurations
    mkdir -p "$to_dir"
    if cp -r "$from_dir"/* "$to_dir"/; then
        echo -e "${GREEN}Configuration sync completed${NC}"
        
        # Update environment-specific variables
        local env_file="$to_dir/.env"
        if [[ -f "$env_file" ]]; then
            sed -i.bak "s/ENVIRONMENT=$from_env/ENVIRONMENT=$to_env/g" "$env_file"
            rm -f "$env_file.bak"
        fi
        
        return 0
    else
        echo -e "${RED}Configuration sync failed${NC}"
        return 1
    fi
}

# STEP 10: Main function
main() {
    local action=""
    local template_file=""
    local config_file=""
    local backup_file=""
    local from_env=""
    local to_env=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --env) ENVIRONMENT=$2; shift 2 ;;
            --app) APP_NAME=$2; shift 2 ;;
            --generate) action="generate"; shift ;;
            --template) template_file=$2; shift 2 ;;
            --validate) action="validate"; config_file=$2; shift 2 ;;
            --backup) action="backup"; shift ;;
            --restore) action="restore"; backup_file=$2; shift 2 ;;
            --sync) action="sync"; shift ;;
            --from) from_env=$2; shift 2 ;;
            --to) to_env=$2; shift 2 ;;
            --help) show_usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_usage; exit 1 ;;
        esac
    done
    
    # Execute action
    case $action in
        generate)
            if [[ -z "$ENVIRONMENT" || -z "$APP_NAME" ]]; then
                echo -e "${RED}Environment and app name required for generation${NC}"
                exit 1
            fi
            generate_config
            ;;
        validate)
            validate_config "$config_file"
            ;;
        backup)
            if [[ -z "$ENVIRONMENT" ]]; then
                echo -e "${RED}Environment required for backup${NC}"
                exit 1
            fi
            backup_configs "$ENVIRONMENT"
            ;;
        restore)
            restore_backup "$backup_file"
            ;;
        sync)
            if [[ -z "$from_env" || -z "$to_env" ]]; then
                echo -e "${RED}Source and target environments required for sync${NC}"
                exit 1
            fi
            sync_configs "$from_env" "$to_env"
            ;;
        *)
            echo -e "${RED}No action specified${NC}"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"