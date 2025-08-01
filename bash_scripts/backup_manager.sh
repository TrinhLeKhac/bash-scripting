#!/bin/bash
# Shebang: Specify script uses bash interpreter

# Backup Manager Script - Manage data backups
# Usage: ./backup_manager.sh [source_dir] [backup_dir]

# STEP 1: Setup basic variables
SOURCE_DIR=${1:-"../data"}  # Source directory (default ../data)
BACKUP_DIR=${2:-"./backups"}  # Backup directory (default ./backups)
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')  # Create timestamp for backup name
LOG_FILE="backup.log"  # Log file

# STEP 2: Define colors
GREEN='\033[0;32m'   # Green color for success
RED='\033[0;31m'     # Red color for errors
YELLOW='\033[1;33m'  # Yellow color for information
NC='\033[0m'         # Reset color

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to create backup
create_backup() {
    local source="$1"
    local backup_name="backup_${TIMESTAMP}"
    local backup_path="${BACKUP_DIR}/${backup_name}"
    
    echo -e "${YELLOW}Creating backup...${NC}"
    log_message "Starting backup of $source"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Create backup
    if cp -r "$source" "$backup_path"; then
        echo -e "${GREEN}Backup created successfully: $backup_path${NC}"
        log_message "Backup created: $backup_path"
        
        # Create compressed version
        if tar -czf "${backup_path}.tar.gz" -C "$BACKUP_DIR" "$backup_name"; then
            rm -rf "$backup_path"
            echo -e "${GREEN}Backup compressed: ${backup_path}.tar.gz${NC}"
            log_message "Backup compressed: ${backup_path}.tar.gz"
        fi
    else
        echo -e "${RED}Backup failed!${NC}"
        log_message "Backup failed for $source"
        return 1
    fi
}

# Function to list backups
list_backups() {
    echo -e "${YELLOW}Available backups:${NC}"
    if [[ -d "$BACKUP_DIR" ]]; then
        ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null | while read -r line; do
            echo "$line"
        done
    else
        echo "No backups found."
    fi
}

# Function to restore backup
restore_backup() {
    echo -e "${YELLOW}Available backups:${NC}"
    local backups=($(ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo -e "${RED}No backups found!${NC}"
        return 1
    fi
    
    for i in "${!backups[@]}"; do
        echo "$((i+1)). $(basename "${backups[$i]}")"
    done
    
    echo -n "Select backup to restore (1-${#backups[@]}): "
    read -r choice
    
    if [[ "$choice" -ge 1 && "$choice" -le ${#backups[@]} ]]; then
        local selected_backup="${backups[$((choice-1))]}"
        local restore_dir="./restored_$(date '+%Y%m%d_%H%M%S')"
        
        echo -e "${YELLOW}Restoring backup...${NC}"
        mkdir -p "$restore_dir"
        
        if tar -xzf "$selected_backup" -C "$restore_dir"; then
            echo -e "${GREEN}Backup restored to: $restore_dir${NC}"
            log_message "Backup restored: $selected_backup -> $restore_dir"
        else
            echo -e "${RED}Restore failed!${NC}"
            log_message "Restore failed for $selected_backup"
        fi
    else
        echo -e "${RED}Invalid selection!${NC}"
    fi
}

# Function to clean old backups
clean_old_backups() {
    echo -n "Keep how many recent backups? (default: 5): "
    read -r keep_count
    keep_count=${keep_count:-5}
    
    if [[ -d "$BACKUP_DIR" ]]; then
        local backup_count=$(ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
        if [[ $backup_count -gt $keep_count ]]; then
            echo -e "${YELLOW}Cleaning old backups...${NC}"
            ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +$((keep_count + 1)) | while read -r old_backup; do
                rm -f "$old_backup"
                echo "Removed: $(basename "$old_backup")"
                log_message "Removed old backup: $old_backup"
            done
            echo -e "${GREEN}Cleanup completed!${NC}"
        else
            echo -e "${GREEN}No cleanup needed.${NC}"
        fi
    fi
}

# Main menu
show_menu() {
    echo ""
    echo -e "${YELLOW}=== Backup Manager ===${NC}"
    echo "1. Create Backup"
    echo "2. List Backups"
    echo "3. Restore Backup"
    echo "4. Clean Old Backups"
    echo "5. Exit"
    echo -n "Choose option (1-5): "
}

# Check if source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo -e "${RED}Source directory $SOURCE_DIR does not exist!${NC}"
    exit 1
fi

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            create_backup "$SOURCE_DIR"
            ;;
        2)
            list_backups
            ;;
        3)
            restore_backup
            ;;
        4)
            clean_old_backups
            ;;
        5)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
done