#!/bin/bash
# Exercise 10 Solution: Database Backup

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DB_TYPE=""
DB_NAME=""
DB_USER=""
DB_PASS=""
DB_HOST="localhost"
DB_PORT=""
BACKUP_DIR="./backups"
ROTATE_DAYS=7
LOG_FILE="backup.log"

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash db_backup.sh [options]"
    echo "Options:"
    echo "  --type TYPE         Database type (mysql, postgres, sqlite)"
    echo "  --db DATABASE       Database name"
    echo "  --user USER         Database user"
    echo "  --pass PASSWORD     Database password"
    echo "  --host HOST         Database host (default: localhost)"
    echo "  --port PORT         Database port"
    echo "  --backup-dir DIR    Backup directory (default: ./backups)"
    echo "  --rotate DAYS       Keep backups for N days (default: 7)"
    echo "  --verify FILE       Verify backup file"
    echo "  --config FILE       Use configuration file"
}

# STEP 3: Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# STEP 4: MySQL backup function
backup_mysql() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/mysql_${DB_NAME}_${timestamp}.sql"
    
    log_message "Starting MySQL backup for database: $DB_NAME"
    
    # Build mysqldump command
    local cmd="mysqldump -h $DB_HOST"
    [[ -n "$DB_PORT" ]] && cmd+=" -P $DB_PORT"
    [[ -n "$DB_USER" ]] && cmd+=" -u $DB_USER"
    [[ -n "$DB_PASS" ]] && cmd+=" -p$DB_PASS"
    cmd+=" --single-transaction --routines --triggers $DB_NAME"
    
    # Create backup
    if eval "$cmd" > "$backup_file"; then
        gzip "$backup_file"
        log_message "MySQL backup completed: ${backup_file}.gz"
        echo -e "${GREEN}Backup successful: ${backup_file}.gz${NC}"
        return 0
    else
        log_message "MySQL backup failed for database: $DB_NAME"
        echo -e "${RED}Backup failed${NC}"
        return 1
    fi
}

# STEP 5: PostgreSQL backup function
backup_postgres() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/postgres_${DB_NAME}_${timestamp}.sql"
    
    log_message "Starting PostgreSQL backup for database: $DB_NAME"
    
    # Set environment variables
    export PGHOST="$DB_HOST"
    [[ -n "$DB_PORT" ]] && export PGPORT="$DB_PORT"
    [[ -n "$DB_USER" ]] && export PGUSER="$DB_USER"
    [[ -n "$DB_PASS" ]] && export PGPASSWORD="$DB_PASS"
    
    # Create backup
    if pg_dump "$DB_NAME" > "$backup_file"; then
        gzip "$backup_file"
        log_message "PostgreSQL backup completed: ${backup_file}.gz"
        echo -e "${GREEN}Backup successful: ${backup_file}.gz${NC}"
        return 0
    else
        log_message "PostgreSQL backup failed for database: $DB_NAME"
        echo -e "${RED}Backup failed${NC}"
        return 1
    fi
}

# STEP 6: SQLite backup function
backup_sqlite() {
    local db_file="$DB_NAME"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/sqlite_$(basename "$db_file")_${timestamp}.db"
    
    log_message "Starting SQLite backup for file: $db_file"
    
    if [[ ! -f "$db_file" ]]; then
        echo -e "${RED}SQLite file not found: $db_file${NC}"
        return 1
    fi
    
    # Create backup
    if cp "$db_file" "$backup_file"; then
        gzip "$backup_file"
        log_message "SQLite backup completed: ${backup_file}.gz"
        echo -e "${GREEN}Backup successful: ${backup_file}.gz${NC}"
        return 0
    else
        log_message "SQLite backup failed for file: $db_file"
        echo -e "${RED}Backup failed${NC}"
        return 1
    fi
}

# STEP 7: Verify backup function
verify_backup() {
    local backup_file=$1
    
    if [[ ! -f "$backup_file" ]]; then
        echo -e "${RED}Backup file not found: $backup_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Verifying backup: $backup_file${NC}"
    
    # Check if file is compressed
    if [[ "$backup_file" == *.gz ]]; then
        if gzip -t "$backup_file"; then
            echo -e "${GREEN}✓ Compression integrity OK${NC}"
        else
            echo -e "${RED}✗ Compression integrity failed${NC}"
            return 1
        fi
        
        # Check SQL content
        if zcat "$backup_file" | head -10 | grep -q "SQL\|CREATE\|INSERT"; then
            echo -e "${GREEN}✓ SQL content detected${NC}"
        else
            echo -e "${YELLOW}? SQL content not clearly detected${NC}"
        fi
    else
        echo -e "${GREEN}✓ Uncompressed file OK${NC}"
    fi
    
    # Show file info
    local size=$(ls -lh "$backup_file" | awk '{print $5}')
    echo -e "${BLUE}File size: $size${NC}"
    
    return 0
}

# STEP 8: Rotate old backups
rotate_backups() {
    echo -e "${BLUE}Rotating backups older than $ROTATE_DAYS days...${NC}"
    
    local deleted_count=0
    find "$BACKUP_DIR" -name "*.gz" -type f -mtime +$ROTATE_DAYS | while read -r old_backup; do
        rm -f "$old_backup"
        log_message "Deleted old backup: $old_backup"
        deleted_count=$((deleted_count + 1))
    done
    
    echo -e "${GREEN}Rotation completed${NC}"
}

# STEP 9: Process config file
process_config() {
    local config_file=$1
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "${RED}Config file not found: $config_file${NC}"
        return 1
    fi
    
    source "$config_file"
    log_message "Loaded configuration from: $config_file"
}

# STEP 10: Main function
main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --type) DB_TYPE=$2; shift 2 ;;
            --db) DB_NAME=$2; shift 2 ;;
            --user) DB_USER=$2; shift 2 ;;
            --pass) DB_PASS=$2; shift 2 ;;
            --host) DB_HOST=$2; shift 2 ;;
            --port) DB_PORT=$2; shift 2 ;;
            --backup-dir) BACKUP_DIR=$2; shift 2 ;;
            --rotate) ROTATE_DAYS=$2; shift 2 ;;
            --verify) verify_backup "$2"; exit $? ;;
            --config) process_config "$2"; shift 2 ;;
            --help) show_usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_usage; exit 1 ;;
        esac
    done
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Validate required parameters
    if [[ -z "$DB_TYPE" ]]; then
        echo -e "${RED}Database type not specified${NC}"
        show_usage
        exit 1
    fi
    
    # Perform backup based on type
    case $DB_TYPE in
        mysql)
            backup_mysql
            ;;
        postgres)
            backup_postgres
            ;;
        sqlite)
            backup_sqlite
            ;;
        *)
            echo -e "${RED}Unsupported database type: $DB_TYPE${NC}"
            exit 1
            ;;
    esac
    
    # Rotate old backups
    rotate_backups
}

main "$@"