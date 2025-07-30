#!/bin/bash
# Exercise 9 Solution: Log Rotator

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MAX_SIZE="100M"
KEEP_COUNT=5
COMPRESS_TYPE="gzip"
ROTATION_LOG="/var/log/logrotate.log"

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash log_rotator.sh [options]"
    echo "Options:"
    echo "  --file FILE         Log file to rotate"
    echo "  --size SIZE         Rotate when file exceeds size (e.g., 100M, 1G)"
    echo "  --daily             Rotate daily"
    echo "  --weekly            Rotate weekly"
    echo "  --monthly           Rotate monthly"
    echo "  --keep N            Keep N rotated files (default: 5)"
    echo "  --compress TYPE     Compression type (gzip, bzip2, xz)"
    echo "  --config FILE       Use configuration file"
    echo "  --schedule          Show cron schedule"
}

# STEP 3: Log rotation activity
log_rotation() {
    local message=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$ROTATION_LOG"
    echo -e "${BLUE}$message${NC}"
}

# STEP 4: Convert size to bytes
size_to_bytes() {
    local size=$1
    local number=$(echo "$size" | sed 's/[^0-9]//g')
    local unit=$(echo "$size" | sed 's/[0-9]//g' | tr '[:lower:]' '[:upper:]')
    
    case $unit in
        K|KB) echo $((number * 1024)) ;;
        M|MB) echo $((number * 1024 * 1024)) ;;
        G|GB) echo $((number * 1024 * 1024 * 1024)) ;;
        *) echo "$number" ;;
    esac
}

# STEP 5: Check if rotation needed by size
needs_size_rotation() {
    local file=$1
    local max_bytes=$(size_to_bytes "$MAX_SIZE")
    local current_size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    
    [[ $current_size -gt $max_bytes ]]
}

# STEP 6: Compress file function
compress_file() {
    local file=$1
    local compressed_file=""
    
    case $COMPRESS_TYPE in
        gzip)
            gzip "$file"
            compressed_file="${file}.gz"
            ;;
        bzip2)
            bzip2 "$file"
            compressed_file="${file}.bz2"
            ;;
        xz)
            xz "$file"
            compressed_file="${file}.xz"
            ;;
        *)
            echo -e "${RED}Unknown compression type: $COMPRESS_TYPE${NC}"
            return 1
            ;;
    esac
    
    if [[ -f "$compressed_file" ]]; then
        log_rotation "Compressed: $file -> $compressed_file"
        return 0
    else
        log_rotation "Compression failed: $file"
        return 1
    fi
}

# STEP 7: Rotate single file
rotate_file() {
    local logfile=$1
    
    if [[ ! -f "$logfile" ]]; then
        echo -e "${RED}Log file not found: $logfile${NC}"
        return 1
    fi
    
    log_rotation "Starting rotation for: $logfile"
    
    # Create backup directory if needed
    local backup_dir=$(dirname "$logfile")
    
    # Rotate existing backups
    for (( i=KEEP_COUNT; i>=1; i-- )); do
        local old_file="${logfile}.$i"
        local new_file="${logfile}.$((i+1))"
        
        # Handle compressed files
        for ext in "" ".gz" ".bz2" ".xz"; do
            if [[ -f "${old_file}${ext}" ]]; then
                if [[ $i -eq $KEEP_COUNT ]]; then
                    rm -f "${old_file}${ext}"
                    log_rotation "Removed old backup: ${old_file}${ext}"
                else
                    mv "${old_file}${ext}" "${new_file}${ext}"
                    log_rotation "Moved: ${old_file}${ext} -> ${new_file}${ext}"
                fi
            fi
        done
    done
    
    # Move current log to .1
    if cp "$logfile" "${logfile}.1"; then
        > "$logfile"  # Truncate original file
        log_rotation "Rotated: $logfile -> ${logfile}.1"
        
        # Compress the rotated file
        compress_file "${logfile}.1"
    else
        log_rotation "Failed to rotate: $logfile"
        return 1
    fi
}

# STEP 8: Process configuration file
process_config() {
    local config_file=$1
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "${RED}Config file not found: $config_file${NC}"
        return 1
    fi
    
    while read -r line; do
        # Skip comments and empty lines
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        # Parse configuration
        if [[ "$line" =~ ^file= ]]; then
            local file=$(echo "$line" | cut -d= -f2)
            rotate_file "$file"
        elif [[ "$line" =~ ^size= ]]; then
            MAX_SIZE=$(echo "$line" | cut -d= -f2)
        elif [[ "$line" =~ ^keep= ]]; then
            KEEP_COUNT=$(echo "$line" | cut -d= -f2)
        elif [[ "$line" =~ ^compress= ]]; then
            COMPRESS_TYPE=$(echo "$line" | cut -d= -f2)
        fi
    done < "$config_file"
}

# STEP 9: Generate cron schedule
show_schedule() {
    echo -e "${BLUE}=== Suggested Cron Schedules ===${NC}"
    echo ""
    echo -e "${GREEN}Daily rotation (at 2 AM):${NC}"
    echo "0 2 * * * $(realpath "$0") --file /path/to/logfile --daily"
    echo ""
    echo -e "${GREEN}Weekly rotation (Sunday at 3 AM):${NC}"
    echo "0 3 * * 0 $(realpath "$0") --file /path/to/logfile --weekly"
    echo ""
    echo -e "${GREEN}Size-based check (every hour):${NC}"
    echo "0 * * * * $(realpath "$0") --file /path/to/logfile --size 100M"
}

# STEP 10: Main function
main() {
    local logfile=""
    local rotation_type="size"
    local config_file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --file)
                logfile=$2
                shift 2
                ;;
            --size)
                MAX_SIZE=$2
                rotation_type="size"
                shift 2
                ;;
            --daily|--weekly|--monthly)
                rotation_type=${1#--}
                shift
                ;;
            --keep)
                KEEP_COUNT=$2
                shift 2
                ;;
            --compress)
                COMPRESS_TYPE=$2
                shift 2
                ;;
            --config)
                config_file=$2
                shift 2
                ;;
            --schedule)
                show_schedule
                exit 0
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Process configuration file
    if [[ -n "$config_file" ]]; then
        process_config "$config_file"
        exit 0
    fi
    
    # Validate log file
    if [[ -z "$logfile" ]]; then
        echo -e "${RED}No log file specified${NC}"
        show_usage
        exit 1
    fi
    
    # Perform rotation based on type
    case $rotation_type in
        size)
            if needs_size_rotation "$logfile"; then
                rotate_file "$logfile"
            else
                log_rotation "No rotation needed for $logfile (size check)"
            fi
            ;;
        daily|weekly|monthly)
            # For time-based rotation, always rotate
            rotate_file "$logfile"
            ;;
    esac
}

main "$@"