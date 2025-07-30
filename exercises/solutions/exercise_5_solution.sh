#!/bin/bash
# Exercise 5 Solution: Text File Analyzer

# STEP 1: Setup variables and colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

EXPORT_FORMAT="text"
SHOW_WORDS=false
SHOW_CHARS=false
TOP_COUNT=10

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash text_analyzer.sh <file> [options]"
    echo "Options:"
    echo "  --words         Show word analysis"
    echo "  --chars         Show character analysis"
    echo "  --export FORMAT Export format (text/csv/json)"
    echo "  --top N         Show top N items (default: 10)"
}

# STEP 3: Basic statistics function
get_basic_stats() {
    local file=$1
    local lines=$(wc -l < "$file")
    local words=$(wc -w < "$file")
    local chars=$(wc -c < "$file")
    local blank_lines=$(grep -c '^$' "$file")
    
    echo "lines:$lines,words:$words,chars:$chars,blank:$blank_lines"
}

# STEP 4: Word frequency analysis
analyze_words() {
    local file=$1
    local top_n=$2
    
    # Get word frequencies
    tr '[:space:]' '\n' < "$file" | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z]//g' | \
    grep -v '^$' | \
    sort | uniq -c | sort -nr | head -n "$top_n"
}

# STEP 5: Character frequency analysis
analyze_chars() {
    local file=$1
    local top_n=$2
    
    # Get character frequencies
    fold -w1 < "$file" | \
    sort | uniq -c | sort -nr | head -n "$top_n"
}

# STEP 6: Generate report
generate_report() {
    local file=$1
    local stats=$(get_basic_stats "$file")
    
    echo -e "${BLUE}=== Text Analysis Report ===${NC}"
    echo -e "${GREEN}File: $file${NC}"
    echo -e "${GREEN}Lines: $(echo $stats | cut -d, -f1 | cut -d: -f2)${NC}"
    echo -e "${GREEN}Words: $(echo $stats | cut -d, -f2 | cut -d: -f2)${NC}"
    echo -e "${GREEN}Characters: $(echo $stats | cut -d, -f3 | cut -d: -f2)${NC}"
    
    if [[ "$SHOW_WORDS" == true ]]; then
        echo -e "${BLUE}--- Top Words ---${NC}"
        analyze_words "$file" "$TOP_COUNT"
    fi
    
    if [[ "$SHOW_CHARS" == true ]]; then
        echo -e "${BLUE}--- Top Characters ---${NC}"
        analyze_chars "$file" "$TOP_COUNT"
    fi
}

# STEP 7: Main function
main() {
    local file=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --words) SHOW_WORDS=true; shift ;;
            --chars) SHOW_CHARS=true; shift ;;
            --export) EXPORT_FORMAT=$2; shift 2 ;;
            --top) TOP_COUNT=$2; shift 2 ;;
            --help) show_usage; exit 0 ;;
            *) file=$1; shift ;;
        esac
    done
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}Error: File not found${NC}"
        exit 1
    fi
    
    generate_report "$file"
}

main "$@"