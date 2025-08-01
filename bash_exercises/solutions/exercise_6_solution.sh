#!/bin/bash
# Exercise 6 Solution: Directory Tree Generator

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

MAX_DEPTH=999
SHOW_SIZE=false
SHOW_HIDDEN=true
FILTER_PATTERN=""
OUTPUT_FILE=""

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash tree_generator.sh <directory> [options]"
    echo "Options:"
    echo "  --depth N       Maximum depth to traverse"
    echo "  --size          Show file sizes"
    echo "  --no-hidden     Hide hidden files"
    echo "  --filter PATTERN Filter files by pattern"
    echo "  --export FILE   Export tree to file"
    echo "  --help          Show this help"
}

# STEP 3: Get file size function
get_file_size() {
    local file=$1
    if [[ -f "$file" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            stat -f%z "$file" | numfmt --to=iec
        else
            stat -c%s "$file" | numfmt --to=iec
        fi
    fi
}

# STEP 4: Check if file matches filter
matches_filter() {
    local file=$1
    if [[ -z "$FILTER_PATTERN" ]]; then
        return 0
    fi
    [[ "$file" == $FILTER_PATTERN ]]
}

# STEP 5: Generate tree structure recursively
generate_tree() {
    local dir=$1
    local prefix=$2
    local depth=$3
    
    # Check depth limit
    if [[ $depth -gt $MAX_DEPTH ]]; then
        return
    fi
    
    # Get directory contents
    local items=()
    while IFS= read -r -d '' item; do
        local basename=$(basename "$item")
        
        # Skip hidden files if requested
        if [[ "$SHOW_HIDDEN" == false && "$basename" == .* ]]; then
            continue
        fi
        
        # Apply filter
        if ! matches_filter "$basename"; then
            continue
        fi
        
        items+=("$item")
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -print0 | sort -z)
    
    # Display items
    local count=${#items[@]}
    for (( i=0; i<count; i++ )); do
        local item="${items[i]}"
        local basename=$(basename "$item")
        local is_last=$((i == count - 1))
        
        # Choose tree symbols
        if [[ $is_last -eq 1 ]]; then
            local current_prefix="└── "
            local next_prefix="    "
        else
            local current_prefix="├── "
            local next_prefix="│   "
        fi
        
        # Display item
        local output="$prefix$current_prefix"
        
        if [[ -L "$item" ]]; then
            # Symbolic link
            local target=$(readlink "$item")
            output+="${CYAN}$basename${NC} -> $target"
        elif [[ -d "$item" ]]; then
            # Directory
            output+="${BLUE}$basename/${NC}"
        else
            # Regular file
            output+="${GREEN}$basename${NC}"
            if [[ "$SHOW_SIZE" == true ]]; then
                local size=$(get_file_size "$item")
                output+=" ${YELLOW}($size)${NC}"
            fi
        fi
        
        echo -e "$output"
        
        # Recurse into directories
        if [[ -d "$item" && ! -L "$item" ]]; then
            generate_tree "$item" "$prefix$next_prefix" $((depth + 1))
        fi
    done
}

# STEP 6: Main function
main() {
    local target_dir=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --depth)
                MAX_DEPTH=$2
                shift 2
                ;;
            --size)
                SHOW_SIZE=true
                shift
                ;;
            --no-hidden)
                SHOW_HIDDEN=false
                shift
                ;;
            --filter)
                FILTER_PATTERN=$2
                shift 2
                ;;
            --export)
                OUTPUT_FILE=$2
                shift 2
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
                target_dir=$1
                shift
                ;;
        esac
    done
    
    # Validate directory
    if [[ -z "$target_dir" ]]; then
        target_dir="."
    fi
    
    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}Error: Directory '$target_dir' not found${NC}"
        exit 1
    fi
    
    # Generate tree
    local tree_output=""
    tree_output+=$(echo -e "${BLUE}$(realpath "$target_dir")/${NC}")
    tree_output+=$'\n'
    tree_output+=$(generate_tree "$target_dir" "" 0)
    
    # Output result
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo "$tree_output" | sed 's/\x1b\[[0-9;]*m//g' > "$OUTPUT_FILE"
        echo -e "${GREEN}Tree exported to: $OUTPUT_FILE${NC}"
    else
        echo "$tree_output"
    fi
}

main "$@"