#!/bin/bash
# Exercise 2 Solution: File Organizer
# Author: Practice Exercise
# Description: Organize files by extension into subdirectories

# STEP 1: Define colors and global variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_OPTION=false
DRY_RUN=false
ORGANIZED_COUNT=0

# STEP 2: Function to display usage help
show_usage() {
    echo -e "${YELLOW}File Organizer Usage:${NC}"
    echo "bash file_organizer.sh <directory> [options]"
    echo ""
    echo "Options:"
    echo "  --backup    Create backup before organizing"
    echo "  --dry-run   Show what would be done without actually doing it"
    echo "  --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  bash file_organizer.sh /path/to/directory"
    echo "  bash file_organizer.sh . --backup"
    echo "  bash file_organizer.sh ~/Downloads --dry-run"
}

# STEP 3: Function to create backup of directory
create_backup() {
    local target_dir=$1
    local backup_name="backup_$(basename "$target_dir")_$(date '+%Y%m%d_%H%M%S')"
    local backup_path="$(dirname "$target_dir")/$backup_name"
    
    echo -e "${BLUE}Creating backup: $backup_path${NC}"
    
    # Copy directory to backup location
    if cp -r "$target_dir" "$backup_path"; then
        echo -e "${GREEN}Backup created successfully${NC}"
        return 0
    else
        echo -e "${RED}Failed to create backup${NC}"
        return 1
    fi
}

# STEP 4: Function to get file extension
get_extension() {
    local filename=$1
    local extension
    
    # Check if file has extension
    if [[ "$filename" == *.* ]]; then
        extension="${filename##*.}"  # Get everything after last dot
        echo "${extension,,}"        # Convert to lowercase
    else
        echo "no_extension"          # No extension found
    fi
}

# STEP 5: Function to organize single file
organize_file() {
    local filepath=$1
    local target_dir=$2
    local filename=$(basename "$filepath")
    local extension=$(get_extension "$filename")
    local dest_dir="$target_dir/$extension"
    local dest_path="$dest_dir/$filename"
    
    # Skip if it's a directory
    if [[ -d "$filepath" ]]; then
        return 0
    fi
    
    # Skip hidden files
    if [[ "$filename" == .* ]]; then
        return 0
    fi
    
    echo -e "${BLUE}Processing: $filename → $extension/${NC}"
    
    # Dry run mode - just show what would happen
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY RUN] Would move: $filepath → $dest_path${NC}"
        return 0
    fi
    
    # Create destination directory if it doesn't exist
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
        echo -e "${GREEN}Created directory: $dest_dir${NC}"
    fi
    
    # Handle duplicate filenames
    local counter=1
    local original_dest_path="$dest_path"
    while [[ -e "$dest_path" ]]; do
        local name_without_ext="${filename%.*}"
        local file_ext="${filename##*.}"
        
        if [[ "$filename" == "$file_ext" ]]; then
            # File has no extension
            dest_path="$dest_dir/${filename}_$counter"
        else
            # File has extension
            dest_path="$dest_dir/${name_without_ext}_$counter.$file_ext"
        fi
        counter=$((counter + 1))
    done
    
    # Move file to destination
    if mv "$filepath" "$dest_path"; then
        echo -e "${GREEN}Moved: $filename${NC}"
        ORGANIZED_COUNT=$((ORGANIZED_COUNT + 1))
    else
        echo -e "${RED}Failed to move: $filename${NC}"
        return 1
    fi
}

# STEP 6: Function to organize directory
organize_directory() {
    local target_dir=$1
    
    echo -e "${BLUE}Organizing directory: $target_dir${NC}"
    echo ""
    
    # Get list of files (not directories)
    local files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$target_dir" -maxdepth 1 -type f -print0)
    
    # Check if directory has files
    if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No files found to organize${NC}"
        return 0
    fi
    
    echo -e "${BLUE}Found ${#files[@]} files to organize${NC}"
    echo ""
    
    # Organize each file
    for file in "${files[@]}"; do
        organize_file "$file" "$target_dir"
    done
    
    echo ""
    echo -e "${GREEN}Organization complete!${NC}"
    echo -e "${GREEN}Files organized: $ORGANIZED_COUNT${NC}"
}

# STEP 7: Function to display summary
show_summary() {
    local target_dir=$1
    
    echo ""
    echo -e "${BLUE}=== Organization Summary ===${NC}"
    echo -e "${BLUE}Directory: $target_dir${NC}"
    echo -e "${BLUE}Files organized: $ORGANIZED_COUNT${NC}"
    echo ""
    
    # Show created subdirectories
    echo -e "${BLUE}Created subdirectories:${NC}"
    for subdir in "$target_dir"/*; do
        if [[ -d "$subdir" ]]; then
            local dirname=$(basename "$subdir")
            local file_count=$(find "$subdir" -type f | wc -l)
            echo -e "${GREEN}  $dirname/ ($file_count files)${NC}"
        fi
    done
}

# STEP 8: Main function
main() {
    local target_dir=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --backup)
                BACKUP_OPTION=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            -*)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$target_dir" ]]; then
                    target_dir=$1
                else
                    echo -e "${RED}Multiple directories specified${NC}"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if directory argument provided
    if [[ -z "$target_dir" ]]; then
        echo -e "${RED}Error: No directory specified${NC}"
        show_usage
        exit 1
    fi
    
    # Validate directory exists
    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}Error: Directory '$target_dir' does not exist${NC}"
        exit 1
    fi
    
    # Convert to absolute path
    target_dir=$(realpath "$target_dir")
    
    # Create backup if requested
    if [[ "$BACKUP_OPTION" == true ]] && [[ "$DRY_RUN" == false ]]; then
        if ! create_backup "$target_dir"; then
            echo -e "${RED}Backup failed. Aborting organization.${NC}"
            exit 1
        fi
        echo ""
    fi
    
    # Organize directory
    organize_directory "$target_dir"
    
    # Show summary (skip for dry run)
    if [[ "$DRY_RUN" == false ]]; then
        show_summary "$target_dir"
    fi
}

# STEP 9: Execute main function with all arguments
main "$@"